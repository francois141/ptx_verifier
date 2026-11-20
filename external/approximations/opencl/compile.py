#!/usr/bin/env python3
"""Compile activations.cl once per activation for gfx950, with launch files.

    python3 compile.py [--clang PATH] [CASE...]

Each case is `<case>.s`, a SIZE x SIZE x SIZE GEMM with the activation fused, on one workgroup,
compiled with -cl-fast-relaxed-math and denormals kept (as the AMD `sigmoid.cl` fixture), so every
exp and log carries clang's denormal guard, and `<case>.launch.json`, naming ../specs/<spec>.spec.
The kernel takes M, N and K as arguments, so `launch` gives any size. The compiler is LLVM's
clang 21 (Apple's lacks the AMDGPU target).
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang"
SIZE = 128
THREADS = 64

# case -> the spec in ../specs it is checked against
CASES = {
    "relu": "relu",
    "leaky_relu": "leaky_relu",
    "hardtanh": "hardtanh",
    "hardsigmoid": "hardsigmoid",
    "hardswish": "hardswish",
    "softshrink": "softshrink",
    "elu": "elu",
    "celu": "celu",
    "selu": "selu",
    "fast_gelu": "gelu_tanh",
    "gelu": "gelu_erf",
    "sigmoid": "sigmoid",
    "silu": "silu",
    "tanh": "tanh",
    "softrelu": "softplus",
}

FLAGS = [
    "-x", "cl", "-cl-std=CL1.2", "--target=amdgcn-amd-amdhsa", "-mcpu=gfx950", "-nogpulib",
    "-O2", "-g0", "-fno-verbose-asm", "-Xclang", "-target-feature", "-Xclang", "-xnack",
    "-cl-fast-relaxed-math",
]


def compile_case(clang: str, case: str) -> str:
    command = [clang, *FLAGS, f"-DACTIVATION={case}", "-S", "activations.cl", "-o", "-"]
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"{case}: clang failed:\n{result.stderr}")
    if "s_swappc_b64" in result.stdout:
        sys.exit(f"{case}: the kernel calls a library function -nogpulib does not provide")
    return result.stdout


def launch(case: str, spec: str, size: int = SIZE) -> dict:
    """The launch of `case` on a `size` x `size` x `size` GEMM: A is M x K, B is N x K."""
    matrix = [size, size]
    return {
        "description": f"activations.cl's {case} after a {size}x{size}x{size} GEMM, one workgroup",
        "kernel": case,
        "block": THREADS,
        "arrays": [
            {"name": "a", "kind": "in", "dtype": "f32", "shape": matrix},
            {"name": "b", "kind": "in", "dtype": "f32", "shape": matrix},
            {"name": "c", "kind": "out", "dtype": "f32", "shape": matrix},
        ],
        "params": [{"ptr": "a"}, {"ptr": "b"}, {"ptr": "c"},
                   {"name": "M", "int": size}, {"name": "N", "int": size},
                   {"name": "K", "int": size}, {"name": "padding", "int": 0}],
        "spec": f"../specs/{spec}.spec",
        "dims": {"M": size, "N": size, "K": size, "TM": size},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    parser.add_argument("cases", nargs="*", default=list(CASES))
    args = parser.parse_args()
    for case in args.cases:
        (ROOT / f"{case}.s").write_text(compile_case(args.clang, case))
        text = json.dumps(launch(case, CASES[case]), indent=2) + "\n"
        (ROOT / f"{case}.launch.json").write_text(text)
        print(f"wrote {case}.s")
    return 0


if __name__ == "__main__":
    sys.exit(main())
