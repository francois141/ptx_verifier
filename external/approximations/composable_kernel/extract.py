#!/usr/bin/env python3
"""Compile gemm.hip once per activation for gfx950 and write each case's launch file.

    CK_ROOT=<composable_kernel rocm-7.0.0 checkout, ck/config.h generated> \\
    HIP_ROOT=<HIP 7.0.2 headers: include/ and share/hip/version> \\
    python3 extract.py [--clang PATH] [CASE...]

Each case is `<case>.s`, the assembly of `gemm.hip` with its C element-wise operation, and
`<case>.launch.json`, the kernel's arguments as CK's host code packs them for M = N = K = 256 with
the operation's parameters, naming the shared spec in ../specs/. The compiler is LLVM's clang 21
(`--clang`, default /opt/homebrew/opt/llvm@21/bin/clang++); Apple's lacks the AMDGPU target.
"""
import argparse
import json
import os
import re
import struct
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CK_OPS = "ck::tensor_operation::element_wise"
M = N = K = 256
TILE_M, TILE_N, TILE_K = 64, 256, 32
AK1 = BK1 = 4
BLOCK = 256
DEFAULT_CLANG = "/opt/homebrew/opt/llvm@21/bin/clang++"


@dataclass(frozen=True)
class Case:
    """`operation` is the C element-wise operation type; `parameters` its float fields in
    declaration order, which the kernel argument carries by value."""

    operation: str
    spec: str
    description: str
    parameters: tuple[tuple[str, float], ...] = ()
    fast_math: bool = True


CASES = {
    "relu": Case(f"{CK_OPS}::Relu", "relu", "CK's Relu"),
    "leaky_relu": Case(
        f"{CK_OPS}::LeakyRelu", "leaky_relu", "CK's LeakyRelu, alpha 0.01", (("alpha", 0.01),)
    ),
    "hardtanh": Case(
        f"{CK_OPS}::ClippedRelu", "hardtanh", "CK's ClippedRelu with bounds -1 and 1",
        (("alpha", -1.0), ("beta", 1.0)),
    ),
    "hardsigmoid": Case("pytorch::Hardsigmoid", "hardsigmoid", "PyTorch's Hardsigmoid"),
    "hardswish": Case("pytorch::Hardswish", "hardswish", "PyTorch's Hardswish"),
    "softshrink": Case(
        "pytorch::Softshrink", "softshrink", "PyTorch's Softshrink, lambd 0.5", (("lambd", 0.5),)
    ),
    "elu": Case(f"{CK_OPS}::Elu", "elu", "CK's Elu (OCML's expm1), alpha 1", (("alpha", 1.0),)),
    "celu": Case(
        "pytorch::Celu", "celu", "PyTorch's CELU, alpha 2", (("alpha", 2.0), ("inv_alpha", 0.5))
    ),
    "selu": Case("pytorch::Selu", "selu", "PyTorch's SELU"),
    "fast_gelu": Case(f"{CK_OPS}::FastGelu", "gelu_tanh", "CK's FastGelu"),
    "gelu": Case(f"{CK_OPS}::Gelu", "gelu_erf", "CK's Gelu (OCML's erf)"),
    "sigmoid": Case(f"{CK_OPS}::Sigmoid", "sigmoid", "CK's Sigmoid"),
    "sigmoid_precise": Case(
        f"{CK_OPS}::Sigmoid", "sigmoid", "CK's Sigmoid without -ffast-math", fast_math=False
    ),
    "silu": Case(f"{CK_OPS}::Silu", "silu", "CK's Silu"),
    "swish": Case(f"{CK_OPS}::Swish", "silu", "CK's Swish, beta 1", (("beta", 1.0),)),
    "tanh": Case(f"{CK_OPS}::TanH", "tanh", "CK's TanH (OCML's tanh)"),
    "softrelu": Case(
        f"{CK_OPS}::SoftRelu", "softplus", "CK's SoftRelu (softplus), alpha 1", (("alpha", 1.0),)
    ),
}


def run(*command, cwd=None):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{command[0]} failed:\n{result.stdout}{result.stderr}")
    return result.stdout


def compile_case(name: str, case: Case, clang: str, ck_root: Path, hip_root: Path) -> str:
    flags = [
        "-x", "hip", "-std=c++20", "-fbracket-depth=1024",
        "--offload-arch=gfx950:xnack-", "--offload-device-only", "-nogpulib",
        f"--hip-path={hip_root}", "-DNDEBUG", "-Wno-unknown-warning-option",
        "-Wno-nan-infinity-disabled", "-O3", "-g0", "-fno-verbose-asm",
        "-fno-hip-fp32-correctly-rounded-divide-sqrt",
        *(["-ffast-math"] if case.fast_math else []),
        f"-I{ck_root / 'include'}", f"-DACTIVATION={case.operation}",
        "-S", "gemm.hip", "-o", f"{name}.s",
    ]
    run(clang, *flags, cwd=ROOT)
    return (ROOT / f"{name}.s").read_text()


def kernel_name(assembly: str) -> str:
    names = re.findall(r"^\s*\.globl\s+(_ZN2ck27kernel_gemm_xdl_cshuffle_v3\S+)", assembly, re.M)
    if len(names) != 1:
        raise RuntimeError(f"expected one GEMM kernel symbol, found {names}")
    return names[0]


def as_f32(value: float) -> float:
    """`value` rounded to the f32 the kernel reads, which the launch file must state exactly."""
    return struct.unpack("f", struct.pack("f", value))[0]


def align(offset: int, to: int) -> int:
    return -(-offset // to) * to


def operation_layout(assembly: str) -> tuple[int, int]:
    """The C operation's size and alignment, the constants gemm.hip exports."""
    values = {}
    for name in ("c_element_op_size", "c_element_op_align"):
        match = re.search(rf"^{name}:\s*\n\s*\.long\s+(\d+)", assembly, re.M)
        if match is None:
            raise RuntimeError(f"{name} is not in the assembly")
        values[name] = int(match[1])
    return values["c_element_op_size"], values["c_element_op_align"]


def kernarg_size(size: int, alignment: int) -> int:
    """`Argument`'s size: BaseArgument's two pointers, Problem's fifteen ints and three element
    operations (the A and B ones empty, one byte each), the three matrix pointers and
    `is_reduce`."""
    offset = align(16 + 15 * 4 + 2, alignment) + size
    offset = align(offset, 8) + 3 * 8 + 1
    return align(offset, 8)


def launch(name: str, case: Case, kernel: str, size: int, alignment: int) -> dict:
    def ceil_to(value, unit):
        return -(-value // unit) * unit

    k_padded = ceil_to(K, TILE_K)
    problem = [
        ("M", M), ("N", N), ("K", K),
        ("StrideA", K), ("StrideB", K), ("StrideC", N),
        ("KBatch", 1),
        ("MPadded", ceil_to(M, TILE_M)), ("NPadded", ceil_to(N, TILE_N)),
        ("KRead", ceil_to(K, AK1)), ("KPadded", k_padded),
        ("AK0", k_padded // AK1), ("BK0", k_padded // BK1),
        ("MBlock", ceil_to(M, TILE_M) // TILE_M), ("NBlock", ceil_to(N, TILE_N) // TILE_N),
    ]
    params = [
        {"name": "BaseArgument vtable pointer, unread (low word, null)", "int": 0},
        {"name": "BaseArgument vtable pointer, unread (high word, null)", "int": 0},
        {"name": "p_workspace_ (low word, null)", "int": 0},
        {"name": "p_workspace_ (high word, null)", "int": 0},
        *({"name": field_name, "int": value} for field_name, value in problem),
    ]
    # The A and B operations are empty; the C operation's floats come first, then whatever else it
    # holds (FastGelu's 256 unread bytes), as zero words. An empty C operation is one padding byte.
    if alignment >= 4 and size % 4 == 0:
        params.append({"name": "a_element_op_, b_element_op_ (no fields) and padding", "int": 0})
        params.extend(
            {"name": f"c_element_op_.{field_name}", "float": as_f32(value)}
            for field_name, value in case.parameters
        )
        params.extend(
            {"name": "c_element_op_ (other bytes, unread)", "int": 0}
            for _ in range(size // 4 - len(case.parameters))
        )
    elif size == 1 and not case.parameters:
        params.append(
            {"name": "a_element_op_, b_element_op_, c_element_op_ (no fields) and padding", "int": 0}
        )
    else:
        raise RuntimeError(f"{name}: a C operation of {size} bytes aligned to {alignment}")
    params.extend([
        {"name": "p_a_grid", "ptr": "a"},
        {"name": "p_b_grid", "ptr": "b"},
        {"name": "p_c_grid", "ptr": "c"},
        {"name": "is_reduce (false) and padding", "int": 0},
        {"name": "padding", "int": 0},
    ])
    grid = (ceil_to(M, TILE_M) // TILE_M) * (ceil_to(N, TILE_N) // TILE_N)
    return {
        "description": f"CK fp32 GEMM with {case.description} fused, M=N=K=256, workgroup 0's "
                       f"{TILE_M}x{TILE_N} tile",
        "kernel": kernel,
        "block": [BLOCK, 1, 1],
        "grid": [grid, 1, 1],
        "arrays": [
            {"name": "a", "kind": "in", "dtype": "f32", "shape": [M, K]},
            {"name": "b", "kind": "in", "dtype": "f32", "shape": [N, K]},
            {"name": "c", "kind": "out", "dtype": "f32", "shape": [TILE_M, N]},
        ],
        "params": params,
        "spec": f"../specs/{case.spec}.spec",
        "dims": {"M": M, "N": N, "K": K, "TM": TILE_M},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    parser.add_argument("--clang", default=DEFAULT_CLANG)
    args = parser.parse_args()
    try:
        ck_root = Path(os.environ["CK_ROOT"])
        hip_root = Path(os.environ["HIP_ROOT"])
    except KeyError as missing:
        print(f"error: set {missing.args[0]} (see the module docstring)", file=sys.stderr)
        return 1
    if not (ck_root / "include/ck/config.h").exists():
        print("error: generate ck/config.h from ck/config.h.in first (see README.md)", file=sys.stderr)
        return 1
    names = args.cases or list(CASES)
    for name in names:
        case = CASES[name]
        assembly = compile_case(name, case, args.clang, ck_root, hip_root)
        kernel = kernel_name(assembly)
        size, alignment = operation_layout(assembly)
        declared = int(re.search(r"\.amdhsa_kernarg_size (\d+)", assembly.split(kernel, 1)[1])[1])
        expected = kernarg_size(size, alignment)
        if declared != expected:
            raise RuntimeError(f"{name}: kernarg size {declared}, launch file packs {expected}")
        if 4 * len(case.parameters) > size:
            raise RuntimeError(f"{name}: {len(case.parameters)} floats in a {size}-byte operation")
        (ROOT / f"{name}.launch.json").write_text(
            json.dumps(launch(name, case, kernel, size, alignment), indent=2) + "\n"
        )
        mfma = len(re.findall(r"v_mfma_f32_16x16x4", assembly))
        print(f"{name}: {len(assembly)} bytes of assembly, {mfma} MFMAs, {declared}-byte kernarg")
    return 0


if __name__ == "__main__":
    sys.exit(main())
