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


# BUG (Volta-found): each lane cp.async's its own 16-byte slot of bfrag_arr (:148), waits
# with cp.async.wait_group (:357, which makes the copies visible to the waiting thread only)
# and then reads other lanes' slots (b_frag_ptr[...] of real_thread_id, :440-449) with no
# __syncwarp: a shared-memory race. The 2048 and 4096 kernels race the same way, then stop
# at a later packed pair used as a scalar word (Volta gap).
CASES += (
    hadamard("hadamard_128_bf16", 8, 128, cta=1, check="REJECTED",
             note=" (per-head rotation, head_dim 128)"),
    hadamard("hadamard_128_bf16_tail", 6, 128, cta=1, check="REJECTED",
             note=" (last warp owns 1 of 2 chunks)"),
    hadamard("hadamard_64_f16_small", 4, 64, dtype="f16", check="REJECTED",
             note=" (numel <= 256 path)"),
    hadamard("hadamard_4096_bf16", 1, 4096, check="REJECTED", note=" (hidden-size rotation)"),
    hadamard("hadamard_2048_f16", 2, 2048, cta=1, dtype="f16", check="REJECTED"),
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


# ===== MoE routing: softmax / sigmoid top-k (csrc/moe/topk_softmax_kernels.cu) =====

TOPK = "csrc/moe/topk_softmax_kernels.cu"
IND_MANGLED = {"i32": "i", "u32": "j", "i64": "l"}


def f32(value):
    """`value` rounded to float32, as a Python float (exact in f64)."""
    import struct
    return struct.unpack("<f", struct.pack("<f", value))[0]


def f32_bits(value):
    import struct
    return struct.unpack("<i", struct.pack("<f", value))[0]


def literal(value):
    """An exact spec literal of a rational (`Fraction`, int or float); real-typed, since
    the spec divides integer literals as integers."""
    from fractions import Fraction
    q = Fraction(value)
    return f"{q.numerator}.0" if q.denominator == 1 else f"({q.numerator}.0 / {q.denominator}.0)"


def table(var, values, default="unwritten"):
    """Nested `where`s over `var` giving `values[i]` (spec text), `default` past them."""
    body = default
    for i, v in reversed(list(enumerate(values))):
        body = f"where({var} == {i}, {v}, {body})"
    return body


def topk_reference(scores, k, bias=None, renormalize=False, scale=1.0, pad=False):
    """moeTopK (:165) on one row of exact probabilities: k rounds of the block arg-max of
    score + bias over the experts not yet chosen (ties to the lowest expert), weight the
    unbiased score; times f32(scale) / (sum if renormalized and > 0, else 1). A padding
    row's index is -1 and, since its chosen experts are never marked (the marking reads
    `indices`, :214), every round picks the same expert."""
    from fractions import Fraction
    s = [Fraction(v) for v in scores]
    b = [Fraction(v) for v in bias] if bias is not None else [Fraction(0)] * len(s)
    chosen, experts = set(), []
    for _ in range(k):
        e = max((i for i in range(len(s)) if i not in chosen), key=lambda i: (s[i] + b[i], -i))
        experts.append(e)
        if not pad:
            chosen.add(e)
    total = sum(s[e] for e in experts)
    denom = total if renormalize and total > 0 else 1
    weights = [s[e] * Fraction(f32(scale)) / denom for e in experts]
    return experts, weights


def moe_topk(name, num_experts, k, tokens=2, cta=1, renormalize=True, scale=1.0, bias=False,
             pad=False, idx="i32", ties=False, seed=11, flip_ties=False, check="ACCEPT",
             note=""):
    """`moeTopK<256>(workspace, nullptr, topk_weights, topk_indices, token_expert_indices,
    E, k, 0, E, renormalize, bias, routed_scaling_factor, is_padding)` on concrete
    probabilities (the softmax/sigmoid workspace, given as float32 bit patterns): the
    unfused path topk_softmax / topk_sigmoid take for an expert count that is not a power
    of two or for row-padded logits, grid tokens, block 256, dispatch :921 (:840).
    Block `cta` routes token `cta`. `ties` repeats scores so the arg-max breaks ties;
    `flip_ties` (a negative case) expects the highest tied expert instead."""
    import random
    rng = random.Random(seed)
    probs = [f32(rng.random()) for _ in range(tokens * num_experts)]
    if ties:
        for t in range(tokens):
            row = probs[t * num_experts:(t + 1) * num_experts]
            top = max(row)
            for e in rng.sample(range(num_experts), 3):
                probs[t * num_experts + e] = top
    bias_vals = [f32(rng.uniform(-0.05, 0.05)) for _ in range(num_experts)] if bias else None
    row = probs[cta * num_experts:(cta + 1) * num_experts]
    experts, weights = topk_reference(row, k, bias_vals, renormalize, scale, pad)
    if flip_ties:
        experts = [num_experts - 1 - e for e in
                   topk_reference(row[::-1], k, bias_vals and bias_vals[::-1], renormalize,
                                  scale, pad)[0]]
    word = (lambda v: v % 2**64) if idx == "i64" else (lambda v: v % 2**32)
    ids = [word(-1 if pad else e) for e in experts]
    spec = write_spec(f"topk_{name}", "\n".join([
        f"// Generated by cases.py (topk_reference) for the case {name}: token {cta}'s "
        f"experts {experts}.",
        "dim T; dim K; dim P;",
        "array topk_weights[T, K];", "array topk_indices[T, K];",
        "array token_expert_indices[T, K];",
        f"topk_weights[t, j] = where(t == P, {table('j', [literal(w) for w in weights])}, "
        "unwritten);",
        f"topk_indices[t, j] = where(t == P, {table('j', ids)}, unwritten);",
        "token_expert_indices[t, j] = where(t == P, j * T + t, unwritten);", ""]))
    arrays = [Array("workspace", "index", "f32", (tokens, num_experts),
                    contents=tuple(f32_bits(v) for v in probs)),
              Array("topk_weights", "out", "f32", (tokens, k)),
              Array("topk_indices", "out", idx, (tokens, k)),
              Array("token_expert_indices", "out", "i32", (tokens, k))]
    if bias:
        arrays.append(Array("bias", "index", "f32", (num_experts,),
                            contents=tuple(f32_bits(v) for v in bias_vals)))
    if pad:  # a 1-byte index array's element i is i (no contents): rows >= 1 are padding
        assert cta >= 1
        arrays.append(Array("is_padding", "index", "u8", (tokens,)))
    return Case(
        name=name,
        description=f"moeTopK, {num_experts} experts, top-{k}, {tokens} tokens, "
                    f"{'' if renormalize else 'no '}renormalize, scale {scale}"
                    f"{', bias' if bias else ''}{', padding row' if pad else ''}, {idx} "
                    f"indices, block {cta}{note}",
        source=f"{TOPK}:165 (moeTopK), dispatch :921",
        unit=TOPK,
        symbol=f"7moeTopKILi256E{IND_MANGLED[idx]}EE",
        args=(Ptr("workspace"), NULL, Ptr("topk_weights"), Ptr("topk_indices"),
              Ptr("token_expert_indices"), Int(num_experts, "num_experts"), Int(k, "k"),
              Int(0, "start_expert"), Int(num_experts, "end_expert"),
              Int(int(renormalize), "renormalize"), Ptr("bias") if bias else NULL,
              Float(scale, "routed_scaling_factor"), Ptr("is_padding") if pad else NULL),
        arrays=tuple(arrays),
        grid=(tokens, 1, 1),
        block=256,
        check=check,
        spec=spec,
        dims={"T": tokens, "K": k, "P": cta},
        cta=(cta, 0, 0),
    )


def moe_softmax(name, num_experts, stride=None, tokens=3, cta=2, dtype="f32", sigmoid=False,
                drop_last=False, check="ACCEPT", note=""):
    """`moeSoftmax<256>` / `moeSigmoid<256>(gating_output, nullptr, workspace, E,
    input_row_stride)`: the first kernel of the unfused path, a row of E scores per block
    into the f32 workspace [T, E]; grid tokens, block 256, dispatch :913 (:832 when the row
    stride is not E). `drop_last` (negative) leaves the last expert out of the spec's
    normalizer."""
    stride = stride or num_experts
    kernel = "10moeSigmoid" if sigmoid else "10moeSoftmax"
    return Case(
        name=name,
        description=f"{'moeSigmoid' if sigmoid else 'moeSoftmax'}, {dtype}, {tokens} tokens of "
                    f"{num_experts} experts, row stride {stride}, block {cta}{note}",
        source=f"{TOPK}:{142 if sigmoid else 81} ({kernel[2:]}), dispatch "
               f"{':832' if stride != num_experts else ':913'}",
        unit=TOPK,
        symbol=f"{kernel}ILi256E{ {'f32': 'f', 'f16': '6__half', 'bf16': '13__nv_bfloat16'}[dtype]}EE",
        args=(Ptr("gating_output"), NULL, Ptr("workspace"), Int(num_experts, "num_cols"),
              Int(stride, "input_row_stride")),
        arrays=(Array("gating_output", "in", dtype, (tokens, stride)),
                Array("workspace", "out", "f32", (tokens, num_experts))),
        grid=(tokens, 1, 1),
        block=256,
        check=check,
        spec="moe_sigmoid.spec" if sigmoid else "moe_softmax.spec",
        dims={"T": tokens, "S": stride, "E": num_experts, "P": cta,
              "N": num_experts - int(drop_last)},
        cta=(cta, 0, 0),
    )


def topk_gating(name, num_experts, k=1, tokens=8, cta=0, dtype="f32", sigmoid=False,
                bias=False, full_warp=False, check="ACCEPT", note=""):
    """`topkGating<VPT, E, 4, BYTES_PER_LDG, 32, int, T, SF, FULL_WARP_SELECT>` (:359), the
    fused path for power-of-two and the listed multiple-of-64 expert counts: VPT and the
    thread split from TopkConstants (:713), 4 warps of rows_per_warp rows, grid
    ceil(ceil(T / rows_per_warp) / 4), launcher :725, dispatch :846. Symbolic logits: the
    arg-max is a select over symbolic comparisons, so only token_expert_indices (and the
    graph checks) are compared; top-1 only (see the cases)."""
    esize = {"f32": 4, "bf16": 2, "f16": 2}[dtype]
    max_bytes = 16 if num_experts & (num_experts - 1) == 0 else (4 if esize == 2 else 8)
    if sigmoid and num_experts == 352:
        max_bytes = esize
    bytes_per_ldg = min(max_bytes, esize * num_experts)
    elts = bytes_per_ldg // esize
    vpt = max(1, num_experts // (elts * 32)) * elts
    rows_per_warp = 32 // (num_experts // vpt)
    rows_per_cta = 4 * rows_per_warp
    grid = -(-(-(-tokens // rows_per_warp)) // 4)
    first = cta * rows_per_cta
    rows = min(rows_per_cta, tokens - first)
    in_t = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16"}[dtype]
    return Case(
        name=name,
        description=f"topkGating, {'sigmoid' if sigmoid else 'softmax'}, {dtype}, {num_experts} "
                    f"experts (VPT {vpt}, {num_experts // vpt} threads per row), top-{k}, "
                    f"{tokens} tokens, block {cta} = rows [{first}, {first + rows}){note}",
        source=f"{TOPK}:359 (topkGating), launcher :725, dispatch :846",
        unit=TOPK,
        symbol=f"10topkGatingILi{vpt}ELi{num_experts}ELi4ELi{bytes_per_ldg}ELi32Ei{in_t}"
               f"LNS0_11ScoringFuncE{int(sigmoid)}ELb{int(full_warp)}EE",
        args=(Ptr("gating_output"), NULL, Ptr("topk_weights"), Int(tokens, "num_rows"),
              Ptr("topk_indices"), Ptr("token_expert_indices"), Int(k, "k"),
              Int(0, "start_expert"), Int(num_experts, "end_expert"), Int(0, "renormalize"),
              Ptr("bias") if bias else NULL, Float(1.0, "routed_scaling_factor"), NULL),
        arrays=(Array("gating_output", "in", dtype, (tokens, num_experts)),
                Array("topk_weights", "out", "f32", (tokens, k)),
                Array("topk_indices", "out", "i32", (tokens, k)),
                Array("token_expert_indices", "out", "i32", (tokens, k)),
                *((Array("bias", "in", "f32", (num_experts,)),) if bias else ())),
        grid=(grid, 1, 1),
        block=(32, 4, 1),
        check=check,
        spec="topk_source_rows.spec",
        dims={"T": tokens, "K": k, "R0": first, "R1": first + rows},
        cta=(cta, 0, 0),
    )


CASES += (
    moe_topk("moe_topk_qwen2_60e_top4", 60, 4, note=" (Qwen1.5-MoE: 60 experts)"),
    moe_topk("moe_topk_60e_ties_no_renorm", 60, 4, renormalize=False, ties=True,
             note=" (4 experts share the top score)"),
    moe_topk("moe_topk_300e_top8_scaled", 300, 8, scale=2.5, tokens=3, cta=2,
             note=" (more experts than threads, routed_scaling_factor 2.5)"),
    moe_topk("moe_topk_72e_bias_top6", 72, 6, bias=True,
             note=" (correction bias picks, unbiased weights)"),
    moe_topk("moe_topk_60e_padding_row", 60, 4, pad=True, note=" (is_padding row)"),
    # Volta gap: the prior-winner check reads `indices[k * row + prior_k]` (:214) of the int64
    # indices as a 4-byte load of each 8-byte element's low word, after which the 8-byte
    # stores no longer read back ("output array 'topk_indices' was written at misaligned
    # offset 0x4"). Correct on hardware.
    moe_topk("moe_topk_60e_i64_indices", 60, 2, idx="i64", tokens=1, cta=0, check="UNKNOWN"),
    moe_topk("moe_topk_60e_u32_indices", 60, 4, idx="u32", renormalize=False),
    moe_topk("moe_topk_1e_top1", 1, 1, tokens=3, cta=2, note=" (a single expert)"),
    # Negative: the spec breaks ties toward the highest tied expert.
    moe_topk("moe_topk_60e_ties_flipped_negative", 60, 4, renormalize=False, ties=True,
             flip_ties=True, check="REJECT"),
    moe_softmax("moe_softmax_60e", 60),
    moe_softmax("moe_softmax_bf16_60e_padded", 60, stride=64, dtype="bf16",
                note=" (Inductor-padded [M, 60] view of stride 64)"),
    moe_softmax("moe_softmax_f16_300e", 300, dtype="f16", tokens=2, cta=1,
                note=" (two columns per thread)"),
    moe_softmax("moe_sigmoid_60e", 60, sigmoid=True),
    moe_softmax("moe_sigmoid_bf16_100e_padded", 100, stride=104, dtype="bf16", sigmoid=True),
    moe_softmax("moe_softmax_60e_negative", 60, drop_last=True, check="REJECT"),
)


CASES += (
    topk_gating("topk_gating_8e_tail", 8, tokens=37, cta=0, note=" (16 rows per warp; warp 2 "
                "half full, warp 3 exits)"),
    topk_gating("topk_gating_bf16_64e", 64, tokens=5, dtype="bf16", note=" (2 threads per row)"),
    topk_gating("topk_gating_192e_non_pow2", 192, tokens=6, cta=1,
                note=" (multiple of 64: 8-byte loads, VPT 6)"),
    topk_gating("topk_gating_f16_576e", 576, tokens=3, dtype="f16", note=" (VPT 18)"),
    topk_gating("topk_gating_sigmoid_352e", 352, tokens=4, sigmoid=True,
                note=" (sigmoid-only 352: eleven scalar loads per lane)"),
    topk_gating("topk_gating_sigmoid_bf16_128e_bias", 128, tokens=4, dtype="bf16",
                sigmoid=True, bias=True, note=" (a correction bias: the loop kernel, :753)"),
    # Volta gap: for k > 1 the winner's slot is cleared by `row_chunk_for_choice[ldg_group *
    # ELTS_PER_LDG + offset] = -10000.f` (:690), a local-memory store at an address the
    # symbolic arg-max picks ("a branch on a symbolic predicate reaches Store").
    topk_gating("topk_gating_8e_top2", 8, k=2, tokens=16, check="UNKNOWN"),
    # The FULL_WARP_SELECT kernel (no bias, >= 128 experts, k <= 32, :564) selects with redux.sync.
    topk_gating("topk_gating_128e_full_warp", 128, tokens=4, full_warp=True),
)


def negative(case, note, **dims):
    """`case` against its spec with `dims` changed: must be refuted."""
    import dataclasses
    return dataclasses.replace(case, name=case.name + "_negative", dims={**case.dims, **dims},
                               check="REJECT", description=case.description + f" (negative: {note})")


CASES += (
    negative(moe_softmax("moe_sigmoid_60e", 60, sigmoid=True), "spec leaves the last expert "
             "unwritten", N=59),
    negative(topk_gating("topk_gating_192e_non_pow2", 192, tokens=6, cta=1),
             "spec expects a row of the block before", R0=3),
)


# ===== MoE routing: sqrt-softplus top-k, DeepSeek-V4 (csrc/moe/topk_softplus_sqrt_*.cu) =====

SOFTPLUS_UNIT = "csrc/moe/topk_softplus_sqrt_{}_int32.cu"
SOFTPLUS_SRC = "csrc/moe/topk_softplus_sqrt_kernels.cuh"
LOG2E_F32 = "12102203 / 8388608"  # __logf(u) lowers to log(u) * f32(log2 e) * f32(ln 2)
LN2_F32 = "0.693147182464599609375"
# The unit instantiating each topk_indices dtype (topk_softplus_sqrt_<gating>_<indices>.cu)
# and the mangled index types: indices int / uint32_t / int64_t, input_ids / tid2eid alike.
SOFTPLUS_UNIT_OF = {"i32": SOFTPLUS_UNIT, "u32": "csrc/moe/topk_softplus_sqrt_{}_uint32.cu",
                    "i64": "csrc/moe/topk_softplus_sqrt_{}_int64.cu"}
SOFTPLUS_IND = {"i32": "i", "u32": "j", "i64": "l"}


def softplus_sqrt(x, threshold=True):
    """The kernels' sqrt(softplus(x)) as Volta lowers it: `__logf(1 + __expf(x))` past the
    threshold 20 (:450, an exact log there), else DeepSeek-V4's stable max(x, 0) +
    __logf(1 + __expf(-|x|)) (:117), its lg2.approx times f32(ln 2) kept."""
    if threshold:
        return f"sqrt(where({x} > 20, {x}, log(1 + exp({x}))))"
    return f"sqrt(max({x}, 0) + log(1 + exp(-abs({x}))) * {LOG2E_F32} * {LN2_F32})"


def hash_routing_spec(name, rows, k, tid2eid, input_ids, pads, scale, renormalize, threshold,
                      index_bits=32):
    """Hash-MoE expected outputs of `rows`: experts tid2eid[input_ids[t]] (concrete), weights
    their sqrt-softplus scores times scale / (their sum if renormalized and > 0, else 1);
    a padding row's indices are -1 and its weights 0."""
    weights, ids = [], []
    for t in rows:
        if t in pads:
            weights.append(table("j", ["0.0"] * k))
            ids.append(table("j", [2**index_bits - 1] * k))
            continue
        experts = tid2eid[input_ids[t] * k:(input_ids[t] + 1) * k]
        w = [softplus_sqrt(f"gating_output[t, {e}]", threshold) for e in experts]
        total = " + ".join(w)
        if renormalize:
            row = [f"{wj} * ({scale} / where({total} > 0, {total}, 1))" for wj in w]
        else:
            row = [f"{wj} * {scale}" for wj in w]
        weights.append(table("j", row))
        ids.append(table("j", experts))
    by_row = lambda per_row: table("t", ["unwritten"] * rows[0] + per_row)
    return write_spec(f"softplus_{name}", "\n".join([
        f"// Generated by cases.py (hash_routing_spec) for the case {name}.",
        "dim T; dim E; dim K;",
        "array gating_output[T, E];", "array topk_weights[T, K];", "array topk_indices[T, K];",
        f"topk_weights[t, j] = {by_row(weights)};",
        f"topk_indices[t, j] = {by_row(ids)};", ""]))


def dsv4_hash_topk(name, num_experts, tokens, cta, pads=(), seed=5, spec_scale=2.5,
                   idx="i32", ids="i32", check="ACCEPT", note=""):
    """`dsv4HashTopkSoftplusSqrt<int, int>(gating, topk_weights, topk_indices, T, E,
    f32(routed_scaling_factor), input_ids, tid2eid, is_padding, nullptr, 0)` (:83), the
    float32 hash path with topk 6, renormalized, 256 or 384 experts (launcher :1 dispatch
    :786): one warp per token, block 128, grid ceil(T / 4) (:203). Block `cta` routes
    tokens 4 cta .. 4 cta + 3."""
    import random
    rng = random.Random(seed)
    vocab = 7
    tid2eid = [e for _ in range(vocab) for e in rng.sample(range(num_experts), 6)]
    input_ids = [rng.randrange(vocab) for _ in range(tokens)]
    if ids == "i64":  # an 8-byte index array's element i is i: token t's experts 6t ..
        vocab, input_ids, tid2eid = tokens, list(range(tokens)), list(range(6 * tokens))
    rows = list(range(4 * cta, min(4 * cta + 4, tokens)))
    spec = hash_routing_spec(name, rows, 6, tid2eid, input_ids, set(pads), spec_scale, True,
                             False, 64 if idx == "i64" else 32)
    given = (lambda v: None) if ids == "i64" else tuple
    arrays = [Array("gating_output", "in", "f32", (tokens, num_experts)),
              Array("topk_weights", "out", "f32", (tokens, 6)),
              Array("topk_indices", "out", idx, (tokens, 6)),
              Array("input_ids", "index", ids, (tokens,), contents=given(input_ids)),
              Array("tid2eid", "index", ids, (vocab, 6), contents=given(tid2eid))]
    if pads:
        assert set(pads) == set(range(1, tokens)), "a 1-byte index array's element i is i"
        arrays.append(Array("is_padding", "index", "u8", (tokens,)))
    return Case(
        name=name,
        description=f"dsv4HashTopkSoftplusSqrt, f32, {tokens} tokens of {num_experts} experts, "
                    f"top-6 renormalized, scale 2.5, block {cta} = tokens {rows}"
                    f"{', padding ' + str(list(pads)) if pads else ''}"
                    f"{f', {idx} indices, {ids} ids' if (idx, ids) != ('i32', 'i32') else ''}{note}",
        source=f"{SOFTPLUS_SRC}:83 (dsv4HashTopkSoftplusSqrt), launcher :203, dispatch :786",
        unit=SOFTPLUS_UNIT_OF[idx].format("f32"),
        symbol=f"24dsv4HashTopkSoftplusSqrtI{SOFTPLUS_IND[idx]}{SOFTPLUS_IND[ids]}EE",
        args=(Ptr("gating_output"), Ptr("topk_weights"), Ptr("topk_indices"),
              Int(tokens, "num_rows"), Int(num_experts, "num_experts"),
              Float(2.5, "routed_scaling_factor"), Ptr("input_ids"), Ptr("tid2eid"),
              Ptr("is_padding") if pads else NULL, NULL, Int(0, "image_sentinel_lo")),
        arrays=tuple(arrays),
        grid=(-(-tokens // 4), 1, 1),
        block=128,
        check=check,
        spec=spec,
        dims={"T": tokens, "E": num_experts, "K": 6},
        cta=(cta, 0, 0),
    )


def softplus_topk(name, num_experts, k, tokens, cta, dtype="bf16", use_hash=True,
                  renormalize=True, pads=(), seed=9, idx="i32", ids="i32", check="ACCEPT",
                  note=""):
    """`topkGatingSoftplusSqrt<VPT, E, 4, BYTES_PER_LDG, 32, USE_HASH, int, int, T>` (:248),
    hash MoE (tid2eid lookups, input_ids int32) or the score top-k; launcher :670, dispatch
    :820 (every case but DeepSeek-V4's f32 / topk 6 / renormalized / 256 or 384 experts).
    Constants as topkGating's; block `cta` routes its rows_per_cta rows."""
    import random
    rng = random.Random(seed)
    esize = {"f32": 4, "bf16": 2, "f16": 2}[dtype]
    max_bytes = 16 if num_experts & (num_experts - 1) == 0 else (4 if esize == 2 else 8)
    bytes_per_ldg = min(max_bytes, esize * num_experts)
    elts = bytes_per_ldg // esize
    vpt = max(1, num_experts // (elts * 32)) * elts
    rows_per_warp = 32 // (num_experts // vpt)
    rows_per_cta = 4 * rows_per_warp
    grid = -(-(-(-tokens // rows_per_warp)) // 4)
    rows = list(range(cta * rows_per_cta, min((cta + 1) * rows_per_cta, tokens)))
    vocab = 5
    tid2eid = [e for _ in range(vocab) for e in rng.sample(range(num_experts), k)]
    input_ids = [rng.randrange(vocab) for _ in range(tokens)]
    if ids == "i64" and use_hash:  # an 8-byte index array's element i is i: experts k t ..
        vocab, input_ids, tid2eid = tokens, list(range(tokens)), list(range(k * tokens))
        assert k * tokens <= num_experts
    given = (lambda v: None) if ids == "i64" else tuple
    in_t = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16"}[dtype]
    arrays = [Array("gating_output", "in", dtype, (tokens, num_experts)),
              Array("topk_weights", "out", "f32", (tokens, k)),
              Array("topk_indices", "out", idx, (tokens, k)),
              Array("token_expert_indices", "out", "i32", (tokens, k))]
    if use_hash:
        arrays += [Array("input_ids", "index", ids, (tokens,), contents=given(input_ids)),
                   Array("tid2eid", "index", ids, (vocab, k), contents=given(tid2eid))]
        spec = hash_routing_spec(name, rows, k, tid2eid, input_ids, set(pads), 1.5,
                                 renormalize, True, 64 if idx == "i64" else 32)
        dims = {"T": tokens, "E": num_experts, "K": k}
    else:
        spec, dims = "topk_source_rows.spec", {"T": tokens, "K": k, "R0": rows[0],
                                               "R1": rows[-1] + 1}
    if pads:
        assert set(pads) == set(range(1, tokens)), "a 1-byte index array's element i is i"
        arrays.append(Array("is_padding", "index", "u8", (tokens,)))
    return Case(
        name=name,
        description=f"topkGatingSoftplusSqrt, {'hash' if use_hash else 'score top-k'}, {dtype}, "
                    f"{tokens} tokens of {num_experts} experts (VPT {vpt}), top-{k}, "
                    f"{'' if renormalize else 'no '}renormalize, scale 1.5, block {cta} = rows "
                    f"[{rows[0]}, {rows[-1] + 1}){', padding ' + str(list(pads)) if pads else ''}"
                    f"{f', {idx} indices, {ids} ids' if (idx, ids) != ('i32', 'i32') else ''}"
                    f"{note}",
        source=f"{SOFTPLUS_SRC}:248 (topkGatingSoftplusSqrt), launcher :670, dispatch :820",
        unit=SOFTPLUS_UNIT_OF[idx].format(dtype),
        symbol=f"22topkGatingSoftplusSqrtILi{vpt}ELi{num_experts}ELi4ELi{bytes_per_ldg}ELi32ELb"
               f"{int(use_hash)}E{SOFTPLUS_IND[idx]}{SOFTPLUS_IND[ids]}{in_t}EE",
        args=(Ptr("gating_output"), NULL, Ptr("topk_weights"), Int(tokens, "num_rows"),
              Ptr("topk_indices"), Ptr("token_expert_indices"), Int(k, "k"),
              Int(0, "start_expert"), Int(num_experts, "end_expert"),
              Int(int(renormalize), "renormalize"), Float(1.5, "routed_scaling_factor"), NULL,
              Ptr("input_ids") if use_hash else NULL, Ptr("tid2eid") if use_hash else NULL,
              Ptr("is_padding") if pads else NULL, NULL, Int(0, "image_sentinel_lo")),
        arrays=tuple(arrays),
        grid=(grid, 1, 1),
        block=(32, 4, 1),
        check=check,
        spec=spec,
        dims=dims,
        cta=(cta, 0, 0),
    )


CASES += (
    dsv4_hash_topk("dsv4_hash_topk_256e", 256, 6, cta=1, note=" (last block: 2 of 4 warps)"),
    dsv4_hash_topk("dsv4_hash_topk_384e_padding", 384, 4, cta=0, pads=(1, 2, 3)),
    dsv4_hash_topk("dsv4_hash_topk_256e_scale_negative", 256, 6, cta=1, spec_scale=2.0,
                   check="REJECT", note=" (negative: spec scales by 2, not 2.5)"),
    softplus_topk("softplus_hash_bf16_256e_top8", 256, 8, 6, cta=1),
    softplus_topk("softplus_hash_bf16_64e_top6_no_renorm", 64, 6, 20, cta=0, renormalize=False,
                  note=" (16 rows per warp)"),
    softplus_topk("softplus_hash_bf16_32e_top4_padding", 32, 4, 3, cta=0, pads=(1, 2)),
    softplus_topk("softplus_hash_f16_192e_top4", 192, 4, 5, cta=1, dtype="f16"),
    softplus_topk("softplus_hash_f32_256e_top6_no_renorm", 256, 6, 4, cta=0, dtype="f32",
                  renormalize=False, note=" (not renormalized: not the DeepSeek-V4 kernel)"),
    softplus_topk("softplus_topk_bf16_256e_top1", 256, 1, 6, cta=1, use_hash=False),
    softplus_topk("softplus_topk_f32_16e_top1", 16, 1, 40, cta=0, dtype="f32", use_hash=False),
)


# ===== MoE permute / unpermute (csrc/moe/moe_permute_unpermute_op.cu) =====

PERMUTE = "csrc/moe/moe_permute_unpermute_op.cu"
PERMUTE_SRC = "csrc/moe/permute_unpermute_kernels/moe_permute_unpermute_kernel.inl"
PERMUTE_MANGLED = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16",
                   "e4m3": "13__nv_fp8_e4m3", "e5m2": "13__nv_fp8_e5m2", "u8": "h"}
VALID_BASE = 0x800000  # an int64 index array whose element V is the valid-row count V


def word_view(dtype, cols):
    """The dtype and row length a case registers a row as: fp8 rows as 32-bit words, since
    their 16-byte copies move whole words and Volta reads back an output element only at
    the width it was written ("written at width 4 (element width 1)")."""
    return ("i32", cols // 4) if dtype in ("e4m3", "e5m2", "u8") else (dtype, cols)


def sorted_routing(tokens, topk, num_experts, local=None, seed=3):
    """What moe_sort_routing (:59) hands the permute kernels: sorted_row_idx (expanded dest
    row -> expanded source row t * topk + j, ordered by local expert, non-local last),
    its inverse, and the number of rows routed to a local expert."""
    ids = routed(tokens, topk, num_experts, seed)
    local = local or (lambda e: e)
    key = lambda i: (local(ids[i]) if local(ids[i]) >= 0 else num_experts, i)
    order = sorted(range(tokens * topk), key=key)
    inverse = [0] * len(order)
    for d, s in enumerate(order):
        inverse[s] = d
    valid = sum(local(e) >= 0 for e in ids)
    return order, inverse, valid


def expand_rows(name, tokens, topk, cols, cta, num_experts=8, dtype="bf16", ep=False,
                check="ACCEPT", note=""):
    """`expandInputRowsKernel<T, CHECK_SKIPPED>(input, permuted_input, sorted_row_idx,
    inv_permuted_idx, permuted_idx, expert_first_token_offset, T, valid_num_ptr, hidden,
    topk, n_local_expert)` (.inl :4): grid T topk, block 256, one 16-byte vector per thread
    and step; CHECK_SKIPPED with an expert map (valid_num_ptr = expert_first_token_offset +
    n_local_expert, moe_permute_impl :152). Block `cta` is expanded dest row `cta`."""
    half = num_experts // 2
    order, _, valid = sorted_routing(tokens, topk, num_experts,
                                     (lambda e: e - half if e >= half else -1) if ep else None)
    src = order[cta]
    in_range = int(not ep or cta < valid)
    view, width = word_view(dtype, cols)
    return Case(
        name=name,
        description=f"expandInputRowsKernel, {dtype}, {tokens} tokens x topk {topk} x {cols}, "
                    f"{num_experts} experts{', EP rank 1 of 2 (' + str(valid) + ' local rows)' if ep else ''}, "
                    f"block {cta} = source row {src}{note}",
        source=f"{PERMUTE_SRC}:4 (expandInputRowsKernel), launcher .inl:55, {PERMUTE}:158",
        unit=PERMUTE,
        symbol=f"21expandInputRowsKernelI{PERMUTE_MANGLED[dtype]}Lb{int(ep)}EE",
        args=(Ptr("input"), Ptr("permuted_input"), Ptr("sorted_row_idx"),
              Ptr("inv_permuted_idx"), Ptr("permuted_idx"), Ptr("expert_first_token_offset"),
              Int(tokens, "num_rows"),
              Int(VALID_BASE + 8 * valid, "num_dest_rows") if ep else NULL,
              Int(cols, "cols"), Int(topk, "k"), Int(half if ep else num_experts,
                                                       "num_local_experts")),
        arrays=(Array("input", "in", view, (tokens, width)),
                Array("permuted_input", "out", view, (tokens * topk, width)),
                Array("sorted_row_idx", "index", "i32", (tokens * topk,), contents=tuple(order)),
                Array("inv_permuted_idx", "out", "i32", (tokens * topk,)),
                Array("permuted_idx", "out", "i32", (tokens * topk,)),
                Array("expert_first_token_offset", "index", "i64", (valid + 1,),
                      base=VALID_BASE)),
        grid=(tokens * topk, 1, 1),
        block=256,
        check=check,
        spec="expand_input_rows.spec",
        dims={"N": tokens, "R": tokens * topk, "D": width, "P": cta, "S": src,
              "SR": src // topk, "V": in_range},
        cta=(cta, 0, 0),
    )


def finalize_routing(name, tokens, topk, cols, cta, num_experts=8, dtype="bf16", ep=False,
                     seed=3, check="ACCEPT", note=""):
    """`finalizeMoeRoutingKernel<T, T, CHECK_SKIPPED>(permuted_hidden_states, hidden_states,
    topk_weights, inv_permuted_idx, hidden, topk, valid_ptr)` (.inl :93), moe_unpermute
    :242: grid T, block 256; token t sums topk_weights[t, j] times its expanded row
    inv_permuted_idx[t topk + j], skipping rows past the valid count (expert map). Block
    `cta` is token `cta`. The spec is generated with the token's concrete rows."""
    half = num_experts // 2
    _, inverse, valid = sorted_routing(tokens, topk, num_experts,
                                       (lambda e: e - half if e >= half else -1) if ep else None,
                                       seed)
    terms = [f"topk_weights[t, {j}] * permuted_hidden_states[{inverse[cta * topk + j]}, c]"
             for j in range(topk) if not ep or inverse[cta * topk + j] < valid]
    spec = write_spec(f"finalize_{name}", "\n".join([
        f"// Generated by cases.py (finalize_routing) for the case {name}: token {cta}'s "
        f"expanded rows {inverse[cta * topk:(cta + 1) * topk]}"
        f"{f', the first {valid} valid' if ep else ''}.",
        "dim T; dim K; dim R; dim D; dim P;",
        "array permuted_hidden_states[R, D];", "array topk_weights[T, K];",
        "array hidden_states[T, D];",
        f"hidden_states[t, c] = where(t == P, {' + '.join(terms) or '0'}, unwritten);", ""]))
    return Case(
        name=name,
        description=f"finalizeMoeRoutingKernel, {dtype}, {tokens} tokens x topk {topk} x {cols}"
                    f"{', EP: ' + str(valid) + ' valid rows' if ep else ''}, block {cta}{note}",
        source=f"{PERMUTE_SRC}:93 (finalizeMoeRoutingKernel), launcher .inl:151, {PERMUTE}:242",
        unit=PERMUTE,
        symbol=f"24finalizeMoeRoutingKernelI{PERMUTE_MANGLED[dtype]}"
               f"{'S0_' if dtype != 'f32' else 'f'}Lb{int(ep)}EE",
        args=(Ptr("permuted_hidden_states"), Ptr("hidden_states"), Ptr("topk_weights"),
              Ptr("inv_permuted_idx"), Int(cols, "orig_cols"), Int(topk, "k"),
              Int(VALID_BASE + 8 * valid, "num_valid_ptr") if ep else NULL),
        arrays=(Array("permuted_hidden_states", "in", dtype, (tokens * topk, cols)),
                Array("hidden_states", "out", dtype, (tokens, cols)),
                Array("topk_weights", "in", "f32", (tokens, topk)),
                Array("inv_permuted_idx", "index", "i32", (tokens * topk,),
                      contents=tuple(inverse)),
                *((Array("expert_first_token_offset", "index", "i64", (valid + 1,),
                         base=VALID_BASE),) if ep else ())),
        grid=(tokens, 1, 1),
        block=256,
        check=check,
        spec=spec,
        dims={"T": tokens, "K": topk, "R": tokens * topk, "D": cols, "P": cta},
        cta=(cta, 0, 0),
    )


def shuffle_rows(name, src_rows, dst2src, cols, cta, dtype="bf16", check="ACCEPT", note=""):
    """`shuffle_rows(input [S, cols], dst2src_map [D] int32, output [D, cols])`, the
    shuffleInputRowsKernel (:252): grid D, block 256; a destination row whose source is out
    of [0, S) is zero-filled. Block `cta` writes destination row `cta`. fp8 rows are
    registered as 32-bit words (see `word_view`)."""
    src = dst2src[cta]
    view, width = word_view(dtype, cols)
    return Case(
        name=name,
        description=f"shuffle_rows, {dtype}, {src_rows} source rows -> {len(dst2src)} rows of "
                    f"{cols}, block {cta} from row {src}{note}",
        source=f"{PERMUTE}:252 (shuffleInputRowsKernel), shuffle_rows :288",
        unit=PERMUTE,
        symbol=f"22shuffleInputRowsKernelI{PERMUTE_MANGLED[dtype]}E",
        args=(Ptr("input"), Ptr("dst2src_map"), Ptr("output"), Int(src_rows, "num_src_rows"),
              Int(len(dst2src), "num_dst_rows"), Int(cols, "num_cols")),
        arrays=(Array("input", "in", view, (src_rows, width)),
                Array("dst2src_map", "index", "i32", (len(dst2src),), contents=tuple(dst2src)),
                Array("output", "out", view, (len(dst2src), width))),
        grid=(len(dst2src), 1, 1),
        block=256,
        check=check,
        spec="shuffle_rows.spec",
        dims={"N": src_rows, "M": len(dst2src), "D": width, "P": cta,
              "S": max(src, 0), "V": int(0 <= src < src_rows)},
        cta=(cta, 0, 0),
    )


SHUFFLE_MAP = (4, 0, -1, 2, 7, 1, 3)  # one -1 (zero row), one id past the 5 source rows

CASES += (
    expand_rows("expand_rows_mixtral_4096", 6, 2, 4096, cta=7, note=" (two 16-byte steps)"),
    expand_rows("expand_rows_f32_100", 4, 3, 100, cta=11, dtype="f32",
                note=" (25 vectors: a partial thread step)"),
    expand_rows("expand_rows_ep_valid", 5, 2, 2048, cta=1, num_experts=8, ep=True),
    expand_rows("expand_rows_ep_skipped", 5, 2, 2048, cta=9, num_experts=8, ep=True,
                note=" (a non-local row: only inv_permuted_idx)"),
    expand_rows("expand_rows_fp8_7168", 3, 8, 7168, cta=20, num_experts=16, dtype="e4m3",
                note=" (DeepSeek-V3 hidden, fp8 activations)"),
    negative(expand_rows("expand_rows_mixtral_4096", 6, 2, 4096, cta=7),
             "spec reads the next source token", SR=4),
    finalize_routing("finalize_routing_f32_4096", 6, 2, 4096, cta=4, dtype="f32"),
    finalize_routing("finalize_routing_f32_ep", 5, 4, 1024, cta=3, num_experts=8, dtype="f32",
                     ep=True, note=" (non-local experts skipped)"),
    finalize_routing("finalize_routing_f32_ep_all_remote", 3, 4, 512, cta=0, num_experts=16,
                     dtype="f32", ep=True, seed=8, note=" (no local expert: a zero row)"),
    # The bf16 / f16 output packs two cvt.rn.bf16.f32 halves with cvt.u32.u16, shl 16 and
    # or.b32 into one 32-bit word (arrayConvert, .inl:144), read back as its two halves.
    finalize_routing("finalize_routing_bf16_4096", 6, 2, 4096, cta=4),
    finalize_routing("finalize_routing_f16_top8_2048", 3, 8, 2048, cta=2, num_experts=16,
                     dtype="f16"),
    negative(finalize_routing("finalize_routing_f32_4096", 6, 2, 4096, cta=4, dtype="f32"),
             "spec expects the previous token's row", P=3),
    shuffle_rows("shuffle_rows_bf16_copy", 5, SHUFFLE_MAP, 4096, cta=0),
    shuffle_rows("shuffle_rows_f16_last", 5, SHUFFLE_MAP, 1024, cta=6, dtype="f16",
                 note=" (last block)"),
    shuffle_rows("shuffle_rows_bf16_zero", 5, SHUFFLE_MAP, 4096, cta=2,
                 note=" (dst2src -1: zero row)"),
    shuffle_rows("shuffle_rows_f32_out_of_range", 5, SHUFFLE_MAP, 1028, cta=4, dtype="f32",
                 note=" (source id 7 >= 5 rows: zero row)"),
    shuffle_rows("shuffle_rows_fp8_7168", 5, SHUFFLE_MAP, 7168, cta=3, dtype="e4m3"),
    negative(shuffle_rows("shuffle_rows_bf16_copy", 5, SHUFFLE_MAP, 4096, cta=0),
             "spec copies row 1", S=1),
)


# ===== fp8 per-token-group quantization (csrc/quantization/w8a8/fp8/per_token_group_quant.cu) =====

PTG = "csrc/quantization/w8a8/fp8/per_token_group_quant.cu"
QUANT_MANGLED = {"bf16": "N3c108BFloat16E", "f16": "N3c104HalfE", "f32": "f"}
QUANT_EPS = f32(1e-10)  # per_token_group_quant_fp8's eps, as the host's (float)eps passes it
FP8_MAX = 448.0


def groups_per_block(num_groups):
    """GetGroupsPerBlock (:323)."""
    return next(g for g in (16, 8, 4, 2, 1) if num_groups % g == 0)


def ptg_quant(name, tokens, hidden, group, cta, dtype="bf16", col_major=False, ue8m0=False,
              pad_rows=0, check="ACCEPT", note=""):
    """`per_token_group_quant_fp8(x [M, H], x_q, x_s, group_size, eps=1e-10, -448, 448,
    use_ue8m0, column_major_scales)`, the host helper :353. The register kernel (:181:
    8 threads per group, 256 per block) when group_size is 128 with 16-bit input (:310),
    else the shared-memory kernel (:102: 16 threads per group, groups_per_block from
    GetGroupsPerBlock of the row count rounded up to even, the bounds-checked instance when
    that does not divide the group count). x_s is [M, H / group] row-major, or the
    permuted view of a [H / group, M + pad_rows] buffer (column_major_scales,
    fp8_utils.py:697; pad_rows models a TMA-aligned stride). UE8M0 scales (rounded up to a
    power of two through the float's exponent bits, :262) are race-only. Only the scales are
    compared:
    the fp8 output bytes are packed from cvt.rn.satfinite.e4m3x2 pairs with shifts and ors
    into words Volta keeps opaque, so x_q is registered as 32-bit words, unchecked."""
    gpr = hidden // group
    num_groups = tokens * gpr
    register = group == 128 and dtype in ("bf16", "f16")
    if register:
        gpb, threads, smem, bounds = 32, 256, 0, None
    else:
        gpb = groups_per_block((tokens + (tokens & 1)) * gpr)
        threads, smem, bounds = gpb * 16, gpb * group * SCALAR_BYTES[dtype], num_groups % gpb != 0
    grid = -(-num_groups // gpb)
    g0, g1 = cta * gpb, min((cta + 1) * gpb, num_groups)
    stride = tokens + pad_rows
    if register:
        symbol = (f"42per_token_group_quant_8bit_register_kernelI{QUANT_MANGLED[dtype]}"
                  f"NS0_13Float8_e4m3fnELb{int(col_major)}ELb{int(ue8m0)}ELi128EE")
        args = (Ptr("x"), Ptr("x_q"), Ptr("x_s"), Int(num_groups, "num_groups"),
                Float(QUANT_EPS, "eps"), Float(-FP8_MAX, "min_8bit"), Float(FP8_MAX, "max_8bit"),
                Int(gpr, "scale_num_rows"), Int(stride if col_major else 1, "scale_stride"))
        source = f"{PTG}:181 (per_token_group_quant_8bit_register_kernel), host :353"
    else:
        symbol = (f"33per_token_group_quant_8bit_kernelI{QUANT_MANGLED[dtype]}"
                  f"{'NS0_' if dtype != 'f32' else 'N3c10'}13Float8_e4m3fnELb{int(col_major)}ELb"
                  f"{int(ue8m0)}EfLb{int(bounds)}EE")
        args = (Ptr("x"), Ptr("x_q"), Ptr("x_s"), Int(group, "group_size"),
                Int(num_groups, "num_groups"), Int(gpb, "groups_per_block"),
                Float(QUANT_EPS, "eps"), Float(-FP8_MAX, "min_8bit"), Float(FP8_MAX, "max_8bit"),
                Int(gpr, "scale_num_rows"), Int(stride if col_major else 1, "scale_stride"))
        source = f"{PTG}:102 (per_token_group_quant_8bit_kernel), host :353"
    return Case(
        name=name,
        description=f"per_token_group_quant_fp8, {dtype}, {tokens} tokens x {hidden}, group "
                    f"{group}, {'register' if register else 'shared-memory'} kernel, "
                    f"{gpb} groups per block{', bounds-checked' if bounds else ''}, "
                    f"{'column-major scales (stride ' + str(stride) + ')' if col_major else 'row-major scales'}"
                    f"{', UE8M0' if ue8m0 else ''}, block {cta} = groups [{g0}, {g1}){note}",
        source=source,
        unit=PTG,
        symbol=symbol,
        args=args,
        arrays=(Array("x", "in", dtype, (tokens, hidden)),
                Array("x_q", "out", "i32", (tokens, hidden // 4)),
                Array("x_s", "out", "f32", (gpr, stride) if col_major else (tokens, gpr))),
        grid=(grid, 1, 1),
        block=threads,
        check=check,
        spec=None if ue8m0 else "ptg_quant_scales_col.spec" if col_major else "ptg_quant_scales.spec",
        dims={} if ue8m0 else {"M": tokens, "H": hidden, "GP": gpr, "S": group, "ST": stride,
                               "G0": g0, "G1": g1},
        cta=(cta, 0, 0),
        smem=smem,
    )


CASES += (
    ptg_quant("ptg_quant_f32_dsv3_3tok", 3, 7168, 128, cta=10, dtype="f32",
              note=" (odd rows: 16 groups per block, 168 groups, last block half full)"),
    ptg_quant("ptg_quant_bf16_g64", 2, 1024, 64, cta=1),
    ptg_quant("ptg_quant_f16_g64_col_major", 3, 512, 64, cta=1, dtype="f16", col_major=True,
              pad_rows=1, note=" (TMA-aligned stride 4)"),
    ptg_quant("ptg_quant_bf16_g128_register", 3, 2048, 128, cta=1,
              note=" (48 groups: the second block's last 16 lanes' groups past the end)"),
    ptg_quant("ptg_quant_bf16_g128_register_col_major", 2, 4096, 128, cta=1, col_major=True,
              pad_rows=2),
    ptg_quant("ptg_quant_f32_g32_col_major_bounds", 5, 96, 32, cta=7, dtype="f32",
              col_major=True, pad_rows=3, note=" (15 groups, 2 per block: the last half empty)"),
    ptg_quant("ptg_quant_bf16_g128_register_ue8m0", 2, 2048, 128, cta=0, ue8m0=True,
              check="VERIFIED", note=" (DeepGEMM power-of-two scales, race-only)"),
    negative(ptg_quant("ptg_quant_f16_g64_col_major", 3, 512, 64, cta=1, dtype="f16",
                       col_major=True, pad_rows=1), "spec scales by the row-major stride", ST=3),
)


# ===== Fused SiLU-and-mul + fp8 per-block quantization (fused_silu_mul_block_quant.cu) =====

SILU_QUANT = "csrc/quantization/fused_kernels/fused_silu_mul_block_quant.cu"
MIN_SCALE = f32(1 / (448 * 512))  # min_scaling_factor<fp8>::val() (utils.cuh:52)


def silu_block_quant_spec(transposed, ub):
    """The scales of silu_and_mul_per_block_quant: group g of token t (global group t G + g)
    over r = silu(gate) up, max(min(max |r| / 448, ub), 1 / (448 * 512)); the block writes
    global groups [G0, G1)."""
    from decimal import Decimal
    r = "input[t, g * S + i] * (1 / (1 + exp(-input[t, g * S + i]))) * input[t, H + g * S + i]"
    scale = f"max(0, max(i in 0..S, abs({r}))) / 448"  # local_max starts at 0 (:145)
    if ub:
        scale = f"min({scale}, scale_ub[0])"
    scale = f"max({scale}, {Decimal(MIN_SCALE)})"
    name = f"silu_block_quant_scales{'_t' if transposed else ''}{'_ub' if ub else ''}"
    return write_spec(name, "\n".join([
        f"// Generated by cases.py (silu_block_quant_spec): the scales of vLLM's",
        f"// silu_and_mul_per_block_quant ({SILU_QUANT}:113), {'[G, T]' if transposed else '[T, G]'}"
        f"{', scale_ub' if ub else ''}.",
        "dim T; dim H; dim G; dim S; dim G0; dim G1;",
        "dim H2;", "array input[T, H2];",
        *(["dim ONE;", "array scale_ub[ONE];"] if ub else []),
        f"array scales[{'G, T' if transposed else 'T, G'}];",
        f"scales[{'g, t' if transposed else 't, g'}] = where(t * G + g < G0, unwritten, "
        f"where(t * G + g < G1, {scale}, unwritten));", ""]))


def silu_block_quant(name, tokens, hidden, group, cta, dtype="bf16", transposed=False,
                     ub=False, vec=True, check="ACCEPT", note=""):
    """`silu_and_mul_per_block_quant(out [T, H] fp8, input [T, 2H], scales, group_size,
    scale_ub, is_scale_transposed)` (:186). With 16-bit input, aligned rows and >= 3072
    groups (:227) the vector kernel (:113: group_size / 8 lanes per group, block 256, grid
    ceil(T G lanes / 256)), else one block of group_size threads per (token, group) (:16).
    Only the scales are compared: the fp8 bytes are packed into words Volta keeps opaque,
    so `out` is registered as 32-bit words, unchecked."""
    groups = hidden // group
    lanes = group // 8
    gpb = 256 // lanes
    total = tokens * groups
    g0, g1 = cta * gpb, min((cta + 1) * gpb, total)
    in_t = QUANT_MANGLED[dtype]
    arrays = [Array("input", "in", dtype, (tokens, 2 * hidden)),
              Array("out", "out", "i32", (tokens, hidden // 4)),
              Array("scales", "out", "f32", (groups, tokens) if transposed else (tokens, groups))]
    if ub:
        arrays.append(Array("scale_ub", "in", "f32", (1,)))
    if vec:
        kernel, line = "39silu_and_mul_per_block_quant_vec_kernel", 113
        args = (Ptr("out"), Ptr("scales"), Ptr("input"), Ptr("scale_ub") if ub else NULL,
                Int(hidden, "hidden_size"), Int(groups, "num_groups"),
                Int(tokens, "num_tokens"))
        grid, block, cta3 = (-(-total * lanes // 256), 1, 1), 256, (cta, 0, 0)
    else:
        kernel, line = "35silu_and_mul_per_block_quant_kernel", 16
        args = (Ptr("out"), Ptr("scales"), Ptr("input"), Ptr("scale_ub") if ub else NULL,
                Int(hidden, "hidden_size"))
        t, g = divmod(cta, groups)
        g0, g1 = cta, cta + 1
        grid, block, cta3 = (tokens, groups, 1), group, (t, g, 0)
    return Case(
        name=name,
        description=f"silu_and_mul_per_block_quant, {dtype} -> fp8, {tokens} tokens x {hidden}, "
                    f"group {group}, {'vector' if vec else 'per-group'} kernel, "
                    f"{'transposed ' if transposed else ''}scales{', scale_ub' if ub else ''}, "
                    f"block {cta3[:2]} = groups [{g0}, {g1}){note}",
        source=f"{SILU_QUANT}:{line} ({kernel[2:]}), dispatch :186",
        unit=SILU_QUANT,
        symbol=f"{kernel}I{in_t}NS1_13Float8_e4m3fnELb{int(transposed)}ELi{group}EE",
        args=args,
        arrays=tuple(arrays),
        grid=grid,
        block=block,
        check=check,
        spec=silu_block_quant_spec(transposed, ub),
        dims={"T": tokens, "H": hidden, "H2": 2 * hidden, "G": groups, "S": group, "G0": g0,
              "G1": g1, **({"ONE": 1} if ub else {})},
        cta=cta3,
    )


CASES += (
    silu_block_quant("silu_block_quant_vec_bf16_g128_tail", 25, 15872, 128, cta=193,
                     note=" (3100 groups: the last block's 12 of 16)"),
    silu_block_quant("silu_block_quant_vec_f16_g64_transposed_ub", 48, 4096, 64, cta=3,
                     dtype="f16", transposed=True, ub=True),
    silu_block_quant("silu_block_quant_vec_bf16_g128_transposed", 24, 16384, 128, cta=100,
                     transposed=True),
    negative(silu_block_quant("silu_block_quant_vec_bf16_g128_transposed", 24, 16384, 128,
                              cta=100, transposed=True), "spec's groups of 64", S=64),
    # Volta gap: the per-group kernel (fewer than 3072 groups) converts with c10's software
    # Float8_e4m3fn and stores each byte from a 32-bit register ("symbolic value stored at
    # sub-register width (8-bit store of a 32-bit register)", :102), aborting the run.
    silu_block_quant("silu_block_quant_bf16_g128_small", 2, 512, 128, cta=6, vec=False,
                     check="UNKNOWN"),
)


# ===== fp32 router GEMM (csrc/fp32_router_gemm.cu) =====

ROUTER = "csrc/fp32_router_gemm.cu"


def router_geometry(dtype, m, experts, hidden):
    """invokeFp32RouterGemm's (block size, experts per block, token groups) on Blackwell
    (:211)."""
    if dtype == "bf16" and (experts, hidden) == (256, 5120):
        if m > 16 and m % 8 == 0:
            return (160 if m == 24 else 128), 2, 4
        return (64 if m == 1 else 128), 1, (2 if m % 2 == 0 else 1)
    if dtype == "bf16" and (experts, hidden) == (128, 6144):
        if m >= 12 and m % 2 == 0:
            return 192, 1, 2
        return 384, 1, (2 if m >= 6 and m % 2 == 0 else 1)
    if dtype == "bf16" and (experts, hidden) == (256, 3072):
        if m >= 14 and m % 2 == 0:
            return 192, 2, 2
        return (192, 1, 2) if 8 <= m <= 12 and m % 2 == 0 else (128, 1, 1)
    if dtype == "bf16" and (experts, hidden) == (256, 8192):
        if m >= 10 and m % 2 == 0:
            return 256, 2, 2
        return (256, 2, 1) if m >= 13 else (256, 1, 1)
    return 128, 1, 1


def router_gemm(name, m, experts, hidden, cta, dtype="bf16", check="ACCEPT", note=""):
    """`fp32_router_gemm_kernel<T, BS, M, EPB, E, H, TG>(out [M, E], a [M, H], b [E, H] fp32)`
    (:85): grid E / EPB, block BS TG; block `cta` computes experts [cta EPB, cta EPB + EPB)
    of every token, launcher :179."""
    bs, epb, tg = router_geometry(dtype, m, experts, hidden)
    in_t = "13__nv_bfloat16" if dtype == "bf16" else "f"
    return Case(
        name=name,
        description=f"fp32_router_gemm, {dtype} activations, M={m}, E={experts}, H={hidden}: "
                    f"block {bs}, {epb} expert(s) per block, {tg} token group(s), block {cta}"
                    f"{note}",
        source=f"{ROUTER}:85 (fp32_router_gemm_kernel), invokeFp32RouterGemm :211",
        unit=ROUTER,
        symbol=f"23fp32_router_gemm_kernelI{in_t}Li{bs}ELi{m}ELi{epb}ELi{experts}ELi{hidden}"
               f"ELi{tg}EE",
        args=(Ptr("out"), Ptr("mat_a"), Ptr("mat_b")),
        arrays=(Array("mat_a", "in", dtype, (m, hidden)),
                Array("mat_b", "in", "f32", (experts, hidden)),
                Array("out", "out", "f32", (m, experts))),
        grid=(experts // epb, 1, 1),
        block=bs * tg,
        check=check,
        spec="router_gemm.spec",
        dims={"M": m, "E": experts, "H": hidden, "E0": cta * epb, "E1": (cta + 1) * epb},
        cta=(cta, 0, 0),
    )


CASES += (
    router_gemm("router_gemm_bf16_m1_256x5120", 1, 256, 5120, cta=255, note=" (64 threads)"),
    router_gemm("router_gemm_bf16_m24_256x5120", 24, 256, 5120, cta=7,
                note=" (160 x 4 token groups, 2 experts per block)"),
    router_gemm("router_gemm_bf16_m7_128x6144", 7, 128, 6144, cta=127, note=" (MiniMax-M3)"),
    router_gemm("router_gemm_bf16_m14_256x3072", 14, 256, 3072, cta=3),
    router_gemm("router_gemm_bf16_m13_256x8192", 13, 256, 8192, cta=127, note=" (Muse Spark)"),
    router_gemm("router_gemm_f32_m3_352x4096", 3, 352, 4096, cta=351, dtype="f32",
                note=" (Step-5, fp32 activations)"),
    negative(router_gemm("router_gemm_bf16_m14_256x3072", 14, 256, 3072, cta=3),
             "spec's dot products stop one element short", H=3071),
)


# ===== DeepSeek-V3 fused-A GEMM (csrc/dsv3_fused_a_gemm.cu, warp-specialized, mbarriers) =====

DSV3_GEMM = "csrc/dsv3_fused_a_gemm.cu"


def fused_a_gemm(name, tokens, hd_in, hd_out, cta, tile_k=256, tile_m=16, row_stride=None,
                 lane0=False, check="REJECT", note=""):
    """`dsv3_fused_a_gemm(output [T, hd_out], mat_a [T, hd_in] (row stride `row_stride`),
    mat_b column-major [hd_in, hd_out], enable_pdl)` (:719): invokeFusedAGemm (:651) swaps
    the operands, tile_n 8 for T <= 8 else 16, stage_cnt = min(hd_in / tile_k,
    192 KiB / ((tile_m + tile_n) tile_k 2)), grid (hd_out / tile_m, ceil(T / tile_n)),
    256 threads: two warps load the weight and two the activations with cp.async +
    cp.async.mbarrier.arrive.noinc, four mma.sync warps split K and reduce through shared
    memory. The weight is registered as its [hd_out, hd_in] row-major storage."""
    stride = row_stride or hd_in
    tile_n = 8 if tokens <= 8 else 16
    max_stage = 1024 * 192 // ((tile_m + tile_n) * tile_k * 2)
    stage = min(hd_in // tile_k, max_stage)
    barrier = (stage * 16 + 1023) // 1024 * 1024
    smem = ((tile_m * 2 + tile_n * 2) * tile_k * stage + barrier + 1023) // 1024 * 1024
    bx, by = cta
    return Case(
        name=name,
        description=f"dsv3_fused_a_gemm, bf16, {tokens} tokens x {hd_in} -> {hd_out}, tiles "
                    f"{tile_m} x {tile_n} x {tile_k}, {stage} stages over {hd_in // tile_k} K "
                    f"tiles, row stride {stride}, block {cta}{note}",
        source=f"{DSV3_GEMM}:588 (fused_a_gemm_kernel), invokeFusedAGemm :651, dispatch :719"
               f"{'; barrier init patched to lane 0' if lane0 else ''}",
        unit=LANE0_UNIT if lane0 else DSV3_GEMM,
        symbol=f"19fused_a_gemm_kernelILi1ELi{hd_out}ELi{hd_in}ELi{tile_m}ELi{tile_n}ELi{tile_k}"
               f"ELi{stage}EE",
        args=(Ptr("output"), Ptr("weight"), Ptr("mat_a"), Int(tokens, "gemm_n"),
              Int(stride, "input_row_stride")),
        arrays=(Array("mat_a", "in", "bf16", (tokens, stride)),
                Array("weight", "in", "bf16", (hd_out, hd_in)),
                Array("output", "out", "bf16", (tokens, hd_out))),
        grid=(hd_out // tile_m, -(-tokens // tile_n), 1),
        block=256,
        check=check,
        spec="fused_a_gemm.spec",
        dims={"T": tokens, "S": stride, "K": hd_in, "O": hd_out, "O0": bx * tile_m,
              "O1": (bx + 1) * tile_m, "N0": by * tile_n, "N1": min((by + 1) * tile_n, tokens)},
        cta=(bx, by, 0),
        smem=smem,
    )


LANE0_UNIT = "../../vllm/patched/dsv3_fused_a_gemm_lane0.cu"  # survey path, relative


def lane0_init_ptx():
    """The fused-A GEMM PTX with its barrier initialization (:563, `if (warp_idx == 4)`)
    restricted to lane 0 of warp 4, so the rest of the kernel can be checked: written to
    external/ptx/vllm/patched/ (only when it changed), from the survey's PTX."""
    import re
    from pathlib import Path
    here = Path(__file__).resolve().parent
    source = here.parent / "survey" / "vllm" / "csrc" / "dsv3_fused_a_gemm.ptx"
    if not source.exists():
        return
    text = source.read_text()
    entry = re.compile(r"(\.visible \.entry _Z19fused_a_gemm_kernel[^(]*\([^)]*\)\n[^{]*\{\n)")
    text, entries = entry.subn(r"\1\t.reg .b32 \t%rlane0;\n\t.reg .pred \t%plane0;\n", text)
    guard = re.compile(r"(\tsetp\.ne\.b32 \t(%p\d+), %r\d+, 4;\n\t@\2 bra \t(\$L__BB\d+_\d+);\n)"
                       r"(?=(?:.*\n){0,3}?\tmbarrier\.init)")
    text, guards = guard.subn(r"\1\tmov.u32 \t%rlane0, %laneid;\n\tsetp.ne.b32 \t%plane0, %rlane0, 0;"
                              r"\n\t@%plane0 bra \t\3;\n", text)
    assert entries == guards, (entries, guards)
    out = here / "patched" / "dsv3_fused_a_gemm_lane0.ptx"
    out.parent.mkdir(exist_ok=True)
    if not out.exists() or out.read_text() != text:
        out.write_text(text)


lane0_init_ptx()

# BUG (Volta-found, ISA-level UB, likely benign on hardware): `if (warp_idx == 4)` (:563)
# has all 32 lanes of warp 4 run initialize_barrier, so each producer/consumer mbarrier is
# initialized 32 times; every init after the first is "an mbarrier.init operation on a
# memory location containing a valid mbarrier object", undefined (PTX ISA 9.7.13.15.9).
# Volta stops at the second init (t129, mbarrier.init of the live object at Shared[0x0]).
# The *_lane0 cases check the rest of the kernel with the init restricted to lane 0.
CASES += (
    fused_a_gemm("fused_a_gemm_128x1536_5tok", 5, 128, 1536, cta=(95, 0), tile_k=128,
                 note=" (one K tile; 3 of 8 token rows zero-filled)"),
    fused_a_gemm("fused_a_gemm_384x7168_13tok", 13, 384, 7168, cta=(447, 0), tile_k=128,
                 note=" (3 stages; tokens 13-15 predicated off)"),
    fused_a_gemm("fused_a_gemm_2048x2048_9tok_tail", 9, 2048, 2048, cta=(5, 0),
                 note=" (16-token tile, 8 stages)"),
    fused_a_gemm("fused_a_gemm_7168x768_3tok_ring", 3, 7168, 768, cta=(47, 0),
                 note=" (28 K tiles through 16 stages: the ring wraps)"),
    fused_a_gemm("fused_a_gemm_6144x2624_tm32_strided", 4, 6144, 2624, cta=(81, 0), tile_m=32,
                 row_stride=6208, note=" (tile_m 32, 9 stages, a strided activation view)"),
    fused_a_gemm("fused_a_gemm_128x1536_5tok_lane0", 5, 128, 1536, cta=(95, 0), tile_k=128,
                 lane0=True, check="ACCEPT"),
    fused_a_gemm("fused_a_gemm_384x7168_13tok_lane0", 13, 384, 7168, cta=(447, 0),
                 tile_k=128, lane0=True, check="ACCEPT"),
    fused_a_gemm("fused_a_gemm_2048x2048_9tok_tail_lane0", 9, 2048, 2048, cta=(5, 0),
                 lane0=True, check="ACCEPT"),
    fused_a_gemm("fused_a_gemm_7168x768_3tok_ring_lane0", 3, 7168, 768, cta=(47, 0),
                 lane0=True, check="ACCEPT"),
    fused_a_gemm("fused_a_gemm_6144x2624_tm32_strided_lane0", 4, 6144, 2624, cta=(81, 0),
                 tile_m=32, row_stride=6208, lane0=True, check="ACCEPT"),
    negative(fused_a_gemm("fused_a_gemm_128x1536_5tok_lane0", 5, 128, 1536, cta=(95, 0),
                          tile_k=128, lane0=True), "spec's tokens shifted by one row",
             N0=1, N1=6),
)


# ===== Fused MLA RoPE + KV-cache write (csrc/cache_kernels_fused.cu) =====

CACHE_FUSED = "csrc/cache_kernels_fused.cu"
MLA_ROPE_RAW = {"bf16": ("N3c108BFloat16E", "S2_", "13__nv_bfloat16S3_"),
                "f16": ("N3c104HalfE", "S2_", "tt"), "f32": ("f", "f", "ff")}


def mla_rope_fused(name, tokens, heads, cta, rot=64, rank=512, q_head_stride=None,
                   k_pe_stride=None, kv_c_stride=None, block_size=64, num_blocks=2,
                   dtype="bf16", neox=False, check="ACCEPT", note=""):
    """`concat_and_cache_mla_rope_fused(positions, q_pe [T, H, rot], k_pe [T, rot], kv_c
    [T, rank], cos_sin_cache [max_pos, rot], is_neox, slot_mapping, kv_cache [NB, BS,
    rank + rot], "auto", scale)` (:217): RoPE in place on q_pe and k_pe, then k_pe and kv_c
    into the slot; grid T, block min(max(min(H rot / 2, 512), rank), 512) (:293). q_pe,
    k_pe and kv_c may be strided views (head stride `q_head_stride`, row strides). int64
    positions and slot_mapping, so Volta gives position t and slot t: block `cta` is token,
    position and slot `cta`. GPT-J arrays are viewed in (index, pair) form."""
    qh = q_head_stride or rot
    kps, kcs = k_pe_stride or rot, kv_c_stride or rank
    entry = rank + rot
    e = rot // 2
    qk, cs, raw = MLA_ROPE_RAW[dtype]
    two = (lambda *shape: shape) if neox else (lambda *shape: (*shape[:-1], shape[-1] // 2, 2))
    block = min(max(min(heads * rot // 2, 512), rank), 512)
    return Case(
        name=name,
        description=f"concat_and_cache_mla_rope_fused, {'NeoX' if neox else 'GPT-J'}, {dtype}, "
                    f"{tokens} tokens x {heads} q heads, rot {rot}, kv_lora_rank {rank}, "
                    f"strides q head {qh} / k_pe {kps} / kv_c {kcs}, block_size {block_size}, "
                    f"{block} threads, block {cta}{note}",
        source=f"{CACHE_FUSED}:24 (concat_and_cache_mla_rope_fused_kernel), dispatch :217",
        unit=CACHE_FUSED,
        symbol=f"38concat_and_cache_mla_rope_fused_kernelI{qk}{cs}Lb{int(neox)}E{raw}"
               "LNS_18Fp8KVCacheDataTypeE0EE",
        args=(Ptr("positions"), Ptr("q_pe"), Ptr("k_pe"), Ptr("kv_c"), Ptr("cos_sin_cache"),
              Int(rot, "rot_dim"), Int(heads * qh, "q_pe_stride_token"),
              Int(qh, "q_pe_stride_head"), Int(kps, "k_pe_stride"), Int(kcs, "kv_c_stride"),
              Int(heads, "num_q_heads"), Ptr("kv_cache"), Ptr("slot_mapping"),
              Int(block_size * entry, "block_stride"), Int(entry, "entry_stride"),
              Int(rank, "kv_lora_rank"), Int(block_size, "block_size"), NULL),
        arrays=(Array("positions", "index", "i64", (tokens,)),
                Array("slot_mapping", "index", "i64", (tokens,)),
                Array("q_pe", "inout", dtype, two(tokens, heads, qh)),
                Array("k_pe", "inout", dtype, two(tokens, kps)),
                Array("kv_c", "in", dtype, (tokens, kcs)),
                Array("cos_sin_cache", "in", dtype, (tokens, rot)),
                Array("kv_cache", "out", dtype, two(num_blocks, block_size, entry))),
        grid=(tokens, 1, 1),
        block=block,
        check=check,
        spec=f"mla_rope_fused_{'neox' if neox else 'gptj'}.spec",
        dims={"T": tokens, "H": heads, "QH": two(qh)[-2] if not neox else qh, "R": rot,
              "E": e, "PM": tokens, "P": cta, "KPS": two(kps)[-2] if not neox else kps,
              "KCS": kcs, "L": rank, "L2": rank // 2, "NB": num_blocks, "BS": block_size,
              "RE": two(entry)[-2] if not neox else entry, "B": cta // block_size,
              "S": cta % block_size, **({} if neox else {"TWO": 2})},
        cta=(cta, 0, 0),
    )


CASES += (
    mla_rope_fused("mla_rope_fused_dsv3_tp8", 70, 16, cta=69,
                   note=" (DeepSeek-V3 TP8: 16 heads, slot 69 of block 1)"),
    mla_rope_fused("mla_rope_fused_dsv3_views", 3, 16, cta=2, q_head_stride=192,
                   k_pe_stride=576, kv_c_stride=576,
                   note=" (q_pe, k_pe, kv_c views of q / kv_a rows)"),
    mla_rope_fused("mla_rope_fused_neox_f16_4heads", 20, 4, cta=17, block_size=16, dtype="f16",
                   neox=True, note=" (rank 512 > 128 rope pairs)"),
    mla_rope_fused("mla_rope_fused_f32_128heads", 2, 128, cta=1, rank=256, rot=32, dtype="f32",
                   note=" (2048 q pairs, 512 threads, rank 256)"),
    negative(mla_rope_fused("mla_rope_fused_dsv3_tp8", 70, 16, cta=69), "spec's slot one "
             "entry later", S=6),
)


# ===== Fused q/k RMSNorm + NeoX RoPE + KV-cache update, Step-5 (fused_qknorm_rope_cache_kernel.cu) =====

QKNORM_CACHE = "csrc/fused_qknorm_rope_cache_kernel.cu"
QKNORM_CACHE_T = {"bf16": "N3c108BFloat16E", "f16": "N3c104HalfE"}


def qknorm_rope_cache_spec(bias):
    """The outputs of qknorm_rope_cache_kernel for global heads [G0, G1) (global head
    t TH + h over the TH = HQ + 2 HK heads of each token): q and k heads RMS-normalized
    with weight + bias, their first 2 RP dims rotated NeoX-style by cos/sin of position t;
    v copied; k and v also into slot t of the caches when t < NS."""
    from decimal import Decimal

    def norm(h, d):
        x = lambda dd: f"qkv[t, {h}, {dd}]"
        w = "q_weight" if h == "h" else "k_weight"
        return (f"{x(d)} / sqrt(sum(j in 0..D, {x('j')} * {x('j')}) / D + {Decimal(EPS):f})"
                f" * ({w}[{d}]{' + 1' if bias else ''})")

    def roped(h):
        return (f"where(d < RP, {norm(h, 'd')} * cos[t, d] - {norm(h, 'd + RP')} * sin[t, d], "
                f"where(d < 2 * RP, {norm(h, 'd - RP')} * sin[t, d - RP] + {norm(h, 'd')} * "
                f"cos[t, d - RP], {norm(h, 'd')}))")

    inside = lambda g, body: f"where({g} < G0, unwritten, where({g} < G1, {body}, unwritten))"
    k_h, v_h = "HQ + h", "HQ + HK + h"
    cache = lambda h, body: (f"where(b * BS + p < NS, {inside(f'(b * BS + p) * TH + {h}', body)}, "
                             "unwritten)")
    roped_k = roped(k_h).replace("t,", "b * BS + p,").replace("[t]", "[b * BS + p]")
    return write_spec(f"qknorm_rope_cache{'_bias' if bias else ''}", "\n".join([
        "// Generated by cases.py (qknorm_rope_cache_spec): vLLM's fused q/k RMSNorm, NeoX RoPE",
        f"// and KV-cache update ({QKNORM_CACHE}:30){', norm weight bias 1' if bias else ''}.",
        "dim T; dim TH; dim HQ; dim HK; dim D; dim RP; dim PM; dim CW; dim NB; dim BS; dim NS;",
        "dim G0; dim G1;",
        "array qkv[T, TH, D];", "array q_weight[D];", "array k_weight[D];",
        "array cos[PM, CW];", "array sin[PM, CW];",
        "array q_out[T, HQ, D];", "array k_out[T, HK, D];", "array v_out[T, HK, D];",
        "array k_cache[NB, BS, HK, D];", "array v_cache[NB, BS, HK, D];",
        f"q_out[t, h, d] = {inside('t * TH + h', roped('h'))};",
        f"k_out[t, h, d] = {inside(f't * TH + {k_h}', roped(k_h))};",
        f"v_out[t, h, d] = {inside(f't * TH + {v_h}', f'qkv[t, {v_h}, d]')};",
        f"k_cache[b, p, h, d] = {cache(k_h, roped_k)};",
        f"v_cache[b, p, h, d] = {cache(v_h, f'qkv[b * BS + p, {v_h}, d]')};", ""]))


def qknorm_rope_cache(name, tokens, hq, hk, head_dim, rotary_pairs, cta, slots=None,
                      block_size=16, num_blocks=2, dtype="bf16", weight="bf16", rope="f32",
                      bias=0.0, check="ACCEPT", note=""):
    """`fused_qknorm_rope_cache(q_out, k_out, v_out, qkv [T, (HQ + 2 HK) D], q_weight,
    k_weight, cos, sin, positions, slot_mapping, k_cache, v_cache [NB, BS, HK, D], D, HQ, HK,
    rotary_pairs, eps, norm_weight_bias, "auto", ...)` (:399): one head per 8 / 16 / 32
    threads (D 64 / <= 192 / 256, or 32 for D 192 with more than 64 rotary pairs), 128
    threads per block, grid ceil(T TH / heads_per_block) (:314). int64 positions and slots,
    so Volta gives position t and slot t; tokens >= `slots` (slot_mapping.numel()) skip the
    caches. cos and sin are [T, rotary_pairs] caches."""
    th = hq + 2 * hk
    wide = head_dim == 192 and rotary_pairs > 64
    tph = 32 if wide else (8 if head_dim <= 64 else 16 if head_dim <= 192 else 32)
    hpb = 128 // tph
    total = tokens * th
    g0, g1 = cta * hpb, min((cta + 1) * hpb, total)
    slots = tokens if slots is None else slots
    entry = hk * head_dim
    tname = {"bf16": QKNORM_CACHE_T["bf16"], "f16": QKNORM_CACHE_T["f16"], "f32": "f"}
    sym_w = "S3_" if weight == dtype else tname[weight]
    sym_r = "S3_" if rope == dtype else tname[rope]
    shift = (block_size.bit_length() - 1) if block_size & (block_size - 1) == 0 else -1
    return Case(
        name=name,
        description=f"fused_qknorm_rope_cache, {dtype} (weight {weight}, rope {rope}), {tokens} "
                    f"tokens x ({hq} q + {hk} kv) heads of {head_dim}, {rotary_pairs} rotary "
                    f"pairs, {tph} threads per head, {slots} slots, block {cta} = heads "
                    f"[{g0}, {g1}){note}",
        source=f"{QKNORM_CACHE}:30 (qknorm_rope_cache_kernel), launcher :314, op :399",
        unit=QKNORM_CACHE,
        symbol=f"24qknorm_rope_cache_kernelI{tname[dtype]}{sym_w}{sym_r}Li{head_dim}"
               f"ELb{int(wide)}ELb0ELb0EE",
        args=(Ptr("qkv"), Ptr("q_out"), Ptr("k_out"), Ptr("v_out"), Ptr("q_weight"),
              Ptr("k_weight"), Ptr("cos"), Ptr("sin"), Ptr("positions"), Ptr("slot_mapping"),
              Ptr("k_cache"), Ptr("v_cache"), Int(th * head_dim, "qkv_token_stride"),
              Int(hq * head_dim, "q_token_stride"), Int(entry, "k_token_stride"),
              Int(entry, "v_token_stride"), Int(rotary_pairs, "cos_token_stride"),
              Int(rotary_pairs, "sin_token_stride"), Int(block_size * entry, "cache_block_stride"),
              Int(entry, "cache_page_stride"), Int(head_dim, "cache_head_stride"),
              Int(tokens, "num_tokens"), Int(slots, "num_slots"), Int(hq, "num_q_heads"),
              Int(hk, "num_kv_heads"), Int(rotary_pairs, "rotary_pairs"),
              Int(block_size, "block_size"), Float(EPS, "epsilon"),
              Int(shift, "block_size_shift"), Float(bias, "norm_weight_bias"), NULL, NULL,
              Float(1.0, "q_scale")),
        arrays=(Array("qkv", "in", dtype, (tokens, th, head_dim)),
                Array("q_weight", "in", weight, (head_dim,)),
                Array("k_weight", "in", weight, (head_dim,)),
                Array("cos", "in", rope, (tokens, rotary_pairs)),
                Array("sin", "in", rope, (tokens, rotary_pairs)),
                Array("positions", "index", "i64", (tokens,)),
                Array("slot_mapping", "index", "i64", (slots,)),
                Array("q_out", "out", dtype, (tokens, hq, head_dim)),
                Array("k_out", "out", dtype, (tokens, hk, head_dim)),
                Array("v_out", "out", dtype, (tokens, hk, head_dim)),
                Array("k_cache", "out", dtype, (num_blocks, block_size, hk, head_dim)),
                Array("v_cache", "out", dtype, (num_blocks, block_size, hk, head_dim))),
        grid=(-(-total // hpb), 1, 1),
        block=128,
        check=check,
        spec=qknorm_rope_cache_spec(bias),
        dims={"T": tokens, "TH": th, "HQ": hq, "HK": hk, "D": head_dim, "RP": rotary_pairs,
              "PM": tokens, "CW": rotary_pairs, "NB": num_blocks, "BS": block_size, "NS": slots,
              "G0": g0, "G1": g1},
        cta=(cta, 0, 0),
    )


CASES += (
    qknorm_rope_cache("qknorm_rope_cache_128_step5", 4, 8, 2, 128, 64, cta=3,
                      note=" (8 heads per block: token 2's heads 4-11)"),
    qknorm_rope_cache("qknorm_rope_cache_128_partial_rotary", 3, 4, 1, 128, 32, cta=1,
                      note=" (half the head rotated)"),
    qknorm_rope_cache("qknorm_rope_cache_64_padded_slots", 5, 6, 2, 64, 16, cta=3, slots=3,
                      note=" (tokens 3-4 padded: no cache write)"),
    qknorm_rope_cache("qknorm_rope_cache_256_gemma_bias", 2, 4, 2, 256, 64, cta=1, bias=1.0,
                      weight="bf16", rope="bf16", note=" (weight + 1)"),
    qknorm_rope_cache("qknorm_rope_cache_192_wide_f16", 2, 2, 1, 192, 96, cta=1, dtype="f16",
                      weight="f32", block_size=24, note=" (32 threads per head; block_size "
                      "24: the division path)"),
    qknorm_rope_cache("qknorm_rope_cache_192_narrow", 2, 2, 1, 192, 32, cta=0,
                      note=" (4-value vectors)"),
    qknorm_rope_cache("qknorm_rope_cache_64_slots_boundary", 5, 6, 2, 64, 16, cta=1, slots=3,
                      note=" (token 1's k / v heads and token 2's heads: the last slots)"),
    negative(qknorm_rope_cache("qknorm_rope_cache_128_partial_rotary", 3, 4, 1, 128, 32,
                               cta=1), "spec's rotation over the first 16 pairs", RP=16),
)


# ===== Kimi-K3 fused MLA epilogues (csrc/fused_kimi_k3_mla_key_concat_kv_cache_kernel.cu) =====

KIMI = "csrc/fused_kimi_k3_mla_key_concat_kv_cache_kernel.cu"
KIMI_NS = "N4vllm17kimi_k3_fused_ops"


def kimi_rot(src, x, s, p, t="t"):
    """GPT-J RoPE of pair `x` (element `s`) of `src` by cos/sin index `p` of position t
    (copyChunk8, :156), or the pair itself when `p` is None."""
    if p is None:
        return f"{src}[{x}, {s}]"
    return (f"{src}[{x}, {s}] * cos_sin_cache[{t}, {p}] + (2 * sum(r in 0..{s}, 1) - 1) * "
            f"{src}[{x}, 1 - {s}] * cos_sin_cache[{t}, {p} + 32]")


def kimi_spec(kernel, rope, split=1):
    """The expected outputs of one Kimi-K3 epilogue block, every 16-bit array viewed as
    (pair, element) so the interleaved RoPE pairs are explicit. Rows are (token, slot), slots
    [0, H) per head and slot H the token's cache insert (prefill, decode), covered when their
    warp is in [W0, W1), a decode row split over 3 warps by 128 / 128 / 32 pairs; or (token,
    head) rows t H + h in [W0, W1) or [W2, W3) (pack: two per warp, grid-strided).
    Positions and slots are t (int64)."""
    cov = lambda w, body: f"where({w} < W0, unwritten, where({w} < W1, {body}, unwritten))"
    if split == 3:
        cover = lambda r, x, body: (f"where({x} < 128, {cov(f'({r}) * 3', body)}, where({x} < 256, "
                                    f"{cov(f'({r}) * 3 + 1', body)}, {cov(f'({r}) * 3 + 2', body)}))")
    else:
        cover = lambda r, x, body: cov(r, body)
    slot_t = "b * BS + n"
    cache_row = f"({slot_t}) * (H + 1) + H"
    k_pe_c = kimi_rot(f"k_pe[{slot_t}", "x - 256", "s", "x - 256" if rope else None, slot_t)
    cache = (f"where(x < 256, kv_c[{slot_t}, 2 * x + s], "
             f"{k_pe_c.replace(f'k_pe[{slot_t}[', f'k_pe[{slot_t}, ')})")
    lines = ["dim T; dim H; dim KP2; dim NB; dim BS; dim PM; dim TWO; dim W0; dim W1;",
             "dim C32; dim C64; dim C96; dim C128; dim C288; dim C512;",
             "array k_pe[T, KP2, TWO];"]
    if kernel != "pack":
        lines.append("array cos_sin_cache[PM, C64];")
    if kernel == "insert":
        lines += ["array q[T, H, C96, TWO];", "array k_nope[T, H, C128];", "array kv_c[T, C512];",
                  "array k_out[T, H, C96, TWO];", "array k_cache[NB, BS, C288, TWO];"]
        k_pe_x = kimi_rot("k_pe[t", "x - 64", "s", "x - 64" if rope else None).replace(
            "k_pe[t[", "k_pe[t, ")
        q_x = kimi_rot("q[t, h", "x", "s", "x - 64").replace("q[t, h[", "q[t, h, ")
        q_body = cover("t * (H + 1) + h", "x", f"where(x < 64, unwritten, {q_x})")
        lines += [
            f"q[t, h, x, s] = {q_body if rope else 'unwritten'};",
            "k_out[t, h, x, s] = " + cover("t * (H + 1) + h", "x",
                                           f"where(x < 64, k_nope[t, h, 2 * x + s], {k_pe_x})")
            + ";",
            "k_cache[b, n, x, s] = " + cover(cache_row, "x", cache) + ";"]
    elif kernel == "decode":
        lines += ["array ql_nope[T, H, C512];", "array q_pe[T, H, C32, TWO];", "array kv_c[T, C512];",
                  "array mqa_q[T, H, C288, TWO];", "array k_cache[NB, BS, C288, TWO];"]
        q_x = kimi_rot("q_pe[t, h", "x - 256", "s", "x - 256" if rope else None).replace(
            "q_pe[t, h[", "q_pe[t, h, ")
        lines += [
            "mqa_q[t, h, x, s] = " + cover("t * (H + 1) + h", "x",
                                           f"where(x < 256, ql_nope[t, h, 2 * x + s], {q_x})")
            + ";",
            "k_cache[b, n, x, s] = " + cover(cache_row, "x", cache) + ";"]
    else:
        body = "where(x < 64, k_nope[t, h, 2 * x + s], k_pe[t, x - 64, s])"
        lines += ["dim W2; dim W3;", "array k_nope[T, H, C128];", "array k_out[T, H, C96, TWO];",
                  f"k_out[t, h, x, s] = where(t * H + h < W2, {cov('t * H + h', body)}, "
                  f"where(t * H + h < W3, {body}, unwritten));"]
    name = f"kimi_{kernel}{'_rope' if rope else ''}{'_split3' if split == 3 else ''}"
    return write_spec(name, "\n".join([
        f"// Generated by cases.py (kimi_spec) for vLLM's Kimi-K3 {kernel} epilogue ({KIMI})"
        f"{', RoPE' if rope else ''}{', rows split over 3 warps' if split == 3 else ''}.",
        *lines, ""]))


def kimi_epilogue(name, kernel, tokens, heads, cta, rope=False, k_pe_stride=64, block_size=16,
                  num_blocks=None, sms=B200_SMS, check="ACCEPT", note=""):
    """The bf16 Kimi-K3 MLA epilogues, 256 threads per block (launchPdlSlots :810):
    `insert` = fused_kimi_k3_mla_key_concat_kv_cache_insert (:889, kernel :392: per-head
    q RoPE in place + key concat, and a cache-insert warp per token), `decode` =
    fused_kimi_k3_mla_decode_q_concat_kv_cache_insert (kernel :685: mqa_q = [ql_nope |
    q_pe] and the cache insert; rows split over 3 warps for <= 64 tokens, :1416), `pack` =
    fused_kimi_k3_mla_kv_concat (kernel :541: key concat, two rows per warp, grid capped at
    8 per SM, :1135). k_pe is a [T, 64] view of row stride `k_pe_stride`."""
    split = 3 if kernel == "decode" and tokens <= 64 else 1
    if kernel == "pack":
        rows = tokens * heads
        warps = -(-rows // 2)
        grid = min(-(-warps // 8), sms * 8)
        w0, w1 = 16 * cta, min(16 * cta + 16, rows)
        w2 = 16 * cta + grid * 16
        w3 = min(w2 + 16, rows)
        assert w2 + grid * 16 >= rows, "at most two grid-stride passes"
        dims_extra = {"W2": min(w2, rows), "W3": max(min(w3, rows), min(w2, rows))}
    else:
        warps = tokens * (heads + 1) * split
        grid = -(-warps // 8)
        w0, w1 = 8 * cta, min(8 * cta + 8, warps)
        dims_extra = {}
    num_blocks = num_blocks or -(-tokens // block_size)
    pairs = lambda *shape: (*shape[:-1], shape[-1] // 2, 2)
    arrays = [Array("k_pe", "in", "bf16", pairs(tokens, k_pe_stride)),
              Array("k_nope", "in", "bf16", (tokens, heads, 128))]
    cache = Array("k_cache", "out", "bf16", (num_blocks, block_size, 288, 2))
    rope_args = (Ptr("positions") if rope else NULL, Ptr("cos_sin_cache") if rope else NULL)
    rope_arrays = [Array("positions", "index", "i64", (tokens,)),
                   Array("cos_sin_cache", "in", "f32", (tokens, 64))] if rope else []
    if kernel == "insert":
        arrays += [Array("q", "inout", "bf16", (tokens, heads, 96, 2)),
                   Array("kv_c", "in", "bf16", (tokens, 512)),
                   Array("k_out", "out", "bf16", (tokens, heads, 96, 2)), cache,
                   Array("slot_mapping", "index", "i64", (tokens,)), *rope_arrays]
        symbol = f"42fusedKimiK3MLAKeyConcatKVCacheInsertKernelIN3c108BFloat16ELb{int(rope)}EE"
        args = (Ptr("q"), Int(heads * 192, "q_tok_stride"), Int(192, "q_head_stride"),
                Ptr("k_nope"), Int(heads * 128, "kn_tok_stride"), Int(128, "kn_head_stride"),
                Ptr("k_pe"), Int(k_pe_stride, "k_pe_tok_stride"), Ptr("kv_c"),
                Int(512, "kv_c_tok_stride"), Ptr("k_out"), Int(heads * 192, "ko_tok_stride"),
                Int(192, "ko_head_stride"), Ptr("k_cache"),
                Int(block_size * 576, "cache_block_stride"), Int(576, "cache_token_stride"),
                Ptr("slot_mapping"), *rope_args, Int(tokens, "num_tokens"),
                Int(heads, "num_heads"), Int(block_size, "cache_block_size"))
        line = 392
    elif kernel == "decode":
        arrays = [Array("k_pe", "in", "bf16", pairs(tokens, k_pe_stride)),
                  Array("ql_nope", "in", "bf16", (tokens, heads, 512)),
                  Array("q_pe", "in", "bf16", (tokens, heads, 32, 2)),
                  Array("kv_c", "in", "bf16", (tokens, 512)),
                  Array("mqa_q", "out", "bf16", (tokens, heads, 288, 2)), cache,
                  Array("slot_mapping", "index", "i64", (tokens,)), *rope_arrays]
        symbol = (f"40fusedKimiK3MLADecodeQConcatKVCacheKernelIN3c108BFloat16ELb0ELb0ELb{int(rope)}"
                  f"ELi{split}EE")
        args = (Ptr("ql_nope"), Int(heads * 512, "qn_tok_stride"), Int(512, "qn_head_stride"),
                Ptr("q_pe"), Int(heads * 64, "qpe_tok_stride"), Int(64, "qpe_head_stride"),
                Ptr("kv_c"), Int(512, "kv_c_tok_stride"), Ptr("k_pe"),
                Int(k_pe_stride, "k_pe_tok_stride"), Ptr("mqa_q"), Int(heads * 576, "mq_tok_stride"),
                Int(576, "mq_head_stride"), Ptr("k_cache"),
                Int(block_size * 576, "cache_block_stride"), Int(576, "cache_token_stride"),
                Ptr("slot_mapping"), NULL, NULL, Int(tokens, "num_tokens"),
                Int(heads, "num_heads"), Int(block_size, "cache_block_size"), *rope_args)
        line = 685
    else:
        arrays += [Array("k_out", "out", "bf16", (tokens, heads, 96, 2))]
        symbol = "32fusedKimiK3MLAKVConcatPackKernelIN3c108BFloat16ELb0ELb0EE"
        args = (Ptr("k_nope"), Int(heads * 128, "kn_tok_stride"), Int(128, "kn_head_stride"),
                Ptr("k_pe"), Int(k_pe_stride, "k_pe_tok_stride"), NULL, Int(0), Int(0),
                Ptr("k_out"), Int(heads * 192, "ko_tok_stride"), Int(192, "ko_head_stride"),
                NULL, Int(0), Int(0), Int(tokens, "num_tokens"), Int(heads, "num_heads"))
        line = 541
    return Case(
        name=name,
        description=f"Kimi-K3 MLA {kernel} epilogue, bf16, {tokens} tokens x {heads} heads"
                    f"{', RoPE' if rope else ''}{', rows split over 3 warps' if split == 3 else ''}, "
                    f"k_pe row stride {k_pe_stride}, grid {grid}, block {cta} = warps/rows "
                    f"[{w0}, {w1}){note}",
        source=f"{KIMI}:{line} ({symbol[2:].split('I')[0]}), launchPdlSlots :810",
        unit=KIMI,
        symbol=symbol,
        args=args,
        arrays=tuple(arrays),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec=kimi_spec(kernel, rope, split),
        dims={"T": tokens, "H": heads, "KP2": k_pe_stride // 2, "NB": num_blocks,
              "BS": block_size, "PM": tokens, "TWO": 2, "W0": w0, "W1": w1, **dims_extra,
              **{f"C{n}": n for n in (32, 64, 96, 128, 288, 512)}},
        cta=(cta, 0, 0),
    )


CASES += (
    kimi_epilogue("kimi_insert_rope_8heads", "insert", 3, 8, cta=2, rope=True,
                  k_pe_stride=576, note=" (k_pe a view of the kv_a rows; token 1's cache warp "
                  "and token 2's heads)"),
    kimi_epilogue("kimi_insert_no_rope", "insert", 2, 7, cta=1),
    kimi_epilogue("kimi_decode_rope_split3", "decode", 2, 8, cta=3, rope=True,
                  note=" (a row's 3 warps straddle blocks)"),
    kimi_epilogue("kimi_decode_no_rope_split3", "decode", 4, 4, cta=7),
    kimi_epilogue("kimi_decode_rope_65tok", "decode", 65, 2, cta=24, rope=True,
                  note=" (65 tokens: one warp per row)"),
    kimi_epilogue("kimi_pack_16heads", "pack", 5, 16, cta=4),
    kimi_epilogue("kimi_pack_grid_stride", "pack", 75, 8, cta=2, sms=4,
                  note=" (a 4-SM device: grid capped at 32 blocks, a second pass)"),
    negative(kimi_epilogue("kimi_insert_rope_8heads", "insert", 3, 8, cta=2, rope=True,
                           k_pe_stride=576), "spec's block one warp later", W0=17, W1=25),
)


# ===== Volta gaps met on the remaining targets (one case each documents the blocker) =====

CASES += (
    # Volta gap: the penalty's `if (logit > 0)` (sampler.cu:38) branches on a symbolic logit
    # around the in-place store ("a branch on a symbolic predicate reaches Store"); logits are
    # in place, so they cannot be given concrete contents. Masks are 1-byte index arrays
    # (element i is i: every entry but multiples of 256 is repeated).
    Case(name="apply_repetition_penalties_f32", description="apply_repetition_penalties_, "
         "f32, 2 sequences of 300, tile 100, block (1, 2)",
         source="csrc/sampler.cu:16 (apply_repetition_penalties_kernel), host :48",
         unit="csrc/sampler.cu", symbol="33apply_repetition_penalties_kernelIfEE",
         args=(Ptr("logits"), Ptr("prompt_mask"), Ptr("output_mask"), Ptr("penalties"),
               Int(2, "num_seqs"), Int(300, "vocab_size"), Int(100, "tile_size")),
         arrays=(Array("logits", "inout", "f32", (2, 300)),
                 Array("prompt_mask", "index", "u8", (600,)),
                 Array("output_mask", "index", "u8", (600,)),
                 Array("penalties", "in", "f32", (2,))),
         grid=(2, 3, 1), block=100, check="ABORT", cta=(1, 2, 0)),
    # Volta gap: the static fp8 RMSNorm kernels (layernorm_quant_kernels.cu:23) convert
    # through cvt.rn.satfinite.e4m3x2.f32 with two sources, which Volta's parser rejects
    # (Cvt: WrongOperandCount { expected: 2, got: 3 }); every kernel of the unit but cub's
    # EmptyKernel fails to lower.
    Case(name="rms_norm_static_fp8_quant_bf16", description="rms_norm_static_fp8_quant, "
         "bf16, 1 token of 4096, VEC 8", source="csrc/layernorm_quant_kernels.cu:23 "
         "(rms_norm_static_fp8_quant_kernel), dispatch :224",
         unit="csrc/layernorm_quant_kernels.cu",
         symbol="32rms_norm_static_fp8_quant_kernelIN3c108BFloat16ENS1_13Float8_e4m3fnELi8EE",
         args=(Ptr("out"), Ptr("input"), Int(4096, "input_stride"), Ptr("weight"),
               Ptr("scale"), Float(EPS, "epsilon"), Int(1, "num_tokens"),
               Int(4096, "hidden_size")),
         arrays=(Array("input", "in", "bf16", (1, 4096)), Array("weight", "in", "bf16", (4096,)),
                 Array("scale", "in", "f32", (1,)), Array("out", "out", "i32", (1, 1024))),
         grid=(1, 1, 1), block=512, check="ABORT"),
    # Volta gap: the int8 dynamic per-token RMSNorm quant (fused_layernorm_dynamic_per_token_
    # quant.cu:50) rounds with cvt.rni.sat.s8.f32 (".sat modifier outside a float->float form
    # ... integer saturation is not modeled"); its fp8 twins hit the e4m3x2 parse gap above.
    Case(name="rms_norm_dynamic_per_token_quant_int8", description="rms_norm_dynamic_per_"
         "token_quant, bf16 -> int8, 1 token of 4096",
         source="csrc/quantization/fused_kernels/fused_layernorm_dynamic_per_token_quant.cu:50 "
                "(rms_norm_dynamic_per_token_quant_kernel), dispatch :157",
         unit="csrc/quantization/fused_kernels/fused_layernorm_dynamic_per_token_quant.cu",
         symbol="39rms_norm_dynamic_per_token_quant_kernelIN3c108BFloat16EaLb0EE",
         args=(Ptr("out"), Ptr("scales"), Ptr("input"), Ptr("weight"), NULL,
               Float(EPS, "epsilon"), Int(4096, "hidden_size"), NULL),
         arrays=(Array("input", "in", "bf16", (1, 4096)), Array("weight", "in", "bf16", (4096,)),
                 Array("scales", "out", "f32", (1,)), Array("out", "out", "i32", (1, 1024))),
         grid=(1, 1, 1), block=1024, check="ABORT"),
)


# ===== HY V4 iHC boundary, two-kernel path (csrc/hy_v4_ihc_kernels.cu) =====

IHC = "csrc/hy_v4_ihc_kernels.cu"
IHC_NS = "N4vllm9hy_v4_ihc"
IHC_SPLIT_CHOICES = (96, 80, 64, 56, 48, 40, 32, 28, 24, 20, 16, 8, 4, 2, 1)  # :79
F32_1E5 = 9.999999747378752e-06  # f32(1e-5), HY V4's layernorm_epsilon (hc.py:51)


def ihc_splits(tokens, hidden):
    """choose_splits (:1801) with split_fits (:1789)."""
    want = (96 if tokens <= 16 else 48 if tokens <= 128 else 24 if tokens <= 512 else
            16 if tokens <= 1024 else 8 if tokens <= 8192 else 4)
    k_total = 4 * hidden
    for s in IHC_SPLIT_CHOICES:
        if s <= want and k_total % (s * 8 * 32) == 0 and hidden % (k_total // (s * 8)) == 0:
            return s
    return 0


def ihc_stats_spec(name, post, pieces):
    """partials[S, t, n] of tokens [T0, T1): sum over the split's k range (`pieces`,
    (channel, h0, h1) runs) of r[t, k] W[n, k] (n < 8) or r[t, k]^2 (n = 8), r the new
    residual post[t, c] x[t, h] + residual_in[t, c, h] (bf16 rounding is exact over the
    reals), which residual_out takes on the same range."""
    r = (lambda c, h: f"(post[t, {c}] * x[t, {h}] + residual_in[t, {c}, {h}])") if post else \
        (lambda c, h: f"residual_in[t, {c}, {h}]")
    mix = " + ".join(f"sum(h in {h0}..{h1}, {r(c, 'h')} * weight[n, {c} * H + h])"
                     for c, h0, h1 in pieces)
    sq = " + ".join(f"sum(h in {h0}..{h1}, {r(c, 'h')} * {r(c, 'h')})" for c, h0, h1 in pieces)
    tok = lambda body: f"where(t < T0, unwritten, where(t < T1, {body}, unwritten))"
    lines = ["dim T; dim HC; dim H; dim NM; dim KT; dim NS; dim NST; dim S; dim T0; dim T1;",
             "array residual_in[T, HC, H];", "array weight[NM, KT];",
             "array partials[NS, T, NST];",
             "partials[s, t, n] = where(s == S, "
             f"{tok(f'where(n < 8, {mix}, {sq})')}, unwritten);"]
    if post:
        body = "unwritten"
        for c, h0, h1 in reversed(pieces):
            body = (f"where(j == {c}, where(h < {h0}, unwritten, where(h < {h1}, "
                    f"{r('j', 'h').replace('t, j]', 't, j]')}, unwritten)), {body})")
        lines[1:1] = ["array x[T, H];", "array post[T, HC];", "array residual_out[T, HC, H];"]
        lines.append(f"residual_out[t, j, h] = {tok(body)};")
    return write_spec(f"ihc_stats_{name}", "\n".join([
        f"// Generated by cases.py (ihc_stats_spec) for the case {name}: {IHC} ihc_stats_kernel.",
        *lines, ""]))


def ihc_stats(name, tokens, hidden, cta, post=True, sliced=False, check="ACCEPT", note=""):
    """`ihc_stats_kernel<has_post, splits>(residual_in [T, 4, H], x [T, H], post [T, 4],
    weight [8, 4H], residual_out, partials [splits, T, 9], T, H)` (:145), launched by
    hy_v4_ihc_boundary's two-kernel path (:2414) with splits = choose_splits(T, H), grid
    ceil(T / 16) * splits, 256 threads. Block `cta` = (token tile cta / splits, split
    cta % splits): 8 warps x mma.sync m16n8k16 over its k range, the FP32 weight split
    into bf16 hi / mid / lo."""
    splits = ihc_splits(tokens, hidden)
    tiles = -(-tokens // 16)
    tile, split = divmod(cta, splits)
    k_split = 4 * hidden // splits
    k0, k1 = split * k_split, (split + 1) * k_split
    pieces = [(c, max(k0, c * hidden) - c * hidden, min(k1, (c + 1) * hidden) - c * hidden)
              for c in range(4) if k0 < (c + 1) * hidden and c * hidden < k1]
    t0, t1 = 16 * tile, min(16 * tile + 16, tokens)
    k_total = 4 * hidden
    if sliced:
        # Only the tile's tokens (and its split's partials) are registered, each array placed
        # at its tile's start; the spec indexes them from 0.
        tt = t1 - t0
        place = lambda i, row: {"base": IHC_STATS_BASES[i] + t0 * row}
        arrays = [Array("residual_in", "in", "bf16", (tt, 4, hidden), **place(0, k_total * 2)),
                  Array("weight", "in", "f32", (8, k_total)),
                  Array("partials", "out", "f32", (1, tt, 9),
                        base=IHC_STATS_BASES[1] + (split * tokens + t0) * 36)]
        if post:
            arrays += [Array("x", "in", "bf16", (tt, hidden), **place(2, hidden * 2)),
                       Array("post", "in", "f32", (tt, 4), **place(3, 16)),
                       Array("residual_out", "out", "bf16", (tt, 4, hidden), **place(4, k_total * 2))]
        ptr = lambda a: Int(IHC_STATS_BASES[("residual_in", "partials", "x", "post",
                                             "residual_out").index(a)], a)
        dims = {"T": tt, "NS": 1, "S": 0, "T0": 0, "T1": tt}
    else:
        arrays = [Array("residual_in", "in", "bf16", (tokens, 4, hidden)),
                  Array("weight", "in", "f32", (8, k_total)),
                  Array("partials", "out", "f32", (splits, tokens, 9))]
        if post:
            arrays += [Array("x", "in", "bf16", (tokens, hidden)),
                       Array("post", "in", "f32", (tokens, 4)),
                       Array("residual_out", "out", "bf16", (tokens, 4, hidden))]
        ptr = Ptr
        dims = {"T": tokens, "NS": splits, "S": split, "T0": t0, "T1": t1}
    return Case(
        name=name,
        description=f"ihc_stats_kernel, {'post step, ' if post else ''}{tokens} tokens x 4 x "
                    f"{hidden}, {splits} splits (k {k_split} each, warp slices of "
                    f"{k_split // 8}), block {cta} = tokens [{t0}, {t1}) split {split}{note}",
        source=f"{IHC}:146 (ihc_stats_kernel), choose_splits :1801, launch :2414",
        unit=IHC,
        symbol=f"{IHC_NS}16ihc_stats_kernelILb{int(post)}ELi{splits}EE",
        args=(ptr("residual_in"), ptr("x") if post else NULL, ptr("post") if post else NULL,
              Ptr("weight"), ptr("residual_out") if post else NULL, ptr("partials"),
              Int(tokens, "num_tokens"), Int(hidden, "hidden")),
        arrays=tuple(arrays),
        grid=(tiles * splits, 1, 1),
        block=256,
        check=check,
        spec=ihc_stats_spec(name, post, pieces),
        dims={"HC": 4, "H": hidden, "NM": 8, "KT": k_total, "NST": 9, **dims},
        cta=(cta, 0, 0),
    )


IHC_STATS_BASES = (0x10000000, 0x20000000, 0x28000000, 0x2c000000, 0x30000000)


def expf_neg(y, name="y"):
    """Accurate `expf(-y)` (no fast math) as Volta reads its PTX: 2^n ex2((-y log2 e - n)),
    n = sat(0.5 - y f32(1 / 174.67)) * 252 - 126 (the magic-number rounding is exact over
    the reals), ex2 lowered through f32(log2 e) and log2 e split into f32 hi + lo parts, so
    over the reals it is close to, not equal to, exp(-y)."""
    n = f"(min(max({name} * (-12294301.0 / 2147483648.0) + 0.5, 0), 1) * 252 - 126)"
    return (f"let({name}, {y}, exp(({name} * (-12102203.0 / 8388608.0) + {name} * "
            f"(-338819.0 / 17592186044416.0) - {n}) * (8388608.0 / 12102203.0)) * exp({n} * log(2)))")


# Where the finish kernel's tensors start; a case registers token `cta`'s slice of each.
IHC_RES_BASE, IHC_PART_BASE, IHC_POST_BASE, IHC_OUT_BASE = (0x10000000, 0x20000000, 0x28000000,
                                                            0x30000000)


def ihc_finish_spec(name, splits, fuse_norm, magnitude, hc_eps, rms_eps, var_eps):
    """Token P's gates and hidden state: stat n = sum over splits of its partials; rstd =
    1 / sqrt(stat 8 / 4H + rms_eps); pre gate j = sigmoid(stat j rstd hc_scale[0] +
    hc_base[j]) + hc_eps, post_out j = magnitude sigmoid(stat 4 + j rstd hc_scale[1] +
    hc_base[4 + j]) + hc_eps; hidden = sum_j pre_j residual[j] (times norm_weight /
    sqrt(mean square + var_eps) when fused). Each split's 9 partials are an array p<s>."""
    stat = lambda n: "(" + " + ".join(f"p{s}[{n}]" for s in range(splits)) + ")"
    sig = lambda z: f"(1 / (1 + {expf_neg(z)}))"
    rstd = f"(1 / sqrt({stat(8)} / KT + {literal(rms_eps)}))"
    gate = lambda j: f"g{j}"
    row = lambda h: " + ".join(f"g{j} * residual[{j}, {h}]" for j in range(4))
    body = f"({row('h')})"
    if fuse_norm:
        body = (f"{body} * (1 / sqrt(sum(k in 0..H, ({row('k')}) * ({row('k')})) / H + "
                f"{literal(var_eps)})) * norm_weight[h]")
    for j in reversed(range(4)):
        body = f"let(g{j}, {sig(f'{stat(j)} * r * hc_scale[0] + hc_base[{j}]')} + " \
               f"{literal(hc_eps)}, {body})"
    post_stat = " + ".join(f"where(j == {j}, {stat(4 + j)}, 0)" for j in range(4))
    post_gate = sig(f"({post_stat}) * r * hc_scale[1] + hc_base[4 + j]")
    post_out = f"let(r, {rstd}, {literal(magnitude)} * {post_gate} + {literal(hc_eps)})"
    lines = ["dim T; dim HC; dim H; dim KT; dim NST; dim TWO; dim NM; dim P;",
             "array residual[HC, H];", "array hc_scale[TWO];", "array hc_base[NM];",
             *[f"array p{s}[NST];" for s in range(splits)],
             *(["array norm_weight[H];"] if fuse_norm else []),
             "array post_out[HC];", "array hidden_out[H];",
             f"post_out[j] = {post_out};",
             f"hidden_out[h] = let(r, {rstd}, {body});"]
    return write_spec(f"ihc_finish_{name}", "\n".join([
        f"// Generated by cases.py (ihc_finish_spec) for the case {name}: {IHC} "
        "ihc_finish_kernel.", *lines, ""]))


def ihc_finish(name, tokens, hidden, cta, fuse_norm=True, round_before=False, splits=None,
               prefetch=0, magnitude=2.0, hc_eps=EPS, rms_eps=F32_1E5, var_eps=EPS,
               check="ACCEPT", note=""):
    """`ihc_finish_kernel<fuse_norm, round_before_norm, false, prefetch>(residual, partials,
    hc_scale, hc_base, norm_weight, post_out, hidden_out, nullptr, nullptr, 0, T, H,
    num_splits, magnitude, hc_eps, rms_eps, var_eps)` (:341): one block of 256 per token
    (launches :2381 (TMA path, prefetch 3 at H = 6144) and :2422); block `cta` = token
    `cta`, whose residual [4, H], per-split partials and outputs the case registers alone.
    HY V4's defaults (hc.py:47): magnitude 2, hc_eps 1e-6, layernorm eps 1e-5."""
    splits = splits or ihc_splits(tokens, hidden)
    k_total = 4 * hidden
    arrays = [Array("residual", "in", "bf16", (4, hidden), base=IHC_RES_BASE + cta * k_total * 2),
              Array("hc_scale", "in", "f32", (2,)), Array("hc_base", "in", "f32", (8,)),
              *[Array(f"p{s}", "in", "f32", (9,), base=IHC_PART_BASE + (s * tokens + cta) * 36)
                for s in range(splits)],
              Array("post_out", "out", "f32", (4,), base=IHC_POST_BASE + cta * 16),
              Array("hidden_out", "out", "bf16", (hidden,), base=IHC_OUT_BASE + cta * hidden * 2)]
    if fuse_norm:
        arrays.append(Array("norm_weight", "in", "bf16", (hidden,)))
    flags = f"Lb{int(fuse_norm)}ELb{int(round_before)}ELb0ELi{prefetch}E"
    return Case(
        name=name,
        description=f"ihc_finish_kernel, {'fused norm' if fuse_norm else 'no norm'}, "
                    f"{'round before norm' if round_before else 'FP32 into the norm'}"
                    f"{f', prefetch {prefetch}' if prefetch else ''}, {tokens} tokens x 4 x "
                    f"{hidden}, {splits} splits, block {cta}{note}",
        source=f"{IHC}:341 (ihc_finish_kernel), "
               f"launch :{2381 if prefetch or tokens > 1024 else 2422}",
        unit=IHC,
        symbol=f"{IHC_NS}17ihc_finish_kernelI{flags}E",
        args=(Int(IHC_RES_BASE, "residual"), Int(IHC_PART_BASE, "partials"), Ptr("hc_scale"),
              Ptr("hc_base"), Ptr("norm_weight") if fuse_norm else NULL,
              Int(IHC_POST_BASE, "post_out"), Int(IHC_OUT_BASE, "hidden_out"), NULL, NULL,
              Int(0, "scale_stride"), Int(tokens, "num_tokens"), Int(hidden, "hidden"),
              Int(splits, "num_splits"), Float(magnitude, "magnitude"), Float(hc_eps, "hc_eps"),
              Float(rms_eps, "rms_eps"), Float(var_eps, "var_eps")),
        arrays=tuple(arrays),
        grid=(tokens, 1, 1),
        block=256,
        check=check,
        spec=ihc_finish_spec(name, splits, fuse_norm, magnitude, hc_eps, rms_eps, var_eps),
        dims={"T": tokens, "HC": 4, "H": hidden, "KT": k_total, "NST": 9, "TWO": 2, "NM": 8,
              "P": cta},
        cta=(cta, 0, 0),
    )


CASES += (
    ihc_stats("ihc_stats_post_50tok_h256_last_tile", 50, 256, cta=15,
              note=" (last tile: 2 of 16 tokens)"),
    ihc_stats("ihc_stats_no_post_3tok_h512", 3, 512, cta=5, post=False,
              note=" (a half-channel split)"),
    ihc_stats("ihc_stats_post_20tok_h320_one_split", 20, 320, cta=1,
              note=" (one split over all 4 channels, 5 chunks per warp)"),
    ihc_stats("ihc_stats_post_289tok_h6144_last", 289, 6144, cta=18 * 24 + 23, sliced=True,
              note=" (HY V4's hidden, 24 splits of 1024; the last tile holds 1 token)"),
    ihc_finish("ihc_finish_round_3tok_h128", 3, 128, cta=2, round_before=True,
               note=" (16 of 256 threads hold the row)"),
    ihc_finish("ihc_finish_fp32_norm_49tok_h192", 49, 192, cta=48,
               note=" (the model's FP32-into-norm path past the 48-token cluster kernel)"),
    ihc_finish("ihc_finish_prefetch_no_norm_1025tok_h6144", 1025, 6144, cta=1024, splits=8,
               fuse_norm=False, prefetch=3, note=" (TMA path on B200: 4 x tma_ksplits = 2 "
               "splits, residual loads issued before the gates)"),
    ihc_finish("ihc_finish_no_norm_60tok_h384", 60, 384, cta=59, fuse_norm=False),
)


def ihc_split_weight(name, hidden, cta, check="ACCEPT", note=""):
    """`ihc_split_weight_kernel(weight [8, 4H] f32, split [24, 4H] bf16, count = 32 H)` (:535),
    launched before the TMA stats kernel (:2356, > 1024 tokens with a post step on B200)
    with grid ceil(count / 4 / 256): block `cta` splits weights [1024 cta, 1024 cta + 1024)
    into rows hi / mid / lo, which the case registers alone. Over the reals bf16 rounding is
    exact, so hi = weight and mid = lo = 0."""
    count = 32 * hidden
    i0 = 1024 * cta
    parts = [Array(p, "out", "bf16", (1024,), base=IHC_OUT_BASE + (k * count + i0) * 2)
             for k, p in enumerate(("hi", "mid", "lo"))]
    spec = write_spec("ihc_split_weight", "\n".join([
        f"// vLLM's ihc_split_weight_kernel ({IHC}:535) on one block's 1024 weights: bf16 "
        "hi / mid / lo parts, exact over the reals (hi = w, mid = lo = 0).",
        "dim N; dim Z;", "array weight[N];", "array hi[N];", "array mid[N];", "array lo[N];",
        "hi[i] = weight[i] * (1 - Z);", "mid[i] = weight[i] * Z;", "lo[i] = weight[i] * Z;", ""]))
    return Case(
        name=name,
        description=f"ihc_split_weight_kernel, weight [8, {4 * hidden}], grid {count // 1024}, "
                    f"block {cta}{note}",
        source=f"{IHC}:535 (ihc_split_weight_kernel), launch :2356",
        unit=IHC,
        symbol=f"{IHC_NS}23ihc_split_weight_kernel",
        args=(Int(IHC_RES_BASE, "weight"), Int(IHC_OUT_BASE, "split"), Int(count, "count")),
        arrays=(Array("weight", "in", "f32", (1024,), base=IHC_RES_BASE + i0 * 4), *parts),
        grid=(count // 1024, 1, 1),
        block=256,
        check=check,
        spec=spec,
        dims={"N": 1024, "Z": 0},
        cta=(cta, 0, 0),
    )


CASES += (
    ihc_split_weight("ihc_split_weight_h6144_last", 6144, cta=191, note=" (the last block)"),
    negative(ihc_split_weight("ihc_split_weight_h6144_last", 6144, cta=191),
             "spec moves the weight into the mid part", Z=1),
    negative(ihc_stats("ihc_stats_post_50tok_h256_last_tile", 50, 256, cta=15),
             "spec expects token 48 unwritten", T0=49),
    negative(ihc_finish("ihc_finish_no_norm_60tok_h384", 60, 384, cta=59, fuse_norm=False),
             "spec's rms over 4H + 4 channels", KT=1540),
)


# ===== DeepSeek-V4 full-cache q-norm + RoPE + KV insert =====
# (csrc/fused_deepseek_v4_qnorm_rope_kv_insert_kernel.cu)

DSV4 = "csrc/fused_deepseek_v4_qnorm_rope_kv_insert_kernel.cu"


def dsv4_full_cache_spec(heads, norm):
    """Rows (token t, slot) of warp t (H + 1) + slot in [W0, W1): a q head (slot < H) is
    RMS-normalized without weight (`norm`) and GPT-J-rotated on pairs [224, 256) by
    cos_sin_cache[t] (cos | sin, 32 each); slot H writes token t's rotated kv row to cache
    slot t (positions and slots are t), tokens [0, TI) only. 16-bit arrays are (pair, element)."""
    cov = lambda w, body: f"where({w} < W0, unwritten, where({w} < W1, {body}, unwritten))"
    rot = lambda src, t: (f"where(x < 224, {src}[x, s], {src}[x, s] * cos_sin_cache[{t}, x - 224]"
                          f" + (2 * sum(r in 0..s, 1) - 1) * {src}[x, 1 - s] * "
                          f"cos_sin_cache[{t}, x - 224 + 32])")
    lines = ["dim T; dim TI; dim H; dim NB; dim BS; dim PM; dim TWO; dim W0; dim W1; dim C64;",
             "dim C256;", "array kv_in[T, C256, TWO];", "array cos_sin_cache[PM, C64];",
             "array k_cache[NB, BS, C256, TWO];"]
    if heads:
        q = rot("q_inout[t, h", "t").replace("q_inout[t, h[", "q_inout[t, h, ")
        if norm:
            q = q.replace("q_inout[t, h, x, s]", "(q_inout[t, h, x, s] * rn)").replace(
                "q_inout[t, h, x, 1 - s]", "(q_inout[t, h, x, 1 - s] * rn)")
            q = (f"let(rn, 1 / sqrt(sum(k in 0..C256, q_inout[t, h, k, 0] * q_inout[t, h, k, 0] + "
                 f"q_inout[t, h, k, 1] * q_inout[t, h, k, 1]) / 512 + {literal(EPS)}), {q})")
        lines += ["array q_inout[T, H, C256, TWO];",
                  f"q_inout[t, h, x, s] = {cov('t * (H + 1) + h', q)};"]
    slot = "b * BS + n"
    kv = rot(f"kv_in[{slot}", slot).replace(f"kv_in[{slot}[", f"kv_in[{slot}, ")
    lines.append(f"k_cache[b, n, x, s] = where({slot} < TI, {cov(f'({slot}) * (H + 1) + H', kv)}, "
                 "unwritten);")
    name = f"dsv4_full_cache{'_q' if heads else '_kv_only'}{'_norm' if norm else ''}"
    return write_spec(name, "\n".join([
        f"// Generated by cases.py (dsv4_full_cache_spec) for {DSV4} fusedDeepseekV4FullCacheKernel"
        f"{', q heads' if heads else ', KV only'}{', q RMSNorm' if norm else ''}.", *lines, ""]))


def dsv4_full_cache(name, tokens, heads, cta, inserted=None, norm=True, block_size=16,
                    num_blocks=None, check="ACCEPT", note=""):
    """`fusedDeepseekV4FullCacheKernel<bf16, false, false, apply_q_norm>` (:805) through
    launchFullCacheKernel (:997): 256 threads, grid ceil(T (H + 1) / 8), one warp per (token,
    slot), the bf16 cache's byte strides = 2 x its element strides. With `heads` it is
    fused_deepseek_v4_qnorm_rope_kv_rope_full_cache_bf16_insert (:1231, q [T, H, 512] in
    place, `inserted` = slot_mapping.size(0) <= T); without, fused_deepseek_v4_kv_rope_insert's
    bf16 cache branch (:1129, no q, T = slot_mapping.size(0), no norm). Block `cta` covers
    warps [8 cta, 8 cta + 8)."""
    inserted = tokens if inserted is None else inserted
    warps = tokens * (heads + 1)
    grid = -(-warps // 8)
    num_blocks = num_blocks or -(-inserted // block_size)
    arrays = [Array("kv_in", "in", "bf16", (tokens, 256, 2)),
              Array("k_cache", "out", "bf16", (num_blocks, block_size, 256, 2)),
              Array("slot_mapping", "index", "i64", (inserted,)),
              Array("position_ids", "index", "i64", (tokens,)),
              Array("cos_sin_cache", "in", "f32", (tokens, 64))]
    if heads:
        arrays.insert(0, Array("q_inout", "inout", "bf16", (tokens, heads, 256, 2)))
    return Case(
        name=name,
        description=f"fusedDeepseekV4FullCacheKernel, bf16, {tokens} tokens"
                    f"{f' x {heads} q heads' if heads else ' (KV only)'}, {inserted} inserted, "
                    f"{'q norm, ' if norm and heads else ''}block size {block_size}, grid {grid}, "
                    f"block {cta} = warps [{8 * cta}, {min(8 * cta + 8, warps)}){note}",
        source=f"{DSV4}:805 (fusedDeepseekV4FullCacheKernel), launchFullCacheKernel :997, "
               f"host :{1231 if heads else 1129}",
        unit=DSV4,
        symbol=f"30fusedDeepseekV4FullCacheKernelIN3c108BFloat16ELb0ELb0ELb{int(norm)}EE",
        args=(Ptr("q_inout") if heads else NULL, NULL, Int(0, "q_fp8_stride0"),
              Int(0, "q_fp8_stride1"), Ptr("kv_in"), Ptr("k_cache"), Ptr("slot_mapping"),
              Ptr("position_ids"), Ptr("cos_sin_cache"), NULL, NULL,
              Float(EPS if heads else 0.0, "eps"), Int(tokens, "num_tokens_full"),
              Int(inserted, "num_tokens_insert"), Int(heads, "num_heads_q"),
              Int(block_size, "cache_block_size"), Int(block_size * 1024, "kv_block_stride"),
              Int(1024, "kv_token_stride")),
        arrays=tuple(arrays),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec=dsv4_full_cache_spec(heads, norm and heads > 0),
        dims={"T": tokens, "TI": inserted, "H": heads, "NB": num_blocks, "BS": block_size,
              "PM": tokens, "TWO": 2, "W0": 8 * cta, "W1": min(8 * cta + 8, warps), "C64": 64,
              "C256": 256},
        cta=(cta, 0, 0),
    )


CASES += (
    dsv4_full_cache("dsv4_full_cache_norm_8h_last_block", 3, 8, cta=3, inserted=2,
                    note=" (token 2 is DP padding: its KV warp returns; warps 27-31 idle)"),
    dsv4_full_cache("dsv4_full_cache_norm_8h_straddle", 3, 8, cta=2, inserted=2,
                    note=" (token 1's last head and KV slot, token 2's first 6 heads)"),
    dsv4_full_cache("dsv4_full_cache_no_norm_16h", 2, 16, cta=4, norm=False,
                    note=" (token 1's last head and KV slot; 6 warps past the grid's rows)"),
    dsv4_full_cache("dsv4_kv_rope_insert_bf16_20tok", 20, 0, cta=2, norm=False,
                    note=" (tokens 16-19 into cache block 1)"),
    negative(dsv4_full_cache("dsv4_full_cache_norm_8h_straddle", 3, 8, cta=2, inserted=2),
             "spec skips token 1's KV insert", TI=1),
)


# ===== GPTQ dequantization (csrc/quantization/gptq/q_gemm.cu) =====

Q_GEMM = "csrc/quantization/gptq/q_gemm.cu"


def packed_field(words, e, bits):
    """Element e of a packed row: bits [e bits, (e + 1) bits) of its words, little-endian."""
    stream = sum(w << (32 * i) for i, w in enumerate(words))
    return (stream >> (e * bits)) & ((1 << bits) - 1)


def pack_fields(values, bits):
    """The 32-bit words packing `values` as packed_field reads them."""
    stream = sum(v << (i * bits) for i, v in enumerate(values))
    return [(stream >> (32 * i)) & 0xffffffff for i in range(-(-len(values) * bits // 32))]


def shuffle_4bit_8(word):
    """qdq_4.cuh:16: nibble 2i to bits 4i, nibble 2i + 1 to bits 16 + 4i."""
    out = 0
    for i in range(4):
        out |= ((word >> (8 * i)) & 0xf) << (4 * i) | ((word >> (8 * i + 4)) & 0xf) << (4 * i + 16)
    return out


def gptq_reconstruct(name, bits, size_k, size_n, groups, cta, exllama=False, v2=False, seed=11,
                     check="ACCEPT", note=""):
    """gptq_gemm's dequantization into temp_dq [K, N] before cuBLAS (q_gemm.cu:1336, M > 50
    rows (8-bit: 24) with exllama, else M > 8 or bits < 4): `reconstruct_exllama_<bits>bit_kernel`
    (grid (ceil(N / 128), ceil(K / 128)), each block 128 rows x 512 columns, 4 per thread,
    weights gptq_shuffle'd (:1488) first) or `reconstruct_gptq_kernel` (grid (ceil(N / 128),
    ceil(K / (32 / bits))), one packed word per thread; 3-bit: 32 rows from 3 words), 128
    threads. Weights and zeros are concrete (index arrays), scales symbolic: out[k, n] =
    (q[k, n] - (zero[g, n] + (0 if v2 else 1)) + ZS) scale[g, n], g = k / (K / groups),
    ZS = 0 (a negative's zero-point shift)."""
    import random
    rng = random.Random(seed)
    pack = 32 // bits if bits != 3 else None
    q = [[rng.randrange(1 << bits) for _ in range(size_n)] for _ in range(size_k)]
    z = [[rng.randrange(1 << bits) for _ in range(size_n)] for _ in range(groups)]
    words_per_32 = bits  # 32 elements pack into `bits` words
    q_words = [[0] * size_n for _ in range(size_k * bits // 32)]
    for n in range(size_n):
        for k0 in range(0, size_k, 32):
            ws = pack_fields([q[k][n] for k in range(k0, k0 + 32)], bits)
            for i, w in enumerate(ws):
                q_words[k0 * bits // 32 + i][n] = shuffle_4bit_8(w) if exllama and bits == 4 else w
    z_words = [pack_fields(row, bits) for row in z]
    gsize = size_k // groups
    bx, by = cta
    if exllama:
        rows = range(128 * by, min(128 * by + 128, size_k))
        cols = range(512 * bx, min(512 * bx + 512, size_n))
        grid = (-(-size_n // 128), -(-size_k // 128), 1)
        kernel, line = f"31reconstruct_exllama_{bits}bit_kernel", {8: 659, 4: 739}[bits]
        args = lambda: (Ptr("w"), Ptr("w_zeros"), Ptr("w_scales"), Int(size_k, "size_k"),
                        Int(size_n, "size_n"), Int(groups, "groups"), Int(int(v2), "use_v2"),
                        Ptr("out"))
    else:
        per = 32 if bits == 3 else 32 // bits
        rows = range(per * by, min(per * by + per, size_k))
        cols = range(128 * bx, min(128 * bx + 128, size_n))
        grid = (-(-size_n // 128), -(-size_k // per), 1)
        kernel = ("28reconstruct_gptq_3bit_kernel" if bits == 3 else
                  f"23reconstruct_gptq_kernelINS0_17MatrixView_q{bits}_rowELi{bits}EE")
        line = 1258 if bits == 3 else 1223
        args = lambda: (Ptr("w"), Ptr("w_scales"), Ptr("w_zeros"), Int(size_k, "height"),
                        Int(size_n, "width"), Int(groups, "num_groups"), Int(int(v2), "use_v2"),
                        Ptr("out"))
    off = 0 if v2 else 1
    value = lambda k, n: q[k][n] - z[k // gsize][n] - off
    body = table("k", ["unwritten"] * rows[0] + [
        table("n", ["unwritten"] * cols[0] + [
            f"({literal(value(k, n))} + ZS) * w_scales[{k // gsize}, n]" for n in cols])
        for k in rows])
    spec = write_spec(f"gptq_{name}", "\n".join([
        f"// Generated by cases.py (gptq_reconstruct) for the case {name}: {Q_GEMM}.",
        "dim K; dim N; dim G; dim ZS;", "array w_scales[G, N];", "array out[K, N];",
        f"out[k, n] = {body};", ""]))
    return Case(
        name=name,
        description=f"{kernel[2:].split('I')[0]}, {bits}-bit, K {size_k} x N {size_n}, {groups} "
                    f"groups, GPTQ{'v2' if v2 else 'v1'} zeros, grid {grid[:2]}, block {cta} = "
                    f"rows [{rows[0]}, {rows[-1] + 1}) x columns [{cols[0]}, {cols[-1] + 1}){note}",
        source=f"{Q_GEMM}:{line} ({kernel[2:].split('I')[0]}), "
               f"{'reconstruct_exllama :983' if exllama else 'reconstruct_gptq :1303'}, "
               "gemm_half_q_half_cuda :1328",
        unit=Q_GEMM,
        symbol=kernel,
        args=args(),
        arrays=(Array("w", "index", "u32", (len(q_words), size_n),
                      contents=tuple(v for row in q_words for v in row)),
                Array("w_zeros", "index", "u32", (groups, len(z_words[0])),
                      contents=tuple(v for row in z_words for v in row)),
                Array("w_scales", "in", "f16", (groups, size_n)),
                Array("out", "out", "f16", (size_k, size_n))),
        grid=grid,
        block=128,
        check=check,
        spec=spec,
        dims={"K": size_k, "N": size_n, "G": groups, "ZS": 0},
        cta=(bx, by, 0),
    )


CASES += (
    gptq_reconstruct("reconstruct_gptq_4bit_tail", 4, 64, 200, 2, cta=(1, 7),
                     note=" (72 of 128 columns; the last row block of group 1)"),
    gptq_reconstruct("reconstruct_gptq_2bit_v2", 2, 64, 64, 4, cta=(0, 3), v2=True,
                     note=" (half the block's threads idle)"),
    gptq_reconstruct("reconstruct_gptq_8bit", 8, 32, 96, 1, cta=(0, 5)),
    gptq_reconstruct("reconstruct_gptq_3bit_groups", 3, 64, 64, 4, cta=(0, 1),
                     note=" (32 rows from 3 words over two 16-row groups)"),
    gptq_reconstruct("reconstruct_exllama_4bit_groups", 4, 64, 16, 2, cta=(0, 0), exllama=True,
                     note=" (shuffled weights; the zeros and scales switch at row 32)"),
    gptq_reconstruct("reconstruct_exllama_8bit", 8, 32, 16, 1, cta=(0, 0), exllama=True),
    negative(gptq_reconstruct("reconstruct_exllama_4bit_groups", 4, 64, 16, 2, cta=(0, 0),
                              exllama=True), "spec reads the zeros as GPTQv2's", ZS=1),
)


CASES += (
    # Race-only: gptq_shuffle (:1488, shuffle_exllama_weight :1433) permutes the packed
    # weight in place, so it is a symbolic `inout` word array. Volta runs the shifts and masks
    # on it as bit-vector terms, but a spec's word operations are opaque, so the natural spec
    # (OR of each nibble shifted to its slot) stays UNKNOWN against nvcc's merged masks
    # (Volta gap for correctness; checked by hand: see shuffle_4bit_8 in qdq_4.cuh:16).
    Case(name="gptq_shuffle_4bit", description="shuffle_4bit_kernel, K 64 x N 40, grid 2, "
         "block 1 (8 of 32 columns)",
         source=f"{Q_GEMM}:1381 (shuffle_4bit_kernel), shuffle_exllama_weight :1433, "
                "gptq_shuffle :1488",
         unit=Q_GEMM, symbol="19shuffle_4bit_kernel",
         args=(Ptr("q_weight"), Int(64, "size_k"), Int(40, "size_n")),
         arrays=(Array("q_weight", "inout", "u32", (8, 40)),),
         grid=(2, 1, 1), block=32, check="VERIFIED", cta=(1, 0, 0)),
)


# ===== Marlin weight repacking (csrc/quantization/marlin/{gptq,awq}_marlin_repack.cu) =====

B200_SMEM_OPTIN = 232448  # cudaDevAttrMaxSharedMemoryPerBlockOptin on B200 (227 KiB)


def marlin_repack_reference(q, size_k, size_n, bits):
    """The repacked tiles (gptq_marlin_repack.cu:93): per (k tile, n tile) of 16 x 64, thread
    (warp w < 4, lane th) packs the elements (k = th % 4 * 2 + {0, 1, 8, 9}, n = 16 w + th / 4
    and + 8) in FasterTransformer's interleaved order into word th * 4 + w (4-bit) or
    th * 8 + 2 w + {0, 1} (8-bit)."""
    n_tiles = size_n // 64
    tiles = {}
    for kt in range(size_k // 16):
        for nt in range(n_tiles):
            words = [0] * (16 * 64 * bits // 32)
            for w in range(4):
                for th in range(32):
                    cur_n = nt * 64 + w * 16 + th // 4
                    ks = [kt * 16 + (th % 4) * 2 + o for o in (0, 1, 8, 9)]
                    vals = [q[k][cur_n] for k in ks] + [q[k][cur_n + 8] for k in ks]
                    if bits == 4:
                        res = 0
                        for i, idx in enumerate((0, 2, 4, 6, 1, 3, 5, 7)):
                            res |= vals[idx] << (4 * i)
                        words[th * 4 + w] = res
                    else:
                        r1 = r2 = 0
                        for i, idx in enumerate((0, 2, 1, 3)):
                            r1 |= vals[idx] << (8 * i)
                            r2 |= vals[4 + idx] << (8 * i)
                        words[th * 8 + 2 * w], words[th * 8 + 2 * w + 1] = r1, r2
            tiles[kt, nt] = words
    return tiles


def marlin_repack(name, kind, bits, size_k, size_n, cta, sms=B200_SMS, seed=13, check="ACCEPT",
                  note=""):
    """`{kind}_marlin_repack_kernel<256, bits>(b_q_weight, out, K, N)` (:15), grid = the SM
    count, 256 threads, the opt-in maximum of dynamic shared memory (:241): block `cta`
    repacks k tiles [cta ceil(k_tiles / grid), ...) through an 8-stage cp.async ring over
    the n tiles. GPTQ packs b_q_weight [K / pack, N] along k, AWQ [K, N / pack] along n in
    the interleaved order (0, 2, 4, 6, 1, 3, 5, 7) (4-bit) / (0, 2, 1, 3) (8-bit). The
    weight is concrete; out [K / 16, N 16 / pack] is checked word for word."""
    import random
    rng = random.Random(seed)
    pack = 32 // bits
    q = [[rng.randrange(1 << bits) for _ in range(size_n)] for _ in range(size_k)]
    if kind == "gptq":
        rows = [[sum(q[kp * pack + i][n] << (bits * i) for i in range(pack)) for n in range(size_n)]
                for kp in range(size_k // pack)]
    else:
        # AWQ's pack order (0, 2, 4, 6, 1, 3, 5, 7): element e of a word sits at position
        # undo_pack[e] (:107)
        undo = (0, 4, 1, 5, 2, 6, 3, 7) if bits == 4 else (0, 2, 1, 3)
        rows = [[sum(q[k][npk * pack + e] << (bits * undo[e]) for e in range(pack))
                 for npk in range(size_n // pack)] for k in range(size_k)]
    tiles = marlin_repack_reference(q, size_k, size_n, bits)
    k_tiles, n_tiles = size_k // 16, size_n // 64
    per = -(-k_tiles // sms)
    mine = range(cta * per, min(cta * per + per, k_tiles))
    tile_words = 16 * 64 // pack
    word = lambda v: str(v % 2**32)
    body = table("a", ["unwritten"] * mine[0] + [
        table("b", [table("i", [word(v) for v in tiles[kt, nt]]) for nt in range(n_tiles)])
        for kt in mine])
    spec = write_spec(f"marlin_{name}", "\n".join([
        f"// Generated by cases.py (marlin_repack) for the case {name}: the block's repacked "
        "tiles, word for word.", "dim KT; dim NT; dim TW;", "array out[KT, NT, TW];",
        f"out[a, b, i] = {body};", ""]))
    unit = f"csrc/quantization/marlin/{kind}_marlin_repack.cu"
    return Case(
        name=name,
        description=f"{kind}_marlin_repack_kernel, {bits}-bit, K {size_k} x N {size_n} ({k_tiles} "
                    f"x {n_tiles} tiles), grid {sms}, block {cta} = k tiles {list(mine)}{note}",
        source=f"{unit}:15 ({kind}_marlin_repack_kernel), host :{200 if kind == 'awq' else 198}",
        unit=unit,
        symbol=f"{25 if kind == 'gptq' else 24}{kind}_marlin_repack_kernelILi256ELi{bits}EE",
        args=(Ptr("b_q_weight"), Ptr("out"), Int(size_k, "size_k"), Int(size_n, "size_n")),
        arrays=(Array("b_q_weight", "index", "u32", (len(rows), len(rows[0])),
                      contents=tuple(v for r in rows for v in r)),
                Array("out", "out", "u32", (k_tiles, n_tiles, tile_words))),
        grid=(sms, 1, 1),
        block=256,
        check=check,
        spec=spec,
        dims={"KT": k_tiles, "NT": n_tiles, "TW": tile_words},
        cta=(cta, 0, 0),
        smem=B200_SMEM_OPTIN,
    )


CASES += (
    marlin_repack("gptq_marlin_repack_4bit", "gptq", 4, 32, 128, cta=1,
                  note=" (2 n tiles: 6 of the ring's fetches skipped)"),
    marlin_repack("gptq_marlin_repack_8bit", "gptq", 8, 16, 64, cta=0),
    marlin_repack("awq_marlin_repack_4bit", "awq", 4, 32, 128, cta=1),
    marlin_repack("awq_marlin_repack_8bit", "awq", 8, 16, 128, cta=0),
    marlin_repack("gptq_marlin_repack_4bit_ring", "gptq", 4, 16, 64 * 10, cta=0,
                  note=" (10 n tiles wrap the 8-stage ring)"),
    marlin_repack("awq_marlin_repack_4bit_2_ktiles", "awq", 4, 16 * 149, 64, cta=73,
                  note=" (149 k tiles over 148 blocks, 2 per block: the ring restarts)"),
    negative(marlin_repack("gptq_marlin_repack_8bit", "gptq", 8, 16, 64, cta=0),
             "spec's tiles shifted by one word", TW=255),
)


# ===== AWQ dequantization and GEMM (csrc/quantization/awq/gemm_kernels.cu) =====

AWQ = "csrc/quantization/awq/gemm_kernels.cu"
AWQ_UNDO = (0, 4, 1, 5, 2, 6, 3, 7)  # element e of a packed int32 sits at nibble AWQ_UNDO[e]


def awq_pack(rows):
    """AWQ's int32 packing of each row's 4-bit values, 8 per word in its interleaved order."""
    return [[sum(r[8 * c + e] << (4 * AWQ_UNDO[e]) for e in range(8)) for c in range(len(r) // 8)]
            for r in rows]


def awq_weights(in_c, out_c, group, seed):
    import random
    rng = random.Random(seed)
    q = [[rng.randrange(16) for _ in range(out_c)] for _ in range(in_c)]
    z = [[rng.randrange(16) for _ in range(out_c)] for _ in range(in_c // group)]
    arrays = (Array("qweight", "index", "i32", (in_c, out_c // 8),
                    contents=tuple(v for r in awq_pack(q) for v in r)),
              Array("qzeros", "index", "i32", (in_c // group, out_c // 8),
                    contents=tuple(v for r in awq_pack(z) for v in r)),
              Array("scales", "in", "f16", (in_c // group, out_c)))
    return (lambda k, n: f"{literal(q[k][n] - z[k // group][n])} * scales[{k // group}, {n}]"), arrays


def awq_dequantize(name, in_c, out_c, group, cta, seed=17, check="ACCEPT", note=""):
    """`awq_dequantize(qweight, scales, qzeros, 0, 0, 0)` (gemm_kernels.cu:407, auto_awq.py:905
    for >= 256 tokens): `dequantize_weights` (:352) on grid (OC / 64, IC / 8) of 8 x 8
    threads, one packed word -> 8 halves (q - zero) scale each; block `cta` = rows
    [8 y, 8 y + 8) x columns [64 x, 64 x + 64)."""
    w, arrays = awq_weights(in_c, out_c, group, seed)
    bx, by = cta
    rows, cols = range(8 * by, 8 * by + 8), range(64 * bx, 64 * bx + 64)
    body = table("k", ["unwritten"] * rows[0] + [
        table("n", ["unwritten"] * cols[0] + [w(k, n) for n in cols]) for k in rows])
    spec = write_spec(f"awq_{name}", "\n".join([
        f"// Generated by cases.py (awq_dequantize) for the case {name}: {AWQ}:352.",
        "dim K; dim N; dim G; dim ZS;", "array scales[G, N];", "array out[K, N];",
        f"out[k, n] = {body.replace(' * scales[', ' * (1 + ZS) * scales[')};", ""]))
    return Case(
        name=name,
        description=f"dequantize_weights, IC {in_c} x OC {out_c}, group {group}, grid "
                    f"({out_c // 64}, {in_c // 8}) x (8, 8), block {cta}{note}",
        source=f"{AWQ}:352 (dequantize_weights), awq_dequantize :407",
        unit=AWQ,
        symbol="18dequantize_weights",
        args=(Ptr("qweight"), Ptr("scales"), Ptr("qzeros"), Ptr("out"), Int(group, "G")),
        arrays=(*arrays, Array("out", "out", "f16", (in_c, out_c))),
        grid=(out_c // 64, in_c // 8, 1),
        block=(8, 8, 1),
        check=check,
        spec=spec,
        dims={"K": in_c, "N": out_c, "G": in_c // group, "ZS": 0},
        cta=(bx, by, 0),
    )


def awq_gemm(name, m, in_c, out_c, group, cta, split_k=8, seed=19, check="ACCEPT", note=""):
    """`awq_gemm(x [M, IC], qweight, scales, qzeros, split_k_iters = pack_factor 8)`
    (gemm_kernels.cu:465, auto_awq.py:908 below 256 tokens): `gemm_forward_4bit_cuda_m16nXk32
    <N>` (:23), N = 128 if OC % 128 == 0 else 64, grid ceil(M / 16) (OC / N) split_k of
    (32, 2) threads, out [split_k, M, OC] (summed afterwards). Block x = (tile y = x %
    (ceil(M / 16) OC / N), split z = x / that) dequantizes its 32 x N weight tiles into
    shared memory and accumulates k chunks z, z + split_k, ... with ldmatrix + mma.sync."""
    w, arrays = awq_weights(in_c, out_c, group, seed)
    nn = 128 if out_c % 128 == 0 else 64
    j = out_c // nn
    tiles = -(-m // 16) * j
    by, bz = cta % tiles, cta // tiles
    rows = range(by // j * 16, min(by // j * 16 + 16, m))
    cols = range(by % j * nn, by % j * nn + nn)
    chunks = [c for c in range(bz, in_c // 32, split_k)]
    terms = []
    for c in chunks:
        wk = table("k", ["0"] * (32 * c) + [table("n", ["0"] * cols[0] + [
            w(k, n).replace(f", {n}]", ", n]") for n in cols]) for k in range(32 * c, 32 * c + 32)])
        terms.append(f"sum(k in {32 * c}..{32 * c + 32}, x[m, k] * ({wk}))")
    body = " + ".join(terms) if terms else "0"
    body = (f"where(z == Z, where(m < {rows[0]}, unwritten, where(m < {rows[-1] + 1}, "
            f"where(n < {cols[0]}, unwritten, where(n < {cols[-1] + 1}, {body}, unwritten)), "
            "unwritten)), unwritten)")
    spec = write_spec(f"awq_{name}", "\n".join([
        f"// Generated by cases.py (awq_gemm) for the case {name}: {AWQ}:23, split {bz}'s "
        "partial sums over its k chunks of one 16 x N tile.",
        "dim SK; dim M; dim K; dim N; dim G; dim Z;", "array x[M, K];", "array scales[G, N];",
        "array out[SK, M, N];", f"out[z, m, n] = {body};", ""]))
    return Case(
        name=name,
        description=f"gemm_forward_4bit_cuda_m16nXk32<{nn}>, M {m} x IC {in_c} x OC {out_c}, "
                    f"group {group}, split_k {split_k}, grid {tiles * split_k}, block {cta} = "
                    f"rows [{rows[0]}, {rows[-1] + 1}) x columns [{cols[0]}, {cols[-1] + 1}), "
                    f"k chunks {chunks}{note}",
        source=f"{AWQ}:23 (gemm_forward_4bit_cuda_m16nXk32), awq_gemm :465",
        unit=AWQ,
        symbol=f"31gemm_forward_4bit_cuda_m16nXk32ILi{nn}EE",
        args=(Int(group, "G"), Int(split_k, "split_k_iters"), Ptr("x"), Ptr("qweight"),
              Ptr("scales"), Ptr("qzeros"), Int(m, "M"), Int(in_c, "IC"), Int(out_c, "OC"),
              Ptr("out")),
        arrays=(Array("x", "in", "f16", (m, in_c)), *arrays,
                Array("out", "out", "f16", (split_k, m, out_c))),
        grid=(tiles * split_k, 1, 1),
        block=(32, 2, 1),
        check=check,
        spec=spec,
        dims={"SK": split_k, "M": m, "K": in_c, "N": out_c, "G": in_c // group, "Z": bz},
        cta=(cta, 0, 0),
    )


CASES += (
    awq_dequantize("awq_dequantize_256x128", 256, 128, 128, cta=(1, 31),
                   note=" (the last row block; the second group)"),
    negative(awq_dequantize("awq_dequantize_256x128", 256, 128, 128, cta=(1, 31)),
             "spec doubles the scales", ZS=1),
    awq_gemm("awq_gemm_n128_5tok_chunk1", 5, 128, 128, 64, cta=1,
             note=" (11 of 16 rows zero-filled)"),
    awq_gemm("awq_gemm_n128_5tok_idle_split", 5, 128, 128, 64, cta=5,
             note=" (split 5 past the 4 k chunks: k_bound 0, zeros)"),
    awq_gemm("awq_gemm_n64_20tok_tile2", 20, 64, 192, 32, cta=11,
             note=" (second M tile: 4 rows; third n tile)"),
    negative(awq_gemm("awq_gemm_n128_5tok_chunk1", 5, 128, 128, 64, cta=1),
             "spec's split one later", Z=2),
)



# ===== sqrt-softplus top-k: the uint32 / int64 index instantiations =====
# topk_softplus_sqrt.cu:145 picks the unit by topk_indices' dtype (int32 / uint32 / int64) and
# the hash table's dtype (int64 or int32, :85) for input_ids / tid2eid.

CASES += (
    softplus_topk("softplus_hash_bf16_64e_top6_u32", 64, 6, 7, cta=0, idx="u32",
                  note=" (4 rows per warp; the second warp 3 rows)"),
    softplus_topk("softplus_hash_f16_32e_top4_i64_i64ids", 32, 4, 8, cta=0, dtype="f16",
                  idx="i64", ids="i64", note=" (int64 ids: token t's experts 4t .. 4t + 3)"),
    # Volta gap: here nvcc narrows `static_cast<int>(load_index_as_int64(tid2eid, ...))`
    # (:447) of the int64 table to a 4-byte load of each element's low word (ld.global.b32
    # at an 8-byte stride), which Volta refuses ("unsupported reinterpretation of Global
    # memory ... the bytes belong to a 8-byte scalar granule"). Correct on hardware.
    softplus_topk("softplus_hash_f32_128e_top2_u32_i64ids_padding", 128, 2, 3, cta=0,
                  dtype="f32", idx="u32", ids="i64", pads=(1, 2), renormalize=False,
                  check="UNKNOWN"),
    softplus_topk("softplus_hash_bf16_256e_top8_i64", 256, 8, 6, cta=1, idx="i64"),
    softplus_topk("softplus_topk_bf16_256e_top1_u32", 256, 1, 6, cta=1, use_hash=False,
                  idx="u32", ids="u32", note=" (no hash: HashIndType = IndType)"),
    softplus_topk("softplus_topk_f32_16e_top1_i64", 16, 1, 40, cta=0, dtype="f32",
                  use_hash=False, idx="i64", ids="i64"),
    # Volta gap: the same low-word load of the int64 tid2eid in dsv4HashTopkSoftplusSqrt
    # (:177, ld.global.b32 [tid2eid + 8 i]) with uint32 or int64 indices, "unsupported
    # reinterpretation of Global memory at 0x500c0 (width 4)".
    dsv4_hash_topk("dsv4_hash_topk_256e_u32_i64ids", 256, 6, cta=1, idx="u32", ids="i64",
                   check="UNKNOWN", note=" (last block: 2 of 4 warps)"),
    dsv4_hash_topk("dsv4_hash_topk_256e_i64_i64ids", 256, 6, cta=1, idx="i64", ids="i64",
                   check="UNKNOWN", note=" (last block: 2 of 4 warps)"),
    dsv4_hash_topk("dsv4_hash_topk_384e_i64_padding", 384, 4, cta=0, pads=(1, 2, 3), idx="i64"),
    negative(softplus_topk("softplus_hash_f16_32e_top4_i64_i64ids", 32, 4, 8, cta=0,
                           dtype="f16", idx="i64", ids="i64"),
             "spec's rows 5 experts wide", K=5),
)


def softplus_image_rows(name, base, sentinel, check="VERIFIED", note=""):
    """`base` (a hash softplus_topk case with int64 ids, token t's id t) with bias_vl given
    and image_sentinel_lo = `sentinel` (fused_topk_bias_router.py:165, DeepSeek-V4's vision
    routing): tokens [sentinel, sentinel + 5) are image rows, routed by score + bias_vl
    (:562, the top-k butterfly) while the other rows of the same warp take the hash path's
    renormalizing butterfly (:467). Race-only (no spec): the image rows' arg-max picks are
    symbolic."""
    import dataclasses
    args = list(base.args)
    args[15], args[16] = Ptr("bias_vl"), Int(sentinel, "image_sentinel_lo")
    e = next(a for a in base.arrays if a.name == "gating_output").shape[1]
    return dataclasses.replace(
        base, name=name, args=tuple(args), check=check, spec=None, dims={},
        arrays=base.arrays + (Array("bias_vl", "in", "f32", (e,)),),
        description=base.description + f", bias_vl, image tokens [{sentinel}, {sentinel + 5})"
                    + note,
        source=base.source + "; image rows fused_topk_bias_router.py:165")


CASES += (
    # Volta gap (a deliberate one): 32 experts put 8 rows in a warp (4 lanes each), so rows
    # 0, 1, 7 (hash) run the renormalizing __shfl_xor_sync at :467 while image rows 2-6 run
    # the arg-max ones at :562. Volta matches a warp collective only at one pc
    # (eval/schedule.rs find_ready_warp_group) and reports "trace: deadlock, 32 blocked
    # thread(s)". Not a kernel bug: on sm_70+ shfl.sync waits for the non-exited threads of
    # membermask to execute *a* shfl.sync with the same qualifiers and mask (PTX ISA
    # 9.7.9.6), every lane sources from its own 4-lane row segment, and the hash rows exit
    # before the image rows' last shuffles. (An all-image warp instead stops at the bias
    # read of the symbolic arg-max, "a branch on a symbolic predicate reaches Load".)
    softplus_image_rows("softplus_image_rows_f16_32e_top1_i64", softplus_topk(
        "softplus_hash_f16_32e_top1_i64_i64ids", 32, 1, 8, cta=0, dtype="f16", idx="i64",
        ids="i64"), 2, check="REJECTED", note=" (hash and image rows share warp 0)"),
)


# ===== CUTLASS MoE metadata (csrc/quantization/w8a8/cutlass/moe/moe_data.cu) =====

MOE_DATA = "csrc/quantization/w8a8/cutlass/moe/moe_data.cu"


def int_outputs_spec(name, outputs, extra_dims=()):
    """A spec giving each output (name -> (shape, values, written range [lo, hi))) its
    concrete 32-bit words, `unwritten` outside the range; a dim D shifts every value (D = 0)."""
    lines = [f"dim D;{''.join(f' dim {d};' for d in extra_dims)}"]
    for out, (shape, values, lo, hi) in outputs.items():
        lines.append(f"array {out}[{shape}];")
        body = "unwritten"
        for i in reversed(range(lo, hi)):
            body = f"where(i == {i}, {values[i] % 2**32} + D, {body})"
        lines.append(f"{out}[i] = {body};")
    return write_spec(f"moe_data_{name}", "\n".join([
        f"// Generated by cases.py (int_outputs_spec) for the case {name}: {MOE_DATA}.",
        *lines, ""]))


def moe_expert_offsets(name, counts, blockscale=False, swap_ab=False, check="ACCEPT", note=""):
    """`compute_expert_offsets` / `compute_expert_blockscale_offsets` (:55 / :68), one thread
    (<<<1, 1>>>, get_cutlass_moe_mm_data_caller :269 / :276): prefix sums of each expert's row count
    (problem_sizes1[e][swap_ab ? 1 : 0], written by compute_problem_sizes), the fp4 path also
    of the counts rounded up to 128; atomic_buffer[e] = the exclusive prefix."""
    e = len(counts)
    ps1 = [v for c in counts for v in ((256, c, 512) if swap_ab else (c, 256, 512))]
    pre = [sum(counts[:i]) for i in range(e + 1)]
    rnd = [sum(-(-c // 128) * 128 for c in counts[:i]) for i in range(e + 1)]
    outputs = {"expert_offsets": ("E1", pre, 0, e + 1), "atomic_buffer": ("E1", pre, 0, e + 1)}
    arrays = [Array("problem_sizes1", "index", "i32", (e, 3), contents=tuple(ps1)),
              Array("expert_offsets", "out", "i32", (e + 1,)),
              Array("atomic_buffer", "out", "i32", (e + 1,))]
    if blockscale:
        outputs["blockscale_offsets"] = ("E1", rnd, 0, e + 1)
        arrays.append(Array("blockscale_offsets", "out", "i32", (e + 1,)))
    kernel = "33compute_expert_blockscale_offsets" if blockscale else "22compute_expert_offsets"
    args = ((Ptr("problem_sizes1"), Ptr("expert_offsets"), Ptr("blockscale_offsets"),
             Ptr("atomic_buffer")) if blockscale else
            (Ptr("problem_sizes1"), Ptr("expert_offsets"), Ptr("atomic_buffer")))
    return Case(
        name=name,
        description=f"{kernel[2:]}, {e} experts, counts {list(counts)}"
                    f"{', swap_ab' if swap_ab else ''}{note}",
        source=f"{MOE_DATA}:{68 if blockscale else 55} ({kernel[2:]}), "
               f"host :{269 if blockscale else 276}",
        unit=MOE_DATA, symbol=f"_Z{kernel}",
        args=(*args, Int(e, "num_experts"), Int(int(swap_ab), "swap_ab")),
        arrays=tuple(arrays), grid=(1, 1, 1), block=1, check=check,
        spec=int_outputs_spec(name, outputs, ("E1",)), dims={"D": 0, "E1": e + 1},
    )


def moe_problem_sizes_from_offsets(name, num_experts, n, k, swap_ab, cta, check="ACCEPT",
                                   note=""):
    """`compute_problem_sizes_from_expert_offsets<swap_ab>` (:145) through
    get_cutlass_moe_mm_problem_sizes_from_expert_offsets_caller (:183, launch :234): min(E,
    256) threads, one expert each, m = offsets[e + 1] - offsets[e] (an int64 index array:
    element i is i, so m = 1). Problem shapes [m, 2n, k] / [m, k, n], swapped [2n, m, k] / [k, m, n]."""
    threads = min(num_experts, 256)
    lo, hi = cta * threads, min(cta * threads + threads, num_experts)
    p1 = [v for _ in range(num_experts) for v in ((2 * n, 1, k) if swap_ab else (1, 2 * n, k))]
    p2 = [v for _ in range(num_experts) for v in ((k, 1, n) if swap_ab else (1, k, n))]
    outputs = {"problem_sizes1": ("E3", p1, 3 * lo, 3 * hi),
               "problem_sizes2": ("E3", p2, 3 * lo, 3 * hi)}
    return Case(
        name=name,
        description=f"compute_problem_sizes_from_expert_offsets<{swap_ab}>, {num_experts} "
                    f"experts, n {n}, k {k}, {threads} threads, block {cta} = experts "
                    f"[{lo}, {hi}){note}",
        source=f"{MOE_DATA}:145 (compute_problem_sizes_from_expert_offsets), launch :234",
        unit=MOE_DATA, symbol=f"41compute_problem_sizes_from_expert_offsetsILb{int(swap_ab)}E",
        args=(Ptr("expert_first_token_offset"), Ptr("problem_sizes1"), Ptr("problem_sizes2"),
              Int(num_experts, "num_experts"), Int(n, "n"), Int(k, "k")),
        arrays=(Array("expert_first_token_offset", "index", "i64", (num_experts + 1,)),
                Array("problem_sizes1", "out", "i32", (num_experts * 3,)),
                Array("problem_sizes2", "out", "i32", (num_experts * 3,))),
        grid=(-(-num_experts // threads), 1, 1), block=threads, check=check,
        spec=int_outputs_spec(name, outputs, ("E3",)), dims={"D": 0, "E3": 3 * num_experts},
        cta=(cta, 0, 0),
    )


def moe_batched_data(name, counts, padded_m, n, k, check="ACCEPT", note=""):
    """`compute_batched_moe_data<swap>` (:294) through get_cutlass_batched_moe_mm_data_caller
    (:318, launches :330 / :337): <<<1, E>>>, swap = E padded_m <= 64; expert_offsets [E]
    (cutlass_moe.py:175)."""
    e = len(counts)
    swap = e * padded_m <= 64
    p1 = [v for c in counts for v in ((2 * n, c, k) if swap else (c, 2 * n, k))]
    p2 = [v for c in counts for v in ((k, c, n) if swap else (c, k, n))]
    offs = [i * padded_m for i in range(e)]
    outputs = {"expert_offsets": ("E", offs, 0, e), "problem_sizes1": ("E3", p1, 0, 3 * e),
               "problem_sizes2": ("E3", p2, 0, 3 * e)}
    return Case(
        name=name,
        description=f"compute_batched_moe_data<{swap}>, {e} local experts, padded_m "
                    f"{padded_m}, counts {list(counts)}{note}",
        source=f"{MOE_DATA}:294 (compute_batched_moe_data), launch :{337 if swap else 330}",
        unit=MOE_DATA, symbol=f"24compute_batched_moe_dataILb{int(swap)}E",
        args=(Ptr("expert_offsets"), Ptr("problem_sizes1"), Ptr("problem_sizes2"),
              Ptr("expert_num_tokens"), Int(padded_m, "padded_m"), Int(n, "n"), Int(k, "k")),
        arrays=(Array("expert_offsets", "out", "i32", (e,)),
                Array("problem_sizes1", "out", "i32", (3 * e,)),
                Array("problem_sizes2", "out", "i32", (3 * e,)),
                Array("expert_num_tokens", "index", "i32", (e,), contents=tuple(counts))),
        grid=(1, 1, 1), block=e, check=check,
        spec=int_outputs_spec(name, outputs, ("E", "E3")), dims={"D": 0, "E": e, "E3": 3 * e},
    )


CASES += (
    moe_expert_offsets("moe_expert_offsets_8e", (3, 0, 17, 1, 0, 0, 9, 2)),
    moe_expert_offsets("moe_expert_offsets_swap_ab_5e", (4, 1, 0, 6, 2), swap_ab=True),
    moe_expert_offsets("moe_expert_blockscale_offsets_6e", (130, 0, 1, 128, 255, 7),
                       blockscale=True, note=" (fp4: counts rounded up to 128)"),
    moe_problem_sizes_from_offsets("moe_problem_sizes_300e_tail", 300, 1024, 7168, False, cta=1,
                                   note=" (44 of 256 threads)"),
    moe_problem_sizes_from_offsets("moe_problem_sizes_swap_8e", 8, 768, 2048, True, cta=0),
    moe_batched_data("moe_batched_data_4e", (5, 0, 32, 1), 32, 1024, 4096),
    moe_batched_data("moe_batched_data_swap_8e", (3, 0, 8, 1, 2, 7, 4, 8), 8, 512, 2048),
    negative(moe_expert_offsets("moe_expert_blockscale_offsets_6e", (130, 0, 1, 128, 255, 7),
                                blockscale=True), "spec's offsets one higher", D=1),
)


# ===== Muse Spark multiply + tanh soft cap (csrc/muse_spark_mul_tanh_soft_cap_kernel.cu) =====

MUSE_CAP = "csrc/muse_spark_mul_tanh_soft_cap_kernel.cu"


def muse_soft_cap(name, tokens, d, cta, dtype="f32", check="VERIFIED", note=""):
    """`muse_spark_mul_tanh_soft_cap(out f32, input, multiplier, soft_cap_temp)` (:48):
    grid (T, clamp(32768 / T, 1, ceil(ceil(d / 4) / 128))), 128 threads; each row goes
    through vectorize_with_alignment<4> (quantization/vectorization_utils.cuh:21): a scalar
    prefix up to input's 4-element alignment, float4-wide middle, scalar tail, or all
    scalar when out cannot be co-aligned. Race-only: the accurate tanhf is piecewise
    (a polynomial below |x| = 0.6), so no spec over the reals matches it."""
    vecs = -(-d // 4)
    per_row = min(max(32768 // tokens, 1), max(-(-vecs // 128), 1))
    in_t = {"f32": "f", "f16": "N3c104HalfE", "bf16": "N3c108BFloat16E"}[dtype]
    return Case(
        name=name,
        description=f"muse_spark_mul_tanh_soft_cap_kernel, {dtype} -> f32, {tokens} rows of {d}, "
                    f"grid ({tokens}, {per_row}), block {cta}{note}",
        source=f"{MUSE_CAP}:25 (muse_spark_mul_tanh_soft_cap_kernel), host :48",
        unit=MUSE_CAP,
        symbol=f"35muse_spark_mul_tanh_soft_cap_kernelI{in_t}EE",
        args=(Ptr("out"), Ptr("input"), Int(d, "d"), Float(0.5, "multiplier"),
              Float(30.0, "soft_cap_temp")),
        arrays=(Array("input", "in", dtype, (tokens, d)), Array("out", "out", "f32", (tokens, d))),
        grid=(tokens, per_row, 1),
        block=128,
        check=check,
        cta=cta,
    )


CASES += (
    muse_soft_cap("muse_soft_cap_f32_1001_row1", 3, 1001, cta=(1, 1, 0),
                  note=" (row 1 starts 4 bytes past a float4: 3-element prefix)"),
    muse_soft_cap("muse_soft_cap_bf16_1001_row1", 3, 1001, cta=(1, 0, 0), dtype="bf16",
                  note=" (in and out not co-aligned: the all-scalar path)"),
    muse_soft_cap("muse_soft_cap_f16_4096", 2, 4096, cta=(1, 7, 0), dtype="f16",
                  note=" (aligned rows: the vector fast path)"),
)


# ===== Direct DCP KV gather: workspace copy (csrc/attention/dcp_utils/dcp_direct_kv_gather.cu) =====

DCP_KV = "csrc/attention/dcp_utils/dcp_direct_kv_gather.cu"
EPOCH_BASE = 0x900000  # an int64 index array (element i is i): the epoch pointer picks its value


def dcp_materialize(name, world, tokens, dim, max_tokens, epoch, cta, check="ACCEPT", note=""):
    """`materialize_kv_gather_kernel<uint4>(received_kv, epoch, gathered_kv, W T D / 8,
    max_tokens D / 8)` (:72, launch :186): min(ceil(items / 256), 1024) blocks of 256 copy
    the world's gathered [W T, D] bf16 rows out of the symmetric buffer slot epoch & 1 of
    received_kv [2, max_tokens, D]. Block `cta` copies items [256 cta, 256 cta + 256)."""
    items = world * tokens * dim // 8
    grid = min(-(-items // 256), 1024)
    assert grid * 256 >= items, "one grid-stride pass"
    e0, e1 = 256 * cta * 8, min(256 * cta + 256, items) * 8
    spec = write_spec("dcp_materialize", "\n".join([
        f"// vLLM's materialize_kv_gather_kernel ({DCP_KV}:72): elements [E0, E1) of the "
        "gathered rows, copied from slot S of the symmetric buffer.",
        "dim TWO; dim MT; dim R; dim D; dim S; dim E0; dim E1;",
        "array received_kv[TWO, MT, D];", "array gathered_kv[R, D];",
        "gathered_kv[r, c] = where(r * D + c < E0, unwritten, where(r * D + c < E1, "
        "received_kv[S, r, c], unwritten));", ""]))
    return Case(
        name=name,
        description=f"materialize_kv_gather_kernel<uint4>, world {world} x {tokens} tokens of "
                    f"{dim} bf16, buffer of {max_tokens} tokens, epoch {epoch} (slot "
                    f"{epoch & 1}), grid {grid}, block {cta}{note}",
        source=f"{DCP_KV}:72 (materialize_kv_gather_kernel), launch :186",
        unit=DCP_KV,
        symbol="28materialize_kv_gather_kernelI5uint4E",
        args=(Ptr("received_kv"), Int(EPOCH_BASE + 8 * epoch, "epoch"), Ptr("gathered_kv"),
              Int(items, "gathered_item_count"), Int(max_tokens * dim // 8, "slot_stride_items")),
        arrays=(Array("received_kv", "in", "bf16", (2, max_tokens, dim)),
                Array("gathered_kv", "out", "bf16", (world * tokens, dim)),
                Array("epoch", "index", "i64", (8,), base=EPOCH_BASE)),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec=spec,
        dims={"TWO": 2, "MT": max_tokens, "R": world * tokens, "D": dim, "S": epoch & 1,
              "E0": e0, "E1": e1},
        cta=(cta, 0, 0),
    )


CASES += (
    dcp_materialize("dcp_materialize_mla_w4_last", 4, 3, 576, 16, epoch=3, cta=3,
                    note=" (96 of 256 threads; slot 1)"),
    dcp_materialize("dcp_materialize_w2_slot0", 2, 8, 128, 32, epoch=2, cta=0),
    negative(dcp_materialize("dcp_materialize_mla_w4_last", 4, 3, 576, 16, epoch=3, cta=3),
             "spec reads slot 0", S=0),
)


# ===== HiSparse hot-cache row loads (csrc/hisparse_kernels.cu) =====

HISPARSE = "csrc/hisparse_kernels.cu"
HISPARSE_NS = "52_GLOBAL__N__ae102f69_19_hisparse_kernels_cu_45c27c1f"


def hisparse_gather(name, kernel, host_rows, hot_blocks, block_size, width, cols, cta,
                    counts=None, check="ACCEPT", note=""):
    """`hisparse_gather_plan` (:1339, kernel :841: grid (rows, min(ceil(top_k / 32),
    max(1, 256 / rows))) x 1024 threads, column c of a row copied when miss_mask) or
    `hisparse_gather_compact` (:1405, kernel :871: grid (min(rows, 64), min(8, max(1, 64 /
    rows))) x 512, columns below the row's clamped miss count), one warp per column:
    host row g -> hot row dst (load_hot_row_warp :131), zeros past the host pool, skipped
    for g < 0 or dst outside the hot cache. Rows are `width` bf16 (16-byte copies).
    `cols` is per row a list of (g, dst, miss) for each column; block `cta` = (row,
    chunk)."""
    rows, top_k = len(cols), len(cols[0])
    hot_rows = hot_blocks * block_size
    if kernel == "plan":
        threads, warps = 1024, 32
        chunks = min(max(1, -(-top_k // warps)), max(1, 256 // rows))
        grid = (rows, chunks, 1)
    else:
        threads, warps = 512, 16
        grid = (min(rows, 64), min(8, max(1, 64 // rows)), 1)
    bx, by = cta
    dst_rows = {}
    for r in range(bx, rows, grid[0] if kernel == "compact" else rows + 1):
        limit = top_k if kernel == "plan" else min(max(counts[r], 0), top_k)
        for c in (c for w in range(warps) for c in range(by * warps + w, limit, grid[1] * warps)):
            g, dst, miss = cols[r][c]
            if (kernel == "plan" and not miss) or g < 0 or dst < 0 or dst >= hot_rows:
                continue
            assert dst not in dst_rows, "the resolver gives each column its own hot row"
            dst_rows[dst] = f"host_cache[{g}, c]" if g < host_rows else "0"
    body = "unwritten"
    for dst in sorted(dst_rows, reverse=True):
        body = f"where(b * BS + s == {dst}, {dst_rows[dst]}, {body})"
    spec = write_spec(f"hisparse_{name}", "\n".join([
        f"// Generated by cases.py (hisparse_gather) for the case {name}: {HISPARSE}, the "
        f"hot rows block {cta} loads: {sorted(dst_rows)}.",
        "dim HR; dim NB; dim BS; dim W; dim Z;", "array host_cache[HR, W];",
        "array hot_cache[NB, BS, W];",
        f"hot_cache[b, s, c] = {body.replace('host_cache[', '(1 + Z) * host_cache[')};", ""]))
    flat = lambda k: tuple(cols[r][c][k] for r in range(rows) for c in range(top_k))
    row_bytes = width * 2
    common = (Int(host_rows, "host_rows"), Int(hot_rows, "hot_rows"), Int(row_bytes, "row_bytes"),
              Int(block_size * row_bytes, "hot_block_stride"), Int(block_size, "hot_block_size"),
              Int(top_k, "top_k"))
    arrays = [Array("host_cache", "in", "bf16", (host_rows, width)),
              Array("hot_cache", "out", "bf16", (hot_blocks, block_size, width)),
              Array("global_indices", "index", "i32", (rows, top_k), contents=flat(0)),
              Array("hot_indices", "index", "i32", (rows, top_k), contents=flat(1))]
    if kernel == "plan":
        arrays.append(Array("miss_mask", "index", "i32", (rows, top_k), contents=flat(2)))
        args = (Ptr("host_cache"), Ptr("hot_cache"), Ptr("global_indices"), Ptr("hot_indices"),
                Ptr("miss_mask"), *common)
        symbol, line, host = f"{HISPARSE_NS}27hisparse_gather_plan_kernel", 841, 1396
    else:
        arrays.append(Array("miss_counts", "index", "i32", (rows,), contents=tuple(counts)))
        args = (Ptr("host_cache"), Ptr("hot_cache"), Ptr("global_indices"), Ptr("hot_indices"),
                Ptr("miss_counts"), *common, Int(rows, "num_rows"))
        symbol, line, host = f"{HISPARSE_NS}30hisparse_gather_compact_kernel", 871, 1454
    return Case(
        name=name,
        description=f"hisparse_gather_{kernel}_kernel, {rows} rows x top-{top_k}, host pool "
                    f"{host_rows} rows, hot cache {hot_blocks} x {block_size} rows of {width} "
                    f"bf16, grid {grid[:2]} x {threads}, block {cta}{note}",
        source=f"{HISPARSE}:{line} (hisparse_gather_{kernel}_kernel), launch :{host}",
        unit=HISPARSE,
        symbol=symbol,
        args=args,
        arrays=tuple(arrays),
        grid=grid,
        block=threads,
        check=check,
        spec=spec,
        dims={"HR": host_rows, "NB": hot_blocks, "BS": block_size, "W": width, "Z": 0},
        cta=(bx, by, 0),
    )


def hisparse_columns(rows, top_k, host_rows, hot_rows, seed):
    """Random plan columns: each (row, column) its own hot row, some host rows past the
    pool (zero-filled), some g = -1 or dst = -1 (skipped), about half marked missing."""
    import random
    rng = random.Random(seed)
    dsts = rng.sample(range(hot_rows), rows * top_k)
    out = []
    for r in range(rows):
        row = []
        for c in range(top_k):
            g = rng.choice([-1, host_rows + 3] + [rng.randrange(host_rows)] * 6)
            dst = dsts[r * top_k + c] if rng.random() > 0.1 else -1
            row.append((g, dst, int(rng.random() < 0.6)))
        out.append(row)
    return out


CASES += (
    hisparse_gather("hisparse_plan_2x40", "plan", 50, 8, 16,
                    576, hisparse_columns(2, 40, 50, 128, 3), cta=(1, 1),
                    note=" (columns 32-39: 8 of 32 warps)"),
    hisparse_gather("hisparse_compact_3x40", "compact", 50, 8, 16, 576,
                    hisparse_columns(3, 40, 50, 128, 4), cta=(2, 1), counts=(40, -3, 20),
                    note=" (row 2's 20 misses: columns 16-19)"),
    hisparse_gather("hisparse_compact_70rows", "compact", 40, 40, 16, 64,
                    hisparse_columns(70, 9, 40, 640, 5), cta=(5, 0),
                    counts=tuple([9, 50, 0, 3, 7, 12] * 12)[:70],
                    note=" (64 blocks: rows 5 and 69, the grid-stride pass; count 50 clamped)"),
    negative(hisparse_gather("hisparse_plan_2x40", "plan", 50, 8, 16, 576,
                             hisparse_columns(2, 40, 50, 128, 3), cta=(1, 1)),
             "spec doubles the copied rows", Z=1),
)


# ===== FP4 blockwise grouped-GEMM argument setup =====
# (csrc/quantization/fp4/{nv,mx}fp4_blockwise_moe_kernel.cu)

# Where A, B, C, SFA, SFB and alpha start (never dereferenced).
FP4_BASES = (0x10000000, 0x20000000, 0x30000000, 0x40000000, 0x50000000, 0x60000000)


def fp4_group_starts(name, kind, experts, n, k, out_dtype="bf16", check="ACCEPT", note=""):
    """`__get_group_gemm_starts` (nvfp4_blockwise_moe_kernel.cu:54, 16-element scale blocks,
    with alphas) / `__mxfp4_get_group_gemm_starts` (mxfp4_blockwise_moe_kernel.cu:36, 32),
    <<<1, E>>> (:126 / :101): expert e's operand pointers A + off_e K / 2, B + e N K / 2,
    C + off_e N (16-bit), SFA + sf_e K / g, SFB + e N K / g (bytes), alpha + e, the
    constant strides, and its CUTLASS scale-factor layouts (five ints: ceil(rows / 128),
    ceil(K / 4g), 1, ceil(K / 4g) 512, ceil(rows / 128) ceil(K / 4g) 512 for rows = m, n)
    into layout tensors allocated [E, 5] int64 (:322). `experts` = (expert_offset,
    sf_offset, m) per expert; the base tensors are never dereferenced."""
    e = len(experts)
    g = 16 if kind == "nv" else 32
    a, b, c, sfa, sfb, alpha = FP4_BASES
    strides = (k, k, n)  # a.stride(0) * 2, b.stride(1) * 2, output.stride(0) (:337)
    ptrs = {"a_ptrs": [a + off * k // 2 for off, _, _ in experts],
            "b_ptrs": [b + i * n * k // 2 for i in range(e)],
            "out_ptrs": [c + 2 * off * n for off, _, _ in experts],
            "a_scales_ptrs": [sfa + sf * k // g for _, sf, _ in experts],
            "b_scales_ptrs": [sfb + i * n * k // g for i in range(e)]}
    if kind == "nv":
        ptrs["alpha_ptrs"] = [alpha + 4 * i for i in range(e)]
    for s, v in zip(("a_strides", "b_strides", "c_strides"), strides):
        ptrs[s] = [v] * e
    kt = -(-k // (4 * g))
    lay = lambda rows: [-(-rows // 128), kt, 1, kt * 512, -(-rows // 128) * kt * 512]
    layouts = {"layout_sfa": [v for _, _, m in experts for v in lay(m)],
               "layout_sfb": [v for _ in experts for v in lay(n)]}
    lines = ["dim E; dim E10; dim D;"]
    for out, vals in {**ptrs, **layouts}.items():
        lines.append(f"array {out}[{'E10' if out.startswith('layout') else 'E'}];")
        lines.append(f"{out}[i] = {table('i', [f'{v} + D' for v in vals])};")
    spec = write_spec(f"fp4_{name}", "\n".join([
        f"// Generated by cases.py (fp4_group_starts) for the case {name}.", *lines, ""]))
    ins = [Array("expert_offsets", "index", "i32", (e,), contents=tuple(x[0] for x in experts)),
           Array("sf_offsets", "index", "i32", (e,), contents=tuple(x[1] for x in experts)),
           Array("problem_sizes", "index", "i32", (e, 3),
                 contents=tuple(v for _, _, m in experts for v in (m, n, k)))]
    outs = [Array(p, "out", "u64" if p.endswith("ptrs") else "i64", (e,)) for p in ptrs]
    outs += [Array(l, "out", "i32", (e * 10,)) for l in layouts]
    bases = (Int(a, "a"), Int(b, "b"), Int(c, "out"), Int(sfa, "a_blockscale"),
             Int(sfb, "b_blockscales"), *((Int(alpha, "alphas"),) if kind == "nv" else ()))
    out_ptr_args = tuple(Ptr(p) for p in ptrs if p.endswith("ptrs"))
    args = (*out_ptr_args, Ptr("layout_sfa"), Ptr("layout_sfb"), *bases,
            Ptr("expert_offsets"), Ptr("sf_offsets"), Ptr("problem_sizes"), Ptr("a_strides"),
            Ptr("b_strides"), Ptr("c_strides"), *(Int(v) for v in strides), Int(k, "K"),
            Int(n, "N"))
    unit = f"csrc/quantization/fp4/{kind}fp4_blockwise_moe_kernel.cu"
    c_t = {"bf16": "ENS0_10bfloat16_tENS0_13float_ue", "f16": "E6__halfNS0_13float_ue"}[out_dtype]
    symbol = (f"23__get_group_gemm_startsIN7cutlass12float_e2m1_t{c_t}" if kind == "nv" else
              f"29__mxfp4_get_group_gemm_startsIN7cutlass12float_e2m1_t{c_t}")
    return Case(
        name=name,
        description=f"{'__get' if kind == 'nv' else '__mxfp4_get'}_group_gemm_starts, "
                    f"{kind}fp4 -> {out_dtype}, {e} experts (offset, sf offset, m) = "
                    f"{list(experts)}, N {n}, K {k}{note}",
        source=f"{unit}:{54 if kind == 'nv' else 36}, launch :{126 if kind == 'nv' else 101}",
        unit=unit,
        symbol=symbol,
        args=args,
        arrays=(*ins, *outs),
        grid=(1, 1, 1),
        block=e,
        check=check,
        spec=spec,
        dims={"E": e, "E10": 10 * e, "D": 0},
    )


CASES += (
    fp4_group_starts("nvfp4_group_starts_bf16_5e", "nv",
                     ((0, 0, 3), (3, 128, 0), (3, 128, 200), (203, 384, 129), (332, 640, 1)),
                     2048, 7168, note=" (an empty expert; m 129 spans two scale tiles)"),
    fp4_group_starts("nvfp4_group_starts_f16_3e", "nv", ((0, 0, 17), (17, 128, 40), (57, 256, 8)),
                     768, 1024, out_dtype="f16"),
    fp4_group_starts("mxfp4_group_starts_bf16_4e", "mx",
                     ((0, 0, 130), (130, 256, 0), (130, 256, 5), (135, 384, 64)), 5760, 2880,
                     note=" (GPT-OSS's K 2880: a partial 128-wide scale tile)"),
    negative(fp4_group_starts("mxfp4_group_starts_bf16_4e", "mx",
                              ((0, 0, 130), (130, 256, 0), (130, 256, 5), (135, 384, 64)), 5760,
                              2880), "spec's values one higher", D=1),
)


# ===== HY V4 iHC statistics, B200 TMA + tcgen05 path (csrc/hy_v4_ihc_kernels.cu:656) =====


@dataclass(frozen=True)
class Struct:
    """A by-value struct parameter: `fields` are launch-file field dicts (offset + one value)."""

    fields: tuple
    name: str = ""


def bf16_tensor_map(array, rows, cols, box_rows):
    """bf16_tensor_map (hy_v4_ihc_kernels.cu, near :2160): a 2-D [rows, cols] bf16 map, box
    64 x box_rows, 128-byte swizzle, zero OOB fill, as a by-value CUtensorMap."""
    return Struct(({"offset": 0, "tensor_map": {
        "array": array, "dtype": "bf16", "dims": [cols, rows], "strides": [cols * 2],
        "box": [64, box_rows], "swizzle": "128B"}},), array)


def ihc_tma_ksplits(tokens, hidden, sms=B200_SMS):
    """tma_ksplits (:2137)."""
    tiles, chunks = -(-tokens // 64), hidden // 128
    best, best_cost = 1, 0.0
    for s in range(1, 24 + 1):
        if chunks % s:
            continue
        cost = -(-(tiles * 4 * s) // sms) * (chunks // s) * (1 + 0.04 * s)
        if s == 1 or cost < best_cost:
            best, best_cost = s, cost
    return best


def ihc_stats_tma_spec(name, units):
    """partials[split, t, n] and residual_out over each of the block's work units (split,
    tokens [t0, t1), channel c, h range [h0, h1)): r = post[t, c] x[t, h] +
    residual_in[t, c, h]; mix n sums r times the hi + mid + lo bf16 parts of the weight
    (rows n, 8 + n, 16 + n of weight_split); stat 8 sums r^2."""
    r = lambda c, h: f"(post[t, {c}] * x[t, {h}] + residual_in[t, {c}, {h}])"
    w = lambda c: (f"(weight_split[n, {c} * H + h] + weight_split[8 + n, {c} * H + h] + "
                   f"weight_split[16 + n, {c} * H + h])")
    part, res = "unwritten", "unwritten"
    for split, t0, t1, c, h0, h1 in reversed(units):
        mix = f"sum(h in {h0}..{h1}, {r(c, 'h')} * {w(c)})"
        sq = f"sum(h in {h0}..{h1}, {r(c, 'h')} * {r(c, 'h')})"
        part = (f"where(s == {split}, where(t < {t0}, {part}, where(t < {t1}, "
                f"where(n < 8, {mix} * (1 + Z), {sq}), {part})), {part})")
        res = (f"where(t < {t0}, {res}, where(t < {t1}, where(j == {c}, where(h < {h0}, {res}, "
               f"where(h < {h1}, {r('j', 'h')}, {res})), {res}), {res}))")
    return write_spec(f"ihc_stats_tma_{name}", "\n".join([
        f"// Generated by cases.py (ihc_stats_tma_spec) for the case {name}: {IHC}:656.",
        "dim T; dim HC; dim H; dim KT; dim NS; dim NST; dim W24; dim Z;",
        "array residual_in[T, HC, H];", "array x[T, H];", "array post[T, HC];",
        "array weight_split[W24, KT];", "array residual_out[T, HC, H];",
        "array partials[NS, T, NST];",
        f"partials[s, t, n] = {part};", f"residual_out[t, j, h] = {res};", ""]))


def ihc_stats_tma(name, tokens, hidden, cta, sms=B200_SMS, waits=False, check="ACCEPT",
                  note=""):
    """`ihc_stats_tma_kernel(tm_res, tm_x, tm_w, tm_out, post, partials, T, H, ksplits)`
    (:656), launched for > 1024 tokens with a post step on B200 (:2351): grid min(units,
    SMs), 256 threads, kSmemBytes of dynamic shared memory; warp 0 lane 0 TMA-loads
    residual / x / weight-split tiles into a 4-stage ring, warps 4-7 apply the post step in
    shared memory, warp 1 lane 0 issues tcgen05.mma into double-buffered TMEM accumulators,
    warp 2 lane 0 TMA-stores the updated tile. A work unit is (64-token tile, channel,
    1 / ksplits of the channel's 128-column chunks); block `cta` takes units cta, cta +
    grid, ..."""
    ks = ihc_tma_ksplits(tokens, hidden, sms)
    per_tile, chunks = 4 * ks, hidden // 128 // ks
    n_units = -(-tokens // 64) * per_tile
    grid = min(n_units, sms)
    units = []
    for u in range(cta, n_units, grid):
        tile, split = divmod(u, per_tile)
        c, c0 = split // ks, u % ks * chunks
        units.append((split, 64 * tile, min(64 * tile + 64, tokens), c, 128 * c0,
                      128 * (c0 + chunks)))
    k_total = 4 * hidden
    smem = 2 * 4 * 64 * 128 * 2 + 4 * 2 * 24 * 64 * 2 + 1024
    return Case(
        name=name,
        description=f"ihc_stats_tma_kernel, {tokens} tokens x 4 x {hidden}, ksplits {ks} "
                    f"({chunks} chunks of 128 per unit), {n_units} units over grid {grid}, "
                    f"block {cta} = units {[u for u in range(cta, n_units, grid)]}{note}",
        source=f"{IHC}:656 (ihc_stats_tma_kernel), tma_ksplits :2137, launch :2369"
               f"{'; mbar_wait given its retry branch' if waits else ''}",
        unit=IHC_WAITS_UNIT if waits else IHC,
        symbol=f"{IHC_NS}20ihc_stats_tma_kernel",
        args=(bf16_tensor_map("residual_in", tokens, k_total, 64),
              bf16_tensor_map("x", tokens, hidden, 64),
              bf16_tensor_map("weight_split", 24, k_total, 24),
              bf16_tensor_map("residual_out", tokens, k_total, 64), Ptr("post"),
              Ptr("partials"), Int(tokens, "num_tokens"), Int(hidden, "hidden"),
              Int(ks, "ksplits")),
        arrays=(Array("residual_in", "in", "bf16", (tokens, 4, hidden)),
                Array("x", "in", "bf16", (tokens, hidden)),
                Array("weight_split", "in", "bf16", (24, k_total)),
                Array("post", "in", "f32", (tokens, 4)),
                Array("residual_out", "out", "bf16", (tokens, 4, hidden)),
                Array("partials", "out", "f32", (4 * ks, tokens, 9))),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec=ihc_stats_tma_spec(name, units),
        dims={"T": tokens, "HC": 4, "H": hidden, "KT": k_total, "NS": 4 * ks, "NST": 9,
              "W24": 24, "Z": 0},
        cta=(cta, 0, 0),
        smem=smem,
    )


IHC_WAITS_UNIT = "../../vllm/patched/hy_v4_ihc_kernels_waits.cu"  # survey path, relative


def ihc_waits_ptx():
    """The iHC PTX with each mbar_wait (:592, `do { try_wait.parity p; selp done, 1, 0, p; }
    while (!done)`, a scoped predicate read back through a register) flattened into the
    retry loop Volta models, `L: try_wait.parity %pw; @!%pw bra L; mov done, 1;` (the setp /
    bra after it then fall through): the same semantics, written to external/ptx/vllm/
    patched/ (only when it changed) from the survey's PTX."""
    import re
    from pathlib import Path
    here = Path(__file__).resolve().parent
    source = here.parent / "survey" / "vllm" / "csrc" / "hy_v4_ihc_kernels.ptx"
    if not source.exists():
        return
    text = source.read_text()
    entry = re.compile(r"(\.visible \.entry [^(]*\([^)]*\)\n[^{]*\{\n)")
    text = entry.sub(r"\1\t.reg .pred \t%pihcw;\n", text)
    wait = re.compile(r"(\$L__BB\d+_\d+):\n\t// begin inline asm\n\t\{\n\.reg \.pred p;\n"
                      r"(mbarrier\.try_wait\.parity[^ ]*) p, ([^\n]*)\n"
                      r"selp\.u32 \t?(%r\d+), 1, 0, p;\n\}\n")
    text, waits = wait.subn(r"\1:\n\t\2 %pihcw, \3\n\t@!%pihcw bra \t\1;\n"
                            r"\tmov.u32 \t\4, 1;\n", text)
    assert waits == 6, waits
    out = here / "patched" / "hy_v4_ihc_kernels_waits.ptx"
    if not out.exists() or out.read_text() != text:
        out.write_text(text)


ihc_waits_ptx()


CASES += (
    # Volta gap: mbar_wait (:592) compiles to `L: { try_wait.parity p, [bar], ph; selp.u32
    # %r, 1, 0, p; } setp.eq.b32 %q, %r, 0; @%q bra L;` (PTX :719-728), a retry loop through
    # a register, which Volta reads as a one-shot wait ("the one-shot mbarrier wait at
    # pc:107 spins on one phase; ... only a blocking wait (the retry loop `L: try_wait p;
    # @!p bra L;`) can wait for a phase").
    ihc_stats_tma("ihc_stats_tma_1025tok_h1024_last", 1025, 1024, cta=135, check="UNKNOWN",
                  note=" (the last tile: 1 token; 4 chunks fill the 4-stage ring)"),
    ihc_stats_tma("ihc_stats_tma_1025tok_h1024_last_waits", 1025, 1024, cta=135, waits=True,
                  note=" (the last tile: 1 token; 4 chunks fill the 4-stage ring)"),
    ihc_stats_tma("ihc_stats_tma_1025tok_h1280_ring_waits", 1025, 1280, cta=7, waits=True,
                  note=" (5 chunks per unit: the 4-stage ring wraps)"),
    ihc_stats_tma("ihc_stats_tma_4800tok_h128_3units_waits", 4800, 128, cta=3, waits=True,
                  note=" (3 units per block: the TMEM double buffer and s_sq reused)"),
    negative(ihc_stats_tma("ihc_stats_tma_1025tok_h1024_last_waits", 1025, 1024, cta=135,
                           waits=True), "spec doubles the gate projections", Z=1),
)


CASES += (
    # Volta gap: DeepSeek-V4's FlashMLA-path q-norm / RoPE / UE8M0-quant cache insert
    # (fused_deepseek_v4_qnorm_rope_kv_insert_kernel.cu:480, every instantiation and the
    # reduced-grid twin) computes the UE8M0 exponent with ceilf(log2f(absmax / 448)) (:390),
    # `cvt.rpi.f32.f32` (PTX :60218), which Volta does not lower ("integer-rounding modifier
    # (floor/ceil/trunc/rint not modeled)"). Grid ceil(T (64 + 1) / 8) x 256 (:667).
    Case(name="dsv4_qnorm_rope_quant_insert_64h", description="fusedDeepseekV4QNormRopeKV"
         "RopeQuantInsertKernel<bf16, 64, norm>, 2 tokens x 64 q heads, V4 584-byte cache "
         "records, block size 64",
         source=f"{DSV4}:480 (fusedDeepseekV4QNormRopeKVRopeQuantInsertKernel), launcher :658",
         unit=DSV4,
         symbol="47fusedDeepseekV4QNormRopeKVRopeQuantInsertKernelIN3c108BFloat16ELi64ELb1ELb0EE",
         args=(Ptr("q_in"), Ptr("q_out"), Ptr("kv_in"), Ptr("k_cache"), Ptr("slot_mapping"),
               Ptr("position_ids"), Ptr("cos_sin_cache"), Float(EPS, "eps"),
               Int(2, "num_tokens_full"), Int(2, "num_tokens_insert"), Int(64, "num_heads_q"),
               Int(64, "cache_block_size"), Int(64 * 584, "kv_block_stride"),
               Int(0, "kv_mxfp8"), Int(1, "apply_q_rope")),
         arrays=(Array("q_in", "in", "bf16", (2, 64, 512)),
                 Array("q_out", "out", "bf16", (2, 64, 512)),
                 Array("kv_in", "in", "bf16", (2, 512)),
                 Array("k_cache", "out", "u8", (1, 64 * 584)),
                 Array("slot_mapping", "index", "i64", (2,)),
                 Array("position_ids", "index", "i64", (2,)),
                 Array("cos_sin_cache", "in", "f32", (2, 64))),
         grid=(17, 1, 1), block=256, check="ABORT", cta=(16, 0, 0)),
)


CASES += (
    # Volta gap: the exllama GPTQ GEMMs (q_gemm.cu:127 and its 2/3/8-bit twins, m_count 1-8,
    # and the alt kernels) accumulate their split-K partials with atomicAdd on half2 through
    # a generic pointer (:250), `atom.add.noftz.f16x2 %r236, [%rd29], %r237` (PTX :904):
    # "Unsupported instruction: Atom(... space: None, op: Add, ty: F16x2 ...)". Decode-size
    # M = 1, grid (ceil(N / 512), M, ceil(K / 128)) x 128 (gemm_half_q_half_cuda_part :637).
    Case(name="gptq_gemm_exllama_4bit_m1", description="gemm_half_q_half_gptq_4bit_kernel<true, "
         "1>, M 1 x K 256 x N 512, 2 groups",
         source=f"{Q_GEMM}:127 (gemm_half_q_half_gptq_4bit_kernel), gemm_half_q_half_cuda_part "
                ":637, gemm_half_q_half_cuda :1328",
         unit=Q_GEMM, symbol="33gemm_half_q_half_gptq_4bit_kernelILb1ELi1EE",
         args=(Ptr("a"), Ptr("w"), Ptr("w_zeros"), Ptr("w_scales"), Ptr("c"), Int(1, "size_m"),
               Int(512, "size_n"), Int(256, "size_k"), Int(2, "groups"), Int(0, "use_v2")),
         arrays=(Array("a", "in", "f16", (1, 256)),
                 Array("w", "index", "u32", (32, 512), contents=tuple([0x76543210] * 32 * 512)),
                 Array("w_zeros", "index", "u32", (2, 64), contents=tuple([0x88888888] * 128)),
                 Array("w_scales", "in", "f16", (2, 512)), Array("c", "inout", "f16", (1, 512))),
         grid=(1, 1, 2), block=128, check="ABORT", cta=(0, 0, 1)),
)


CASES += (
    # Volta gap: compute_arg_sorts (moe_data.cu:88) and compute_problem_sizes (:17) claim
    # slots with a value-returning global atomic, `atom.global.add.u32 %r45, [%rd5], 1`
    # (PTX :957): "Unsupported instruction: Atom(... space: Some(Global), op: Add, ty: U32
    # ...) Reason: Instruction not yet implemented".
    Case(name="moe_arg_sorts_8e", description="compute_arg_sorts, 8 experts, 3 tokens x top-2",
         source=f"{MOE_DATA}:88 (compute_arg_sorts), launch :282",
         unit=MOE_DATA, symbol="_Z17compute_arg_sorts",
         args=(Ptr("topk_ids"), Ptr("input_permutation"), Ptr("output_permutation"), NULL,
               Ptr("atomic_buffer"), Int(6, "topk_length"), Int(2, "topk")),
         arrays=(Array("topk_ids", "index", "i32", (3, 2), contents=(1, 5, 5, 0, 7, 1)),
                 Array("input_permutation", "out", "i32", (6,)),
                 Array("output_permutation", "out", "i32", (6,)),
                 Array("atomic_buffer", "inout", "i32", (9,))),
         grid=(8, 1, 1), block=6, check="ABORT", cta=(5, 0, 0)),
)
