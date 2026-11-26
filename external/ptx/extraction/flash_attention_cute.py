# /// script
# requires-python = ">=3.10"
# ///
"""Compile FlashAttention-4's CuTe DSL Blackwell kernels (`flash_attn/cute`) to PTX for sm_100a without a GPU.

    uv run external/ptx/extraction/flash_attention_cute.py                  # every variant
    uv run external/ptx/extraction/flash_attention_cute.py fwd bwd_causal   # some of them
    uv run external/ptx/extraction/flash_attention_cute.py --list

Each variant calls FlashAttention's own host entry point (`_flash_attn_fwd`,
`_flash_attn_bwd`, `flash_attn_combine`) under torch's `FakeTensorMode`, the
path FlashAttention itself uses to precompile its kernel cache: the tensors
carry shapes and dtypes but no storage, the config selectors run as they would
on a B200 (`FLASH_ATTENTION_ARCH=sm_100`, `FLASH_ATTENTION_NUM_SMS=148`), and
`cute.compile` targets `CUTE_DSL_ARCH=sm_100a`. The only driver query on the
way, `cutlass.utils.HardwareInfo` (the SM count of the persistent schedulers),
answers for a 148-SM B200. CuTe DSL's embedded ptxas also builds each cubin,
so every PTX written here has passed ptxas. nvidia-cutlass-dsl ships Linux
wheels only, so without it importable (macOS) the script builds an image with
CPU torch and the DSL once, runs itself in a container and copies the PTX out
(`--backend`); running third-party code there also isolates it.

Every kernel a variant compiles lands in `<out>/<variant>[_<role>].ptx`
(by default `external/ptx/survey/flash-attention-cute/`), beside a `.json`
with the problem, the kernel's FlashAttention config, and its launch: block,
cluster and dynamic shared memory read from the compiled host code (the
`cudaLaunchKernelEx` config the DSL emits), and the grid, which the host
computes from the runtime shapes, worked out for the variant's problem from
the kernel's tile scheduler (`grid_source` says which).
"""

import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
FA_ROOT = REPO_ROOT / "target" / "ptx-sources" / "flash-attention"
DEFAULT_OUT = EXTERNAL_ROOT / "survey" / "flash-attention-cute"
ARCH = "sm_100a"
NUM_SMS = 148
CUTLASS_DSL = "4.8.1"
DOCKER_IMAGE = f"volta-flash-attention-cute:cutlass-dsl-{CUTLASS_DSL}"
# quack (a FlashAttention dependency) imports triton at import time; nothing here runs it.
DOCKERFILE = f"""FROM python:3.12-slim
RUN pip install --no-cache-dir --timeout 120 --retries 10 torch==2.15.0 --index-url https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir --timeout 120 --retries 10 nvidia-cutlass-dsl=={CUTLASS_DSL} quack-kernels==0.6.5 \\
    einops typing_extensions apache-tvm-ffi==0.1.16 torch-c-dlpack-ext==0.1.5 numpy triton==3.9.0
WORKDIR /work
"""

# name -> what to compile. Problem: batch, heads, seqlen (q and k), head dim, bf16.
VARIANTS: dict[str, dict] = {
    "fwd": dict(kind="fwd", causal=False),
    "fwd_causal": dict(kind="fwd", causal=True),
    "bwd": dict(kind="bwd", causal=False),
    "bwd_causal": dict(kind="bwd", causal=True),
    "combine": dict(kind="combine", num_splits=2),
    "decode": dict(kind="decode", causal=False, seqlen_q=1),
    # FlashAttention's own switch to 1-CTA MMAs (`FA_DISABLE_2CTA`), for the kernels that default to 2-CTA.
    "bwd_1cta": dict(kind="bwd", causal=False, env={"FA_DISABLE_2CTA": "1"}),
    "bwd_causal_1cta": dict(kind="bwd", causal=True, env={"FA_DISABLE_2CTA": "1"}),
}
# FlashAttention kernel class -> role in the file name ("" for a variant's main kernel).
ROLES = {
    "FlashAttentionBackwardPreprocess": "preprocess",
    "FlashAttentionBackwardPostprocess": "postprocess",
}
ENTRY = re.compile(r"^\.visible \.entry (\S+?)\(", re.MULTILINE)
DIRECTIVE = re.compile(r"^\s*\.(maxntid|reqntid|reqnctapercluster|maxnreg|minnctapersm)\s+([\d, ]+)$", re.MULTILINE)


# ---------------------------------------------------------------------------------------------
# Inside the container (`--backend local`): one variant per process (`--worker`).


def launch_configs(llvm_ir: str) -> dict[str, dict]:
    """Each `cudaLaunchKernelEx` of the compiled host code: kernel -> the constants it stores in
    its `cudaLaunchConfig_t` (gridDim, blockDim, dynamicSmemBytes); None where the host computes it."""
    configs = {}
    for body in re.split(r"\n  llvm\.func ", llvm_ir):
        if "llvm.call @_cudaLaunchKernelEx(" not in body:
            continue
        local = dict(re.findall(r"(%\w+) = llvm\.mlir\.constant\((-?\d+) : i\d+\)", body))
        cfg = re.search(r"(%\w+) = llvm\.alloca %\w+ x !llvm\.struct<\(array<3 x i32>, array<3 x i32>, i64, ptr, ptr, i32\)>", body)
        if cfg is None:
            continue
        geps = {
            g: tuple(int(x) for x in idx.split(", "))
            for g, idx in re.findall(r"(%\w+) = llvm\.getelementptr " + re.escape(cfg.group(1)) + r"\[([\d, ]+)\]", body)
        }
        vals = {}
        for v, p in re.findall(r"llvm\.store (%\w+), (%\w+) :", body):
            if p in geps:
                vals[geps[p]] = int(local[v]) if v in local else None
        kernel = re.search(r"llvm\.mlir\.addressof @kernels_(\w+) :[^\n]*\n[^\n]*\n[^\n]*_cudaLaunchKernelEx", body)
        configs[kernel.group(1) if kernel else "?"] = {
            "grid": [vals.get((0, 0, i)) for i in range(3)],
            "block": [vals.get((0, 1, i)) for i in range(3)],
            "dynamic_smem": vals.get((0, 2)),
        }
    return configs


def single_tile_grid(num_block: int, heads: int, batch: int, splits: int = 1, cluster_m: int = 1, cluster_idx: bool = False) -> list[int]:
    """`SingleTileScheduler.get_grid_shape`."""
    grid_x = num_block * cluster_m if cluster_idx else math.ceil(num_block / cluster_m) * cluster_m
    return [grid_x, heads * splits, batch]


def scheduler_grid(info: dict, problem: dict) -> list[int] | None:
    """The grid each kernel's `__call__` builds for the problem (its `TileSchedulerArguments`)."""
    sched, a, cls = info.get("scheduler"), info["attrs"], info["class"]
    b, h, sq, sk = problem["batch"], problem["heads"], problem["seqlen_q"], problem["seqlen_k"]
    splits = info.get("host", {}).get("num_splits", 1)
    cluster_m = (a.get("cluster_shape_mnk") or [1])[0]
    if cls == "FlashAttentionForwardSm100":
        num_work_m = math.ceil(sq / (a["m_block_size"] * a["q_stage"] * a["cta_group_size"]))
        work_tiles = num_work_m * h * b * splits
        if sched == "StaticPersistentTileScheduler":
            return [min((NUM_SMS // cluster_m) * cluster_m, work_tiles * cluster_m), 1, 1]
        if sched == "SingleTileLPTScheduler":
            return [num_work_m * h * b * cluster_m, splits, 1]
        if sched == "SingleTileScheduler":
            return single_tile_grid(num_work_m, h, b, splits, cluster_m, a["cta_group_size"] > 1)
    elif cls == "FlashAttentionBackwardSm100" and sched == "SingleTileScheduler":
        num_block = math.ceil(sk / a["cluster_tile_n"])
        return single_tile_grid(num_block, h // a["groups_per_tile"], b, 1, cluster_m, a["cta_group_size"] > 1)
    elif cls in ("FlashAttentionBackwardPreprocess", "FlashAttentionBackwardPostprocess") and sched == "SingleTileScheduler":
        return single_tile_grid(math.ceil(sq / a["tile_m"]), h, b)
    elif cls == "FlashAttentionForwardCombine" and sched == "SingleTileScheduler":
        return single_tile_grid(math.ceil(sq * h / a["tile_m"]), math.ceil(a["head_dim"] / a["k_block_size"]), b)
    elif cls == "_SwapABCore" and not a.get("num_splits_dynamic"):
        return single_tile_grid(1, h, b, splits)
    return None


def run_worker(variant: str, problem: dict, out: Path) -> None:
    os.environ.update(
        CUTE_DSL_ARCH=ARCH,
        FLASH_ATTENTION_ARCH=ARCH.removesuffix("a"),
        FLASH_ATTENTION_NUM_SMS=str(NUM_SMS),
        CUTE_DSL_KEEP="ptx",
        CUTE_DSL_DUMP_DIR=str(out / f".dump-{variant}"),
    )
    Path(os.environ["CUTE_DSL_DUMP_DIR"]).mkdir(parents=True, exist_ok=True)
    spec = VARIANTS[variant]
    os.environ.update(spec.get("env", {}))
    if spec["kind"] == "decode":
        os.environ["FLASH_ATTENTION_SM100_BACKEND"] = "swapab"
    import types

    # Skip flash_attn/__init__.py, which imports the FA2 CUDA extension (as flash_attn/cute/autotune.py does).
    package = types.ModuleType("flash_attn")
    package.__path__ = [str(Path(problem["source"]) / "flash_attn")]
    sys.modules["flash_attn"] = package

    import torch
    from torch._subclasses.fake_tensor import FakeTensorMode
    import cutlass.cute as cute
    import cutlass.utils
    import cutlass.utils.hardware_info as hardware_info
    from cutlass.cutlass_dsl.cutlass import CutlassBaseDSL

    class B200HardwareInfo:
        def __init__(self, *args, **kwargs):
            pass

        def get_device_multiprocessor_count(self):
            return NUM_SMS

        def get_max_active_clusters(self, cluster_size=1):
            return NUM_SMS // cluster_size

        def __getattr__(self, name):
            raise RuntimeError(f"HardwareInfo.{name} needs a GPU")

    cutlass.utils.HardwareInfo = hardware_info.HardwareInfo = B200HardwareInfo

    # Each kernel launch traced: the FlashAttention object that launches it and its tile scheduler.
    launches: dict[str, dict] = {}
    launch_func = CutlassBaseDSL.cuda_launch_func

    def recording_launch(stream, kernel, *args, **kwargs):
        frame, info = sys._getframe(1), None
        while frame is not None and info is None:
            obj = frame.f_locals.get("self")
            if obj is not None and type(obj).__module__.startswith("flash_attn.") and frame.f_code.co_name == "__call__":
                sched = frame.f_locals.get("TileScheduler", getattr(obj, "TileScheduler", None))
                attrs = {}
                for k, v in vars(obj).items():
                    if isinstance(v, (bool, int, str)) or (
                        isinstance(v, tuple) and all(isinstance(x, int) for x in v)
                    ):
                        attrs[k] = list(v) if isinstance(v, tuple) else v
                info = {"class": type(obj).__name__, "scheduler": getattr(sched, "__name__", None), "attrs": attrs}
            frame = frame.f_back
        info = info or {"class": None, "scheduler": None, "attrs": {}}
        host = sys._getframe(1)
        while host is not None and not host.f_code.co_name.startswith("_flash_attn"):
            host = host.f_back
        if host is not None:
            info["host"] = {k: host.f_locals[k] for k in ("num_splits",) if isinstance(host.f_locals.get(k), int)}
        launches[str(kernel).rsplit("@", 1)[-1]] = info
        return launch_func(stream, kernel, *args, **kwargs)

    CutlassBaseDSL.cuda_launch_func = staticmethod(recording_launch)
    compiled = []
    compile_og = cute.compile

    def recording_compile(*args, **kwargs):
        result = compile_og(*args, **kwargs)
        compiled.append(result)
        return result

    cute.compile = recording_compile

    from flash_attn.cute import interface

    b, h, d = problem["batch"], problem["heads"], problem["headdim"]
    sq = spec.get("seqlen_q", problem["seqlen_q"])
    sk = problem["seqlen_k"]
    problem = {**problem, "seqlen_q": sq, **{k: v for k, v in spec.items() if k not in ("kind", "env")}, **({"env": spec["env"]} if "env" in spec else {})}
    dtype = torch.bfloat16
    with FakeTensorMode():
        q = torch.empty(b, sq, h, d, dtype=dtype, device="cuda")
        k = torch.empty(b, sk, h, d, dtype=dtype, device="cuda")
        v = torch.empty(b, sk, h, d, dtype=dtype, device="cuda")
        if spec["kind"] in ("fwd", "decode"):
            interface._flash_attn_fwd(q, k, v, causal=spec["causal"], return_lse=True)
        elif spec["kind"] == "bwd":
            o, lse = interface._flash_attn_fwd(q, k, v, causal=spec["causal"], return_lse=True)[:2]
            compiled.clear()
            launches.clear()
            interface._flash_attn_bwd(q, k, v, o, torch.empty_like(o), lse, causal=spec["causal"])
        elif spec["kind"] == "combine":
            out_partial = torch.empty(spec["num_splits"], b, sq, h, d, dtype=torch.float32, device="cuda")
            lse_partial = torch.empty(spec["num_splits"], b, sq, h, dtype=torch.float32, device="cuda")
            interface.flash_attn_combine(out_partial, lse_partial, out_dtype=dtype, return_lse=True)

    for function in compiled:
        ptx = function.__ptx__
        ptx = (ptx() if callable(ptx) else ptx or "").rstrip("\x00")
        if ".entry " not in ptx:  # the DSL keeps it only in CUTE_DSL_DUMP_DIR
            name = getattr(function, "function_name", "")
            dumped = [p for p in Path(os.environ["CUTE_DSL_DUMP_DIR"]).glob(f"*{name}*.ptx")]
            ptx = dumped[0].read_text().rstrip("\x00") if dumped else ""
        configs = launch_configs(str(function.ir_module))
        for kernel in ENTRY.findall(ptx):
            info = launches.get(kernel, {"class": None, "scheduler": None, "attrs": {}})
            role = ROLES.get(info["class"], "")
            stem = variant + (f"_{role}" if role else "")
            launch = dict(configs.get(kernel, {}))
            host_grid, derived = launch.get("grid") or [None] * 3, scheduler_grid(info, problem)
            if None not in host_grid:
                grid_source = "host code"
            elif derived is None:
                grid_source = "unresolved (None: computed at run time)"
            elif all(c is None or c == d for c, d in zip(host_grid, derived)):
                grid_source = f"{info['scheduler'] or 'SingleTileScheduler'} for the problem (host code's constants agree)"
                launch["grid"] = derived
            else:
                grid_source = f"MISMATCH: host code {host_grid}, scheduler {derived}"
            directives = {}
            header = ptx[ptx.index(f".entry {kernel}(") :]
            header = header[: header.index("{")]
            for name, values in DIRECTIVE.findall(header):
                directives[name] = [int(x) for x in values.split(",")]
            attrs = info["attrs"]
            # FlashAttention passes `cluster=self.cluster_shape_mnk` when it has more than one CTA.
            cluster = attrs.get("cluster_shape_mnk") or directives.get("reqnctapercluster") or [1, 1, 1]
            summary = {
                "source": f"flash_attn/cute ({info['class']})",
                "variant": variant,
                "kernel": kernel,
                "target": ARCH,
                "problem": {k: v for k, v in problem.items() if k != "source"},
                "dtype": "bf16",
                "tile_scheduler": info["scheduler"],
                "launch": {
                    **launch,
                    "grid_source": grid_source,
                    "cluster": cluster,
                    "cta_group": 2 if "cta_group::2" in ptx else 1,
                },
                "ptx_directives": directives,
                "config": {k: v for k, v in attrs.items() if not k.startswith("_")},
            }
            (out / f"{stem}.ptx").write_text(ptx)
            (out / f"{stem}.json").write_text(json.dumps(summary, indent=2, default=str) + "\n")
            print(f"{variant}: {info['class']} -> {stem}.ptx", file=sys.stderr)
    shutil.rmtree(os.environ["CUTE_DSL_DUMP_DIR"], ignore_errors=True)


def compile_local(variants: list[str], problem: dict, out: Path, jobs: int) -> None:
    try:
        import cutlass  # noqa: F401
    except ImportError:
        sys.exit("nvidia-cutlass-dsl is not importable (use --backend docker)")
    out.mkdir(parents=True, exist_ok=True)
    from concurrent.futures import ThreadPoolExecutor

    def run(variant):
        command = [sys.executable, "-I", __file__, "--worker", variant, f"--out={out}", f"--problem={json.dumps(problem)}"]
        return variant, subprocess.run(command, capture_output=True, text=True)

    failed = []
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        for variant, result in pool.map(run, variants):
            sys.stderr.write(result.stderr if result.returncode == 0 else "")
            if result.returncode != 0:
                failed.append(variant)
                tail = "\n".join(result.stderr.strip().splitlines()[-25:])
                print(f"{variant} failed:\n{tail}", file=sys.stderr)
    if failed:
        sys.exit(f"failed: {', '.join(failed)}")


# ---------------------------------------------------------------------------------------------
# On the host.


def docker(*args: str, stdin: str | None = None, quiet: bool = False) -> None:
    result = subprocess.run(["docker", *args], input=stdin, text=True, capture_output=quiet)
    if result.returncode != 0:
        sys.exit(f"docker {args[0]} failed{': ' + result.stderr.strip() if quiet else ''}")


def compile_in_docker(variants: list[str], problem: dict, out: Path, jobs: int) -> None:
    """Run this script with `--backend local` in a container, then copy its output dir out."""
    if subprocess.run(["docker", "info"], capture_output=True).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)
    container = f"volta-flash-attention-cute-{uuid.uuid4().hex[:12]}"
    script = Path(__file__).resolve()
    inner = {**problem, "source": "/work/flash-attention"}
    command = [
        "python3", "-I", f"/work/{script.name}", *variants, "--backend=local", "--out=/work/out",
        f"--jobs={jobs}", f"--problem={json.dumps(inner)}",
    ]
    docker("create", "--name", container, f"--cpus={jobs}", DOCKER_IMAGE, *command, quiet=True)
    try:
        with tempfile.TemporaryDirectory() as staging:
            staged = Path(staging)
            shutil.copy(script, staged / script.name)
            # FlashAttention's cute package only: flash_attn/__init__.py would import the FA2 extension.
            shutil.copytree(
                Path(problem["source"]) / "flash_attn" / "cute",
                staged / "flash-attention" / "flash_attn" / "cute",
                ignore=shutil.ignore_patterns("__pycache__"),
            )
            docker("cp", f"{staging}/.", f"{container}:/work/", quiet=True)
        docker("start", "--attach", container)
        out.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory() as fetched:
            docker("cp", f"{container}:/work/out/.", fetched, quiet=True)
            for path in Path(fetched).iterdir():
                if path.suffix in (".ptx", ".json"):
                    shutil.copy(path, out / path.name)
                    print(f"wrote {out / path.name}")
    finally:
        subprocess.run(["docker", "rm", "--force", container], capture_output=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("variants", nargs="*", help=f"variants to compile (default: all of {', '.join(VARIANTS)})")
    parser.add_argument("--list", action="store_true", help="list the variants and exit")
    parser.add_argument("--batch", type=int, default=1)
    parser.add_argument("--heads", type=int, default=1)
    parser.add_argument("--seqlen", type=int, default=128, help="seqlen_q = seqlen_k (decode: seqlen_q = 1)")
    parser.add_argument("--headdim", type=int, default=128)
    parser.add_argument("--source", type=Path, default=FA_ROOT, help=f"flash-attention checkout (default {FA_ROOT})")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output dir (default {DEFAULT_OUT})")
    parser.add_argument("--jobs", type=int, default=4, help="variants compiled at once (default 4)")
    parser.add_argument(
        "--backend",
        choices=["auto", "local", "docker"],
        default="auto",
        help="where CuTe DSL runs (default: local if nvidia-cutlass-dsl is importable, else docker)",
    )
    parser.add_argument("--worker", help=argparse.SUPPRESS)
    parser.add_argument("--problem", help=argparse.SUPPRESS)
    args = parser.parse_args()

    if args.list:
        for name, spec in VARIANTS.items():
            print(f"{name}: {spec}")
        return
    if args.problem:
        problem = json.loads(args.problem)
    else:
        problem = {
            "batch": args.batch, "heads": args.heads, "seqlen_q": args.seqlen, "seqlen_k": args.seqlen,
            "headdim": args.headdim, "source": str(args.source.resolve()),
        }
    if args.worker:
        run_worker(args.worker, problem, args.out)
        return
    unknown = [v for v in args.variants if v not in VARIANTS]
    if unknown:
        sys.exit(f"unknown variant(s) {', '.join(unknown)}: pick among {', '.join(VARIANTS)}")
    variants = args.variants or list(VARIANTS)
    if not (Path(problem["source"]) / "flash_attn" / "cute").is_dir():
        sys.exit(f"no flash_attn/cute under {problem['source']} (see external/ptx/extraction/fetch_sources.py)")
    backend = args.backend
    if backend == "auto":
        try:
            import cutlass  # noqa: F401

            backend = "local"
        except ImportError:
            backend = "docker"
    (compile_local if backend == "local" else compile_in_docker)(variants, problem, args.out, args.jobs)


if __name__ == "__main__":
    main()
