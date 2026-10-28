# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Compile the TritonBench-G kernels to PTX for Blackwell (sm_100a).

    uv run external/extraction/tritonbench.py                   # the files of `SIZES`
    uv run external/extraction/tritonbench.py add_example.py    # some files (names or paths)
    uv run external/extraction/tritonbench.py --jobs 2 --timeout 600

Each file's own test code runs unchanged, with CPU torch standing in for CUDA,
and every Triton launch it makes is compiled instead of run: a fake B200
driver lets Triton's own binder specialize the arguments exactly as a launch
would (dtypes, 16-byte divisibility, constexprs), an autotuned kernel takes
its first config, and the outputs are never computed. Triton ships Linux
wheels only, so without an importable `triton` (macOS) the script builds an
image with torch and triton once, runs itself in a container and copies the
PTX out (`--backend`); running third-party test code there also isolates it.

Each distinct PTX of a file lands in `<out>/<file stem>/<kernel>[_vN].ptx`
(by default `external/tritonbench/`), beside a `.json` with its launch
configuration (in the format of `ai_compiler_kernels/`) and every launch
that produced it: grid, and each argument's dtype, shape and storage or
value. A file of `SIZES` records only the launches of its sizes, each called
through the file's own wrapper after its test code ran, and each becomes a
Volta launch file `<kernel>.<size>.launch.json` (`volta analyze --config`);
for any other file, up to `LAUNCH_FILES` of its test code's launches,
smallest first, become `<kernel>.<i>.launch.json`. A launch file holds one
`inout` array per tensor storage, the kernel's scalars, and zeros for
Triton's trailing scratch pointers. `--summary` (by default
`external/output/tritonbench_extraction.csv`) says how each file went. A
file's earlier output directory is replaced.
"""

import argparse
import contextlib
import csv
import hashlib
import importlib.util
import inspect
import json
import math
import os
import re
import runpy
import shutil
import subprocess
import sys
import tempfile
import time
import traceback
import uuid
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path
from types import SimpleNamespace

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
BENCH_DIR = EXTERNAL_ROOT / "sources" / "TritonBench" / "data" / "TritonBench_G_v1"
DEFAULT_OUT = EXTERNAL_ROOT / "tritonbench"
DEFAULT_SUMMARY = EXTERNAL_ROOT / "output" / "tritonbench_extraction.csv"
LAUNCH_FILES = 3
# The files Volta checks: size label -> a call of the file's own wrapper, run in its namespace.
# A constexpr size (swiglu's n_cols) compiles each size to its own PTX.
SIZES = {
    "add_example.py": {f"n{n}": f"add_wrapper(torch.randn({n}), torch.randn({n}))" for n in (16, 64, 256)},
    "swiglu_triton.py": {
        f"{r}x{c}": f"swiglu_backward(torch.randn({r}, {c}), torch.randn({r}, {c}), torch.randn({r}, {c}))"
        for r, c in ((32, 256),)
    },
}
ARRAY_ALIGN = 0x10000
# torch dtype -> launch-file dtype and its bytes per element.
LAUNCH_DTYPES = {
    "float64": ("f64", 8), "float32": ("f32", 4), "float16": ("f16", 2), "bfloat16": ("bf16", 2),
    "float8_e4m3fn": ("e4m3", 1), "float8_e4m3fnuz": ("e4m3", 1),
    "float8_e5m2": ("e5m2", 1), "float8_e5m2fnuz": ("e5m2", 1),
    "int64": ("i64", 8), "int32": ("i32", 4), "int16": ("i16", 2), "int8": ("i8", 1),
    "uint64": ("u64", 8), "uint32": ("u32", 4), "uint16": ("u16", 2), "uint8": ("u8", 1), "bool": ("u8", 1),
}
BLACKWELL_CAPABILITY = 100
WARP_SIZE = 32
B200_SMS = 148
TRITON_VERSION = "3.5.1"
TORCH_VERSION = "2.9.0"
DOCKER_IMAGE = f"volta-tritonbench:triton-{TRITON_VERSION}-torch-{TORCH_VERSION}"
DOCKERFILE = f"""FROM python:3.12-slim
RUN pip install --no-cache-dir torch=={TORCH_VERSION} --index-url https://download.pytorch.org/whl/cpu \\
 && pip install --no-cache-dir triton=={TRITON_VERSION} numpy
WORKDIR /work
"""


# ---------------------------------------------------------------------------
# Capture: one file's test code, in a child process (`--capture`).
# ---------------------------------------------------------------------------


def jsonable(value):
    if isinstance(value, (bool, int, float, str)) or value is None:
        return value
    if isinstance(value, (list, tuple)):
        return [jsonable(v) for v in value]
    return str(value)


def describe_args(bound_args: dict, constexprs: dict) -> dict:
    """Each runtime argument; tensors sharing a storage name the same `storage` index."""
    import torch

    storages: dict[int, int] = {}
    described = {}
    for name, value in bound_args.items():
        if name in constexprs:
            continue
        if not isinstance(value, torch.Tensor):
            described[name] = {"value": jsonable(value)}
            continue
        storage = value.untyped_storage()
        described[name] = {
            "dtype": str(value.dtype).removeprefix("torch."),
            "shape": list(value.shape),
            "strides": list(value.stride()),
            "storage": storages.setdefault(storage.data_ptr(), len(storages)),
            "storage_bytes": storage.nbytes(),
            "offset_bytes": value.data_ptr() - storage.data_ptr(),
        }
    return described


class Unlaunchable(Exception):
    """A recorded launch no launch file can express."""


def ptx_param_count(ptx: str) -> int:
    entry = re.search(r"\.entry\s+\S+\((.*?)\)", ptx, re.DOTALL)
    return entry.group(1).count(".param") if entry else 0


def launch_text(summary: dict, launch: dict, ptx_params: int, description: str) -> str:
    """One launch as a Volta launch file; raises `Unlaunchable`."""
    arrays: dict[int, dict] = {}
    params: list[dict] = []
    viewed = any(arg.get("offset_bytes") for arg in launch["args"].values())
    next_base = ARRAY_ALIGN
    for name, arg in launch["args"].items():
        if "storage" in arg:
            if arg["storage"] not in arrays:
                if arg["dtype"] not in LAUNCH_DTYPES:
                    raise Unlaunchable(f"{name} has dtype {arg['dtype']}")
                dtype, width = LAUNCH_DTYPES[arg["dtype"]]
                length = max(1, -(-arg["storage_bytes"] // width))
                whole = arg["shape"] and not arg["offset_bytes"] and math.prod(arg["shape"]) == length
                array = {"name": name, "kind": "inout", "dtype": dtype} | (
                    {"shape": arg["shape"]} if whole else {"len": length}
                )
                if viewed:
                    array["base"] = f"{next_base:#x}"
                    next_base += -(-length * width // ARRAY_ALIGN) * ARRAY_ALIGN
                arrays[arg["storage"]] = array
            array = arrays[arg["storage"]]
            if arg["offset_bytes"]:
                params.append({"name": name, "int": int(array["base"], 16) + arg["offset_bytes"]})
            else:
                params.append({"name": name, "ptr": array["name"]})
        elif isinstance(arg["value"], bool):
            params.append({"name": name, "int": int(arg["value"])})
        elif isinstance(arg["value"], int):
            params.append({"name": name, "int": arg["value"]})
        elif isinstance(arg["value"], float) and math.isfinite(arg["value"]):
            params.append({"name": name, "float": arg["value"]})
        else:
            raise Unlaunchable(f"{name} = {arg['value']!r}")
    scratch = ptx_params - len(params)
    if scratch < 0:
        raise Unlaunchable(f"{len(params)} arguments for {ptx_params} PTX parameters")
    params += [{"name": "Triton scratch pointer", "int": 0}] * scratch

    def row(entry: dict) -> str:
        return "{" + ", ".join(f"{json.dumps(k)}: {json.dumps(v)}" for k, v in entry.items()) + "}"

    lines = [
        "{",
        f'  "description": {json.dumps(description)},',
        f'  "kernel": {json.dumps(summary["kernel"])},',
        f'  "block": {summary["num_threads_x"]},',
        f'  "grid": {json.dumps(launch["grid"])},',
        f'  "dynamic_shared_bytes": {summary["shared"]},',
        '  "arrays": [',
        ",\n".join(f"    {row(a)}" for a in arrays.values()),
        "  ],",
        '  "params": [',
        ",\n".join(f"    {row(p)}" for p in params),
        "  ]",
        "}",
    ]
    return "\n".join(lines) + "\n"


@dataclass
class Variant:
    stem: str
    summary: dict
    launches: list = field(default_factory=list)


class Recorder:
    """Every launch of the file's kernels, grouped by the PTX they compile to."""

    def write_launch_files(self) -> tuple[int, list[str]]:
        """Each variant's sized, or else smallest distinct, launches as launch files; returns (written, why not)."""
        written, unlaunchable = 0, []
        for variant in self.variants.values():
            ptx_params = ptx_param_count((self.out_dir / f"{variant.stem}.ptx").read_text())

            if self.sized:
                named = [(launch["size"], launch) for launch in variant.launches]
            else:
                distinct = {json.dumps(launch, sort_keys=True): launch for launch in variant.launches}
                runnable = [launch for launch in distinct.values() if all(launch["grid"])]

                def footprint(launch: dict) -> int:
                    storages = {a["storage"]: a["storage_bytes"] for a in launch["args"].values() if "storage" in a}
                    return sum(storages.values())

                smallest = sorted(runnable, key=footprint)[:LAUNCH_FILES]
                named = [(str(index), launch) for index, launch in enumerate(smallest, start=1)]

            for name, launch in named:
                shapes = ", ".join(f"{n} {a['dtype']}{a['shape']}" for n, a in launch["args"].items() if "storage" in a)
                description = f"TritonBench {self.source.name}: {variant.summary['kernel']} on {shapes or 'scalars'}"
                try:
                    text = launch_text(variant.summary, launch, ptx_params, description)
                except Unlaunchable as why:
                    unlaunchable.append(f"{variant.stem}: {why}")
                    continue
                (self.out_dir / f"{variant.stem}.{name}.launch.json").write_text(text)
                written += 1
        return written, unlaunchable

    def __init__(self, source: Path, out_dir: Path, sized: bool):
        self.source = source
        self.out_dir = out_dir
        self.variants: dict[str, Variant] = {}
        self.launches = 0
        self.compile_failures: list[str] = []
        # A sized file records only the launches made while `size` names one of its sizes.
        self.sized = sized
        self.size: str | None = None

    def launched(self, fn, kernel, grid, args, kwargs) -> None:
        import triton

        if self.sized and self.size is None:
            return
        device_cache = fn.device_caches[0]
        bound_args, specialization, _ = device_cache[4](*args, **kwargs)
        if callable(grid):
            grid = grid(bound_args)
        grid = [int(g) for g in grid] + [1] * (3 - len(grid))
        self.launches += 1
        ptx = kernel.asm["ptx"]
        key = hashlib.sha256(ptx.encode()).hexdigest()
        if key not in self.variants:
            metadata = kernel.metadata
            same_name = sum(v.summary["kernel"] == metadata.name for v in self.variants.values())
            stem = metadata.name if same_name == 0 else f"{metadata.name}_v{same_name + 1}"
            names = list(bound_args)
            self.variants[key] = Variant(
                stem,
                {
                    "num_threads_x": metadata.num_warps * WARP_SIZE,
                    "num_threads_y": 1,
                    "num_threads_z": 1,
                    "num_warps": metadata.num_warps,
                    "num_ctas": metadata.num_ctas,
                    "shared": metadata.shared,
                    "kernel": metadata.name,
                    "source": self.source.name,
                    "triton": triton.__version__,
                    "target": f"sm_{BLACKWELL_CAPABILITY}a",
                    "signature": {n: s[0] for n, s in zip(names, specialization)},
                    "constexprs": {
                        n: jsonable(bound_args[n]) for n, s in zip(names, specialization) if s[0] == "constexpr"
                    },
                    "specialization": {
                        n: s[1] for n, s in zip(names, specialization) if s[0] != "constexpr" and isinstance(s[1], str) and s[1]
                    },
                },
            )
            self.out_dir.mkdir(parents=True, exist_ok=True)
            (self.out_dir / f"{stem}.ptx").write_text(ptx)
        variant = self.variants[key]
        launch = {"grid": grid, "args": describe_args(bound_args, variant.summary["constexprs"])}
        if self.size is not None:
            launch["size"] = self.size
        variant.launches.append(launch)
        summary = variant.summary | {"launches": variant.launches}
        (self.out_dir / f"{variant.stem}.json").write_text(json.dumps(summary, indent=2) + "\n")


def fake_cuda(torch) -> None:
    """CPU torch answering the CUDA queries and context managers the test code uses."""
    noop = lambda *args, **kwargs: None  # noqa: E731
    properties = SimpleNamespace(
        name="NVIDIA B200", major=10, minor=0, multi_processor_count=B200_SMS, total_memory=192 << 30
    )

    class Event:
        def __init__(self, *args, **kwargs):
            pass

        record = synchronize = wait = noop

        def elapsed_time(self, other):
            return 0.0

    cuda = torch.cuda
    cuda.is_available = lambda: True
    cuda.device_count = lambda: 1
    cuda.current_device = lambda: 0
    cuda.set_device = cuda.synchronize = cuda.empty_cache = noop
    cuda.manual_seed = cuda.manual_seed_all = noop
    cuda.get_device_name = lambda *args: properties.name
    cuda.get_device_capability = lambda *args: (properties.major, properties.minor)
    cuda.get_device_properties = lambda *args: properties
    cuda.device = cuda._DeviceGuard = lambda *args, **kwargs: contextlib.nullcontext()
    cuda.current_stream = lambda *args: SimpleNamespace(cuda_stream=0, synchronize=noop)
    cuda.Event = Event
    # A CUDA generator's state is its (seed, offset) pair of int64s.
    cuda.default_generators = (
        SimpleNamespace(get_state=lambda: torch.zeros(2, dtype=torch.int64).view(torch.uint8), set_state=noop),
    )
    torch._C._cuda_getCurrentRawStream = lambda device: 0
    guards = torch._C._dynamo.guards
    guards._empty_strided_cuda = guards._empty_strided_cpu
    torch.Tensor.is_cuda = property(lambda self: True)
    # The kernels never ran, so any comparison with a reference would fail.
    torch.allclose = lambda *args, **kwargs: True
    torch.testing.assert_close = noop


def cuda_to_cpu_mode(torch):
    from torch.overrides import TorchFunctionMode

    def to_cpu(device):
        if isinstance(device, str) and device.startswith("cuda"):
            return "cpu"
        if isinstance(device, torch.device) and device.type == "cuda":
            return torch.device("cpu")
        return device

    class CudaToCpu(TorchFunctionMode):
        def __torch_function__(self, func, types, args=(), kwargs=None):
            kwargs = dict(kwargs or {})
            if func in (torch.Tensor.cuda, torch.Tensor.pin_memory):
                return args[0]
            if "device" in kwargs:
                kwargs["device"] = to_cpu(kwargs["device"])
            if func is torch.Tensor.to:
                args = tuple(to_cpu(a) for a in args)
            return func(*args, **kwargs)

    return CudaToCpu()


def fake_blackwell_driver(torch):
    from triton.backends.compiler import GPUTarget

    target = GPUTarget("cuda", BLACKWELL_CAPABILITY, WARP_SIZE)
    device_properties = {
        "multiprocessor_count": B200_SMS,
        "max_shared_mem": 232448,
        "max_num_regs": 65536,
        "warpSize": WARP_SIZE,
        "sm_clock_rate": 1965000,
        "mem_clock_rate": 3996000,
        "mem_bus_width": 8192,
    }
    return SimpleNamespace(
        is_active=lambda: True,
        get_current_target=lambda: target,
        get_current_device=lambda: 0,
        get_current_stream=lambda device=None: 0,
        get_active_torch_device=lambda: torch.device("cpu"),
        get_device_interface=lambda: torch.cuda,
        get_benchmarker=lambda: (lambda fn, *args, **kwargs: 0.0),
        utils=SimpleNamespace(get_device_properties=lambda device: device_properties),
    )


def last_line(error: BaseException) -> str:
    return "".join(traceback.format_exception_only(error)).strip().splitlines()[-1]


def capture(source: Path, out_dir: Path, result: Path) -> None:
    import torch
    from triton.runtime import driver
    from triton.runtime.autotuner import Autotuner
    from triton.runtime.jit import JITFunction

    fake_cuda(torch)
    driver.set_active(fake_blackwell_driver(torch))
    shutil.rmtree(out_dir, ignore_errors=True)
    sizes = SIZES.get(source.name, {})
    recorder = Recorder(source, out_dir, sized=bool(sizes))
    compile_only = JITFunction.run

    def run(self, *args, grid, warmup, **kwargs):
        try:
            kernel = compile_only(self, *args, grid=grid, warmup=True, **kwargs)
        except Exception as error:
            recorder.compile_failures.append(f"{self._fn_name}: {last_line(error)}")
            return None
        if not warmup and kernel is not None:
            recorder.launched(self, kernel, grid, args, kwargs)
        return kernel

    JITFunction.run = run
    # Every config "takes" 0 ms, so the autotuner keeps the first one.
    Autotuner._bench = lambda self, *args, config, **meta: [0.0]

    def guarded(run) -> str | None:
        try:
            with cuda_to_cpu_mode(torch):
                run()
        except BaseException as raised:  # noqa: BLE001 - SystemExit from the test code included
            if not (isinstance(raised, SystemExit) and raised.code in (None, 0)):
                return last_line(raised)
        return None

    sys.argv = [str(source)]
    module: dict = {}
    error = guarded(lambda: module.update(runpy.run_path(str(source), run_name="__main__")))

    if sizes and error is None:
        for size, call in sizes.items():
            recorder.size = size
            error = error or guarded(lambda: exec(call, module))
        recorder.size = None
    # Some files define their tests without calling them.
    elif recorder.launches == 0 and error is None:
        tests = [
            fn for name, fn in module.items()
            if name.startswith("test") and inspect.isfunction(fn) and fn.__code__.co_filename == str(source)
            and not any(p.default is p.empty for p in inspect.signature(fn).parameters.values())
        ]
        error = next(filter(None, map(guarded, tests)), None)
    launch_files, unlaunchable = recorder.write_launch_files()
    result.write_text(
        json.dumps(
            {
                "launch_files": launch_files,
                "unlaunchable": unlaunchable,
                "ptx_files": sorted(f"{v.stem}.ptx" for v in recorder.variants.values()),
                "kernels": sorted({v.summary["kernel"] for v in recorder.variants.values()}),
                "launches": recorder.launches,
                "compile_failures": recorder.compile_failures,
                "error": error,
            }
        )
    )


# ---------------------------------------------------------------------------
# Batch: every file in its own `--capture` process (`--backend local`).
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class FileReport:
    file: str
    status: str
    ptx_files: int
    kernels: int
    launches: int
    launch_files: int
    compile_failures: int
    seconds: float
    detail: str


def capture_in_child(source: Path, out: Path, timeout: float) -> FileReport:
    start = time.perf_counter()
    with tempfile.TemporaryDirectory() as scratch:
        result_path = Path(scratch) / "result.json"
        command = [
            sys.executable, str(Path(__file__).resolve()), "--capture", str(source),
            "--out", str(out), "--result", str(result_path),
        ]
        try:
            child = subprocess.run(command, capture_output=True, text=True, timeout=timeout, cwd=scratch)
        except subprocess.TimeoutExpired:
            written = len(list((out / source.stem).glob("*.ptx")))
            return FileReport(source.name, "TIMEOUT", written, 0, 0, 0, 0, timeout, f"no exit after {timeout:.0f}s")
        seconds = time.perf_counter() - start
        if not result_path.exists():
            tail = (child.stderr.strip().splitlines() or [f"exit status {child.returncode}"])[-1]
            return FileReport(source.name, "CRASHED", 0, 0, 0, 0, 0, seconds, tail)
        result = json.loads(result_path.read_text())
    failures = result["compile_failures"]
    problems = [
        *failures,
        *(f"no launch file for {why}" for why in result["unlaunchable"]),
        *([f"test raised {result['error']}"] if result["error"] else []),
    ]
    if not result["ptx_files"]:
        status = "FAILED"
        detail = "; ".join(problems) or "no kernel launched"
    else:
        status = "PARTIAL" if problems else "OK"
        detail = ", ".join(result["ptx_files"]) + ("; " + "; ".join(problems) if problems else "")
    return FileReport(
        source.name, status, len(result["ptx_files"]), len(result["kernels"]),
        result["launches"], result["launch_files"], len(failures), seconds, detail,
    )


def compile_local(sources: list[Path], out: Path, summary_path: Path, jobs: int, timeout: float) -> None:
    out.mkdir(parents=True, exist_ok=True)
    width = max(len(s.name) for s in sources)

    def one(source: Path) -> FileReport:
        report = capture_in_child(source, out, timeout)
        print(f"{report.file:<{width}}  {report.status:<7}  {report.seconds:6.1f}s  {report.detail}", flush=True)
        return report

    with ThreadPoolExecutor(max_workers=jobs) as pool:
        reports = list(pool.map(one, sources))
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    with summary_path.open("w", newline="") as summary:
        writer = csv.writer(summary)
        writer.writerow(
            ["file", "status", "ptx_files", "kernels", "launches", "launch_files", "compile_failures", "seconds", "detail"]
        )
        for r in sorted(reports, key=lambda r: r.file):
            writer.writerow(
                [r.file, r.status, r.ptx_files, r.kernels, r.launches, r.launch_files, r.compile_failures,
                 f"{r.seconds:.1f}", r.detail]
            )
    counts = {status: sum(r.status == status for r in reports) for status in dict.fromkeys(r.status for r in reports)}
    total_ptx = sum(r.ptx_files for r in reports)
    total_launches = sum(r.launch_files for r in reports)
    print(
        f"\n{total_ptx} PTX files and {total_launches} launch files from {len(reports)} files: "
        + ", ".join(f"{n} {s}" for s, n in counts.items())
    )


# ---------------------------------------------------------------------------
# Host: the batch inside a container, its output copied out (`--backend docker`).
# ---------------------------------------------------------------------------


def docker(*args: str, stdin: str | None = None, quiet: bool = False) -> None:
    result = subprocess.run(["docker", *args], input=stdin, text=True, capture_output=quiet)
    if result.returncode != 0:
        sys.exit(f"docker {args[0]} failed{': ' + result.stderr.strip() if quiet else ''}")


def compile_in_docker(sources: list[Path], out: Path, summary_path: Path, jobs: int | None, timeout: float) -> None:
    if subprocess.run(["docker", "info"], capture_output=True).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)
    container = f"volta-tritonbench-{uuid.uuid4().hex[:12]}"
    command = [
        "python", Path(__file__).name, *(f"kernels/{s.name}" for s in sources),
        "--backend=local", "--out=/work/out", "--summary=/work/summary.csv", f"--timeout={timeout}",
        *([f"--jobs={jobs}"] if jobs else []),
    ]
    docker("create", "--name", container, DOCKER_IMAGE, *command, quiet=True)
    try:
        with tempfile.TemporaryDirectory() as staging:
            kernels = Path(staging) / "kernels"
            kernels.mkdir()
            for source in sources:
                shutil.copy(source, kernels)
            docker("cp", __file__, f"{container}:/work/", quiet=True)
            docker("cp", str(kernels), f"{container}:/work/", quiet=True)
        docker("start", "--attach", container)
        out.mkdir(parents=True, exist_ok=True)
        for source in sources:
            shutil.rmtree(out / source.stem, ignore_errors=True)
        docker("cp", f"{container}:/work/out/.", str(out), quiet=True)
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        docker("cp", f"{container}:/work/summary.csv", str(summary_path), quiet=True)
    finally:
        subprocess.run(["docker", "rm", "--force", container], capture_output=True)
    print(f"copied to {out}, summary in {summary_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("files", nargs="*", help=f"kernel files, or names under {BENCH_DIR} (default: those of SIZES)")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help=f"output root (default {DEFAULT_OUT})")
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY, help=f"how each file went (default {DEFAULT_SUMMARY})")
    parser.add_argument("--jobs", type=int, help="files captured at once (default: the CPU count)")
    parser.add_argument("--timeout", type=float, default=300, help="seconds per file (default 300)")
    parser.add_argument(
        "--backend",
        choices=["auto", "local", "docker"],
        default="auto",
        help="where Triton runs (default: local if it is importable, else docker)",
    )
    parser.add_argument("--capture", type=Path, help=argparse.SUPPRESS)
    parser.add_argument("--result", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()

    if args.capture is not None:
        capture(args.capture.resolve(), args.out.resolve() / args.capture.stem, args.result)
        return

    sources = []
    for name in args.files or sorted(SIZES):
        path = Path(name) if Path(name).exists() else BENCH_DIR / name
        if not path.exists():
            sys.exit(f"no such kernel file: {name}")
        sources.append(path.resolve())
    backend = args.backend
    if backend == "auto":
        backend = "local" if importlib.util.find_spec("triton") else "docker"
    if backend == "local":
        compile_local(sources, args.out.resolve(), args.summary.resolve(), args.jobs or os.cpu_count() or 1, args.timeout)
    else:
        compile_in_docker(sources, args.out.resolve(), args.summary.resolve(), args.jobs, args.timeout)


if __name__ == "__main__":
    main()
