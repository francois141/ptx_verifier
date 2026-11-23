#!/usr/bin/env python3
"""Compile kernels.py's tutorial kernels and the binary GEMMs offline for AMD gfx950.

The binary GEMMs are external/bitwise's Triton sources, written beside their PTX builds: its
XOR-popcount GEMM and BitDelta's upstream kernels. Run with triton==3.5.1 and torch (which
BitDelta imports) on Linux (the volta-tritonbench:triton-3.5.1-torch-2.9.0 image; no GPU is
needed):
    python extract.py [--out DIR] [CASE...]
writes, under DIR as under the repository (its default), <case>.s (the AMDGCN assembly),
<case>.json (compiler, constants, hashes) and <case>.launch.json (workgroup 0 of the grid,
checked against the spec beside it), in external/amd/triton unless the case names its files. Triton
allocates LDS dynamically: a launch's dynamic_shared_bytes is metadata.shared.
"""
import argparse
import hashlib
import importlib.util
import json
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPOSITORY = ROOT.parents[2]
TARGET = ("hip", "gfx950", 64)
WAVE = 64
EPS = struct.unpack("f", struct.pack("f", 1e-5))[0]


@dataclass
class Case:
    """`kernel` names a function of `source` (an autotuned one compiles with the config in
    `constants` and `options`); `pointers` its pointer arguments in order, each an array of
    `arrays`, typed by `pointer_types` (default fp32); `scalars` its other runtime arguments, as
    launch-file parameters. `files` is its output files' stem in the repository, `spec` beside
    them."""

    kernel: str
    description: str
    constants: dict
    pointers: list
    arrays: list
    grid: int
    spec: str
    dims: dict
    scalars: list = field(default_factory=list)
    signature: dict = field(default_factory=dict)
    options: dict = field(default_factory=lambda: {"num_warps": 4})
    source: str = "kernels.py"
    pointer_types: dict = field(default_factory=dict)
    files: str | None = None


def matmul(activation):
    m, n, k = 128, 64, 64
    block_m, block_n, block_k = 32, 64, 16
    return Case(
        kernel="matmul_kernel",
        description=f"matrix multiplication tutorial, fp32, {activation} after the K loop; "
                    f"M={m}, N={n}, K={k}, workgroup 0's {block_m}x{block_n} tile of C",
        constants=dict(
            M=m, N=n, K=k, stride_am=k, stride_ak=1, stride_bk=n, stride_bn=1, stride_cm=n,
            stride_cn=1, BLOCK_SIZE_M=block_m, BLOCK_SIZE_N=block_n, BLOCK_SIZE_K=block_k,
            GROUP_SIZE_M=8, ACTIVATION=activation,
        ),
        pointers=["a", "b", "c"],
        arrays=[
            dict(name="a", kind="in", dtype="f32", shape=[m, k]),
            dict(name="b", kind="in", dtype="f32", shape=[k, n]),
            dict(name="c", kind="out", dtype="f32", shape=[block_m, n]),
        ],
        grid=(m // block_m) * (n // block_n),
        spec="matmul" if activation == "none" else f"matmul_{activation}",
        dims=dict(M=m, N=n, K=k, TM=block_m),
        options={"num_warps": 4, "num_stages": 2, "matrix_instr_nonkdim": 16},
    )


BITDELTA = "../../bitwise/bitdelta_triton/upstream/binary_gemm_kernel.py"


def bitdelta(kernel, num_warps, grid):
    """BitDelta's upstream kernel under its first autotune config, as bitwise/bitdelta_triton
    compiles it for sm_90a, but with fp32 activations and output: the AMD frontend models no
    f16. Batch 0's arrays only, as there."""
    batch = dict(stride_batch_a=65536, stride_batch_b=2048, stride_batch_c=65536)
    return Case(
        kernel=kernel,
        description=f"BitDelta {kernel}, fp32 x times signs packed 32 per int32, its fp16 "
                    f"result stored as fp32; M=N=K=256, tile 16x256x64, workgroup 0's 16x256 "
                    f"tile of C",
        constants=dict(
            M=256, N=256, K=256, n_bits=32, stride_am=256, stride_ak=1, stride_bk=256,
            stride_bn=1, stride_cm=256, stride_cn=1, BLOCK_SIZE_M=16, BLOCK_SIZE_N=256,
            BLOCK_SIZE_K=64, GROUP_SIZE_M=8, ACTIVATION="",
            **(batch if kernel == "binary_bmm_kernel" else {}),
        ),
        pointers=["a", "b", "c"],
        arrays=[
            dict(name="a", kind="in", dtype="f32", shape=[256, 256]),
            dict(name="b", kind="in", dtype="i32", shape=[8, 256]),
            dict(name="c", kind="out", dtype="f32", shape=[16, 256]),
        ],
        grid=grid,
        spec="bitdelta",
        dims=dict(M=16, N=256, K=256, KW=8, NB=256, MA=256),
        options={"num_warps": num_warps, "num_stages": 3, "matrix_instr_nonkdim": 16},
        source=BITDELTA,
        pointer_types=dict(b_ptr="*i32"),
        files=f"external/bitwise/bitdelta_triton/{kernel}_amd",
    )


BINARY_GEMM = Case(
    kernel="binary_gemm_kernel",
    description="XOR-popcount binary GEMM (bitwise/triton_binary_gemm's), c[m, n] = sum_w popc(a[m, w] ^ b[n, w]); "
                "M=N=K=256 (8 words per row), workgroup 0's 16x256 tile of C",
    constants=dict(M=256, N=256, KW=8, stride_am=8, stride_bn=8, stride_cm=256,
                   BLOCK_M=16, BLOCK_N=256),
    pointers=["a", "b", "c"],
    arrays=[
        dict(name="a", kind="in", dtype="i32", shape=[256, 8]),
        dict(name="b", kind="in", dtype="i32", shape=[256, 8]),
        dict(name="c", kind="out", dtype="i32", shape=[16, 256]),
    ],
    grid=[16, 1],
    spec="binary_gemm",
    dims=dict(MA=256, N=256, KW=8, TM=16),
    options={"num_warps": 4, "num_stages": 1},
    pointer_types=dict(a_ptr="*i32", b_ptr="*i32", c_ptr="*i32"),
    files="external/bitwise/triton_binary_gemm/kernel_amd",
)


# Every case is workgroup 0 of its grid; its output arrays are what that workgroup writes.
CASES = {
    "vector_add": Case(
        kernel="add_kernel",
        description="vector addition tutorial, 4096 elements in blocks of 1024, workgroup 0's block",
        constants=dict(n_elements=4096, BLOCK_SIZE=1024),
        pointers=["x", "y", "output"],
        arrays=[
            dict(name="x", kind="in", dtype="f32", shape=[4096]),
            dict(name="y", kind="in", dtype="f32", shape=[4096]),
            dict(name="output", kind="out", dtype="f32", shape=[1024]),
        ],
        grid=4,
        spec="vector_add",
        dims=dict(N=4096, B=1024),
    ),
    "softmax": Case(
        kernel="softmax_kernel",
        description="fused softmax tutorial, 4 rows of 100 columns in 128-lane blocks, one "
                    "workgroup looping over every row",
        constants=dict(
            input_row_stride=100, output_row_stride=100, n_rows=4, n_cols=100, NUM_PROGRAMS=1,
            BLOCK_SIZE=128,
        ),
        pointers=["output", "x"],
        arrays=[
            dict(name="x", kind="in", dtype="f32", shape=[4, 100]),
            dict(name="output", kind="out", dtype="f32", shape=[4, 100]),
        ],
        grid=1,
        spec="softmax",
        dims=dict(R=4, C=100),
    ),
    "matmul": matmul("none"),
    "matmul_leaky_relu": matmul("leaky_relu"),
    "binary_gemm": BINARY_GEMM,
    "bitdelta_matmul": bitdelta("binary_matmul_kernel", 8, [16, 1]),
    "bitdelta_bmm": bitdelta("binary_bmm_kernel", 4, [16, 2]),
    "layer_norm": Case(
        kernel="layer_norm_fwd_kernel",
        description="layer normalization tutorial's forward pass, 4 rows of 100 columns in "
                    "64-lane blocks, eps f32(1e-5), workgroup 0's row",
        constants=dict(stride=100, N=100, BLOCK_SIZE=64),
        pointers=["x", "y", "w", "b", "mean", "rstd"],
        arrays=[
            dict(name="x", kind="in", dtype="f32", shape=[4, 100]),
            dict(name="y", kind="out", dtype="f32", shape=[1, 100]),
            dict(name="w", kind="in", dtype="f32", shape=[100]),
            dict(name="b", kind="in", dtype="f32", shape=[100]),
            dict(name="mean", kind="out", dtype="f32", shape=[1]),
            dict(name="rstd", kind="out", dtype="f32", shape=[1]),
        ],
        grid=4,
        spec="layer_norm",
        dims=dict(M=4, R=1, N=100),
        scalars=[dict(name="eps (f32 1e-5)", float=EPS)],
        signature=dict(eps="fp32"),
    ),
}
POINTER_NAMES = {
    "add_kernel": ["x_ptr", "y_ptr", "output_ptr"],
    "softmax_kernel": ["output_ptr", "input_ptr"],
    "matmul_kernel": ["a_ptr", "b_ptr", "c_ptr"],
    "layer_norm_fwd_kernel": ["X", "Y", "W", "B", "Mean", "Rstd"],
    "binary_gemm_kernel": ["a_ptr", "b_ptr", "c_ptr"],
    "binary_matmul_kernel": ["a_ptr", "b_ptr", "c_ptr"],
    "binary_bmm_kernel": ["a_ptr", "b_ptr", "c_ptr"],
}


def kernarg_params(case, pointer_names, kernarg_size):
    """The launch file's parameters, filling the argument buffer as Triton lays it out: the
    pointers, the runtime scalars, then its two scratch pointers (null), each 8-byte aligned."""
    params = [dict(name=name, ptr=array) for name, array in zip(pointer_names, case.pointers)]
    offset = 8 * len(params)
    for scalar in case.scalars:
        params.append(scalar)
        offset += 4
    for scratch in ("global_scratch", "profile_scratch"):
        if offset % 8:
            params.append(dict(name="padding", int=0))
            offset += 4
        params += [dict(name=f"{scratch} (low word, null)", int=0),
                   dict(name=f"{scratch} (high word, null)", int=0)]
        offset += 8
    if offset != kernarg_size:
        raise RuntimeError(f"{case.kernel}: {offset} argument bytes, descriptor says {kernarg_size}")
    return params


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    parser.add_argument("--out", type=Path, default=REPOSITORY,
                        help="directory to write into, laid out as the repository")
    args = parser.parse_args()

    import triton
    from triton.backends.compiler import GPUTarget
    from triton.compiler import ASTSource

    if triton.__version__ != "3.5.1":
        raise RuntimeError("Reproduction requires triton==3.5.1")
    modules = {}

    def load(source):
        if source not in modules:
            spec = importlib.util.spec_from_file_location(Path(source).stem, ROOT / source)
            modules[source] = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(modules[source])
        return modules[source]

    for name in args.cases or list(CASES):
        case = CASES[name]
        fn = getattr(load(case.source), case.kernel)
        if isinstance(fn, triton.runtime.Autotuner):
            fn = fn.fn
        source_sha256 = hashlib.sha256((ROOT / case.source).read_bytes()).hexdigest()
        signature = {arg: "constexpr" for arg in fn.arg_names}
        signature.update({p: "*fp32" for p in POINTER_NAMES[case.kernel]})
        signature.update(case.pointer_types)
        signature.update(case.signature)
        kernel = triton.compile(
            ASTSource(fn, signature, constexprs=case.constants),
            target=GPUTarget(*TARGET), options=case.options,
        )
        asm = kernel.asm["amdgcn"]
        stem = args.out / (case.files or f"external/amd/triton/{name}")
        stem.parent.mkdir(parents=True, exist_ok=True)
        stem.with_name(f"{stem.name}.s").write_text(asm)

        kernarg_size = next(
            int(line.split()[-1]) for line in asm.splitlines()
            if line.strip().startswith(".amdhsa_kernarg_size")
        )
        block = [WAVE * case.options["num_warps"], 1, 1]
        grid = ([case.grid] if isinstance(case.grid, int) else case.grid) + [1, 1]
        grid = grid[:3]
        metadata = dict(
            triton=triton.__version__, target=TARGET[1], source=case.source,
            constants=case.constants,
            options=case.options, shared=kernel.metadata.shared, kernel=kernel.metadata.name,
            grid=grid, block=block, source_sha256=source_sha256,
            asm_sha256=hashlib.sha256(asm.encode()).hexdigest(),
        )
        stem.with_name(f"{stem.name}.json").write_text(json.dumps(metadata, indent=2) + "\n")

        launch = dict(
            description=f"Triton {case.description}",
            kernel=kernel.metadata.name, grid=grid, block=block,
            dynamic_shared_bytes=kernel.metadata.shared, arrays=case.arrays,
            params=kernarg_params(case, POINTER_NAMES[case.kernel], kernarg_size),
            spec=f"{case.spec}.spec", dims=case.dims,
        )
        stem.with_name(f"{stem.name}.launch.json").write_text(json.dumps(launch, indent=2) + "\n")
        print(f"{name}: {len(asm)} assembly bytes, {kernel.metadata.shared} LDS bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
