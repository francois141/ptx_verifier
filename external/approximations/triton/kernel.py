"""A Triton GEMM with a fused activation, after the matrix multiplication tutorial: c = act(a @ b^T),
a [M, K] row-major, b stored as N rows of K (a column-major K x N matrix), c [M, N] row-major.

Each program computes a BLOCK_M x BLOCK_N tile over the whole K with tl.dot (TF32 tensor cores for
fp32 operands) and applies ACTIVATION, one of the activations below, before the store. tanh is the
tanh.approx.f32 instruction (as Liger-Kernel's GELU takes it); tl.log, like the *_libdevice and erf
activations, is libdevice's software function, and softplus_fast takes its fast_logf (lg2.approx).
"""
import triton
import triton.language as tl
from triton.language.extra import libdevice

ACTIVATIONS = (
    "relu", "leaky_relu", "hardtanh", "hardsigmoid", "hardswish", "softshrink", "elu", "celu",
    "selu", "gelu_tanh", "gelu_tanh_libdevice", "gelu_erf", "sigmoid", "silu", "tanh", "softplus",
    "softplus_fast", "softplus_threshold",
)


@triton.jit
def tanh_approx(x):
    return tl.inline_asm_elementwise(
        "tanh.approx.f32 $0, $1;", "=r,r", [x], dtype=tl.float32, is_pure=True, pack=1
    )


@triton.jit
def activation(x, ACTIVATION: tl.constexpr):
    if ACTIVATION == "relu":
        y = tl.maximum(x, 0.0)
    elif ACTIVATION == "leaky_relu":
        y = tl.where(x > 0, x, 0.01 * x)
    elif ACTIVATION == "hardtanh":
        y = tl.minimum(tl.maximum(x, -1.0), 1.0)
    elif ACTIVATION == "hardsigmoid":
        y = tl.minimum(tl.maximum(x + 3.0, 0.0), 6.0) * (1.0 / 6.0)
    elif ACTIVATION == "hardswish":
        y = x * tl.minimum(tl.maximum(x + 3.0, 0.0), 6.0) * (1.0 / 6.0)
    elif ACTIVATION == "softshrink":
        y = tl.where(x > 0.5, x - 0.5, tl.where(x < -0.5, x + 0.5, 0.0))
    elif ACTIVATION == "elu":
        y = tl.where(x > 0, x, tl.exp(x) - 1.0)
    elif ACTIVATION == "celu":
        y = tl.where(x > 0, x, 2.0 * (tl.exp(x * 0.5) - 1.0))
    elif ACTIVATION == "selu":
        y = tl.where(x > 0, 1.0507009873554805 * x, 1.7580993175506592 * (tl.exp(x) - 1.0))
    elif ACTIVATION == "gelu_tanh":
        y = 0.5 * x * (1.0 + tanh_approx(0.7978845608028654 * (x + 0.044715 * x * x * x)))
    elif ACTIVATION == "gelu_tanh_libdevice":
        y = 0.5 * x * (1.0 + libdevice.tanh(0.7978845608028654 * (x + 0.044715 * x * x * x)))
    elif ACTIVATION == "gelu_erf":
        y = 0.5 * x * (1.0 + libdevice.erf(x * 0.7071067811865476))
    elif ACTIVATION == "sigmoid":
        y = tl.sigmoid(x)
    elif ACTIVATION == "silu":
        y = x * tl.sigmoid(x)
    elif ACTIVATION == "tanh":
        y = tanh_approx(x)
    elif ACTIVATION == "softplus":
        y = tl.log(1.0 + tl.exp(x))
    elif ACTIVATION == "softplus_fast":
        y = libdevice.fast_logf(1.0 + tl.exp(x))
    elif ACTIVATION == "softplus_threshold":
        y = tl.where(x > 20.0, x, libdevice.fast_logf(1.0 + tl.exp(x)))
    else:
        tl.static_assert(ACTIVATION == "none", "unknown activation")
        y = x
    return y


@triton.jit
def fused_gemm_kernel(
    a_ptr, b_ptr, c_ptr,
    M, N, K,
    stride_am, stride_ak, stride_bn, stride_bk, stride_cm, stride_cn,
    BLOCK_M: tl.constexpr, BLOCK_N: tl.constexpr, BLOCK_K: tl.constexpr,
    ACTIVATION: tl.constexpr,
):
    pid_m = tl.program_id(0)
    pid_n = tl.program_id(1)
    rm = pid_m * BLOCK_M + tl.arange(0, BLOCK_M)
    rn = pid_n * BLOCK_N + tl.arange(0, BLOCK_N)
    rk = tl.arange(0, BLOCK_K)
    a_ptrs = a_ptr + rm[:, None] * stride_am + rk[None, :] * stride_ak
    b_ptrs = b_ptr + rk[:, None] * stride_bk + rn[None, :] * stride_bn
    acc = tl.zeros((BLOCK_M, BLOCK_N), dtype=tl.float32)
    for k in range(0, tl.cdiv(K, BLOCK_K)):
        a = tl.load(a_ptrs, mask=rk[None, :] < K - k * BLOCK_K, other=0.0)
        b = tl.load(b_ptrs, mask=rk[:, None] < K - k * BLOCK_K, other=0.0)
        acc = tl.dot(a, b, acc)
        a_ptrs += BLOCK_K * stride_ak
        b_ptrs += BLOCK_K * stride_bk
    c = activation(acc, ACTIVATION)
    c_ptrs = c_ptr + rm[:, None] * stride_cm + rn[None, :] * stride_cn
    tl.store(c_ptrs, c, mask=(rm[:, None] < M) & (rn[None, :] < N))
