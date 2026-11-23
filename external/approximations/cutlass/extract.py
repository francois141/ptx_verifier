#!/usr/bin/env python3
"""Compile kernel.cu once per activation to PTX, locally or through Docker, and write launch files.

    python3 extract.py [--cutlass DIR] [--backend auto|local|docker] [CASE...]

Each case is `<case>.ptx`, `<case>.json` (compiler, configuration, hashes) and `<case>.launch.json`
(M = N = K = 256, CTA 0's 128 x 256 tile of C, the shared spec in ../specs/). CUTLASS v3.9.2 is
downloaded unless `--cutlass` names a clean checkout of it; `nvcc` runs locally when installed,
else in the nvidia/cuda:12.9.1-devel-ubuntu24.04 image. No GPU is needed.
"""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent
COMMIT = "ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e"
TAG = "v3.9.2"
IMAGE = "nvidia/cuda:12.9.1-devel-ubuntu24.04"
FUNCTORS = "cutlass::epilogue::thread"
M = N = K = 256
TILE_M, TILE_N, TILE_K = 128, 256, 32
WARP = (64, 64, 32)
INSTRUCTION = (16, 8, 8)
STAGES = 3
MMA = "mma.sync.aligned.m16n8k8.row.col.f32.tf32.tf32.f32"


@dataclass(frozen=True)
class Case:
    functor: str
    spec: str
    description: str
    defines: tuple[str, ...] = ()
    fast_math: bool = True


CASES = {
    "relu": Case(f"{FUNCTORS}::ReLu", "relu", "CUTLASS's ReLu"),
    "leaky_relu": Case(f"{FUNCTORS}::LeakyReLU", "leaky_relu", "CUTLASS's LeakyReLU, slope 0.01"),
    "hardtanh": Case(f"{FUNCTORS}::Clamp", "hardtanh", "CUTLASS's Clamp with bounds -1 and 1"),
    "hardsigmoid": Case("pytorch::Hardsigmoid", "hardsigmoid", "PyTorch's Hardsigmoid"),
    "hardswish": Case(f"{FUNCTORS}::HardSwish", "hardswish", "CUTLASS's HardSwish"),
    "softshrink": Case("pytorch::Softshrink", "softshrink", "PyTorch's Softshrink, lambd 0.5"),
    "elu": Case("pytorch::ELU", "elu", "PyTorch's ELU, alpha 1"),
    "celu": Case("pytorch::CELU", "celu", "PyTorch's CELU, alpha 2"),
    "selu": Case("pytorch::SELU", "selu", "PyTorch's SELU"),
    "gelu_tanh": Case(f"{FUNCTORS}::GELU_taylor", "gelu_tanh", "CUTLASS's GELU_taylor (tanh.approx)"),
    "gelu_erf": Case(f"{FUNCTORS}::GELU", "gelu_erf", "CUTLASS's GELU (erff)"),
    "sigmoid": Case(f"{FUNCTORS}::Sigmoid", "sigmoid", "CUTLASS's Sigmoid"),
    "sigmoid_tanh": Case(
        f"{FUNCTORS}::Sigmoid", "sigmoid", "CUTLASS's Sigmoid as 0.5 * tanh(x / 2) + 0.5",
        ("CUTLASS_USE_TANH_FOR_SIGMOID",),
    ),
    "sigmoid_precise": Case(
        f"{FUNCTORS}::Sigmoid", "sigmoid", "CUTLASS's Sigmoid without -use_fast_math", fast_math=False
    ),
    "silu": Case(f"{FUNCTORS}::SiLu", "silu", "CUTLASS's SiLu"),
    "tanh": Case(f"{FUNCTORS}::Tanh", "tanh", "CUTLASS's Tanh (tanh.approx)"),
    "softplus": Case("pytorch::Softplus", "softplus", "PyTorch's Softplus without its threshold"),
    "softplus_threshold": Case(
        "pytorch::SoftplusThreshold", "softplus_threshold", "PyTorch's Softplus with its threshold 20"
    ),
}


def run(*command, cwd=None):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{command[0]} failed:\n{result.stdout}{result.stderr}")
    return result.stdout.strip()


def nvcc_flags(name: str, case: Case, include: str) -> list[str]:
    return [
        "-std=c++17", "-O3", "-arch=sm_80", "-ptx",
        *(["-use_fast_math"] if case.fast_math else []),
        f"-DACTIVATION={case.functor}", *(f"-D{define}" for define in case.defines),
        f"-I{include}", "kernel.cu", "-o", f"out/{name}.ptx",
    ]


def compile_all(names, backend: str, source: Path, work: Path) -> None:
    (work / "out").mkdir()
    for file in ("kernel.cu", "activations.h"):
        shutil.copy2(ROOT / file, work / file)
    if backend == "local":
        for name in names:
            run("nvcc", *nvcc_flags(name, CASES[name], str(source / "include")), cwd=work)
        return
    script = ["set -e", "mkdir -p /work/out"]
    for name in names:
        flags = " ".join(f"'{flag}'" for flag in nvcc_flags(name, CASES[name], "/work/include"))
        script.append(f"echo '== {name}' && nvcc {flags}")
    (work / "compile.sh").write_text("\n".join(script) + "\n")
    container = f"volta-cutlass-approximations-{uuid.uuid4().hex[:10]}"
    run("docker", "create", "--name", container, "--workdir", "/work", IMAGE, "bash", "/work/compile.sh")
    try:
        run("docker", "cp", str(source / "include"), f"{container}:/work/include")
        for file in ("kernel.cu", "activations.h", "compile.sh"):
            run("docker", "cp", str(work / file), f"{container}:/work/{file}")
        run("docker", "start", "--attach", container)
        run("docker", "cp", f"{container}:/work/out/.", str(work / "out"))
    finally:
        run("docker", "rm", "--force", container)


def launch(name: str, case: Case, shared: int, threads: int) -> dict:
    return {
        "description": f"CUTLASS {TAG} TF32 GEMM with {case.description} fused, M=N=K=256, "
                       f"CTA 0's {TILE_M}x{TILE_N} tile",
        "kernel": "cutlass_gemm",
        "block": [threads, 1, 1],
        "grid": [M // TILE_M, N // TILE_N, 1],
        "dynamic_shared_bytes": shared,
        "arrays": [
            {"name": "a", "kind": "in", "dtype": "f32", "shape": [M, K]},
            {"name": "b", "kind": "in", "dtype": "f32", "shape": [N, K]},
            {"name": "c", "kind": "out", "dtype": "f32", "shape": [TILE_M, N]},
        ],
        "params": [{"name": "a", "ptr": "a"}, {"name": "b", "ptr": "b"}, {"name": "c", "ptr": "c"}],
        "spec": f"../specs/{case.spec}.spec",
        "dims": {"M": M, "N": N, "K": K, "TM": TILE_M},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    parser.add_argument("--cutlass", type=Path, help=f"clean checkout of {TAG}; otherwise downloaded")
    parser.add_argument("--backend", choices=["auto", "local", "docker"], default="auto")
    args = parser.parse_args()
    names = args.cases or list(CASES)
    backend = args.backend
    if backend == "auto":
        backend = "local" if shutil.which("nvcc") else "docker"
    with tempfile.TemporaryDirectory(prefix="volta-cutlass-approximations-") as temporary:
        work = Path(temporary)
        source = args.cutlass.resolve() if args.cutlass else work / "cutlass"
        if args.cutlass is None:
            run("git", "clone", "--depth", "1", "--branch", TAG,
                "https://github.com/NVIDIA/cutlass.git", str(source))
        if run("git", "-C", str(source), "rev-parse", "HEAD") != COMMIT:
            raise RuntimeError(f"CUTLASS checkout must be at {COMMIT}")
        if run("git", "-C", str(source), "status", "--porcelain", "--", "include"):
            raise RuntimeError("CUTLASS include tree has local changes")
        compile_all(names, backend, source, work)
        cuda = None
        for name in names:
            case = CASES[name]
            ptx = (work / "out" / f"{name}.ptx").read_text()
            if MMA not in ptx:
                raise RuntimeError(f"{name}: the PTX has no {MMA}")
            shared = int(re.search(r"cutlass_shared_bytes = (\d+);", ptx)[1])
            threads = int(re.search(r"cutlass_threads = (\d+);", ptx)[1])
            cuda = re.search(r"Cuda compilation tools, (.+)", ptx)[1]
            (ROOT / f"{name}.ptx").write_text(ptx)
            (ROOT / f"{name}.launch.json").write_text(
                json.dumps(launch(name, case, shared, threads), indent=2) + "\n"
            )
            metadata = dict(
                repository="https://github.com/NVIDIA/cutlass", tag=TAG, commit=COMMIT, cuda=cuda,
                target="sm_80", backend=backend, docker_image=IMAGE if backend == "docker" else None,
                flags=nvcc_flags(name, case, "<cutlass>/include"), activation=case.functor,
                M=M, N=N, K=K, threadblock_shape=[TILE_M, TILE_N, TILE_K], warp_shape=list(WARP),
                instruction_shape=list(INSTRUCTION), stages=STAGES,
                grid=[M // TILE_M, N // TILE_N, 1], block=[threads, 1, 1], shared_bytes=shared,
                source_sha256=hashlib.sha256((ROOT / "kernel.cu").read_bytes()).hexdigest(),
                activations_sha256=hashlib.sha256((ROOT / "activations.h").read_bytes()).hexdigest(),
                ptx_sha256=hashlib.sha256(ptx.encode()).hexdigest(),
            )
            (ROOT / f"{name}.json").write_text(json.dumps(metadata, indent=2) + "\n")
            print(f"{name}: {len(ptx)} PTX bytes; {threads} threads, {shared} shared bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
