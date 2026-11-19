#!/usr/bin/env python3
"""Offline compilation of the two unchanged upstream BitDelta Triton kernels.

Run with Python, triton==3.5.1 and torch (upstream imports it) on Linux; no GPU is needed.
The first upstream autotuning configuration is selected explicitly, not benchmarked.
"""

import hashlib
import importlib.util
import json
from pathlib import Path

COMMIT = "ecbee1e28f6b02444d535e0a165b48cba3fe217a"
SOURCE_SHA256 = "3ad7d5d8cb1d8b4407efba5bdac7cf6bd196f0e1a88ab01b07be812bd8302def"
ROOT = Path(__file__).resolve().parent


def main():
    import triton
    from triton.backends.compiler import GPUTarget
    from triton.compiler import ASTSource

    if triton.__version__ != "3.5.1":
        raise RuntimeError("Reproduction requires triton==3.5.1")

    source = ROOT / "upstream/binary_gemm_kernel.py"
    if hashlib.sha256(source.read_bytes()).hexdigest() != SOURCE_SHA256:
        raise RuntimeError("Upstream source differs from the pinned extraction")
    module_spec = importlib.util.spec_from_file_location("binary_gemm_kernel", source)
    module = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(module)

    for name in ("binary_matmul_kernel", "binary_bmm_kernel"):
        batched = name == "binary_bmm_kernel"
        # Compile the @triton.jit function under @triton.autotune directly: the
        # autotuner would need a GPU to benchmark its configurations.
        fn = getattr(module, name).fn
        constants = dict(
            M=256, N=256, K=256, n_bits=32,
            stride_am=256, stride_ak=1, stride_bk=256, stride_bn=1,
            stride_cm=256, stride_cn=1,
            BLOCK_SIZE_M=16, BLOCK_SIZE_N=256, BLOCK_SIZE_K=64,
            GROUP_SIZE_M=8, ACTIVATION="",
        )
        if batched:
            constants.update(stride_batch_a=65536, stride_batch_b=2048, stride_batch_c=65536)
        signature = {n: "constexpr" for n in fn.arg_names}
        signature.update(a_ptr="*fp16", b_ptr="*i32", c_ptr="*fp16")
        options = {"num_warps": 4 if batched else 8, "num_stages": 3}
        kernel = triton.compile(
            ASTSource(fn, signature, constexprs=constants),
            target=GPUTarget("cuda", 90, 32), options=options,
        )
        ptx = kernel.asm["ptx"]
        (ROOT / f"{name}.ptx").write_text(ptx)
        metadata = dict(
            repository="https://github.com/FasterDecoding/BitDelta", commit=COMMIT,
            upstream_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
            ptx_sha256=hashlib.sha256(ptx.encode()).hexdigest(),
            triton=triton.__version__, target="sm_90a", constants=constants,
            options=options, shared=kernel.metadata.shared,
            kernel=kernel.metadata.name, grid=[16, 2 if batched else 1, 1],
            block=[32 * options["num_warps"], 1, 1],
        )
        (ROOT / f"{name}.json").write_text(json.dumps(metadata, indent=2) + "\n")
        # Volta analyzes CTA (0,0,0). Its full-width 16x256 output is contiguous,
        # so the original PTX can be checked with no output-stride modification.
        launch = dict(
            description=f"{name}: original 256x256x256 PTX, CTA (0,0,0), all 4096 tile outputs",
            kernel=kernel.metadata.name, grid=metadata["grid"], block=metadata["block"],
            dynamic_shared_bytes=kernel.metadata.shared,
            arrays=[
                dict(name="a", kind="in", dtype="f16", shape=[256, 256]),
                dict(name="b", kind="in", dtype="i32", shape=[8, 256]),
                dict(name="c", kind="out", dtype="f16", shape=[16, 256]),
            ],
            params=[dict(name=n, ptr=n[0]) for n in ("a_ptr", "b_ptr", "c_ptr")]
                   + [dict(name="global_scratch", int=0), dict(name="profile_scratch", int=0)],
            spec="bitdelta.spec", dims=dict(M=16, N=256, K=256, KW=8, NB=256, MA=256),
        )
        (ROOT / f"{name}.launch.json").write_text(json.dumps(launch, indent=2) + "\n")
        print(f"{name}: {len(ptx)} PTX bytes, {kernel.metadata.shared} shared bytes", flush=True)


if __name__ == "__main__":
    main()
