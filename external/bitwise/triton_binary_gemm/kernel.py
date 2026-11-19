"""Binary XOR-popcount GEMM in Triton: c[m, n] = sum_w popc(a[m, w] ^ b[n, w]).

A holds M rows and B holds N rows of KW packed 32-bit words (K = 32 * KW bits),
so each output is the Hamming distance between a row of A and a row of B.
"""
import triton
import triton.language as tl
from triton.language.extra import libdevice


@triton.jit
def binary_gemm_kernel(
    a_ptr, b_ptr, c_ptr,
    M, N, KW,
    stride_am, stride_bn, stride_cm,
    BLOCK_M: tl.constexpr, BLOCK_N: tl.constexpr,
):
    rm = tl.program_id(0) * BLOCK_M + tl.arange(0, BLOCK_M)
    rn = tl.program_id(1) * BLOCK_N + tl.arange(0, BLOCK_N)
    acc = tl.zeros((BLOCK_M, BLOCK_N), dtype=tl.int32)
    for w in range(KW):
        a = tl.load(a_ptr + rm * stride_am + w, mask=rm < M, other=0)
        b = tl.load(b_ptr + rn * stride_bn + w, mask=rn < N, other=0)
        acc += libdevice.popc(a[:, None] ^ b[None, :])
    c = c_ptr + rm[:, None] * stride_cm + rn[None, :]
    tl.store(c, acc, mask=(rm[:, None] < M) & (rn[None, :] < N))
