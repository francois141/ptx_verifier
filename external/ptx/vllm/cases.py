"""vLLM kernels checked by Volta: what each case compiles, launches and checks.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`csrc/` unit of vLLM at the commit `external/ptx/sources/frameworks.txt` pins, compiled for
sm_100a by `external/ptx/extraction/survey.py` with vLLM's own flags; `symbol` is a substring
of its mangled name. The launch (grid, block, arguments) is the one the unit's host dispatch
makes for the case's shape, read from the source cited in `source`.
"""

import math
from dataclasses import dataclass, field

EPS = 9.999999974752427e-07  # f32(1e-6), the epsilon of vLLM's norm tests


@dataclass(frozen=True)
class Array:
    """`base`, when given, places the array: a case passes the tensor's own start as an
    `Int` address when the analyzed block touches only a slice of it."""

    name: str
    kind: str  # "in", "out" or "inout"
    dtype: str
    shape: tuple
    base: int | None = None


@dataclass(frozen=True)
class Ptr:
    array: str


@dataclass(frozen=True)
class Int:
    value: int
    name: str = ""


@dataclass(frozen=True)
class Float:
    value: float
    name: str = ""


NULL = Int(0, "nullptr")


@dataclass(frozen=True)
class Case:
    """`check` is the verdict the case expects: "ACCEPT" or "REJECT" against `spec`, or
    without one "VERIFIED"/"REJECTED" from the graph checks; "ABORT" an execution error."""

    name: str
    description: str
    source: str
    unit: str
    symbol: str | tuple  # substring(s) of the kernel's mangled name, all of them
    args: tuple
    arrays: tuple
    grid: tuple
    block: int
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    cta: tuple = (0, 0, 0)  # the block Volta analyzes


# ===== RMSNorm (csrc/layernorm_kernels.cu) =====

LAYERNORM = "csrc/layernorm_kernels.cu"
DTYPE_MANGLED = {"bf16": "N3c108BFloat16E", "f16": "N3c104HalfE"}


def rms_norm(name, hidden, dtype="bf16", weight=True, check="ACCEPT", note=""):
    """`rms_norm(out, input, weight, eps)` on one 2-D row: VEC = gcd(16 / sizeof, hidden),
    block = min(hidden / VEC, 1024) (fewer than 256 tokens), dispatch :222."""
    vec = math.gcd(8, hidden)
    weight_args = (Ptr("weight"), Int(0, "weight_stride")) if weight else (NULL, Int(0))
    arrays = [Array("input", "in", dtype, (1, hidden)), Array("out", "out", dtype, (1, hidden))]
    if weight:
        arrays.insert(1, Array("weight", "in", dtype, (hidden,)))
    return Case(
        name=name,
        description=f"rms_norm, {dtype}, 1 token of {hidden}, VEC_SIZE={vec}, "
                    f"{'' if weight else 'no '}weight{note}",
        source=f"{LAYERNORM}:15 (rms_norm_kernel), dispatch :222",
        unit=LAYERNORM,
        symbol=f"15rms_norm_kernelI{DTYPE_MANGLED[dtype]}Li{vec}ELi2ELb{int(weight)}E",
        args=(Ptr("out"), Ptr("input"), Int(hidden, "input_stride_d2"), Int(0), Int(0), Int(0),
              Int(0), *weight_args, Float(EPS, "epsilon"), Int(1, "num_tokens"),
              Int(hidden, "hidden_size")),
        arrays=tuple(arrays),
        grid=(1, 1, 1),
        block=min(hidden // vec, 1024),
        check=check,
        spec="rms_norm.spec" if weight else "rms_norm_no_weight.spec",
        dims={"T": 1, "N": hidden},
    )


def fused_add_rms_norm(name, hidden, width=8, check="ACCEPT", note=""):
    """`fused_add_rms_norm(input, residual, weight, eps)` in place on one row: width 8 when
    the pointers are 16-byte aligned and hidden a multiple of 8, else the generic width 0;
    block = min(hidden, 1024), dispatch :315."""
    return Case(
        name=name,
        description=f"fused_add_rms_norm, bf16, 1 token of {hidden}, width {width}{note}",
        source=f"{LAYERNORM}:{109 if width else 182} (fused_add_rms_norm_kernel), dispatch :315",
        unit=LAYERNORM,
        symbol=f"25fused_add_rms_norm_kernelI{DTYPE_MANGLED['bf16']}Li{width}ELb1E",
        args=(Ptr("input"), Int(hidden, "input_stride"), Ptr("residual"), Ptr("weight"),
              Float(EPS, "epsilon"), Int(1, "num_tokens"), Int(hidden, "hidden_size"),
              Int(hidden, "residual_stride")),
        arrays=(Array("input", "inout", "bf16", (1, hidden)),
                Array("residual", "inout", "bf16", (1, hidden)),
                Array("weight", "in", "bf16", (hidden,))),
        grid=(1, 1, 1),
        block=min(hidden, 1024),
        check=check,
        spec="fused_add_rms_norm.spec",
        dims={"T": 1, "N": hidden},
    )


OUT_BASE = 0x100000  # where a sliced output tensor starts, past the auto-placed arrays


def qk_rms_norm(name, batch, heads, kv_heads, head_dim, cta, check="ACCEPT", note=""):
    """`rms_norm(out, q, weight, eps)` on q = qkv[..., :heads * head_dim] viewed [batch, heads,
    head_dim] (a 3-D q/k norm): row strides head_dim and (heads + 2 kv_heads) head_dim, grid
    batch * heads; block `cta` normalizes head cta % heads of batch cta / heads into its row of
    the contiguous `out`, which the case registers alone."""
    vec = math.gcd(8, head_dim)
    stride3 = (heads + 2 * kv_heads) * head_dim
    b, h = divmod(cta, heads)
    row_bytes = head_dim * 2
    return Case(
        name=name,
        description=f"rms_norm, 3-D q of qkv, bf16, batch {batch} x {heads} heads of {head_dim} "
                    f"(row stride {stride3}), block {cta} = batch {b} head {h}, "
                    f"{head_dim // vec} threads{note}",
        source=f"{LAYERNORM}:36 (rms_norm_kernel NUM_DIMS == 3), dispatch :222",
        unit=LAYERNORM,
        symbol=f"15rms_norm_kernelI{DTYPE_MANGLED['bf16']}Li{vec}ELi3ELb1E",
        args=(Int(OUT_BASE, "out"), Ptr("qkv"), Int(head_dim, "input_stride_d2"),
              Int(stride3, "input_stride_d3"), Int(0), Int(heads, "input_shape_d2"), Int(0),
              Ptr("weight"), Int(0, "weight_stride"), Float(EPS, "epsilon"),
              Int(batch * heads, "num_tokens"), Int(head_dim, "hidden_size")),
        arrays=(Array("qkv", "in", "bf16", (batch, stride3)),
                Array("weight", "in", "bf16", (head_dim,)),
                Array("out", "out", "bf16", (head_dim,), base=OUT_BASE + cta * row_bytes)),
        grid=(batch * heads, 1, 1),
        block=min(head_dim // vec, 1024),
        check=check,
        spec="qk_rms_norm.spec",
        dims={"R": batch, "S": stride3, "D": head_dim, "B": b, "H": h},
        cta=(cta, 0, 0),
    )


# ===== Rotary embedding (csrc/pos_encoding_kernels.cu) =====

POS_ENCODING = "csrc/pos_encoding_kernels.cu"
Q_BASE, K_BASE = 0x200000, 0x300000  # where query and key start; a case registers one token


def rope(name, tokens, heads, kv_heads, head_size, cta, neox=True, check="ACCEPT", note=""):
    """`rotary_embedding(positions, query, key, head_size, cos_sin_cache, is_neox)` in place on
    bf16 query [tokens, heads, head_size] and key [tokens, kv_heads, head_size] with a bf16
    cache of rot_dim = head_size, positions[t] = t: grid tokens, block min(heads * rot / 2,
    512), dispatch :105. Block `cta` rotates token `cta`, whose query and key slices the case
    registers."""
    e = head_size // 2
    token = (lambda h: (h, 2, e)) if neox else (lambda h: (h, e, 2))
    q_row, k_row = heads * head_size * 2, kv_heads * head_size * 2
    return Case(
        name=name,
        description=f"rotary_embedding, {'NeoX' if neox else 'GPT-J'}, bf16, {tokens} tokens of "
                    f"{heads} q / {kv_heads} kv heads of {head_size}, block {cta}{note}",
        source=f"{POS_ENCODING}:78 (rotary_embedding_kernel), dispatch :105",
        unit=POS_ENCODING,
        symbol=f"23rotary_embedding_kernelI{DTYPE_MANGLED['bf16']}S2_Lb{int(neox)}E",
        args=(Ptr("positions"), Int(Q_BASE, "query"), Int(K_BASE, "key"), Ptr("cache"),
              Int(head_size, "rot_dim"), Int(heads * head_size, "query_stride"),
              Int(kv_heads * head_size, "key_stride"), Int(head_size, "head_stride"),
              Int(heads, "num_heads"), Int(kv_heads, "num_kv_heads"),
              Int(head_size, "head_size"), Int(0, "rope_dim_offset"), Int(0, "inverse")),
        arrays=(Array("positions", "index", "i64", (tokens,)),
                Array("cache", "in", "bf16", (tokens, 2, e)),
                Array("query", "inout", "bf16", token(heads), base=Q_BASE + cta * q_row),
                Array("key", "inout", "bf16", token(kv_heads), base=K_BASE + cta * k_row)),
        grid=(tokens, 1, 1),
        block=min(heads * head_size // 2, 512),
        check=check,
        spec="rope_neox.spec" if neox else "rope_gptj.spec",
        dims={"TWO": 2, "H": heads, "KH": kv_heads, "E": e, "PM": tokens, "P": cta},
        cta=(cta, 0, 0),
    )


# ===== Fused q/k RMSNorm + RoPE (csrc/fused_qknorm_rope_kernel.cu, TensorRT-LLM's) =====

QKNORM_ROPE = "csrc/fused_qknorm_rope_kernel.cu"
QKV_BASE = 0x400000  # where qkv starts; a case registers one token's q and k heads


def qk_norm_rope(name, tokens, nq, nk, nv, head_dim, cta, neox=True, check="ACCEPT", note=""):
    """`fused_qk_norm_rope(qkv, nq, nk, nv, head_dim, eps, q_weight, k_weight, cos_sin_cache,
    is_neox, positions)` in place on bf16 qkv [tokens, (nq + nk + nv) * head_dim] with a bf16
    cache of rot = head_dim and positions[t] = t, the base kernel (token_heads_per_warp 1 off
    sm_90): one warp per (token, q or k head), 256 threads, grid ceil(tokens (nq + nk) / 8),
    dispatch :626. With nq + nk = 8, block `cta` is token `cta`, whose q and k heads the case
    registers (v is neither read nor written)."""
    assert nq + nk == 8, "one token per block"
    e = head_dim // 2
    head = (lambda h: (h, 2, e)) if neox else (lambda h: (h, e, 2))
    weight = (2, e) if neox else (e, 2)
    row = (nq + nk + nv) * head_dim * 2
    q_at = QKV_BASE + cta * row
    return Case(
        name=name,
        description=f"fused_qk_norm_rope, {'NeoX' if neox else 'GPT-J'}, bf16, {tokens} tokens of "
                    f"{nq} q / {nk} k / {nv} v heads of {head_dim}, full rotary, block {cta}{note}",
        source=f"{QKNORM_ROPE}:104 (fusedQKNormRopeKernel), dispatch :626",
        unit=QKNORM_ROPE,
        symbol=f"21fusedQKNormRopeKernelI{DTYPE_MANGLED['bf16']}S3_Li{head_dim}ELb{int(not neox)}E",
        args=(Int(QKV_BASE, "qkv"), Int(nq, "num_heads_q"), Int(nk, "num_heads_k"),
              Int(nv, "num_heads_v"), Float(EPS, "eps"), Ptr("qw"), Ptr("kw"), Ptr("cache"),
              Ptr("positions"), Int(tokens, "num_tokens"), Int(head_dim, "rotary_dim")),
        arrays=(Array("positions", "index", "i64", (tokens,)),
                Array("cache", "in", "bf16", (tokens, 2, e)),
                Array("qw", "in", "bf16", weight),
                Array("kw", "in", "bf16", weight),
                Array("q", "inout", "bf16", head(nq), base=q_at),
                Array("k", "inout", "bf16", head(nk), base=q_at + nq * head_dim * 2)),
        grid=(-(-tokens * (nq + nk) // 8), 1, 1),
        block=256,
        check=check,
        spec="qk_norm_rope_neox.spec" if neox else "qk_norm_rope_gptj.spec",
        dims={"TWO": 2, "HQ": nq, "HK": nk, "E": e, "D": head_dim, "PM": tokens, "P": cta},
        cta=(cta, 0, 0),
    )


# ===== Gated activations (csrc/activation_kernels.cu) =====

ACTIVATION = "csrc/activation_kernels.cu"


def act_and_mul(name, d, tokens=1, act_first=True, check="ACCEPT", note=""):
    """`silu_and_mul(out, input)` (`mul_and_silu` without `act_first`) on bf16 rows [x | y]:
    the 128-bit vector path when d % 8 == 0 (block min(d / 8, 1024)), the 256-bit one with
    more than 128 tokens on sm_100 (d % 16, block min(d / 16, 1024)), else the scalar path
    (block min(d, 1024)); dispatch :244. Workgroup 0 computes token 0."""
    b256 = tokens > 128 and d % 16 == 0
    vec = 16 if b256 else 8
    use_vec = d % vec == 0
    path = "256-bit" if b256 else "128-bit" if use_vec else "scalar"
    return Case(
        name=name,
        description=f"{'silu_and_mul' if act_first else 'mul_and_silu'}, bf16, {tokens} "
                    f"token(s) of d={d}, {path} path{note}",
        source=f"{ACTIVATION}:110 (act_and_mul_kernel), dispatch :244",
        unit=ACTIVATION,
        symbol=(f"18act_and_mul_kernelI{DTYPE_MANGLED['bf16']}",
                f"11silu_kernelIS2_EET_RKS5_fEEXadL_ZNS_18packed_silu_kernelIS3_EES5_S7_fEE"
                f"Lb{int(act_first)}ELb{int(use_vec)}ELb0ELb{int(b256)}E"),
        args=(Ptr("out"), Ptr("input"), Int(d, "d"), Float(0.0, "limit"), Float(1.0, "alpha"),
              Float(0.0, "beta")),
        arrays=(Array("input", "in", "bf16", (tokens, 2, d)), Array("out", "out", "bf16", (1, d))),
        grid=(tokens, 1, 1),
        block=min(d // vec if use_vec else d, 1024),
        check=check,
        spec="silu_and_mul.spec" if act_first else "mul_and_silu.spec",
        dims={"T": 1, "S": 2, "D": d},
    )


CASES = (
    rms_norm("rms_norm_4096", 4096),
    rms_norm("rms_norm_100", 100, note=" (25 threads)"),
    rms_norm("rms_norm_4096_no_weight", 4096, weight=False),
    rms_norm("rms_norm_f16_2048", 2048, dtype="f16"),
    fused_add_rms_norm("fused_add_rms_norm_4096", 4096),
    fused_add_rms_norm("fused_add_rms_norm_generic_100", 100, width=0),
    qk_rms_norm("qk_rms_norm_last_head", 2, 4, 2, 128, cta=7),
    qk_rms_norm("qk_rms_norm_head_1", 2, 4, 2, 128, cta=1),
    rope("rope_neox_gqa", 4, 8, 2, 128, cta=3),
    rope("rope_gptj_gqa", 4, 8, 2, 128, cta=2, neox=False),
    rope("rope_neox_mha_64", 2, 4, 4, 64, cta=1),
    qk_norm_rope("qk_norm_rope_neox_128", 4, 6, 2, 2, 128, cta=3),
    qk_norm_rope("qk_norm_rope_gptj_128", 4, 6, 2, 2, 128, cta=1, neox=False),
    qk_norm_rope("qk_norm_rope_neox_64", 2, 4, 4, 4, 64, cta=1),
    qk_norm_rope("qk_norm_rope_neox_256", 2, 4, 4, 4, 256, cta=0),
    act_and_mul("silu_and_mul_4096", 4096),
    act_and_mul("silu_and_mul_256b_4096", 4096, tokens=129, note=" (token 0 of 129)"),
    act_and_mul("silu_and_mul_scalar_100", 100),
    act_and_mul("mul_and_silu_4096", 4096, act_first=False),
)
