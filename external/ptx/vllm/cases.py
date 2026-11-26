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
    contents: tuple | None = None  # a 4-byte `index` array's elements (else element i is i)


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
    smem: int = 0  # dynamic shared memory bytes


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


def qk_norm_rope(name, tokens, nq, nk, nv, head_dim, cta, neox=True, check="ACCEPT", note="",
                 rotary=None):
    """`fused_qk_norm_rope(qkv, nq, nk, nv, head_dim, eps, q_weight, k_weight, cos_sin_cache,
    is_neox, positions)` in place on bf16 qkv [tokens, (nq + nk + nv) * head_dim] with a bf16
    cache of rot = head_dim and positions[t] = t, the base kernel (token_heads_per_warp 1 off
    sm_90): one warp per (token, q or k head), 256 threads, grid ceil(tokens (nq + nk) / 8),
    dispatch :626. With nq + nk = 8, block `cta` is token `cta`, whose q and k heads the case
    registers (v is neither read nor written)."""
    assert nq + nk == 8, "one token per block"
    rotary = rotary or head_dim
    e = head_dim // 2
    partial = rotary != head_dim
    if partial:
        head = (lambda h: (h, head_dim)) if neox else (lambda h: (h, e, 2))
        weight = (head_dim,) if neox else (e, 2)
        cache = (tokens, rotary) if neox else (tokens, 2, rotary // 2)
    else:
        head = (lambda h: (h, 2, e)) if neox else (lambda h: (h, e, 2))
        weight = (2, e) if neox else (e, 2)
        cache = (tokens, 2, e)
    row = (nq + nk + nv) * head_dim * 2
    q_at = QKV_BASE + cta * row
    return Case(
        name=name,
        description=f"fused_qk_norm_rope, {'NeoX' if neox else 'GPT-J'}, bf16, {tokens} tokens of "
                    f"{nq} q / {nk} k / {nv} v heads of {head_dim}, rotary dim {rotary}, "
                    f"block {cta}{note}",
        source=f"{QKNORM_ROPE}:104 (fusedQKNormRopeKernel), dispatch :626",
        unit=QKNORM_ROPE,
        symbol=f"21fusedQKNormRopeKernelI{DTYPE_MANGLED['bf16']}S3_Li{head_dim}ELb{int(not neox)}E",
        args=(Int(QKV_BASE, "qkv"), Int(nq, "num_heads_q"), Int(nk, "num_heads_k"),
              Int(nv, "num_heads_v"), Float(EPS, "eps"), Ptr("qw"), Ptr("kw"), Ptr("cache"),
              Ptr("positions"), Int(tokens, "num_tokens"), Int(rotary, "rotary_dim")),
        arrays=(Array("positions", "index", "i64", (tokens,)),
                Array("cache", "in", "bf16", cache),
                Array("qw", "in", "bf16", weight),
                Array("kw", "in", "bf16", weight),
                Array("q", "inout", "bf16", head(nq), base=q_at),
                Array("k", "inout", "bf16", head(nk), base=q_at + nq * head_dim * 2)),
        grid=(-(-tokens * (nq + nk) // 8), 1, 1),
        block=256,
        check=check,
        spec=f"qk_norm_rope_{'neox' if neox else 'gptj'}{'_partial' if partial else ''}.spec",
        dims=({"HQ": nq, "HK": nk, "D": head_dim, "R": rotary, "RH": rotary // 2,
               "PM": tokens, "P": cta} if partial and neox else
              {"TWO": 2, "HQ": nq, "HK": nk, "D": head_dim, "D2": e, "RH": rotary // 2,
               "PM": tokens, "P": cta} if partial else
              {"TWO": 2, "HQ": nq, "HK": nk, "E": e, "D": head_dim, "PM": tokens, "P": cta}),
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
    qk_norm_rope("qk_norm_rope_neox_partial_64", 2, 6, 2, 2, 128, cta=1, rotary=64),
    qk_norm_rope("qk_norm_rope_gptj_partial_64", 2, 6, 2, 2, 128, cta=1, neox=False, rotary=64),
    # rotary_dim not a multiple of head_dim / 16: the lanes split the rotation at the wrong
    # dimension. TensorRT-LLM's launcher rejects such a rotary_dim; vLLM's does not.
    qk_norm_rope("qk_norm_rope_neox_partial_20", 2, 6, 2, 2, 128, cta=1, rotary=20,
                 check="REJECT", note=" (unsupported rotary_dim, unchecked)"),
    qk_norm_rope("qk_norm_rope_gptj_partial_22", 2, 6, 2, 2, 128, cta=1, neox=False, rotary=22,
                 check="REJECT", note=" (unsupported rotary_dim, unchecked)"),
    act_and_mul("silu_and_mul_4096", 4096),
    act_and_mul("silu_and_mul_256b_4096", 4096, tokens=129, note=" (token 0 of 129)"),
    act_and_mul("silu_and_mul_scalar_100", 100),
    act_and_mul("mul_and_silu_4096", 4096, act_first=False),
)


# ===== MoE top-k reduce and block alignment (csrc/moe/moe_align_sum_kernels.cu) =====

MOE = "csrc/moe/moe_align_sum_kernels.cu"
SCALAR_MANGLED = {**DTYPE_MANGLED, "f32": "f"}
SCALAR_BYTES = {"bf16": 2, "f16": 2, "f32": 4}
VEC_TOPK = (1, 2, 4, 6, 8, 9)  # the topks moe_sum templates (dispatch :964, :899)


def moe_sum(name, tokens, topk, hidden, cta=0, dtype="bf16", topk_ids=None, expert_map=None,
            idx="i", check="ACCEPT", note=""):
    """`moe_sum(input [tokens, topk, hidden], output [tokens, hidden], topk_ids, expert_map)`
    on a contiguous input: the 16-byte vector path when hidden % VEC == 0 (block 256, grid
    ceil(tokens * hidden / VEC / 256), one vector per thread), templated on topk in
    `VEC_TOPK` else the runtime-topk kernel; dispatch :949 (pad-aware with topk_ids :876).
    Block `cta` writes out's flattened elements [cta * 256 VEC, (cta + 1) * 256 VEC). With
    `topk_ids` (one token's ids, int32 `contents`) the slots whose id is < 0 or maps to -1 in
    `expert_map` are skipped; an int64 `idx` has ids 0..topk-1 (Volta gives no contents)."""
    vec = 16 // SCALAR_BYTES[dtype]
    assert hidden % vec == 0
    total = tokens * hidden // vec
    grid = min(-(-total // 256), 65535)
    pad = topk_ids is not None or idx == "l"
    ids = topk_ids if topk_ids is not None else tuple(range(topk))
    skipped = [k for k in range(topk)
               if ids[k] < 0 or (expert_map is not None and expert_map[ids[k]] < 0)]
    assert len(skipped) <= 2 and (not pad or tokens == 1)
    skipped += [topk] * (2 - len(skipped))
    mangled = SCALAR_MANGLED[dtype]
    templated = topk in VEC_TOPK
    symbol = (f"18moe_sum_vec_kernelI{mangled}{idx}Li{topk}ELb{int(pad)}E" if templated else
              f"26moe_sum_vec_dynamic_kernelI{mangled}{idx}Lb{int(pad)}E")
    tk_args = ((Ptr("topk_ids"), Ptr("expert_map") if expert_map is not None else NULL,
                Int(topk, "stride_tk_token"), Int(1, "stride_tk_k")) if pad else
               (NULL, NULL, Int(0), Int(0)))
    arrays = [Array("input", "in", dtype, (tokens, topk, hidden)),
              Array("out", "out", dtype, (tokens, hidden))]
    if pad:
        arrays.append(Array("topk_ids", "index", "i32" if idx == "i" else "i64", (tokens, topk),
                            contents=tuple(ids) if idx == "i" else None))
    if expert_map is not None:
        arrays.append(Array("expert_map", "index", "i32", (len(expert_map),),
                            contents=tuple(expert_map)))
    lo, hi = cta * 256 * vec, min((cta + 1) * 256, total) * vec
    return Case(
        name=name,
        description=f"moe_sum, {dtype}, {tokens} token(s) x topk {topk} x {hidden}, "
                    f"{'templated' if templated else 'runtime'}-topk vector path, block {cta} "
                    f"of {grid}{', pad-aware' if pad else ''}{note}",
        source=f"{MOE}:{420 if templated else 467} (moe_sum_vec{'' if templated else '_dynamic'}"
               f"_kernel), dispatch :{876 if pad else 949}",
        unit=MOE,
        symbol=symbol,
        args=(Ptr("out"), Ptr("input"), Int(tokens, "num_tokens"), Int(hidden, "d"),
              *(() if templated else (Int(topk, "topk"),)),
              Int(topk * hidden, "stride_token"), Int(hidden, "stride_topk"), *tk_args),
        arrays=tuple(arrays),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec="moe_sum.spec",
        dims={"T": tokens, "K": topk, "D": hidden, "LO": lo, "HI": hi,
              "S0": skipped[0], "S1": skipped[1]},
        cta=(cta, 0, 0),
    )


def moe_sum_scalar(name, tokens, topk, hidden, cta, dtype="bf16", stride_token=None,
                   check="ACCEPT", note=""):
    """`moe_sum` through the stride-aware scalar kernel, taken when the vector path cannot
    (hidden % VEC != 0, or a token stride not a whole number of vectors): grid tokens,
    block min(hidden, 1024), dispatch :994. Block `cta` computes token `cta`."""
    st = stride_token or topk * hidden
    return Case(
        name=name,
        description=f"moe_sum, {dtype}, {tokens} tokens x topk {topk} x {hidden}, token stride "
                    f"{st}, scalar path, block {cta}{note}",
        source=f"{MOE}:513 (moe_sum_scalar_kernel), dispatch :994",
        unit=MOE,
        symbol=f"21moe_sum_scalar_kernelI{SCALAR_MANGLED[dtype]}iLb0E",
        args=(Ptr("out"), Ptr("input"), Int(hidden, "d"), Int(topk, "topk"),
              Int(st, "stride_token"), Int(hidden, "stride_topk"), Int(1, "stride_hidden"),
              NULL, NULL, Int(0), Int(0)),
        arrays=(Array("input", "in", dtype, (tokens, st)),
                Array("out", "out", dtype, (tokens, hidden))),
        grid=(tokens, 1, 1),
        block=min(hidden, 1024),
        check=check,
        spec="moe_sum_strided.spec",
        dims={"T": tokens, "K": topk, "D": hidden, "ST": st, "P": cta},
        cta=(cta, 0, 0),
    )


CASES += (
    moe_sum("moe_sum_topk8_2048", 1, 8, 2048),
    moe_sum("moe_sum_topk8_7168_tail", 1, 8, 7168, cta=3, note=" (last, partial block)"),
    moe_sum("moe_sum_topk2_4096_4tok", 4, 2, 4096, cta=1, note=" (Mixtral)"),
    moe_sum("moe_sum_topk4_f32_1024", 2, 4, 1024, dtype="f32"),
    moe_sum("moe_sum_topk8_f16_2048", 1, 8, 2048, dtype="f16"),
    moe_sum("moe_sum_topk10_runtime_2048", 1, 10, 2048, note=" (Qwen3-Next topk 10)"),
    moe_sum("moe_sum_pad_topk8_2048", 1, 8, 2048, topk_ids=(3, -1, 7, 0, 12, -1, 5, 1)),
    moe_sum("moe_sum_pad_ep_topk8_2048", 1, 8, 2048, topk_ids=(3, 9, 7, 0, 2, 14, 5, 1),
            expert_map=(0, 1, 2, 3, 4, 5, 6, 7) + (-1,) * 8, note=" (expert map, EP rank 0)"),
    moe_sum("moe_sum_pad_runtime_topk5", 1, 5, 2048, topk_ids=(4, -1, 2, 0, 6)),
    moe_sum("moe_sum_pad_i64_topk6_2048", 1, 6, 2048, idx="l", note=" (int64 topk_ids)"),
    moe_sum_scalar("moe_sum_scalar_100", 3, 2, 100, cta=2, note=" (hidden % 8 != 0)"),
    moe_sum_scalar("moe_sum_scalar_strided_2052", 2, 8, 2052, cta=1, stride_token=8 * 2052 + 4,
                   note=" (hidden 2052, padded token rows)"),
)


INT_MANGLED = {"i32": "i", "i64": "l"}


def moe_align_small(name, num_experts, topk, topk_ids, block_size=16, dtype="i32",
                    expert_map=None, scatter=False, check="ACCEPT", note=""):
    """`moe_align_block_size(topk_ids [tokens, topk], num_experts, block_size, ...)` in its
    small-batch mode (numel < 1024, num_experts <= 64): one block of 256 fill threads plus
    max(num_experts, 32) counting threads, dynamic shared ((threads + 1) E + E + 1) ints,
    dispatch :722; sorted_token_ids has numel + E (block_size - 1) slots (at most numel *
    block_size when numel < E), expert_ids that / block_size, as
    vllm/model_executor/layers/fused_moe/moe_align_block_size.py:137 allocates them."""
    numel = len(topk_ids)
    padded = numel + num_experts * (block_size - 1)
    if numel < num_experts:
        padded = min(numel * block_size, padded)
    m_blocks = -(-padded // block_size)
    threads = max(num_experts, 32)
    arrays = [Array("topk_ids", "index", dtype, (numel // topk, topk),
                    contents=tuple(topk_ids) if dtype == "i32" else None),
              Array("sorted_token_ids", "out", "i32", (padded,)),
              Array("expert_ids", "out", "i32", (m_blocks,)),
              Array("num_tokens_post_pad", "out", "i32", (1,))]
    if expert_map is not None:
        arrays.append(Array("expert_map", "index", "i32", (len(expert_map),),
                            contents=tuple(expert_map)))
    if scatter:
        arrays.append(Array("scatter_idx", "out", "i32", (numel,)))
    sorted_ids, expert_ids, total, scatter_idx = moe_align_reference(
        num_experts, topk_ids, block_size, padded, m_blocks, threads, expert_map)
    spec = write_spec(f"moe_align_{name}", "\n".join([
        f"// Generated by cases.py (moe_align_reference) for the case {name}.",
        "dim P; dim M; dim ONE; dim N;",
        "array sorted_token_ids[P];", "array expert_ids[M];", "array num_tokens_post_pad[ONE];",
        *(["array scatter_idx[N];"] if scatter else []),
        int_table("sorted_token_ids", sorted_ids, numel),
        int_table("expert_ids", expert_ids, -1),
        f"num_tokens_post_pad[i] = {total};",
        *([int_table("scatter_idx", scatter_idx, -1)] if scatter else []), ""]))
    return Case(
        name=name,
        description=f"moe_align_block_size small-batch, {dtype} topk_ids of {numel // topk} "
                    f"tokens x topk {topk}, {num_experts} experts, block_size {block_size}"
                    f"{', expert map' if expert_map else ''}{', scatter_idx' if scatter else ''}"
                    f"{note}",
        source=f"{MOE}:542 (moe_align_block_size_small_batch_expert_kernel, body :232), "
               "dispatch :722",
        unit=MOE,
        symbol=f"46moe_align_block_size_small_batch_expert_kernelI{INT_MANGLED[dtype]}Li256E",
        args=(Ptr("topk_ids"), Ptr("sorted_token_ids"), Ptr("expert_ids"),
              Ptr("num_tokens_post_pad"),
              Ptr("expert_map") if expert_map is not None else NULL,
              Int(num_experts, "num_experts"), Int(block_size, "block_size"),
              Int(numel, "numel"), Int(padded, "max_num_tokens_padded"), Int(topk, "topk_num"),
              Int(int(expert_map is not None), "has_expert_map"),
              Ptr("scatter_idx") if scatter else NULL),
        arrays=tuple(arrays),
        grid=(1, 1, 1),
        block=256 + threads,
        check=check,
        spec=spec,
        dims={"P": padded, "M": m_blocks, "ONE": 1, "N": numel},
        smem=((threads + 1) * num_experts + num_experts + 1) * 4,
    )


def moe_align_reference(num_experts, topk_ids, block_size, padded, m_blocks, stride,
                        expert_map=None):
    """What moe_align_block_size should produce: token slots grouped by local expert, each
    group padded to a multiple of block_size with `numel`, `expert_ids` naming each block's
    expert (-1 past the last), and scatter_idx[i] = i for routed slots, else -1. Within an
    expert the kernel's order is by thread then iteration, (i % stride, i // stride)."""
    numel = len(topk_ids)

    def local(i):
        e = topk_ids[i]
        if e < 0 or e >= num_experts:
            return -1
        return expert_map[e] if expert_map is not None else e

    members = {e: [] for e in range(num_experts)}
    for i in sorted(range(numel), key=lambda i: (i % stride, i // stride)):
        if local(i) != -1:
            members[local(i)].append(i)
    sorted_ids, expert_ids, at = [numel] * padded, [-1] * m_blocks, 0
    for e in range(num_experts):
        for r, i in enumerate(members[e]):
            sorted_ids[at + r] = i
        size = -(-len(members[e]) // block_size) * block_size
        for b in range(at // block_size, (at + size) // block_size):
            expert_ids[b] = e
        at += size
    scatter = [i if local(i) != -1 else -1 for i in range(numel)]
    return sorted_ids, expert_ids, at, scatter


def int_table(name, values, default):
    """A spec equation giving the integer `values` (a 32-bit word, -1 as 2^32 - 1), the
    elements equal to `default` folded into the innermost branch."""
    word = lambda v: v % 2**32
    body = str(word(default))
    for i, v in reversed(list(enumerate(values))):
        if v != default:
            body = f"where(i == {i}, {word(v)}, {body})"
    return f"{name}[i] = {body};"


def write_spec(name, text):
    """Write a generated spec beside this file (only when it changed), return its name."""
    from pathlib import Path
    path = Path(__file__).with_name(f"{name}.spec")
    if not path.exists() or path.read_text() != text:
        path.write_text(text)
    return path.name


def routed(tokens, topk, num_experts, seed=7):
    """A router's topk_ids: per token, topk distinct experts (seeded, so cases are stable)."""
    import random
    rng = random.Random(seed)
    return tuple(e for _ in range(tokens) for e in rng.sample(range(num_experts), topk))


EP_MAP_16 = (-1,) * 8 + tuple(range(8))  # EP rank 1 of 2 over 16 experts: 8..15 -> 0..7

CASES += (
    moe_align_small("moe_align_mixtral_4tok", 8, 2, (0, 3, 3, 5, 1, 0, 7, 3)),
    moe_align_small("moe_align_dsv2lite_3tok", 64, 6, routed(3, 6, 64),
                    note=" (numel < num_experts: sorted_token_ids of numel * block_size)"),
    moe_align_small("moe_align_olmoe_16tok", 64, 8, routed(16, 8, 64),
                    note=" (numel 128 > 64 counting threads)"),
    moe_align_small("moe_align_bs64_12tok", 32, 8, routed(12, 8, 32), block_size=64),
    moe_align_small("moe_align_ep_8tok", 16, 2, routed(8, 2, 16), expert_map=EP_MAP_16,
                    note=" (EP rank 1 of 2)"),
    moe_align_small("moe_align_scatter_4tok", 8, 2, (0, 3, 3, 5, 1, 0, 7, 3), scatter=True),
    # Volta gap: `int expert_id = topk_ids[idx]` (:124) on int64 ids compiles to a 4-byte load
    # of the 8-byte element's low word, which Volta cannot reinterpret ("unsupported
    # reinterpretation of Global memory ... 8-byte scalar granule"). Correct on hardware.
    moe_align_small("moe_align_i64_6tok", 64, 2, tuple(range(12)), dtype="i64",
                    check="UNKNOWN", note=" (int64 ids 0..11)"),
)


# ===== Merging split attention states (csrc/attention/merge_attn_states.cu) =====

MERGE = "csrc/attention/merge_attn_states.cu"
MERGE_MANGLED = {"bf16": "13__nv_bfloat16S1_", "f16": "ttL", "f32": "ffL"}


def merge_attn_states(name, tokens, heads, head_size, cta, dtype="bf16", prefix_tokens=None,
                      lse=True, check="ACCEPT", note=""):
    """`merge_attn_states(output [n, h, d], output_lse [h, n], prefix_output, prefix_lse
    [h, n], suffix_output, suffix_lse, prefill_tokens_with_context)` on contiguous tensors,
    non-FP8 output: one thread per 16-byte pack, 128 threads, grid ceil(n h d / pack / 128),
    dispatch :312. Tokens >= prefill_tokens_with_context copy the suffix."""
    pack = 16 // SCALAR_BYTES[dtype]
    per_head = head_size // pack
    total = tokens * heads * per_head
    first, last = cta * 128, min(cta * 128 + 128, total)
    t, h0 = divmod(first // per_head, heads)
    assert (last - 1) // per_head // heads == t, "one token per block"
    h1 = h0 + (last - first) // per_head
    pn = tokens if prefix_tokens is None else prefix_tokens
    symbol = (f"24merge_attn_states_kernelI{MERGE_MANGLED[dtype]}Lj128ELb0E" if dtype == "bf16"
              else f"24merge_attn_states_kernelI{MERGE_MANGLED[dtype]}j128ELb0E")
    return Case(
        name=name,
        description=f"merge_attn_states, {dtype}, {tokens} tokens x {heads} heads x {head_size}, "
                    f"{'' if lse else 'no output_lse, '}"
                    f"{pn} with context, block {cta} = token {t} heads [{h0}, {h1}){note}",
        source=f"{MERGE}:18 (merge_attn_states_kernel), dispatch :312",
        unit=MERGE,
        symbol=symbol,
        args=(Ptr("output"), Ptr("output_lse") if lse else NULL, Ptr("prefix_output"),
              Ptr("prefix_lse"),
              Ptr("suffix_output"), Ptr("suffix_lse"), Int(tokens, "num_tokens"),
              Int(heads, "num_heads"), Int(head_size, "head_size"),
              Int(head_size, "prefix_head_stride"), Int(head_size, "output_head_stride"),
              Int(tokens, "prefix_lse_head_stride"), Int(1, "prefix_lse_token_stride"),
              Int(tokens, "suffix_lse_head_stride"), Int(1, "suffix_lse_token_stride"),
              Int(tokens if lse else 0, "output_lse_head_stride"),
              Int(1 if lse else 0, "output_lse_token_stride"),
              Int(pn, "prefix_num_tokens"), NULL),
        arrays=(Array("prefix_output", "in", dtype, (tokens, heads, head_size)),
                Array("suffix_output", "in", dtype, (tokens, heads, head_size)),
                Array("prefix_lse", "in", "f32", (heads, tokens)),
                Array("suffix_lse", "in", "f32", (heads, tokens)),
                Array("output", "out", dtype, (tokens, heads, head_size)),
                *((Array("output_lse", "out", "f32", (heads, tokens)),) if lse else ())),
        grid=(-(-total // 128), 1, 1),
        block=128,
        check=check,
        spec="merge_attn_states.spec" if lse else "merge_attn_states_no_lse.spec",
        dims={"N": tokens, "H": heads, "D": head_size, "PN": pn, "T": t, "H0": h0, "H1": h1},
        cta=(cta, 0, 0),
    )


CASES += (
    merge_attn_states("merge_attn_states_copy_suffix", 4, 32, 128, cta=13, prefix_tokens=2,
                      note=" (token past prefill_tokens_with_context)"),
    merge_attn_states("merge_attn_states_mla_512_copy", 2, 16, 512, cta=9, prefix_tokens=1,
                      lse=False, note=" (MLA kv_lora_rank head, token past the context)"),
    merge_attn_states("merge_attn_states_bf16_128", 4, 32, 128, cta=5, lse=False),
    merge_attn_states("merge_attn_states_f16_128", 4, 32, 128, cta=6, dtype="f16", lse=False),
    merge_attn_states("merge_attn_states_f32_128", 2, 16, 128, cta=3, dtype="f32", lse=False),
    # Volta gap: out_lse = logf(out_se) + max_lse (:189) carries logf's special cases
    # (logf(0) = -inf), and the solver refuses the non-finite constant.
    merge_attn_states("merge_attn_states_lse_bf16_128", 4, 32, 128, cta=5, check="UNKNOWN"),
)


# ===== KV-cache writes (csrc/cache_kernels.cu) =====

CACHE = "csrc/cache_kernels.cu"
CACHE_MANGLED = {"bf16": "13__nv_bfloat16S1_", "f16": "tt", "f32": "ff"}


def reshape_and_cache_flash(name, tokens, heads, head_size, cta, block_size=16, num_blocks=2,
                            dtype="bf16", hnd=False, key_stride=None, value_stride=None,
                            check="ACCEPT", note=""):
    """`reshape_and_cache_flash(key [T, H, D], value, key_cache, value_cache, slot_mapping,
    "auto", k_scale [1], v_scale [1])`, cache [num_blocks, block_size, H, D] with NHD strides
    or (`hnd`) a permuted view of a [num_blocks, H, block_size, D] buffer; key/value may be
    views of a fused qkv (row strides `key_stride`, `value_stride`). Grid T, block
    min(H D, 512), dispatch :971. slot_mapping is int64, so Volta gives slot_mapping[t] = t:
    block `cta` writes slot `cta`."""
    ks, vs = key_stride or heads * head_size, value_stride or heads * head_size
    page, head = (head_size, block_size * head_size) if hnd else (heads * head_size, head_size)
    cache_shape = ((num_blocks, heads, block_size, head_size) if hnd else
                   (num_blocks, block_size, heads, head_size))
    assert cta < num_blocks * block_size
    return Case(
        name=name,
        description=f"reshape_and_cache_flash, {dtype}, {'HND' if hnd else 'NHD'}, {tokens} "
                    f"tokens x {heads} kv heads x {head_size}, block_size {block_size}, row "
                    f"strides {ks}/{vs}, block {cta} = slot {cta}{note}",
        source=f"{CACHE}:336 (reshape_and_cache_flash_kernel), dispatch :971",
        unit=CACHE,
        symbol=f"30reshape_and_cache_flash_kernelI{CACHE_MANGLED[dtype]}LNS_18Fp8KVCacheDataTypeE0EE",
        args=(Ptr("key"), Ptr("value"), Ptr("key_cache"), Ptr("value_cache"),
              Ptr("slot_mapping"), Int(block_size * heads * head_size, "block_stride"),
              Int(page, "page_stride"), Int(head, "head_stride"), Int(ks, "key_stride"),
              Int(vs, "value_stride"), Int(heads, "num_heads"), Int(head_size, "head_size"),
              Int(block_size, "block_size"), NULL, NULL, Int(0, "kv_scale_stride")),
        arrays=(Array("key", "in", dtype, (tokens, ks)),
                Array("value", "in", dtype, (tokens, vs)),
                Array("slot_mapping", "index", "i64", (tokens,)),
                Array("key_cache", "out", dtype, cache_shape),
                Array("value_cache", "out", dtype, cache_shape)),
        grid=(tokens, 1, 1),
        block=min(heads * head_size, 512),
        check=check,
        spec=f"reshape_and_cache_flash_{'hnd' if hnd else 'nhd'}.spec",
        dims={"T": tokens, "KS": ks, "VS": vs, "NB": num_blocks, "BS": block_size, "H": heads,
              "D": head_size, "P": cta, "B": cta // block_size, "S": cta % block_size},
        cta=(cta, 0, 0),
    )


CASES += (
    reshape_and_cache_flash("reshape_and_cache_flash_nhd_llama8b", 20, 8, 128, cta=19),
    reshape_and_cache_flash("reshape_and_cache_flash_nhd_qkv_view", 20, 8, 128, cta=19,
                            key_stride=6144, value_stride=6144,
                            note=" (k, v views of Llama-3-8B's qkv)"),
    reshape_and_cache_flash("reshape_and_cache_flash_hnd_llama8b", 20, 8, 128, cta=19, hnd=True),
    reshape_and_cache_flash("reshape_and_cache_flash_nhd_f16_64", 6, 2, 64, cta=5, dtype="f16",
                            note=" (64 threads)"),
    reshape_and_cache_flash("reshape_and_cache_flash_nhd_f32_80", 6, 4, 80, cta=5,
                            dtype="f32", note=" (head_size 80)"),
    reshape_and_cache_flash("reshape_and_cache_flash_hnd_mqa_256", 40, 1, 256, cta=33,
                            block_size=32, hnd=True, note=" (one kv head of 256, Gemma)"),
)


def concat_and_cache_mla(name, tokens, cta, rank=512, pe=64, block_size=64, num_blocks=2,
                         dtype="bf16", kv_c_stride=None, k_pe_stride=None, check="ACCEPT",
                         note=""):
    """`concat_and_cache_mla(kv_c [T, rank], k_pe [T, pe], kv_cache [num_blocks, block_size,
    rank + pe], slot_mapping, "auto", scale)`: grid T, block min(rank, 512), dispatch :1144.
    slot_mapping[t] = t (int64, no contents): block `cta` writes slot `cta`."""
    kcs, kps = kv_c_stride or rank, k_pe_stride or pe
    entry = rank + pe
    return Case(
        name=name,
        description=f"concat_and_cache_mla, {dtype}, {tokens} tokens, kv_lora_rank {rank} + "
                    f"pe {pe}, block_size {block_size}, row strides {kcs}/{kps}, block {cta}"
                    f"{note}",
        source=f"{CACHE}:492 (concat_and_cache_mla_kernel), dispatch :1144",
        unit=CACHE,
        symbol=f"27concat_and_cache_mla_kernelI{CACHE_MANGLED[dtype]}LNS_18Fp8KVCacheDataTypeE0ELb0E",
        args=(Ptr("kv_c"), Ptr("k_pe"), Ptr("kv_cache"), Ptr("slot_mapping"),
              Int(block_size * entry, "block_stride"), Int(entry, "entry_stride"),
              Int(kcs, "kv_c_stride"), Int(kps, "k_pe_stride"), Int(rank, "kv_lora_rank"),
              Int(pe, "pe_dim"), Int(block_size, "block_size"), NULL),
        arrays=(Array("kv_c", "in", dtype, (tokens, kcs)),
                Array("k_pe", "in", dtype, (tokens, kps)),
                Array("slot_mapping", "index", "i64", (tokens,)),
                Array("kv_cache", "out", dtype, (num_blocks, block_size, entry))),
        grid=(tokens, 1, 1),
        block=min(rank, 512),
        check=check,
        spec="concat_and_cache_mla.spec",
        dims={"T": tokens, "KCS": kcs, "KPS": kps, "NB": num_blocks, "BS": block_size,
              "RE": entry, "R": rank, "P": cta, "B": cta // block_size, "S": cta % block_size},
        cta=(cta, 0, 0),
    )


CASES += (
    concat_and_cache_mla("concat_and_cache_mla_dsv3", 70, cta=69, note=" (DeepSeek-V3)"),
    concat_and_cache_mla("concat_and_cache_mla_dsv3_views", 70, cta=69, kv_c_stride=576,
                         k_pe_stride=576, note=" (kv_c, k_pe views of the kv_a output)"),
    concat_and_cache_mla("concat_and_cache_mla_f16_bs16", 20, cta=17, block_size=16,
                         dtype="f16"),
    concat_and_cache_mla("concat_and_cache_mla_f32_r256", 8, cta=7, rank=256, pe=32,
                         block_size=16, dtype="f32", note=" (256 threads)"),
)


def reshape_and_cache(name, tokens, heads, head_size, cta, block_size=16, num_blocks=2,
                      dtype="bf16", key_stride=None, value_stride=None, check="ACCEPT", note=""):
    """`reshape_and_cache(key [T, H, D], value, key_cache [num_blocks, H, D / x, block_size,
    x], value_cache [num_blocks, H, D, block_size], slot_mapping, "auto", k_scale, v_scale,
    interleaved_v=False)`, x = 16 / sizeof: grid T, block min(H D / x, 512), dispatch :862.
    slot_mapping[t] = t (int64): block `cta` writes slot `cta`."""
    x = 16 // SCALAR_BYTES[dtype]
    ks, vs = key_stride or heads * head_size, value_stride or heads * head_size
    return Case(
        name=name,
        description=f"reshape_and_cache, {dtype}, {tokens} tokens x {heads} kv heads x "
                    f"{head_size}, x {x}, block_size {block_size}, block {cta}{note}",
        source=f"{CACHE}:266 (reshape_and_cache_kernel), dispatch :862",
        unit=CACHE,
        symbol=f"24reshape_and_cache_kernelI{CACHE_MANGLED[dtype]}LNS_18Fp8KVCacheDataTypeE0EE",
        args=(Ptr("key"), Ptr("value"), Ptr("key_cache"), Ptr("value_cache"),
              Ptr("slot_mapping"), Int(ks, "key_stride"), Int(vs, "value_stride"),
              Int(heads, "num_heads"), Int(head_size, "head_size"),
              Int(block_size, "block_size"), Int(x, "x"), NULL, NULL, Int(0, "interleaved_v")),
        arrays=(Array("key", "in", dtype, (tokens, ks)),
                Array("value", "in", dtype, (tokens, vs)),
                Array("slot_mapping", "index", "i64", (tokens,)),
                Array("key_cache", "out", dtype,
                      (num_blocks, heads, head_size // x, block_size, x)),
                Array("value_cache", "out", dtype, (num_blocks, heads, head_size, block_size))),
        grid=(tokens, 1, 1),
        block=min(heads * head_size // x, 512),
        check=check,
        spec="reshape_and_cache.spec",
        dims={"T": tokens, "KS": ks, "VS": vs, "NB": num_blocks, "H": heads,
              "DX": head_size // x, "X": x, "D": head_size, "BS": block_size, "P": cta,
              "B": cta // block_size, "S": cta % block_size},
        cta=(cta, 0, 0),
    )


CASES += (
    reshape_and_cache("reshape_and_cache_llama3_8b", 20, 8, 128, cta=19),
    reshape_and_cache("reshape_and_cache_llama2_7b", 20, 32, 128, cta=18, num_blocks=2,
                      note=" (MHA, 512 threads)"),
    reshape_and_cache("reshape_and_cache_f16_qkv_view", 6, 2, 64, cta=5, dtype="f16",
                      key_stride=512, value_stride=512, note=" (k, v views of qkv)"),
)


# ===== RMSNorm, remaining shapes (csrc/layernorm_kernels.cu) =====


def rms_norm_nd(name, shape, strides, cta, dtype="bf16", weight_2d=False, check="ACCEPT",
                note=""):
    """`rms_norm(out, input, weight, eps)` on a rank-2/3/4 input of logical `shape` (the
    rows' dims, then hidden D) and row `strides` (elements, one per row dim), out contiguous;
    weight [D] or (`weight_2d`) [input.size(0), D] with weight_stride D. VEC = gcd(16 /
    sizeof, D), block min(D / VEC, 1024 if fewer than 256 rows else 256), grid = rows,
    dispatch :222. The case views the rows as [B, S, H] (missing dims 1)."""
    rank = len(shape)
    d = shape[-1]
    rows = shape[:-1]
    b, s, h = (rows[0], 1, 1) if rank == 2 else (rows[0], 1, rows[1]) if rank == 3 else rows
    sb, ss, sh = ((strides[0], 0, 0) if rank == 2 else (strides[0], 0, strides[1])
                  if rank == 3 else strides)
    stride_d2, stride_d3, stride_d4 = (sb, 0, 0) if rank == 2 else \
        (sh, sb, 0) if rank == 3 else (sh, ss, sb)
    shape_d2, shape_d3 = (0, 0) if rank == 2 else (h, 0) if rank == 3 else (h, s)
    tokens = b * s * h
    vec = math.gcd(16 // SCALAR_BYTES[dtype], d)
    cb, rest = divmod(cta, s * h)
    cs, ch = divmod(rest, h)
    nin = (b - 1) * sb + (s - 1) * ss + (h - 1) * sh + d
    ws = d if weight_2d else 0
    return Case(
        name=name,
        description=f"rms_norm, {dtype}, rank {rank} input {tuple(shape)} with row strides "
                    f"{tuple(strides)}, weight {'[B, D]' if weight_2d else '[D]'}, VEC {vec}, "
                    f"block {cta}{note}",
        source=f"{LAYERNORM}:15 (rms_norm_kernel NUM_DIMS == {rank}), dispatch :222",
        unit=LAYERNORM,
        symbol=f"15rms_norm_kernelI{SCALAR_MANGLED[dtype]}Li{vec}ELi{rank}ELb1E",
        args=(Ptr("out"), Ptr("input"), Int(stride_d2, "input_stride_d2"),
              Int(stride_d3, "input_stride_d3"), Int(stride_d4, "input_stride_d4"),
              Int(shape_d2, "input_shape_d2"), Int(shape_d3, "input_shape_d3"),
              Ptr("weight"), Int(ws, "weight_stride"), Float(EPS, "epsilon"),
              Int(tokens, "num_tokens"), Int(d, "hidden_size")),
        arrays=(Array("input", "in", dtype, (nin,)),
                Array("weight", "in", dtype, ((b if weight_2d else 1) * d,)),
                Array("out", "out", dtype, (b, s, h, d))),
        grid=(tokens, 1, 1),
        block=min(d // vec, 1024 if tokens < 256 else 256),
        check=check,
        spec="rms_norm_strided.spec",
        dims={"B": b, "S": s, "H": h, "D": d, "NIN": nin, "NW": (b if weight_2d else 1) * d,
              "SB": sb, "SS": ss, "SH": sh, "WS": ws, "CB": cb, "CS": cs, "CH": ch},
        cta=(cta, 0, 0),
    )


def fused_add_rms_norm_strided(name, tokens, hidden, cta, dtype="bf16", input_stride=None,
                               residual_stride=None, check="ACCEPT", note=""):
    """`fused_add_rms_norm(input, residual, weight, eps)` with row strides: the width-8
    kernel when hidden and both strides are multiples of 8 (and the pointers 16-byte
    aligned), else the generic one; block min(hidden, 1024), dispatch :315."""
    ins, rs = input_stride or hidden, residual_stride or hidden
    width = 8 if hidden % 8 == 0 and ins % 8 == 0 and rs % 8 == 0 else 0
    return Case(
        name=name,
        description=f"fused_add_rms_norm, {dtype}, {tokens} tokens of {hidden}, row strides "
                    f"{ins}/{rs}, width {width}, block {cta}{note}",
        source=f"{LAYERNORM}:{109 if width else 182} (fused_add_rms_norm_kernel), dispatch :315",
        unit=LAYERNORM,
        symbol=f"25fused_add_rms_norm_kernelI{SCALAR_MANGLED[dtype]}Li{width}ELb1E",
        args=(Ptr("input"), Int(ins, "input_stride"), Ptr("residual"), Ptr("weight"),
              Float(EPS, "epsilon"), Int(tokens, "num_tokens"), Int(hidden, "hidden_size"),
              Int(rs, "residual_stride")),
        arrays=(Array("input", "inout", dtype, (tokens, ins)),
                Array("residual", "inout", dtype, (tokens, rs)),
                Array("weight", "in", dtype, (hidden,))),
        grid=(tokens, 1, 1),
        block=min(hidden, 1024),
        check=check,
        spec="fused_add_rms_norm_strided.spec",
        dims={"T": tokens, "N": hidden, "IS": ins, "RS": rs, "P": cta},
        cta=(cta, 0, 0),
    )


CASES += (
    rms_norm_nd("rms_norm_4d_bshd", (2, 3, 4, 128), (1536, 512, 128), cta=17,
                note=" (transformers backend q norm, contiguous)"),
    rms_norm_nd("rms_norm_4d_transposed", (2, 3, 4, 128), (1536, 128, 384), cta=17,
                note=" ([B, H, S, D] transposed to [B, S, H, D])"),
    rms_norm_nd("rms_norm_2d_weight", (4, 2048), (2048,), cta=2, weight_2d=True),
    rms_norm_nd("rms_norm_3d_2d_weight", (2, 4, 128), (1024, 128), cta=6, weight_2d=True,
                note=" (per-batch weight rows)"),
    rms_norm_nd("rms_norm_2d_strided_f16", (3, 4096), (6144,), cta=1, dtype="f16",
                note=" (rows of a wider buffer)"),
    rms_norm_nd("rms_norm_f32_4096", (2, 4096), (4096,), cta=1, dtype="f32"),
    rms_norm_nd("rms_norm_4d_f16_64", (1, 5, 2, 64), (640, 128, 64), cta=9, dtype="f16"),
    fused_add_rms_norm_strided("fused_add_rms_norm_strided_input", 2, 4096, cta=1,
                               input_stride=8192, note=" (input a view of [T, 2H])"),
    fused_add_rms_norm_strided("fused_add_rms_norm_generic_strided", 2, 4096, cta=1,
                               input_stride=4100, note=" (stride not a multiple of 8)"),
    fused_add_rms_norm_strided("fused_add_rms_norm_f16_4096", 2, 4096, cta=1, dtype="f16"),
    fused_add_rms_norm_strided("fused_add_rms_norm_f32_2048", 2, 2048, cta=1, dtype="f32"),
    fused_add_rms_norm_strided("fused_add_rms_norm_f32_generic", 2, 1000, cta=1, dtype="f32",
                               note=" (hidden % 8 != 0)"),
)


# ===== Element-wise and other gated activations (csrc/activation_kernels.cu) =====


def activation(name, act, d, tokens=1, dtype="bf16", spec=True, check=None, note=""):
    """`gelu_new / gelu_fast / gelu_quick / relu_squared(out, input)` on [tokens, d]: the
    128-bit vector path when d % (16 / sizeof) == 0 (block min(d / VEC, 1024)), the 256-bit
    one with more than 128 tokens on sm_100, else scalar (block min(d, 1024)); dispatch
    :1327. Block 0 computes token 0. gelu_new and gelu_fast are tanh-based: race-only."""
    b256 = tokens > 128
    vec = (32 if b256 else 16) // SCALAR_BYTES[dtype]
    use_vec = d % vec == 0
    width = {"gelu_new": 15, "gelu_fast": 16, "gelu_quick": 17, "relu_squared": 19}[act]
    return Case(
        name=name,
        description=f"{act}, {dtype}, {tokens} token(s) of {d}, "
                    f"{'256-bit' if use_vec and b256 else '128-bit' if use_vec else 'scalar'} "
                    f"path{note}",
        source=f"{ACTIVATION}:1280 (activation_kernel), dispatch :1327",
        unit=ACTIVATION,
        symbol=(f"17activation_kernelI{DTYPE_MANGLED[dtype]}XadL_ZNS_{width}{act}_kernel",
                f"Lb{int(use_vec)}ELb{int(use_vec and b256)}E"),
        args=(Ptr("out"), Ptr("input"), Int(d, "d")),
        arrays=(Array("input", "in", dtype, (tokens, d)), Array("out", "out", dtype, (1, d))),
        grid=(tokens, 1, 1),
        block=min(d // vec if use_vec else d, 1024),
        check=check or ("ACCEPT" if spec else "VERIFIED"),
        spec=f"{act}.spec" if spec else None,
        dims={"T": 1, "D": d} if spec else {},
    )


def gelu_and_mul(name, d, tokens=1, tanh=False, check="VERIFIED", note=""):
    """`gelu_and_mul` / `gelu_tanh_and_mul(out, input)`, erf / tanh based: race-only. Paths
    and blocks as `act_and_mul` (dispatch :244)."""
    b256 = tokens > 128 and d % 16 == 0
    vec = 16 if b256 else 8
    use_vec = d % vec == 0
    fn, packed = ("16gelu_tanh_kernel", "23packed_gelu_tanh_kernel") if tanh else \
        ("11gelu_kernel", "18packed_gelu_kernel")
    return Case(
        name=name,
        description=f"{'gelu_tanh' if tanh else 'gelu'}_and_mul, bf16, {tokens} token(s) of "
                    f"d={d}, {'256-bit' if b256 else '128-bit' if use_vec else 'scalar'} path"
                    f"{note}",
        source=f"{ACTIVATION}:110 (act_and_mul_kernel), dispatch :244",
        unit=ACTIVATION,
        symbol=(f"18act_and_mul_kernelI{DTYPE_MANGLED['bf16']}14__nv_bfloat162XadL_ZNS_{fn}",
                f"{packed}IS3_EES5_S7_fEELb1ELb{int(use_vec)}ELb0ELb{int(b256)}E"),
        args=(Ptr("out"), Ptr("input"), Int(d, "d"), Float(0.0, "limit"), Float(1.0, "alpha"),
              Float(0.0, "beta")),
        arrays=(Array("input", "in", "bf16", (tokens, 2, d)),
                Array("out", "out", "bf16", (tokens, d))),
        grid=(tokens, 1, 1),
        block=min(d // vec if use_vec else d, 1024),
        check=check,
    )


def swigluoai_and_mul(name, d, tokens, cta, check="ACCEPT", note=""):
    """`swigluoai_and_mul(out, input, alpha=1.702, limit=7.0)` (gpt-oss) on bf16 interleaved
    [tokens, d, 2]: block min(d, 1024), grid tokens, dispatch :1013; the int4 / int2 vector
    loop when the token's rows are 16 / 8-byte aligned, scalar cleanup past d / 4 * 4."""
    return Case(
        name=name,
        description=f"swigluoai_and_mul, bf16, {tokens} tokens of d={d}, block {cta}{note}",
        source=f"{ACTIVATION}:422 (swigluoai_and_mul_kernel), dispatch :1013",
        unit=ACTIVATION,
        symbol=f"24swigluoai_and_mul_kernelI{DTYPE_MANGLED['bf16']}",
        args=(Ptr("out"), Ptr("input"), Int(d, "d"), Float(1.702, "alpha"),
              Float(7.0, "limit")),
        arrays=(Array("input", "in", "bf16", (tokens, d, 2)),
                Array("out", "out", "bf16", (tokens, d))),
        grid=(tokens, 1, 1),
        block=min(d, 1024),
        check=check,
        spec="swigluoai_and_mul.spec",
        dims={"T": tokens, "D": d, "TWO": 2, "P": cta},
        cta=(cta, 0, 0),
    )


CASES += (
    activation("gelu_quick_4096", "gelu_quick", 4096),
    activation("gelu_quick_scalar_100", "gelu_quick", 100),
    activation("relu_squared_4096", "relu_squared", 4096),
    activation("gelu_new_4096", "gelu_new", 4096, spec=False),
    activation("gelu_fast_4096", "gelu_fast", 4096, spec=False),
    gelu_and_mul("gelu_and_mul_4096", 4096),
    gelu_and_mul("gelu_tanh_and_mul_4096", 4096, tanh=True),
    gelu_and_mul("gelu_and_mul_256b_4096", 4096, tokens=129, note=" (token 0 of 129)"),
    gelu_and_mul("gelu_tanh_and_mul_scalar_100", 100, tanh=True),
    swigluoai_and_mul("swigluoai_and_mul_gpt_oss_2880", 2880, 2, cta=1),
    swigluoai_and_mul("swigluoai_and_mul_odd_1001", 1001, 2, cta=1,
                      note=" (rows 2 x 1001 x 2 bytes apart: token 1 unaligned, scalar loop)"),
)


# ===== Vocab-parallel embedding (csrc/vocab_parallel_embedding_kernels.cu) =====

EMBED = "csrc/vocab_parallel_embedding_kernels.cu"
B200_SMS = 148


def vocab_embedding(name, ids, hidden, num_rows, org, cta, added=(0, 0), padding=0,
                    dtype="bf16", check="ACCEPT", note=""):
    """`vocab_parallel_embedding(out [T, hidden], input_ids [T] int32, weight [num_rows,
    hidden], org_start, org_end, num_org_vocab_padding, added_start, added_end)`: rows copied
    as the widest of uint4 / uint2 / ... dividing the row bytes (bases 16-byte aligned),
    256 threads, grid (min(ceil(vecs / 256), 256), min(T, 4 SMs)), dispatch :140. Block
    `cta` = (x, y) copies vectors [256 x, 256 x + 256) of tokens y, y + grid_y, ..."""
    esize = SCALAR_BYTES[dtype]
    row_bytes = hidden * esize
    vec_bytes = next(w for w in (16, 8, 4, 2, 1) if row_bytes % w == 0)
    vec_t = {16: "5uint4", 8: "5uint2", 4: "j", 2: "t", 1: "h"}[vec_bytes]
    vecs = row_bytes // vec_bytes
    grid_x = min(-(-vecs // 256), 256)
    grid_y = min(len(ids), 4 * B200_SMS)
    bx, by = cta
    assert len(ids) <= grid_y, "one token per block"
    added_row_offset = org[1] - org[0] + padding - added[0]
    tid = ids[by]
    in_org, in_added = org[0] <= tid < org[1], added[0] <= tid < added[1]
    row = tid - org[0] if in_org else tid + added_row_offset if in_added else 0
    per_vec = vec_bytes // esize
    c0, c1 = 256 * bx * per_vec, min(256 * (bx + 1), vecs) * per_vec
    return Case(
        name=name,
        description=f"vocab_parallel_embedding, {dtype}, {len(ids)} int32 ids, {num_rows} local "
                    f"rows of {hidden}, org vocab [{org[0]}, {org[1]}), added [{added[0]}, "
                    f"{added[1]}), {vec_t.lstrip('5')} copies, block {cta} = token {by} "
                    f"(id {tid}){note}",
        source=f"{EMBED}:28 (vocab_parallel_embedding_kernel), dispatch :140",
        unit=EMBED,
        symbol=f"31vocab_parallel_embedding_kernelIi{vec_t}EE",
        args=(Ptr("out"), Ptr("input_ids"), Ptr("weight"), Int(len(ids), "num_tokens"),
              Int(vecs, "vecs_per_row"), Int(org[0], "org_vocab_start_index"),
              Int(org[1], "org_vocab_end_index"), Int(added[0], "added_vocab_start_index"),
              Int(added[1], "added_vocab_end_index"), Int(added_row_offset, "added_row_offset")),
        arrays=(Array("input_ids", "index", "i32", (len(ids),), contents=tuple(ids)),
                Array("weight", "in", dtype, (num_rows, hidden)),
                Array("out", "out", dtype, (len(ids), hidden))),
        grid=(grid_x, grid_y, 1),
        block=256,
        check=check,
        spec="vocab_parallel_embedding.spec",
        dims={"T": len(ids), "NR": num_rows, "H": hidden, "P": by, "ROW": row,
              "IN": int(in_org or in_added), "C0": c0, "C1": c1},
        cta=(bx, by, 0),
    )


EMBED_IDS = (5, 700, 512, 1023, 100, 600)  # TP 2 over a 1024 vocab: rank 1 owns [512, 1024)

CASES += (
    vocab_embedding("vocab_embedding_tp2_owned", EMBED_IDS, 1024, 512, (512, 1024), (0, 3),
                    note=" (last row of the shard)"),
    vocab_embedding("vocab_embedding_tp2_other_rank", EMBED_IDS, 1024, 512, (512, 1024), (0, 0),
                    note=" (id of rank 0: zeros)"),
    vocab_embedding("vocab_embedding_4096_x1", EMBED_IDS, 4096, 512, (512, 1024), (1, 1),
                    note=" (second column block)"),
    vocab_embedding("vocab_embedding_uint2_1004", EMBED_IDS, 1004, 512, (512, 1024), (0, 5),
                    note=" (row bytes 2008: uint2)"),
    vocab_embedding("vocab_embedding_lora_added", (3, 1030, 600, 1039), 1024, 528, (0, 512),
                    (0, 1), added=(1024, 1040), note=" (LoRA added-vocab id)"),
)


# ===== Hadamard transform (csrc/quantization/hadamard/hadacore, race-only) =====

HADAMARD = "csrc/quantization/hadamard/hadacore/hadamard_transform_cuda.cu"
HADAMARD_BIG = {9: (2, 1, 24), 10: (2, 2, 16), 11: (2, 4, 8), 12: (2, 8, 4), 13: (2, 16, 3),
                14: (4, 16, 2), 15: (8, 16, 1)}  # launch_configs_big (:38)


def hadamard(name, rows, had_size, cta=0, dtype="bf16", check="VERIFIED", note=""):
    """`hadacore_transform(x [rows, had_size], inplace=False)` with rows * had_size a multiple
    of 256: (chunks_per_warp, warps_per_block, blocks_per_sm) = (1, 1, 24) when numel <= 256,
    (2, 1, 24) up to 256 (the masked kernel when the chunks do not fill the last warp), else
    launch_configs_big; grid chunks / cpw / wpb, block 32 wpb, shared cpw wpb 512 bytes,
    run_fht :732. Race-only: the tensor-core butterfly has no exact spec here."""
    log = had_size.bit_length() - 1
    numel = rows * had_size
    assert numel % 256 == 0
    chunks = numel // 256
    cpw, wpb, bps = ((1, 1, 24) if numel <= 256 else (2, 1, 24) if log <= 8 else
                     HADAMARD_BIG[log])
    mask = numel > 256 and log <= 8 and chunks % (cpw * wpb) != 0
    grid = -(-(-(-chunks // cpw)) // wpb) if mask else chunks // cpw // wpb
    return Case(
        name=name,
        description=f"hadacore_transform, {dtype}, {rows} rows of {had_size}, chunks/warp {cpw}, "
                    f"{wpb} warps, {'masked, ' if mask else ''}block {cta} of {grid}{note}",
        source=f"{HADAMARD}:112 (hadamard_transform_kernel), run_fht :732",
        unit=HADAMARD,
        symbol=f"25hadamard_transform_kernelILl{cpw}ELl{wpb}ELl{log}ELl{bps}ELb{int(mask)}E"
               f"LN3c1010ScalarTypeE{15 if dtype == 'bf16' else 5}EE",
        args=(Ptr("a"), Ptr("out"), Int(chunks, "total_num_chunks")),
        arrays=(Array("a", "in", dtype, (rows, had_size)),
                Array("out", "out", dtype, (rows, had_size))),
        grid=(grid, 1, 1),
        block=32 * wpb,
        check=check,
        cta=(cta, 0, 0),
        smem=cpw * wpb * 128 * 4,
    )


# Volta gap: every instantiation stops at its first `selp.b32` over a packed b16x2 register
# (e.g. PTX :21411 `selp.b32 %r12, %r69, %r80, %p5` in the <2, 1, 7> kernel, the fragment
# swap before the shfl.sync.bfly) with "value kind mismatch (packed pair used as a scalar)".
CASES += (
    hadamard("hadamard_128_bf16", 8, 128, cta=1, check="ABORT",
             note=" (per-head rotation, head_dim 128)"),
    hadamard("hadamard_128_bf16_tail", 6, 128, cta=1, check="ABORT",
             note=" (last warp owns 1 of 2 chunks)"),
    hadamard("hadamard_64_f16_small", 4, 64, dtype="f16", check="ABORT",
             note=" (numel <= 256 path)"),
    hadamard("hadamard_4096_bf16", 1, 4096, check="ABORT", note=" (hidden-size rotation)"),
    hadamard("hadamard_2048_f16", 2, 2048, cta=1, dtype="f16", check="ABORT"),
)


def batched_moe_align(name, max_tokens, block_size, counts, check="ACCEPT", note=""):
    """`batched_moe_align_block_size(max_tokens_per_batch, block_size, batch_num_tokens [B]
    int32, sorted_ids, batch_ids, num_tokens_post_pad)`: one block of 1024 threads, the
    cooperative-writes kernel when max_tokens_per_batch >= max(256, 8 B), dispatch :790.
    Expected: batch b's tokens b * max_tokens + i (i < count_b) from its padded prefix offset,
    sentinel B * max_tokens elsewhere, batch_ids b over its blocks and -1 past the last."""
    b = len(counts)
    per_batch = -(-max_tokens // block_size)
    size = per_batch * b * block_size
    coop = max_tokens >= max(256, 8 * b)
    sorted_ids, batch_ids, at = [b * max_tokens] * size, [-1] * (size // block_size), 0
    for i, n in enumerate(counts):
        for t in range(n):
            sorted_ids[at + t] = i * max_tokens + t
        padded = -(-n // block_size) * block_size
        for blk in range(at // block_size, (at + padded) // block_size):
            batch_ids[blk] = i
        at += padded
    spec = write_spec(f"moe_align_{name}", "\n".join([
        f"// Generated by cases.py (batched_moe_align) for the case {name}.",
        "dim P; dim M; dim ONE;",
        "array sorted_ids[P];", "array batch_ids[M];", "array num_tokens_post_pad[ONE];",
        int_table("sorted_ids", sorted_ids, b * max_tokens),
        int_table("batch_ids", batch_ids, -1),
        f"num_tokens_post_pad[i] = {at};", ""]))
    return Case(
        name=name,
        description=f"batched_moe_align_block_size, {b} batches of at most {max_tokens} tokens "
                    f"(counts {list(counts)}), block_size {block_size}, "
                    f"{'cooperative' if coop else 'per-thread'} writes{note}",
        source=f"{MOE}:27 (batched_moe_align_block_size_kernel), dispatch :790",
        unit=MOE,
        symbol=f"35batched_moe_align_block_size_kernelILb{int(coop)}E",
        args=(Int(b, "num_batches"), Int(max_tokens, "max_tokens_per_batch"),
              Int(block_size, "block_size"), Ptr("batch_num_tokens"), Ptr("sorted_ids"),
              Ptr("batch_ids"), Ptr("num_tokens_post_pad")),
        arrays=(Array("batch_num_tokens", "index", "i32", (b,), contents=tuple(counts)),
                Array("sorted_ids", "out", "i32", (size,)),
                Array("batch_ids", "out", "i32", (size // block_size,)),
                Array("num_tokens_post_pad", "out", "i32", (1,))),
        grid=(1, 1, 1),
        block=1024,
        check=check,
        spec=spec,
        dims={"P": size, "M": size // block_size, "ONE": 1},
    )


CASES += (
    batched_moe_align("batched_moe_align_8x64", 64, 16, (5, 0, 17, 64, 1, 33, 0, 9)),
    batched_moe_align("batched_moe_align_coop_4x256", 256, 64, (100, 3, 256, 0),
                      note=" (cooperative path)"),
    batched_moe_align("batched_moe_align_coop_3x300", 300, 16, (300, 7, 129),
                      note=" (max tokens not a multiple of block_size)"),
)


def race_only_gate(name, kernel, d, tokens=1, check="VERIFIED", note=""):
    """Race-only gated activations on bf16 [tokens, 2, d]: `fatrelu_and_mul(out, input,
    threshold=0.1)` (data-dependent select, vector path when d % 8 == 0, block min(d / 8,
    1024), dispatch :1027) and Kimi's tanh-based `situ_and_mul(out, input, beta=4,
    linear_beta=25)` (block min(d, 1024), dispatch :1041)."""
    if kernel == "fatrelu":
        use_vec = d % 8 == 0
        symbol = (f"29act_and_mul_kernel_with_paramI{DTYPE_MANGLED['bf16']}14__nv_bfloat162XadL"
                  f"_ZNS_14fatrelu_kernel", f"Lb{int(use_vec)}ELb0EE")
        args, block, line = (Ptr("out"), Ptr("input"), Int(d, "d"), Float(0.1, "threshold")), \
            min(d // 8 if use_vec else d, 1024), 362
    else:
        symbol = f"19situ_and_mul_kernelI{DTYPE_MANGLED['bf16']}"
        args, block, line = (Ptr("out"), Ptr("input"), Int(d, "d"), Float(4.0, "beta"),
                             Float(25.0, "linear_beta")), min(d, 1024), 500
    return Case(
        name=name,
        description=f"{kernel}_and_mul, bf16, {tokens} token(s) of d={d}{note}",
        source=f"{ACTIVATION}:{line} ({kernel} kernel)",
        unit=ACTIVATION,
        symbol=symbol,
        args=args,
        arrays=(Array("input", "in", "bf16", (tokens, 2, d)),
                Array("out", "out", "bf16", (tokens, d))),
        grid=(tokens, 1, 1),
        block=block,
        check=check,
    )


CASES += (
    race_only_gate("fatrelu_and_mul_4096", "fatrelu", 4096),
    race_only_gate("fatrelu_and_mul_scalar_100", "fatrelu", 100),
    race_only_gate("situ_and_mul_kimi_3072", "situ", 3072, note=" (Kimi SituGLU)"),
)
