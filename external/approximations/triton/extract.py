#!/usr/bin/env python3
"""Compile kernel.py's fused GEMM to PTX offline, once per activation, for M=N=K=256 on Ampere.

Run with triton==3.5.1 on Linux (the volta-tritonbench:triton-3.5.1 image; no GPU is needed):
    python extract.py [--out DIR] [CASE...]
writes <case>.ptx, <case>.json (compiler, constants, hashes) and <case>.launch.json (CTA 0's
64 x 256 tile of C, the shared spec in ../specs/).
"""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
M = N = K = 256
BLOCK_M, BLOCK_N, BLOCK_K = 64, 256, 32
OPTIONS = {"num_warps": 4, "num_stages": 3}
TARGET = ("cuda", 80, 32)

# Each case's spec in ../specs/ and what it is.
CASES = {
    "relu": ("relu", "relu"),
    "leaky_relu": ("leaky_relu", "leaky ReLU, slope 0.01"),
    "hardtanh": ("hardtanh", "hardtanh (-1, 1)"),
    "hardsigmoid": ("hardsigmoid", "hardsigmoid"),
    "hardswish": ("hardswish", "hardswish"),
    "softshrink": ("softshrink", "softshrink, lambd 0.5"),
    "elu": ("elu", "ELU, alpha 1"),
    "celu": ("celu", "CELU, alpha 2"),
    "selu": ("selu", "SELU"),
    "gelu_tanh": ("gelu_tanh", "tanh GELU with tanh.approx.f32"),
    "gelu_tanh_libdevice": ("gelu_tanh", "tanh GELU with libdevice's tanh"),
    "gelu_erf": ("gelu_erf", "exact GELU with libdevice's erf"),
    "sigmoid": ("sigmoid", "sigmoid (tl.sigmoid)"),
    "silu": ("silu", "SiLU, x * tl.sigmoid(x)"),
    "tanh": ("tanh", "tanh.approx.f32"),
    "softplus": ("softplus", "softplus without its threshold, libdevice's log"),
    "softplus_fast": ("softplus", "softplus without its threshold, libdevice's fast_logf"),
    "softplus_threshold": (
        "softplus_threshold", "PyTorch's softplus with its threshold 20, fast_logf"
    ),
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    parser.add_argument("--out", type=Path, default=ROOT, help="directory to write into")
    args = parser.parse_args()

    import triton
    from triton.backends.compiler import GPUTarget
    from triton.compiler import ASTSource

    if triton.__version__ != "3.5.1":
        raise RuntimeError("Reproduction requires triton==3.5.1")
    spec = importlib.util.spec_from_file_location("fused_gemm", ROOT / "kernel.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    fn = module.fused_gemm_kernel
    source_sha256 = hashlib.sha256((ROOT / "kernel.py").read_bytes()).hexdigest()
    args.out.mkdir(parents=True, exist_ok=True)

    for name in args.cases or list(CASES):
        spec_name, description = CASES[name]
        constants = dict(
            M=M, N=N, K=K, stride_am=K, stride_ak=1, stride_bn=K, stride_bk=1, stride_cm=N,
            stride_cn=1, BLOCK_M=BLOCK_M, BLOCK_N=BLOCK_N, BLOCK_K=BLOCK_K, ACTIVATION=name,
        )
        signature = {arg: "constexpr" for arg in fn.arg_names}
        signature.update(a_ptr="*fp32", b_ptr="*fp32", c_ptr="*fp32")
        kernel = triton.compile(
            ASTSource(fn, signature, constexprs=constants), target=GPUTarget(*TARGET), options=OPTIONS
        )
        ptx = kernel.asm["ptx"]
        (args.out / f"{name}.ptx").write_text(ptx)

        grid = [M // BLOCK_M, N // BLOCK_N, 1]
        block = [32 * OPTIONS["num_warps"], 1, 1]
        metadata = dict(
            triton=triton.__version__, target=f"sm_{TARGET[1]}", constants=constants,
            options=OPTIONS, shared=kernel.metadata.shared, kernel=kernel.metadata.name,
            grid=grid, block=block, source_sha256=source_sha256,
            ptx_sha256=hashlib.sha256(ptx.encode()).hexdigest(),
        )
        (args.out / f"{name}.json").write_text(json.dumps(metadata, indent=2) + "\n")

        # Volta analyzes CTA 0, whose BLOCK_M x BLOCK_N tile is the first BLOCK_M rows of C.
        launch = dict(
            description=f"Triton TF32 GEMM with {description} fused, M=N=K=256, CTA 0's "
                        f"{BLOCK_M}x{BLOCK_N} tile",
            kernel=kernel.metadata.name, grid=grid, block=block,
            dynamic_shared_bytes=kernel.metadata.shared,
            arrays=[
                dict(name="a", kind="in", dtype="f32", shape=[M, K]),
                dict(name="b", kind="in", dtype="f32", shape=[N, K]),
                dict(name="c", kind="out", dtype="f32", shape=[BLOCK_M, N]),
            ],
            params=[dict(name=f"{p}_ptr", ptr=p) for p in ("a", "b", "c")]
                   + [dict(name="global_scratch", int=0), dict(name="profile_scratch", int=0)],
            spec=f"../specs/{spec_name}.spec", dims=dict(M=M, N=N, K=K, TM=BLOCK_M),
        )
        (args.out / f"{name}.launch.json").write_text(json.dumps(launch, indent=2) + "\n")
        print(f"{name}: {len(ptx)} PTX bytes, {kernel.metadata.shared} shared bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
