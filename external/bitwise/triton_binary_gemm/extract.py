#!/usr/bin/env python3
"""Compile kernel.py's binary GEMM to PTX offline, for M=N=K=256 on Blackwell (sm_100).

Run with triton==3.5.1 on Linux; no GPU is needed. Writes kernel.ptx, kernel.json
(compiler, constants, hashes) and kernel.launch.json (CTA 0's full 16x256 tile of C).
"""
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
M = N = 256
KW = 256 // 32
BLOCK_M, BLOCK_N = 16, 256
OPTIONS = {"num_warps": 4, "num_stages": 1}


def main():
    import triton
    from triton.backends.compiler import GPUTarget
    from triton.compiler import ASTSource

    if triton.__version__ != "3.5.1":
        raise RuntimeError("Reproduction requires triton==3.5.1")
    spec = importlib.util.spec_from_file_location("binary_gemm", ROOT / "kernel.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    fn = module.binary_gemm_kernel

    constants = dict(
        M=M, N=N, KW=KW, stride_am=KW, stride_bn=KW, stride_cm=N,
        BLOCK_M=BLOCK_M, BLOCK_N=BLOCK_N,
    )
    signature = {name: "constexpr" for name in fn.arg_names}
    signature.update(a_ptr="*i32", b_ptr="*i32", c_ptr="*i32")
    kernel = triton.compile(
        ASTSource(fn, signature, constexprs=constants),
        target=GPUTarget("cuda", 100, 32), options=OPTIONS,
    )
    ptx = kernel.asm["ptx"]
    (ROOT / "kernel.ptx").write_text(ptx)

    grid = [M // BLOCK_M, N // BLOCK_N, 1]
    block = [32 * OPTIONS["num_warps"], 1, 1]
    metadata = dict(
        triton=triton.__version__, target="sm_100a", constants=constants, options=OPTIONS,
        shared=kernel.metadata.shared, kernel=kernel.metadata.name, grid=grid, block=block,
        source_sha256=hashlib.sha256((ROOT / "kernel.py").read_bytes()).hexdigest(),
        ptx_sha256=hashlib.sha256(ptx.encode()).hexdigest(),
    )
    (ROOT / "kernel.json").write_text(json.dumps(metadata, indent=2) + "\n")

    # Volta analyzes CTA 0, whose 16x256 output tile is contiguous rows of C.
    launch = dict(
        description=f"Triton XOR-popcount GEMM, M=N=K=256, CTA 0's {BLOCK_M}x{BLOCK_N} tile",
        kernel=kernel.metadata.name, grid=grid, block=block,
        dynamic_shared_bytes=kernel.metadata.shared,
        arrays=[
            dict(name="a", kind="in", dtype="u32", shape=[M, KW]),
            dict(name="b", kind="in", dtype="u32", shape=[N, KW]),
            dict(name="c", kind="out", dtype="i32", shape=[BLOCK_M, N]),
        ],
        params=[dict(name=n, ptr=n[0]) for n in ("a_ptr", "b_ptr", "c_ptr")]
               + [dict(name="global_scratch", int=0), dict(name="profile_scratch", int=0)],
        spec="binary_gemm.spec", dims=dict(MA=M, N=N, KW=KW, TM=BLOCK_M),
    )
    (ROOT / "kernel.launch.json").write_text(json.dumps(launch, indent=2) + "\n")
    print(f"{kernel.metadata.name}: {len(ptx)} PTX bytes, {kernel.metadata.shared} shared bytes")


if __name__ == "__main__":
    main()
