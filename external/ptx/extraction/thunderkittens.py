# /// script
# requires-python = ">=3.10"
# ///
"""Compile ThunderKittens' kernels to PTX for Volta, one suite at a time.

    uv run external/ptx/extraction/thunderkittens.py                         # educational_b200, levels 01-09
    uv run external/ptx/extraction/thunderkittens.py 6 7                     # its levels 06 and 07
    uv run external/ptx/extraction/thunderkittens.py --suite kernels         # fftconv_non_pc, layernorm
    uv run external/ptx/extraction/thunderkittens.py --suite units           # the unit tests (~860 kernels)
    uv run external/ptx/extraction/thunderkittens.py --suite patched         # the unit tests with `FIXES`

Suites:
- `educational_b200` (and `educational_h100`): the GEMM tutorial's levels, each built with
  the tutorial's own Makefile (`make ptx`, the flags and architecture of `kernels/common.mk`).
- `kernels`: the standalone kernels Volta can lower (`KERNELS`), with `common.mk`'s flags;
  fftconv_non_pc for sm_90a (its harness needs `<chrono>`, included on the command line),
  layernorm for sm_100a. The B200 GEMMs (bf16, fp8, int8, mxfp8, nvfp4) and rotary compile too
  but stop at lowering (`cta_group::2` TMA and a 2-CTA `.reqnctapercluster`; a register-named
  `bar.sync` of varying count), so they have no launch files.
- `units`: `tests/` for sm_100a at `TEST_INTENSITY=1` and `-O3`, one PTX per test file, then
  `thunderkittens_units.py` writes the curated kernels' launch files (all of them with `--all`).
- `patched`: the unit test files `FIXES` corrects (`thunderkittens/bugs.txt`), compiled as
  `units` is, the controls that show each bug's diagnosis: the fixed test verifies.

Each needs `nvcc` from CUDA 12.8 or later. nvcc compiles for an explicit target, so no GPU is
needed; without one on the PATH (macOS) the script builds an image with the CUDA toolkit
once, runs itself in a container and copies the PTX out (`--backend`). The PTX lands in
`<out>/<suite>/` (by default `external/ptx/thunderkittens/`), beside a `.json` summary of what
the PTX itself states about its kernels' launch (tutorial and kernels); launch files there are kept.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
TK_ROOT = EXTERNAL_ROOT / "sources" / "ThunderKittens"
GEMM_DIR = TK_ROOT / "kernels" / "gemm"
TUTORIALS = ["educational_b200", "educational_h100"]
SUITES = [*TUTORIALS, "kernels", "units", "patched"]
DEFAULT_OUT = EXTERNAL_ROOT / "thunderkittens"
CUDA_IMAGE = "nvidia/cuda:12.9.1-devel-ubuntu24.04"
DOCKER_IMAGE = "volta-thunderkittens:cuda-12.9.1"
DOCKERFILE = f"""FROM {CUDA_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends python3 make && rm -rf /var/lib/apt/lists/*
WORKDIR /work
"""
# What the container needs of the submodule: the headers, the kernels tree (`common.mk`) and the tests.
TK_PARTS = ["include", "prototype", "kernels", "tests"]

ENTRY = re.compile(r"^(?:\.visible )?\.entry (\S+?)\(", re.MULTILINE)
DIRECTIVE = re.compile(r"^\s*\.(maxntid|reqntid|reqnctapercluster|maxnreg|minnctapersm)\s+([\d, ]+)$", re.MULTILINE)

# kernels/common.mk's standalone flags, without the host link flags `--ptx` ignores.
COMMON_FLAGS = [
    "-std=c++20", "-O3", "--use_fast_math", "--expt-extended-lambda", "--expt-relaxed-constexpr",
    "-forward-unknown-to-host-compiler", "-Xcompiler=-Wno-psabi", "-Xcompiler=-fno-strict-aliasing",
    "-DNDEBUG", "-lineinfo",
]
ARCH_FLAGS = {
    "SM90": ["-DKITTENS_SM90", "-gencode", "arch=compute_90a,code=sm_90a"],
    "SM100": ["-DKITTENS_SM100", "-gencode", "arch=compute_100a,code=sm_100a"],
}
# (PTX stem, source under kernels/, architecture, extra flags)
KERNELS = [
    ("fftconv_non_pc", "fftconv/fftconv_non_pc.cu", "SM90", ["-include", "chrono"]),
    ("layernorm", "layernorm/layernorm.cu", "SM100", []),
]
# tests/Makefile's flags at its lowest intensity, optimized as its `profile` level is.
UNIT_FLAGS = [
    "-std=c++20", "--expt-relaxed-constexpr", "-Itesting_commons", "-I../include", "--extended-lambda",
    "-O3", "-diag-suppress", "20054", "-DTEST_INTENSITY=1", "-DTEST_ALL",
]


SYNCWARP_AFTER_READ = "\n                __syncwarp(); // fix: no lane rewrites the tile before lane 0 waited"
TMEM_RELEASE = ("kittens::tensor_before_thread_sync();\n{indent}__syncthreads(); "
                "// fix: every warp's Tensor Memory reads precede warp 0's dealloc")
# Test file -> its (old, new) text replacements, each fixing a bug of thunderkittens/bugs.txt.
FIXES = {
    "thread/memory/tile/tma.cu": [  # TK-2, TK-3, TK-6
        ("kittens::warp::store(output, shared_tile[i][j], {a, b, i, j});\n            }\n        }\n",
         "kittens::warp::store(output, shared_tile[i][j], {a, b, i, j});\n            }\n"
         "            __syncwarp(); // fix: every lane read the tiles before the next TMA load\n        }\n"),
        ("kittens::tma::store_async_read_wait<3>(); // make sure next tile is ready for write",
         "kittens::tma::store_async_read_wait<0>(); // fix: no store issues between the four loads"
         + SYNCWARP_AFTER_READ),
    ],
    "thread/memory/vec/tma.cu": [  # TK-2, TK-3
        ("kittens::warp::store(output, shared_vec, {a, b, c, d});\n",
         "kittens::warp::store(output, shared_vec, {a, b, c, d});\n"
         "                __syncwarp(); // fix: every lane read the vector before the next TMA load\n"),
        ("if(threadIdx.x == 0) kittens::tma::store_async_read_wait();",
         "if(threadIdx.x == 0) kittens::tma::store_async_read_wait();" + SYNCWARP_AFTER_READ),
    ],
    "group/mma/tensor/mma.cu": [  # TK-4, TK-5, TK-7
        ("kittens::warp::init_semaphore(sem, 0, 1);",
         "if(threadIdx.x == 0) kittens::init_semaphore(sem, 0, 1); // fix: one init, not one per warp"),
        ("kittens::wait(sem, 0);\n            run_mma<TA, TB, true>",
         "kittens::wait(sem, 0);\n            __syncthreads(); // fix: every warp saw phase 0 before phase 1\n"
         "            run_mma<TA, TB, true>"),
        ("    kittens::tensor_load_wait();\n    G::store(o_gl, d_reg, {});\n}",
         "    kittens::tensor_load_wait();\n    G::store(o_gl, d_reg, {});\n    "
         + TMEM_RELEASE.format(indent="    ") + "\n}"),
    ],
    "group/memory/tile/tensor_to_register.cu": [  # TK-5
        ("            G::store(output, dst_reg, {});\n        }\n    }",
         "            G::store(output, dst_reg, {});\n        }\n        " + TMEM_RELEASE.format(indent="        ")
         + "\n    }"),
        ("            else output[{0, 0, row, col}] = col < LOAD_COLS ? dst[col][0] : 0.0f;\n        }\n    }",
         "            else output[{0, 0, row, col}] = col < LOAD_COLS ? dst[col][0] : 0.0f;\n        }\n        "
         + TMEM_RELEASE.format(indent="        ") + "\n    }"),
    ],
}


def fixed_tests(staging: Path) -> Path:
    """A copy of `tests/` beside the headers, with `FIXES` applied; the copy's `tests` directory."""
    root = staging / "ThunderKittens"
    shutil.copytree(TK_ROOT / "tests", root / "tests")
    (root / "include").symlink_to(TK_ROOT / "include")
    for name, replacements in FIXES.items():
        path = root / "tests" / name
        text = path.read_text()
        for old, new in replacements:
            if old not in text:
                sys.exit(f"fix no longer applies to {name}: {old[:60]!r}")
            text = text.replace(old, new)
        path.write_text(text)
    return root / "tests"


def levels_of(tutorial: str) -> list[str]:
    return sorted(p.stem.removeprefix("level_") for p in (GEMM_DIR / tutorial).glob("level_*.cu"))


def parse_level(text: str, available: list[str]) -> str:
    level = f"{int(text):02d}" if text.isdigit() else text
    if level not in available:
        sys.exit(f"no level {text!r}: pick among {', '.join(available)}")
    return level


def launch_summary(ptx: str) -> list[dict[str, object]]:
    """Each kernel's name and its launch directives, in source order."""
    kernels = []
    for entry in ENTRY.finditer(ptx):
        header = ptx[entry.start() : ptx.index("{", entry.end())]
        directives = {d: [int(x) for x in v.split(",")] for d, v in DIRECTIVE.findall(header)}
        kernels.append({"kernel": entry.group(1), **directives})
    return kernels


def nvcc_version() -> str:
    output = subprocess.run(["nvcc", "--version"], capture_output=True, text=True, check=True).stdout
    match = re.search(r"release ([\d.]+)", output)
    return match.group(1) if match else output.strip().splitlines()[-1]


def write_summary(ptx_path: Path, source: str, version: str) -> None:
    ptx = ptx_path.read_text()
    target = re.search(r"^\.target (\S+)", ptx, re.MULTILINE)
    summary = {"source": source, "nvcc": version, "target": target.group(1) if target else None,
               "kernels": launch_summary(ptx)}
    ptx_path.with_suffix(".json").write_text(json.dumps(summary, indent=2) + "\n")


def nvcc(source: Path, flags: list[str], out: Path, cwd: Path) -> str | None:
    """Compile `source` to PTX at `out`; the compiler's errors if it failed."""
    build = subprocess.run(["nvcc", str(source), *flags, "--ptx", "-o", str(out)],
                           capture_output=True, text=True, cwd=cwd)
    return None if build.returncode == 0 else build.stdout + build.stderr


def compile_tutorial(tutorial: str, levels: list[str], out_dir: Path, version: str) -> None:
    for level in levels:
        stem = out_dir.resolve() / f"level_{level}"
        build = subprocess.run(
            ["make", "-C", str(GEMM_DIR / tutorial), "ptx", f"LEVEL={level}", f"OUT={stem}"],
            capture_output=True,
            text=True,
        )
        if build.returncode != 0:
            sys.exit(f"level {level} failed to compile:\n{build.stdout}{build.stderr}")
        ptx_path = stem.with_name(f"{stem.name}.ptx")
        write_summary(ptx_path, f"kernels/gemm/{tutorial}/level_{level}.cu", version)
        print(f"{tutorial} level {level} -> {ptx_path}")


def compile_kernels(names: list[str], out_dir: Path, version: str) -> None:
    includes = [f"-I{TK_ROOT / 'include'}", f"-I{TK_ROOT / 'prototype'}"]
    for stem, source, arch, extra in KERNELS:
        if names and stem not in names:
            continue
        ptx_path = out_dir.resolve() / f"{stem}.ptx"
        if errors := nvcc(TK_ROOT / "kernels" / source, [*COMMON_FLAGS, *includes, *ARCH_FLAGS[arch], *extra],
                          ptx_path, TK_ROOT / "kernels"):
            sys.exit(f"{stem} failed to compile:\n{errors}")
        write_summary(ptx_path, f"kernels/{source}", version)
        print(f"kernels {stem} -> {ptx_path}")


def compile_units(names: list[str], out_dir: Path, tests: Path = TK_ROOT / "tests") -> None:
    """One PTX per test file; files that instantiate no kernel at this intensity are dropped."""
    sources = sorted(p.relative_to(tests) for d in ("group", "thread") for p in (tests / d).rglob("*.cu"))
    sources = [s for s in sources if not names or any(n in str(s) for n in names)]

    def build(source: Path) -> str:
        stem = str(source.with_suffix("")).replace("/", "_")
        ptx_path = out_dir.resolve() / f"{stem}.ptx"
        if errors := nvcc(tests / source, [*UNIT_FLAGS, *ARCH_FLAGS["SM100"]], ptx_path, tests):
            return f"FAILED {source}:\n{errors}"
        if not ENTRY.search(ptx_path.read_text()):
            ptx_path.unlink()
            return f"no kernels {source}"
        return f"units {source} -> {ptx_path}"

    with ThreadPoolExecutor(6) as pool:
        for line in pool.map(build, sources):
            print(line, flush=True)


def compile_local(suite: str, names: list[str], out: Path) -> None:
    if shutil.which("nvcc") is None:
        sys.exit("nvcc is not on the PATH (use --backend docker)")
    out_dir = out / suite
    out_dir.mkdir(parents=True, exist_ok=True)
    if suite in TUTORIALS:
        available = levels_of(suite)
        compile_tutorial(suite, [parse_level(n, available) for n in names] or available, out_dir, nvcc_version())
    elif suite == "kernels":
        compile_kernels(names, out_dir, nvcc_version())
    elif suite == "patched":
        with tempfile.TemporaryDirectory() as staging:
            compile_units(names or list(FIXES), out_dir, fixed_tests(Path(staging)))
    else:
        compile_units(names, out_dir)


def docker(*args: str, stdin: str | None = None, quiet: bool = False) -> None:
    result = subprocess.run(["docker", *args], input=stdin, text=True, capture_output=quiet)
    if result.returncode != 0:
        sys.exit(f"docker {args[0]} failed{': ' + result.stderr.strip() if quiet else ''}")


def compile_in_docker(suite: str, names: list[str], out: Path) -> None:
    """Run this script with `--backend local` in a container, then copy its output dir out."""
    if subprocess.run(["docker", "info"], capture_output=True).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)
    container = f"volta-thunderkittens-{uuid.uuid4().hex[:12]}"
    script = Path(__file__).resolve()
    command = [
        "python3", f"/work/{script.parent.name}/{script.name}", *names,
        f"--suite={suite}", "--backend=local", "--out=/work/out",
    ]
    docker("create", "--name", container, DOCKER_IMAGE, *command, quiet=True)
    try:
        with tempfile.TemporaryDirectory() as staging:
            # `docker cp` creates no parent directories, so `/work` mirrors `external/ptx/` whole.
            staged = Path(staging)
            (staged / script.parent.name).mkdir()
            shutil.copy(script, staged / script.parent.name)
            shutil.copy(script.with_name("thunderkittens_units.py"), staged / script.parent.name)
            for part in TK_PARTS:
                shutil.copytree(TK_ROOT / part, staged / TK_ROOT.relative_to(EXTERNAL_ROOT) / part)
            docker("cp", f"{staging}/.", f"{container}:/work/", quiet=True)
        docker("start", "--attach", container)
        out.mkdir(parents=True, exist_ok=True)
        docker("cp", f"{container}:/work/out/{suite}", str(out), quiet=True)
    finally:
        subprocess.run(["docker", "rm", "--force", container], capture_output=True)
    print(f"copied {suite}/ to {out}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*",
                        help="what to compile (default: all): tutorial levels (3 or 03), kernels "
                             "(layernorm) or unit test files (a substring of their path)")
    parser.add_argument("--suite", choices=SUITES, default=TUTORIALS[0], help=f"default {TUTORIALS[0]}")
    parser.add_argument("--tutorial", choices=TUTORIALS, help="the same as --suite, for a tutorial")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output root (default {DEFAULT_OUT})")
    parser.add_argument(
        "--backend",
        choices=["auto", "local", "docker"],
        default="auto",
        help="where nvcc runs (default: local if it is on the PATH, else docker)",
    )
    parser.add_argument("--all", action="store_true",
                        help="units, patched: a launch file per kernel, not only the curated ones")
    args = parser.parse_args()
    suite = args.tutorial or args.suite

    if not (TK_ROOT / "include").is_dir():
        sys.exit(f"no {TK_ROOT}: run `git submodule update --init external/ptx/sources/ThunderKittens`")
    backend = args.backend
    if backend == "auto":
        backend = "local" if shutil.which("nvcc") else "docker"
    (compile_local if backend == "local" else compile_in_docker)(suite, args.names, args.out)
    if suite in ("units", "patched"):
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import thunderkittens_units

        written, skipped = thunderkittens_units.write_launches(args.out / suite, args.all)
        print(f"wrote {written} {suite} launch files; skipped {sum(skipped.values())}")


if __name__ == "__main__":
    main()
