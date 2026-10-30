# /// script
# requires-python = ">=3.10"
# ///
"""Download or compile TileLang 0.1.11's example kernels to PTX for Blackwell (sm_100a).

    uv run external/extraction/tilelang_kernels.py                     # every kernel
    uv run external/extraction/tilelang_kernels.py warp_specialize     # one example directory's kernels
    uv run external/extraction/tilelang_kernels.py gemv --backend docker

Most kernels are sentryward's corpus (https://github.com/gpu-verifier/sentryward)
at a pinned commit, compiled from TileLang at `TILELANG_COMMIT` (its v0.1.11 tag)
with nvcc 13.2: each download must match its recorded sha256. The others
(`COMPILED`) are compiled here from that commit's examples, each at the
configuration the example's `main()` runs, through TileLang's own PTX export;
compiling needs nvcc, so without TileLang and nvcc (macOS) the script builds an
image with both once, runs itself in a container and copies the PTX out
(`--backend`). Every PTX lands in `<out>/<example>/<stem>.ptx` (by default
`external/tilelang/`), beside a `.json` naming its source and the kernels it
defines (and, for a compiled one, its configuration and launch: grid, block,
dynamic shared memory and parameters in the kernel's own order); the launch
files there are kept.
The script is not named `tilelang.py`, which would shadow the package it imports.
"""

import argparse
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import uuid
from dataclasses import dataclass, field
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUT = EXTERNAL_ROOT / "tilelang"
SENTRYWARD_COMMIT = "421ff2c7d140341f64d2bc1f1edd045b65a7c403"
SENTRYWARD_RAW = f"https://raw.githubusercontent.com/gpu-verifier/sentryward/{SENTRYWARD_COMMIT}/corpus"
SENTRYWARD_BLOB = f"https://github.com/gpu-verifier/sentryward/blob/{SENTRYWARD_COMMIT}/corpus"
TILELANG_VERSION = "0.1.11"
TILELANG_COMMIT = "cd37ed5fc35ae7a60a1277c8eb49028174ac51e6"
TILELANG_RAW = f"https://raw.githubusercontent.com/tile-ai/tilelang/{TILELANG_COMMIT}"
SENTRYWARD_NVCC = "13.2"
TARGET = "sm_100a"

# TileLang 0.1.11 breaks with newer apache-tvm-ffi releases, so its dependencies are pinned to
# the versions current at its release; uv provides Python, so the build needs no apt mirror.
DOCKER_IMAGE = f"volta-tilelang:{TILELANG_VERSION}-cuda-12.9.1"
DOCKERFILE = f"""FROM ghcr.io/astral-sh/uv:0.8.10 AS uv
FROM nvidia/cuda:12.9.1-devel-ubuntu24.04
COPY --from=uv /uv /usr/local/bin/uv
ENV UV_PYTHON_INSTALL_DIR=/opt/python
RUN uv venv --python 3.12 /venv \\
 && uv pip install --python /venv --no-cache torch==2.12.0 --index-url https://download.pytorch.org/whl/cpu \\
 && uv pip install --python /venv --no-cache tilelang=={TILELANG_VERSION} apache-tvm-ffi==0.1.11
ENV PATH=/venv/bin:$PATH
WORKDIR /work
"""

ENTRY = re.compile(r"^\.visible \.entry (\S+?)\(", re.MULTILINE)
NVCC_RELEASE = re.compile(r"release (\d+\.\d+)")


@dataclass(frozen=True)
class Downloaded:
    """One sentryward corpus file: where it lands, the TileLang example it was compiled from, and its checksum."""

    stem: str  # `<example>/<stem>` under the output directory
    source: str
    corpus_file: str
    sha256: str


@dataclass(frozen=True)
class Compiled:
    """One kernel of a TileLang example, compiled here at the configuration its `main()` runs."""

    stem: str
    source: str
    function: str
    config: dict[str, int] = field(hash=False)


DOWNLOADED = [
    Downloaded(
        "gemm_sm100/matmul_kernel",
        "examples/gemm_sm100/gemm_tcgen5mma.py",
        "tilelang-gemm-sm100-tcgen5mma.ptx",
        "7fe7fbb2e01887577320c2028919750847411d01ab0cf1dcbf13d4bbe79982a2",
    ),
    Downloaded(
        "online_softmax/softmax_kernel_kernel",
        "examples/online_softmax/online_softmax.py",
        "tilelang-online-softmax.ptx",
        "30aed65c1d8f2cdd55e8f37c229a7d015f3389cd22ede1879eebf10aabbaeb62",
    ),
    Downloaded(
        "warp_specialize/matmul_kernel_barrierpipe_stage2",
        "examples/warp_specialize/example_warp_specialize_gemm_barrierpipe_stage2.py",
        "tilelang-ws-gemm-barrierpipe-stage2.ptx",
        "fb4845c7f182d35c1325b77d342f335bc0f216e7f6bad3161552b734cd2d8835",
    ),
    Downloaded(
        "warp_specialize/matmul_kernel_softpipe_stage2",
        "examples/warp_specialize/example_warp_specialize_gemm_softpipe_stage2.py",
        "tilelang-ws-gemm-softpipe-stage2.ptx",
        "54feb44f5a4ede27ba2ffe7597761bb32d043c2187017e78cfea8e15dac0d46c",
    ),
    Downloaded(
        "warp_specialize/matmul_warp_specialize_copy_0_gemm_1_kernel",
        "examples/warp_specialize/example_warp_specialize_gemm_copy_0_gemm_1.py",
        "tilelang-ws-gemm-copy-0-gemm-1.ptx",
        "dc1dd56ce8752303f4c32d8b6742221beebedc61e8c26b4bf13973cfc7fda11d",
    ),
    Downloaded(
        "warp_specialize/matmul_warp_specialize_copy_1_gemm_0_kernel",
        "examples/warp_specialize/example_warp_specialize_gemm_copy_1_gemm_0.py",
        "tilelang-ws-gemm-copy-1-gemm-0.ptx",
        "f24146eda628b30d9565ea82df543cb306871b53e3f91be7a101b312eacdf3eb",
    ),
    Downloaded(
        "warp_specialize/matmul_warp_specialize_copy_gemm_0_1_kernel",
        "examples/warp_specialize/example_warp_specialize_gemm_copy_gemm_0_1.py",
        "tilelang-ws-gemm-copy-gemm-0-1.ptx",
        "906489fd9861d455156d442247d122429c74635a0103ba17be99a614d94bdaa6",
    ),
]

GEMV = "examples/gemv/example_gemv.py"
# `gemv_alloc_reducer` is autotuned on a GPU in `main()`; here it keeps its default
# `num_stages = 2, threads = 256`.
COMPILED = [
    Compiled("gemv/naive_gemv", GEMV, "naive_gemv", {"N": 1024, "K": 1024, "BLOCK_N": 128, "BLOCK_K": 128}),
    Compiled("gemv/naive_splitk_gemv", GEMV, "naive_splitk_gemv", {"N": 1024, "K": 1024, "BLOCK_N": 32, "BLOCK_K": 32}),
    Compiled(
        "gemv/splitk_gemv",
        GEMV,
        "splitk_gemv",
        {"N": 1024, "K": 1024, "BLOCK_N": 32, "BLOCK_K": 32, "reduce_threads": 32},
    ),
    Compiled(
        "gemv/splitk_gemv_vectorized",
        GEMV,
        "splitk_gemv_vectorized",
        {"N": 1024, "K": 1024, "BLOCK_N": 2, "reduce_threads": 32},
    ),
    Compiled(
        "gemv/splitk_gemv_vectorized_tvm",
        GEMV,
        "splitk_gemv_vectorized_tvm",
        {"N": 1024, "K": 1024, "BLOCK_N": 2, "reduce_threads": 32},
    ),
    Compiled(
        "gemv/gemv_alloc_reducer",
        GEMV,
        "gemv_alloc_reducer",
        {"M": 1024, "N": 1024, "block_M": 128, "block_N": 128},
    ),
]


def example_of(stem: str) -> str:
    return stem.split("/")[0]


def write_kernel(out: Path, stem: str, ptx: bytes, meta: dict[str, object]) -> None:
    ptx_path = out / f"{stem}.ptx"
    ptx_path.parent.mkdir(parents=True, exist_ok=True)
    ptx_path.write_bytes(ptx)
    meta["kernels"] = [{"kernel": name} for name in ENTRY.findall(ptx.decode())]
    ptx_path.with_suffix(".json").write_text(json.dumps(meta, indent=2) + "\n")
    print(f"wrote {ptx_path}", flush=True)


# Download: a sentryward corpus file, checked against its recorded checksum.


def download(kernel: Downloaded, out: Path) -> None:
    url = f"{SENTRYWARD_RAW}/{kernel.corpus_file}"
    with urllib.request.urlopen(url, timeout=60) as response:
        ptx = response.read()

    digest = hashlib.sha256(ptx).hexdigest()
    if digest != kernel.sha256:
        sys.exit(f"{url}: sha256 {digest}, expected {kernel.sha256}")

    meta = {
        "source": kernel.source,
        "tilelang": TILELANG_COMMIT,
        "nvcc": SENTRYWARD_NVCC,
        "target": TARGET,
        "ptx": {"from": f"{SENTRYWARD_BLOB}/{kernel.corpus_file}", "sha256": kernel.sha256},
    }
    write_kernel(out, kernel.stem, ptx, meta)


# Compile, where TileLang and nvcc are installed (`--backend local`).


def nvcc_release() -> str:
    version = subprocess.run(["nvcc", "--version"], capture_output=True, text=True, check=True).stdout
    match = NVCC_RELEASE.search(version)
    if match is None:
        sys.exit(f"no release in `nvcc --version`: {version}")
    return match[1]


def load_example(source: str, directory: Path):
    """Import a TileLang example (not as `__main__`, so its benchmarks do not run)."""
    path = directory / Path(source).name
    if not path.exists():
        with urllib.request.urlopen(f"{TILELANG_RAW}/{source}", timeout=60) as response:
            path.write_bytes(response.read())

    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def launch_of(kernel) -> dict[str, object]:
    """The grid, block, dynamic shared memory and parameters of a compiled kernel's one device function."""
    [device_func] = kernel.artifact.device_mod.functions.values()
    extent = device_func.attrs["thread_extent"]
    dims = {str(axis): int(size) for axis, size in extent.items()}

    # The device function orders its parameters its own way (`a, o, x` for `a, x -> o`), each
    # named after the buffer whose data it is.
    buffers = {buffer.data.name: buffer for buffer in kernel.prim_func.buffer_map.values()}
    params = []
    for param in device_func.params:
        buffer = buffers[param.name]
        params.append({"name": param.name, "shape": [int(d) for d in buffer.shape], "dtype": str(buffer.dtype)})

    return {
        "grid": [dims.get(f"blockIdx.{axis}", 1) for axis in "xyz"],
        "block": [dims.get(f"threadIdx.{axis}", 1) for axis in "xyz"],
        "dynamic_shared_bytes": int(device_func.attrs.get("dyn_shared_memory_buf", 0)),
        "params": params,
    }


def compile_locally(kernels: list[Compiled], out: Path) -> None:
    nvcc = nvcc_release()
    with tempfile.TemporaryDirectory() as sources:
        for kernel in kernels:
            example = load_example(kernel.source, Path(sources))

            # An autotuned function's JIT function compiles one configuration, untuned.
            function = getattr(example, kernel.function)
            jit = getattr(function, "jit_impl", function)
            jit.target = {"kind": "cuda", "arch": TARGET}
            compiled = jit.compile(**kernel.config)

            ptx_path = Path(sources) / f"{kernel.function}.ptx"
            compiled.export_ptx(str(ptx_path))
            meta = {
                "source": kernel.source,
                "function": kernel.function,
                "config": kernel.config,
                "tilelang": TILELANG_COMMIT,
                "nvcc": nvcc,
                "target": TARGET,
                "launch": launch_of(compiled),
            }
            write_kernel(out, kernel.stem, ptx_path.read_bytes(), meta)


# Compile in a container (`--backend docker`), its output copied out.


def docker(*args: str, stdin: str | None = None, quiet: bool = False) -> None:
    result = subprocess.run(["docker", *args], input=stdin, text=True, capture_output=quiet, check=False)
    if result.returncode != 0:
        sys.exit(f"docker {args[0]} failed{': ' + result.stderr.strip() if quiet else ''}")


def compile_in_docker(kernels: list[Compiled], out: Path) -> None:
    if subprocess.run(["docker", "info"], capture_output=True, check=False).returncode != 0:
        sys.exit("the Docker daemon is not running (start Docker Desktop, or `colima start`)")
    if subprocess.run(["docker", "image", "inspect", DOCKER_IMAGE], capture_output=True, check=False).returncode != 0:
        print(f"building {DOCKER_IMAGE} (once)", file=sys.stderr)
        docker("build", "-t", DOCKER_IMAGE, "-", stdin=DOCKERFILE)

    examples = sorted({example_of(kernel.stem) for kernel in kernels})
    container = f"volta-tilelang-{uuid.uuid4().hex[:8]}"
    command = ["python", f"/work/{Path(__file__).name}", "--backend=local", "--out=/work/out", *examples]
    docker("create", "--name", container, DOCKER_IMAGE, *command, quiet=True)
    try:
        docker("cp", __file__, f"{container}:/work/", quiet=True)
        docker("start", "--attach", container)
        out.mkdir(parents=True, exist_ok=True)
        docker("cp", f"{container}:/work/out/.", str(out), quiet=True)
    finally:
        subprocess.run(["docker", "rm", "--force", container], capture_output=True, check=False)


def main() -> None:
    examples = sorted({example_of(kernel.stem) for kernel in [*DOWNLOADED, *COMPILED]})
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("examples", nargs="*", choices=examples, help="example directories (default: all)")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help="output directory (default: %(default)s)")
    parser.add_argument(
        "--backend",
        choices=["auto", "local", "docker"],
        default="auto",
        help="where the compiled kernels compile (default: local if TileLang and nvcc are installed, else docker)",
    )
    args = parser.parse_args()

    def selected(kernel: Downloaded | Compiled) -> bool:
        return not args.examples or example_of(kernel.stem) in args.examples

    for kernel in DOWNLOADED:
        if selected(kernel):
            download(kernel, args.out)

    to_compile = [kernel for kernel in COMPILED if selected(kernel)]
    if not to_compile:
        return

    backend = args.backend
    if backend == "auto":
        local = importlib.util.find_spec("tilelang") is not None and shutil.which("nvcc") is not None
        backend = "local" if local else "docker"
    if backend == "local":
        compile_locally(to_compile, args.out)
    else:
        compile_in_docker(to_compile, args.out.resolve())


if __name__ == "__main__":
    main()
