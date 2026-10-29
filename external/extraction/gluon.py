# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Compile the 14 Gluon tutorials of Triton 3.9.0 to PTX for Blackwell (sm_100a).

    uv run external/extraction/gluon.py                      # every tutorial
    uv run external/extraction/gluon.py 06-tcgen05.py        # some tutorials (names or paths)
    uv run external/extraction/gluon.py --jobs 2 --timeout 600

The tutorials (`python/tutorials/gluon/` at `TRITON_TAG`) are downloaded once
into `external/sources/gluon/<tag>/`. Each runs as a module, not as
`__main__` (whose benchmarks launch GPU-sized problems), and then the calls of
its `SIZES`, each a call of the tutorial's own test or wrapper at a size small
enough for Volta, in its namespace; every launch is compiled instead of run
(`triton_capture.py`) and becomes a Volta launch file
`<kernel>.<size>.launch.json` under `external/gluon/<tutorial stem>/`. Host
tensor descriptors become their TMA maps; 05-wgmma is Hopper-only and compiles
for sm_90a. `--summary` (by default `external/output/gluon_extraction.csv`)
says how each tutorial went, including the launches no launch file can express
(clusters of CTAs).
"""

import urllib.request
from pathlib import Path

import triton_capture

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
TRITON_VERSION = "3.9.0"
TRITON_TAG = f"v{TRITON_VERSION}"
TUTORIALS_URL = f"https://raw.githubusercontent.com/triton-lang/triton/{TRITON_TAG}/python/tutorials/gluon"
TUTORIALS_DIR = EXTERNAL_ROOT / "sources" / "gluon" / TRITON_TAG


def tensors(*shapes: str, dtype: str = "float16") -> str:
    """Random `cuda` tensors of `shapes`, as a call's arguments."""
    return ", ".join(f"torch.randn({shape}, device='cuda', dtype=torch.{dtype})" for shape in shapes)


def gemm_operands(m: int, n: int, k: int) -> str:
    """`A [m, k]`, `B [k, n]` and an empty `C [m, n]` in fp16, as a call's arguments."""
    c = f"torch.empty({m}, {n}, device='cuda', dtype=torch.float16)"
    return f"{tensors(f'{m}, {k}', f'{k}, {n}')}, {c}"


# Size label -> a call of the tutorial's own test (`assert_close` is a no-op) or wrapper, at
# about one tile per CTA, keeping the tests' constexpr configurations.
SIZES = {
    "01-intro.py": {
        "scalar": "test_copy_scalar()",
        "n40": "test_memcpy(XBLOCK=64, xnumel=40)",
        "n256": f"memcpy_autotune({tensors('256', dtype='float32')}, torch.empty(256, device='cuda'))",
    },
    "02-layouts.py": {
        "n200": "test_memcpy_1d(XBLOCK=128, xnumel=200, num_warps=4)",
        "100x200": "test_memcpy_2d(XBLOCK=128, YBLOCK=256, xnumel=100, ynumel=200, transposed=False, num_warps=4)",
        "100x200T": "test_memcpy_2d(XBLOCK=128, YBLOCK=256, xnumel=100, ynumel=200, transposed=True, num_warps=4)",
        "128x128_inT": "test_memcpy_2d_inout(xnumel=128, ynumel=128, transpose_in=True, transpose_out=False)",
        "128x128_outT": "test_memcpy_2d_inout(xnumel=128, ynumel=128, transpose_in=False, transpose_out=True)",
    },
    "03-async-copy.py": {
        "n200": "test_memcpy_1d_cpasync(xnumel=200, XBLOCK=128)",
        "32x32": "test_elementwise_add(xnumel=32, ynumel=32, XBLOCK=32, YBLOCK=32)",
        "cpasync_32x32": "test_elementwise_add_cpasync(xnumel=32, ynumel=32, XBLOCK=32, YBLOCK=32)",
        **{
            f"32x192_b{b}": f"test_elementwise_add_pipelined(xnumel=32, ynumel=192, XBLOCK=32, YBLOCK=64, num_buffers={b})"
            for b in (1, 2, 3)
        },
    },
    "04-tma.py": {
        "n40": "test_memcpy_1d_tma(XBLOCK=64, xnumel=40)",
        "message16": "test_tma_message_passing(MESSAGE_SIZE=16)",
        **{
            f"32x192_b{b}": f"test_elementwise_add_pipelined(xnumel=32, ynumel=192, XBLOCK=32, YBLOCK=64, num_buffers={b})"
            for b in (1, 2, 3)
        },
    },
    "05-wgmma.py": {
        "64x32x32": "test_small_mma(M=64, N=32, K=32, LHS_IN_REG=False, INSTR_SHAPE_N=16, num_warps=4)",
        "64x64x64": "test_blocked_matmul(M=64, N=64, K=64, BLOCK_M=64, BLOCK_N=64, BLOCK_K=64, TRANSPOSE_B=False, num_warps=4)",
        "64x64x192": "test_blocked_matmul_pipelined(M=64, N=64, K=192, BLOCK_M=64, BLOCK_N=64, BLOCK_K=64, num_warps=4)",
    },
    "06-tcgen05.py": {
        "tmem_64x64": "test_tmem_example_kernel(M=64, N=64, num_warps=4)",
        "64x128x128": "test_small_mma(M=64, N=128, K=128, LHS_IN_TMEM=False, USE_COMMIT=True, num_warps=4)",
        "64x64": "test_blocked_matmul(M=64, N=64, K=64, BLOCK_M=64, BLOCK_N=64, BLOCK_K=64, TRANSPOSE_B=False, num_warps=4)",
        "128x64x192": "test_blocked_matmul_pipelined(M=128, N=64, K=192, BLOCK_M=64, BLOCK_N=64, BLOCK_K=64, num_warps=4)",
    },
    "07-persistence.py": {
        "128x256x128": "test_pipelined_matmul(M=128, N=256, K=128, BLOCK_M=128, BLOCK_N=256, BLOCK_K=64, num_buffers=2, num_warps=4)",
        "persistent_128x256x128": (
            "test_persistent_matmul(M=128, N=256, K=128, BLOCK_M=128, BLOCK_N=256, BLOCK_K=64, num_buffers=2,"
            " num_warps=4, SchedulerImpl=schedulers[0])"
        ),
        "persistent_128x128x192": (
            "test_persistent_matmul_pipelined(M=128, N=128, K=192, BLOCK_M=64, BLOCK_N=64, BLOCK_K=64, num_buffers=3,"
            " num_warps=4, SchedulerImpl=schedulers[0])"
        ),
    },
    "08-warp-specialization.py": {
        "add_32x128": (
            "test_elementwise_add_warp_specialized(xnumel=32, ynumel=128, XBLOCK=32, YBLOCK=64, num_load_buffers=1,"
            " num_store_buffers=1, num_warps=4)"
        ),
        "matmul_128x256x128": (
            "test_matmul_warp_specialized(M=128, N=256, K=128, BLOCK_M=128, BLOCK_N=256, BLOCK_K=64, num_buffers=2,"
            " SUBTILE_FACTOR=4, num_warps=4, SchedulerImpl=t7.schedulers[0])"
        ),
    },
    # The tests take a pytest fixture, so the wrappers are called directly.
    "09-tma-gather-scatter.py": {
        "gather_8x16": (
            f"async_gather({tensors('64, 64', dtype='bfloat16')}, torch.arange(8, dtype=torch.int32, device='cuda'),"
            " 0, 8, 16)"
        ),
        "scatter_8x16": (
            f"async_scatter({tensors('64, 64', dtype='bfloat16')}, torch.arange(8, dtype=torch.int32, device='cuda'),"
            f" 0, {tensors('8, 16', dtype='bfloat16')}, 8, 16)"
        ),
        "matmul_128x128x128": (
            "test_matmul_fused_gather_scatter(M=128, N=128, K=128, BLOCK_M=128, BLOCK_N=128, BLOCK_K=64, num_buffers=3)"
        ),
    },
    "10-tcgen05-copy.py": {
        "copy_128x32": "test_tcgen05_copy_nvmma_shared(M=128, N=32, TMEM_BLOCK_N=32, dtype=torch.float32, swizzle=128)",
        "matmul_128x128x128": (
            "test_matmul_accumulate(M=128, N=128, K=128, BLOCK_M=128, BLOCK_N=128, BLOCK_K=64, num_buffers=3,"
            " dtype=torch.float16)"
        ),
    },
    "11-tcgen05-mma-scaled.py": {
        **{
            f"{name}_128x128x128": (
                f"{test}(M=128, N=128, K=128, a_format='mxfp8', b_format='mxfp8', BLOCK_N=128, BLOCK_K=128)"
            )
            for name, test in (
                ("simple", "test_simple_mma_scaled"),
                ("contig", "test_mma_scaled_contig"),
                ("packed", "test_mma_scaled_packed_block"),
                ("copy", "test_mma_scaled_tcgen05_copy"),
            )
        },
        **{
            f"{name}_128x128x128": (
                f"test_mma_scaled_pipelined(M=128, N=128, K=128, a_format='mxfp8', b_format='mxfp8', impl_kernel={kernel})"
            )
            for name, kernel in (
                ("pipelined", "mma_scaled_pipelined_kernel"),
                ("ws", "mma_scaled_warp_specialized_kernel"),
            )
        },
    },
    # The test's sizes are GPU-sized, so the wrapper is called directly.
    "12-cluster-launch-control.py": {
        "clc_256x256x128": f"run_matmul_kernel({gemm_operands(256, 256, 128)}, use_clc=True)",
        "static_256x256x128": f"run_matmul_kernel({gemm_operands(256, 256, 128)}, use_clc=False)",
    },
    "13-conv-im2col.py": {
        "im2col_4x4": "test_tma_im2col_simple()",
        "1x16x16x64": "test_conv2d_tma_im2col(N=1, H=16, W=16, Ci=64, Co=64, R=1, S=1, stride=1, padding=0)",
    },
    # All but the softmax launch clusters of CTAs, which no launch file expresses.
    "14-multicta.py": {
        "softmax_2x64": "test_multicta_softmax_f32(M=2, N=64)",
        "two_cta_tcgen05": "test_two_cta_tcgen05()",
        "tma_multicast": "test_tma_multicast_copy()",
        "tma_tcgen05": "test_tma_tcgen05()",
        "matmul": "test_matmul_multicta()",
    },
}


def fetch_tutorials() -> None:
    """Download the tutorials that are not there yet (they import one another)."""
    for name in SIZES:
        path = TUTORIALS_DIR / name
        if not path.exists():
            TUTORIALS_DIR.mkdir(parents=True, exist_ok=True)
            with urllib.request.urlopen(f"{TUTORIALS_URL}/{name}") as response:
                path.write_bytes(response.read())


SUITE = triton_capture.Suite(
    name="Gluon tutorial",
    slug="gluon",
    script=Path(__file__),
    sources=TUTORIALS_DIR,
    out=EXTERNAL_ROOT / "gluon",
    summary=EXTERNAL_ROOT / "output" / "gluon_extraction.csv",
    sizes=SIZES,
    triton_version=TRITON_VERSION,
    torch_version="2.15.0",
    pip_extras=("numpy", "pytest"),
    run_as_main=False,
    sibling_imports=True,
    capabilities={"05-wgmma.py": 90},
    index_args={"09-tma-gather-scatter.py": frozenset({"x_offsets_ptr", "X_gather_indx_ptr", "out_scatter_indx_ptr"})},
    fetch=fetch_tutorials,
)

if __name__ == "__main__":
    triton_capture.main(SUITE, __doc__, sorted(SIZES))
