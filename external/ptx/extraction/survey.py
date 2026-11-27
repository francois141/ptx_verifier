# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Survey which kernels of the PTX frameworks Volta can lower: compile, then `volta parse --lower`.

    uv run external/ptx/extraction/survey.py                       # every framework of `SUITES`
    uv run external/ptx/extraction/survey.py vllm FlashMLA         # some of them
    uv run external/ptx/extraction/survey.py --skip-compile        # lower the PTX already compiled
    uv run external/ptx/extraction/survey.py --jobs 4 --timeout 900
    uv run external/ptx/extraction/survey.py vllm --only layernorm_kernels.cu   # some units

Each suite names translation units of a framework's checkout in `target/ptx-sources/`
(`just ptx-sources`) that instantiate its kernels. Each compiles with nvcc to PTX for
Blackwell (sm_100a) in a container with CUDA 13.2 and PyTorch's headers (vLLM's versions), into
`external/ptx/survey/<framework>/<unit>.ptx`. No launch files are written: the survey only
lowers every kernel entry of each PTX, which needs no launch. `--csv` (by default
`external/ptx/output/survey.csv`) holds one row per kernel (LOWERED or UNSUPPORTED with
Volta's first lowering error) or per unit that did not compile (COMPILE-FAILED), and a
summary counts the lowering errors across frameworks.
"""

import argparse
import collections
import concurrent.futures
import csv
import json
import os
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
SOURCES_DIR = REPO_ROOT / "target" / "ptx-sources"
SURVEY_DIR = EXTERNAL_ROOT / "survey"
DEFAULT_CSV = EXTERNAL_ROOT / "output" / "survey.csv"
VOLTA = REPO_ROOT / "target" / "release" / "volta"

CUDA_IMAGE = "nvidia/cuda:13.2.1-devel-ubuntu24.04"
TORCH_WHEEL = "torch==2.14.0"
TORCH_INDEX = "https://download.pytorch.org/whl/cu130"
DOCKER_IMAGE = "volta-ptx-survey:cuda-13.2.1-torch-2.14.0"
DOCKERFILE = f"""FROM {CUDA_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-dev python3-pip \\
    && rm -rf /var/lib/apt/lists/*
RUN pip install --break-system-packages --no-deps --index-url {TORCH_INDEX} {TORCH_WHEEL}
WORKDIR /work
"""
TORCH_INCLUDE = "/usr/local/lib/python3.12/dist-packages/torch/include"
PYTHON_INCLUDE = "/usr/include/python3.12"

NVCC_FLAGS = [
    "-ptx", "-arch=sm_100a", "-O3", "-DNDEBUG", "--expt-relaxed-constexpr",
    "--expt-extended-lambda", "-U__CUDA_NO_HALF_OPERATORS__", "-U__CUDA_NO_HALF_CONVERSIONS__",
    "-U__CUDA_NO_BFLOAT16_CONVERSIONS__", "-U__CUDA_NO_HALF2_OPERATORS__", "-w",
]
TORCH_FLAGS = [
    f"-I{TORCH_INCLUDE}", f"-I{TORCH_INCLUDE}/torch/csrc/api/include", f"-I{PYTHON_INCLUDE}",
    "-D_GLIBCXX_USE_CXX11_ABI=1", "-DTORCH_EXTENSION_NAME=survey", "-DTORCH_API_INCLUDE_EXTENSION_H",
]


@dataclass(frozen=True)
class Suite:
    """Translation units of one framework (globs under its checkout) and how they compile."""

    framework: str
    units: tuple[str, ...]
    includes: tuple[str, ...] = ()
    flags: tuple[str, ...] = ()
    torch: bool = False
    std: str = "c++17"
    exclude: tuple[str, ...] = field(default=())
    # A repo directory of instantiation units copied into the checkout's `volta_units/` first
    # (header-only libraries such as FlashInfer, whose own units need its JIT bindings).
    local_units: str = ""


CUTLASS_INCLUDES = ("include", "tools/util/include", "examples/common")
SUITES = [
    Suite(
        "cutlass",
        (
            "examples/70_blackwell_gemm/*.cu", "examples/71_blackwell_gemm_with_collective_builder/*.cu",
            "examples/72_blackwell_narrow_precision_gemm/*.cu", "examples/73_blackwell_gemm_preferred_cluster/*.cu",
            "examples/74_blackwell_gemm_streamk/*.cu", "examples/75_blackwell_grouped_gemm/*.cu",
            "examples/76_blackwell_conv/*.cu", "examples/77_blackwell_fmha/*.cu",
            "examples/81_blackwell_gemm_blockwise/*.cu", "examples/86_blackwell_mixed_dtype_gemm/*.cu",
            "examples/91_fp4_gemv/*.cu", "examples/92_blackwell_moe_gemm/*.cu",
            "examples/93_blackwell_low_latency_gqa/*.cu",
        ),
        CUTLASS_INCLUDES + ("examples/77_blackwell_fmha", "examples/93_blackwell_low_latency_gqa"),
        ("-DCUTLASS_ARCH_MMA_SM100_SUPPORTED", "-DCUTLASS_ENABLE_GDC_FOR_SM100=1"),
    ),
    Suite(
        "FlashMLA",
        ("csrc/cuda_kernels/sm100/**/*.cu", "csrc/cuda_kernels/smxx/**/*.cu"),
        ("csrc", "csrc/cuda_kernels", "csrc/3rdparty/cutlass/include", "csrc/3rdparty/cutlass/tools/util/include",
         "csrc/3rdparty/kerutils/include"),
        ("-DFLASH_MLA_IS_BUILD_ON_CUDA", "-DKERUTILS_IS_BUILD_ON_CUDA", "-DUSE_CUDA", "--use_fast_math",
         "--diag-suppress=445"),
        torch=True,
        std="c++20",
    ),
    Suite(
        "flash-attention",
        ("csrc/flash_attn/src/flash_fwd_hdim128_bf16_sm80.cu", "csrc/flash_attn/src/flash_fwd_hdim128_bf16_causal_sm80.cu",
         "csrc/flash_attn/src/flash_fwd_split_hdim128_bf16_sm80.cu", "csrc/flash_attn/src/flash_bwd_hdim128_bf16_sm80.cu",
         "csrc/flash_attn/src/flash_fwd_hdim64_fp16_sm80.cu"),
        ("csrc/flash_attn", "csrc/flash_attn/src", "csrc/cutlass/include"),
        ("--use_fast_math",),
        torch=True,
    ),
    Suite(
        "vllm",
        ("csrc/*.cu", "csrc/attention/**/*.cu", "csrc/moe/*.cu", "csrc/quantization/**/*.cu", "csrc/core/*.cu",
         "csrc/mamba/**/*.cu"),
        ("csrc", "../cutlass/include", "../cutlass/tools/util/include"),
        ("-DENABLE_FP8", "-DENABLE_NVFP4_SM100=1", "-DENABLE_SCALED_MM_SM100=1", "-DUSE_CUDA"),
        torch=True,
        std="c++20",
        exclude=("csrc/rocm/", "csrc/cpu/", "custom_all_reduce", "custom_all_gather"),
    ),
    Suite(
        "flashinfer",
        ("volta_units/*.cu",),
        ("include", "csrc", "3rdparty/cutlass/include", "3rdparty/cccl/libcudacxx/include"),
        ("-DFLASHINFER_ENABLE_BF16", "-DFLASHINFER_ENABLE_F16"),
        std="c++17",
        local_units="external/ptx/flashinfer/units",
    ),
    Suite(
        "TensorRT-LLM",
        ("cpp/tensorrt_llm/kernels/*.cu",
         # subdirectories of kernels that are neither CUTLASS GEMMs nor communication kernels
         "cpp/tensorrt_llm/kernels/dsv3MinLatencyKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/llama4MinLatencyKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/selectiveScan/**/*.cu",
         "cpp/tensorrt_llm/kernels/mamba2MTPSSMCache/**/*.cu",
         "cpp/tensorrt_llm/kernels/speculativeDecoding/**/*.cu",
         "cpp/tensorrt_llm/kernels/fusedSampling/**/*.cu",
         "cpp/tensorrt_llm/kernels/groupRmsNormKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/fusedLayernormKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/fusedGatedRMSNormQuant/**/*.cu",
         "cpp/tensorrt_llm/kernels/fp8PerTokenQuant/**/*.cu",
         "cpp/tensorrt_llm/kernels/causalConv1d/**/*.cu",
         "cpp/tensorrt_llm/kernels/cudaCoreGemm/**/*.cu",
         "cpp/tensorrt_llm/kernels/lmHeadArgmax/**/*.cu",
         "cpp/tensorrt_llm/kernels/kdaDecode/**/*.cu",
         "cpp/tensorrt_llm/kernels/mhcKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/kimiK3AttnRes/**/*.cu",
         "cpp/tensorrt_llm/kernels/unfusedAttentionKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/decoderMaskedMultiheadAttention/**/*.cu",
         "cpp/tensorrt_llm/kernels/compressorKernels/**/*.cu",
         "cpp/tensorrt_llm/kernels/tinygemm2/**/*.cu",
         "cpp/tensorrt_llm/kernels/csa2SparseDecode/**/*.cu",
         "cpp/tensorrt_llm/kernels/csa2SparseContext/**/*.cu",
        ),
        ("cpp", "cpp/include", "../cutlass/include", "../cutlass/tools/util/include"),
        ("-DENABLE_BF16", "-DENABLE_FP8", "-DENABLE_FP4"),
        std="c++20",
        exclude=("customAllReduce", "helixAllToAll", "dwdpFabric"),
    ),
]


def units_of(suite: Suite) -> list[Path]:
    root = SOURCES_DIR / suite.framework
    if suite.local_units and root.is_dir():
        target = root / "volta_units"
        target.mkdir(exist_ok=True)
        for unit in (REPO_ROOT / suite.local_units).glob("*.cu"):
            (target / unit.name).write_text(unit.read_text())
    found = {p for pattern in suite.units for p in root.glob(pattern)}
    return sorted(p for p in found if not any(x in str(p.relative_to(root)) for x in suite.exclude))


def ptx_path(suite: Suite, unit: Path) -> Path:
    rel = unit.relative_to(SOURCES_DIR / suite.framework)
    return SURVEY_DIR / suite.framework / rel.with_suffix(".ptx")


# ----- inside the container ------------------------------------------------------------------


def compile_unit(job: dict) -> dict:
    out = Path(job["out"])
    out.parent.mkdir(parents=True, exist_ok=True)
    start = time.time()
    try:
        result = subprocess.run(job["cmd"] + ["-o", str(out)], capture_output=True, text=True,
                                timeout=job["timeout"], cwd=job["cwd"])
        ok, log = result.returncode == 0, result.stderr
    except subprocess.TimeoutExpired:
        ok, log = False, f"timed out after {job['timeout']}s"
    errors = [line for line in log.splitlines() if "error" in line.lower()]
    return {"unit": job["unit"], "ok": ok, "seconds": round(time.time() - start, 1),
            "error": "" if ok else (errors[0] if errors else log.strip()[-300:])}


def run_inside(jobs_file: Path, jobs: int) -> None:
    work = json.loads(jobs_file.read_text())
    results = []
    with concurrent.futures.ThreadPoolExecutor(jobs) as pool:
        for result in pool.map(compile_unit, work):
            print(f"{'OK  ' if result['ok'] else 'FAIL'} {result['seconds']:7.1f}s {result['unit']}", flush=True)
            results.append(result)
    (jobs_file.parent / "compile_results.json").write_text(json.dumps(results, indent=1))


# ----- on the host ---------------------------------------------------------------------------


def ensure_image() -> None:
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode == 0:
        return
    print(f"building {DOCKER_IMAGE} (once)", flush=True)
    result = subprocess.run(["docker", "build", "-t", DOCKER_IMAGE, "-"], input=DOCKERFILE, text=True)
    if result.returncode != 0:
        sys.exit("docker build failed")


def selected_units(suite: Suite, only: tuple[str, ...] = ()) -> list[Path]:
    """`suite`'s units, or those whose path contains one of `only`."""
    units = units_of(suite)
    return [u for u in units if any(o in str(u) for o in only)] if only else units


def container_jobs(suites: list[Suite], timeout: int, only: tuple[str, ...] = ()) -> list[dict]:
    jobs = []
    for suite in suites:
        root = f"/src/{suite.framework}"
        flags = NVCC_FLAGS + [f"-std={suite.std}"] + list(suite.flags) + (TORCH_FLAGS if suite.torch else [])
        includes = [f"-I{os.path.normpath(f'{root}/{inc}')}" for inc in suite.includes]
        for unit in selected_units(suite, only):
            rel = unit.relative_to(SOURCES_DIR)
            out = ptx_path(suite, unit).relative_to(SURVEY_DIR)
            jobs.append({"unit": str(rel), "cwd": str(Path("/src") / rel.parent), "timeout": timeout,
                         "cmd": ["nvcc", *flags, *includes, f"-I/src/{rel.parent}", f"/src/{rel}"],
                         "out": f"/out/{out}"})
    return jobs


def compile_all(suites: list[Suite], jobs: int, timeout: int, only: tuple[str, ...] = ()) -> dict[str, dict]:
    """Compile the suites' units (only those `only` selects, keeping the others' PTX)."""
    ensure_image()
    for suite in suites:
        if not only:
            shutil.rmtree(SURVEY_DIR / suite.framework, ignore_errors=True)
        for unit in selected_units(suite, only):
            ptx_path(suite, unit).unlink(missing_ok=True)
    SURVEY_DIR.mkdir(parents=True, exist_ok=True)
    work = container_jobs(suites, timeout, only)
    jobs_file = SURVEY_DIR / "compile_jobs.json"
    jobs_file.write_text(json.dumps(work))
    print(f"compiling {len(work)} units in {DOCKER_IMAGE}", flush=True)
    subprocess.run(
        ["docker", "run", "--rm", "-v", f"{SOURCES_DIR}:/src:ro", "-v", f"{SURVEY_DIR}:/out",
         "-v", f"{Path(__file__).resolve()}:/survey.py:ro", DOCKER_IMAGE,
         "python3", "/survey.py", "--inside", "/out/compile_jobs.json", "--jobs", str(jobs)],
        check=True,
    )
    results = json.loads((SURVEY_DIR / "compile_results.json").read_text())
    return {r["unit"]: r for r in results}


def demangle(names: list[str]) -> list[str]:
    tool = shutil.which("c++filt") or shutil.which("llvm-cxxfilt")
    if tool is None or not names:
        return names
    result = subprocess.run([tool], input="\n".join(names), capture_output=True, text=True)
    lines = result.stdout.splitlines()
    return lines if len(lines) == len(names) else names


LOWER_LINE = re.compile(r"^(LOWERED|UNSUPPORTED) (\S+?)(?:: (.*))?$")


def lower_ptx(ptx: Path) -> list[tuple[str, str, str]]:
    result = subprocess.run([str(VOLTA), "--no-log-file", "parse", "--lower", str(ptx)],
                            capture_output=True, text=True, timeout=600)
    rows = [m.groups("") for m in map(LOWER_LINE.match, result.stdout.splitlines()) if m]
    if not rows and "Entries (kernels): 0" in result.stdout:
        return []
    if not rows:
        message = " ".join((result.stderr or result.stdout).split())[:400]
        return [("", "PARSE-FAILED", message)]
    return [(kernel, status, detail) for status, kernel, detail in rows]


def blocker(detail: str) -> str:
    """The construct a lowering error names, for counting across kernels."""
    if m := re.match(r"Unsupported instruction: (\w+)\((\w+)", detail):
        return f"{m.group(1)} ({m.group(2)})"
    if m := re.match(r"Unsupported instruction: Other \{ kind: (\w+)", detail):
        return m.group(1)
    if m := re.match(r"Unsupported instruction: (\S+) Reason: (.{0,70})", detail):
        return f"{m.group(1)}: {m.group(2)}"
    return detail[:90]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("frameworks", nargs="*", help="suites to survey (default: every one)")
    parser.add_argument("--jobs", type=int, default=2, help="units compiled in parallel (nvcc is memory hungry)")
    parser.add_argument("--timeout", type=int, default=900, help="seconds per unit")
    parser.add_argument("--skip-compile", action="store_true", help="lower the PTX already in external/ptx/survey")
    parser.add_argument("--only", action="append", default=[], help="compile only units whose path contains this")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--inside", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.inside:
        return run_inside(args.inside, args.jobs)

    known = {s.framework: s for s in SUITES}
    if unknown := [f for f in args.frameworks if f not in known]:
        sys.exit(f"unknown suites {unknown}: pick among {sorted(known)}")
    suites = [known[f] for f in args.frameworks] if args.frameworks else SUITES
    if missing := [s.framework for s in suites if not (SOURCES_DIR / s.framework).is_dir()]:
        sys.exit(f"no checkout of {missing} in {SOURCES_DIR}: run `just ptx-sources`")

    subprocess.run(["cargo", "build", "--release", "-q", "-p", "volta_cli"], cwd=REPO_ROOT, check=True)
    only = tuple(args.only)
    compiled = {} if args.skip_compile else compile_all(suites, args.jobs, args.timeout, only)

    rows = []
    for suite in suites:
        for unit in units_of(suite):
            rel = str(unit.relative_to(SOURCES_DIR))
            ptx = ptx_path(suite, unit)
            if rel in compiled and not compiled[rel]["ok"]:
                rows.append([suite.framework, rel, "", "COMPILE-FAILED", compiled[rel]["error"]])
                continue
            if not ptx.exists():
                continue
            lowered = lower_ptx(ptx)
            names = demangle([k for k, _, _ in lowered])
            rows += [[suite.framework, rel, name, status, detail] for name, (_, status, detail) in zip(names, lowered)]

    surveyed = {s.framework for s in suites}
    if args.csv.exists():
        with args.csv.open(newline="") as f:
            kept = [r for r in csv.reader(f)][1:]
        rows = [r for r in kept if r and r[0] not in surveyed] + rows
    args.csv.parent.mkdir(parents=True, exist_ok=True)
    with args.csv.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["framework", "unit", "kernel", "status", "detail"])
        writer.writerows(rows)

    print()
    for suite in suites:
        counts = collections.Counter(r[3] for r in rows if r[0] == suite.framework)
        print(f"{suite.framework:16} " + ", ".join(f"{n} {s}" for s, n in sorted(counts.items())))
    blockers = collections.Counter(blocker(r[4]) for r in rows if r[3] == "UNSUPPORTED")
    print("\nlowering errors, by kernels they block:")
    for name, n in blockers.most_common(40):
        print(f"  {n:5}  {name}")
    print(f"\nwrote {args.csv}")


if __name__ == "__main__":
    main()
