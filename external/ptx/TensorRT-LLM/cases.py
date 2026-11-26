"""TensorRT-LLM kernels checked by Volta: what each case compiles, launches and checks.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`cpp/tensorrt_llm/kernels/` unit of TensorRT-LLM at the commit
`external/ptx/sources/frameworks.txt` pins, compiled for sm_100a by
`external/ptx/extraction/survey.py`; `symbol` is a substring of its mangled name. The launch
(grid, block, arguments) is the one the unit's host code makes for the case's shape, read from
the source cited in `source`.
"""

from dataclasses import dataclass, field

EPS = 9.999999974752427e-07  # f32(1e-6)
KERNELS = "cpp/tensorrt_llm/kernels/"


@dataclass(frozen=True)
class Array:
    """`base`, when given, places the array: a case passes the tensor's own start as an
    `Int` address when the analyzed block touches only a slice of it. `contents` gives a
    4-byte index array's elements (without it element i is i)."""

    name: str
    kind: str  # "in", "out", "inout" or "index"
    dtype: str
    shape: tuple
    base: int | None = None
    contents: tuple | None = None


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
class Struct:
    """A by-value struct parameter: `fields` are launch-file field dicts (offset + one value)."""

    fields: tuple
    name: str = ""


@dataclass(frozen=True)
class Case:
    """`check` is the verdict the case expects: "ACCEPT" or "REJECT" against `spec`, or
    without one "VERIFIED"/"REJECTED" from the graph checks; "ABORT" an execution error
    ("ERROR" with a spec). `smem` is the launch's dynamic shared memory in bytes."""

    name: str
    description: str
    source: str
    unit: str
    symbol: str | tuple  # substring(s) of the kernel's mangled name, all of them
    args: tuple
    arrays: tuple
    grid: tuple
    block: int | tuple
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    cta: tuple = (0, 0, 0)  # the block Volta analyzes
    smem: int = 0


T2_MANGLED = {"bf16": "14__nv_bfloat162", "f16": "7__half2"}
T_MANGLED = {"bf16": "13__nv_bfloat16", "f16": "6__half"}


# ===== generalRmsNorm / generalLayerNorm (rmsnormKernels.cu, layernormKernels.cu) =====
# Volta gap: every instantiation carries the int8/fp8 quantization pass (QuantT is a template
# argument; the pass is skipped at run time when the quant pointers are null), and lowering
# the whole kernel fails on its `cvt.sat` to int8 / `cvt` to e4m3 before any execution. The
# cases are written for the non-quantized path a correct kernel takes and expect "ERROR"
# until Volta lowers those conversions (their true verdict is then expected to be ACCEPT).

RMSNORM = KERNELS + "rmsnormKernels.cu"
LAYERNORM = KERNELS + "layernormKernels.cu"


def general_norm(name, unit, hidden, layer=False, beta=False, dtype="bf16", check="ERROR",
                 note=""):
    """`invokeGeneralRmsNorm` / `invokeGeneralLayerNorm(out, input, gamma, beta, eps, tokens,
    hidden, QuantMode none)`: grid tokens, block 32 ceil(min(hidden, 1024) / 32), packed T2
    (hidden even), shared memory hidden * sizeof(T) so USE_SHMEM; one token."""
    block = 32 * -(-min(hidden, 1024) // 32)
    kernel = "16generalLayerNorm" if layer else "14generalRmsNorm"
    tail = "Lb1ELb0EE" if layer else "Lb1EEE"  # USE_SHMEM (, !USE_DIFF_OF_SQUARES)
    arrays = [Array("input", "in", dtype, (1, hidden)), Array("gamma", "in", dtype, (hidden,))]
    if beta:
        arrays.append(Array("beta", "in", dtype, (hidden,)))
    arrays.append(Array("out", "out", dtype, (1, hidden)))
    return Case(
        name=name,
        description=f"{'generalLayerNorm' if layer else 'generalRmsNorm'}, {dtype}x2, 1 token of "
                    f"{hidden}, {'' if beta else 'no '}beta, no quantization{note}",
        source=f"{unit}:{'64' if layer else '54'}, host invokeGeneral{'Layer' if layer else 'Rms'}Norm",
        unit=unit,
        symbol=f"{kernel}I{T2_MANGLED[dtype]}a{tail}",
        args=(Ptr("input"), Ptr("gamma"), Ptr("beta") if beta else NULL, Ptr("out"),
              Float(EPS, "eps"), Int(1, "tokens"), Int(hidden, "hidden_dim"), NULL, NULL, NULL,
              NULL, NULL, Int(0, "hasFp8MinScaling")),
        arrays=tuple(arrays),
        grid=(1, 1, 1),
        block=block,
        check=check,
        spec="general_layer_norm.spec" if layer else
             "general_rms_norm_beta.spec" if beta else "general_rms_norm.spec",
        dims={"T": 1, "N": hidden},
        smem=hidden * 2,
    )


# ===== In-place MLA RoPE (mlaKernels.cu:2271 mlaRoPEInplaceKernel) =====

MLA = KERNELS + "mlaKernels.cu"


def mla_rope(name, tokens, heads, nope, rope, cta, neox=True, inverse=False, dtype="bf16",
             positions=None, check="ACCEPT", note=""):
    """`invokeMLARoPEInplace(data, position_ids, cos_sin_cache, tokens, heads, nope, rope,
    inverse, is_neox)` on data [tokens, heads, nope + rope] with a float cache [PM, 2, rope / 2]:
    vecs = (rope / 2 if neox else rope) * 2 / 16, hpb = max(1, min(256 / vecs, heads, 16)),
    grid (tokens, ceil(heads / hpb)), block (vecs, HPB) with HPB = 4, 8 or 16 the first >= hpb
    (host :2353). Block `cta` = (token, head block)."""
    vecs = (rope // 2 if neox else rope) * 2 // 16
    hpb = max(1, min(256 // vecs, heads, 16))
    HPB = 4 if hpb <= 4 else 8 if hpb <= 8 else 16
    positions = positions or tuple(range(tokens - 1, -1, -1))
    pm = max(positions) + 1
    half = rope // 2
    hs = nope + rope
    t, hb = cta
    h0, h1 = hb * HPB, min(heads, hb * HPB + HPB)
    data_shape = (tokens, heads, hs) if neox else (tokens, heads, hs // 2, 2)
    dims = {"TWO": 2, "T": tokens, "H": heads, "HALF": half, "PM": pm, "P": t, "POS": positions[t], "H0": h0, "H1": h1,
            "INV": int(inverse)}
    dims.update({"HS": hs, "NOPE": nope} if neox else {"HS2": hs // 2, "NOPE2": nope // 2})
    return Case(
        name=name,
        description=f"mlaRoPEInplace, {'NeoX' if neox else 'interleaved'}{', inverse' if inverse else ''}, "
                    f"{dtype}, {tokens} tokens of {heads} heads of {nope} nope + {rope} rope, "
                    f"block (token {t}, heads {h0}..{h1}), {vecs}x{HPB} threads{note}",
        source=f"{MLA}:2271 (mlaRoPEInplaceKernel), host invokeMLARoPEInplace :2353",
        unit=MLA,
        symbol=f"20mlaRoPEInplaceKernelI{T_MANGLED[dtype]}Lb{int(inverse)}ELb{int(neox)}ELi{HPB}E",
        args=(Ptr("data"), Ptr("pos"), Ptr("cache"), Int(heads, "num_heads"), Int(nope, "nope_dim"),
              Int(rope, "rope_dim")),
        arrays=(Array("pos", "index", "i32", (tokens,), contents=positions),
                Array("cache", "in", "f32", (pm, 2, half)),
                Array("data", "inout", dtype, data_shape)),
        grid=(tokens, -(-heads // hpb), 1),
        block=(vecs, HPB, 1),
        check=check,
        spec="mla_rope_neox.spec" if neox else "mla_rope_gptj.spec",
        dims=dims,
        cta=(t, hb, 0),
    )


# ===== Unfused attention helpers (unfusedAttentionKernels.cu) =====

UNFUSED = KERNELS + "unfusedAttentionKernels.cu"
IA3_TASKS = 3


def qkv_transpose(name, batch, seq, heads, size, cta, bias=True, ia3=None, dtype="bf16",
                  check="ACCEPT", note=""):
    """`invokeAddQKVBiasIA3Transpose(q_buf, k_buf, v_buf, Q, bias_Q, K, bias_K, V, bias_V, batch,
    seq, heads, size, ia3_tasks, ia3_key_weights, ia3_value_weights)`: grid (batch, seq); with
    16-bit T and heads * size even the packed T2 kernel, block min(heads * size / 2, 512), size / 2
    passed (host :127). `ia3` gives each batch's task (both IA3 weights), else none."""
    k = heads * size
    packed = k % 2 == 0
    sph = size // 2 if packed else size
    block = min(k // 2 if packed else k, 512)
    t = T2_MANGLED[dtype] if packed else T_MANGLED[dtype]
    io = (batch, seq, heads, size)
    out = (batch, heads, seq, size)
    arrays = [Array("q_in", "in", dtype, io), Array("k_in", "in", dtype, io), Array("v_in", "in", dtype, io),
              Array("bias_q", "in", dtype, (heads, size)), Array("bias_k", "in", dtype, (heads, size)),
              Array("bias_v", "in", dtype, (heads, size)),
              Array("ia3_k", "in", dtype, (IA3_TASKS, heads, size)),
              Array("ia3_v", "in", dtype, (IA3_TASKS, heads, size)),
              Array("ia3_tasks", "index", "i32", (batch,), contents=ia3 or (0,) * batch),
              Array("q_out", "out", dtype, out), Array("k_out", "out", dtype, out),
              Array("v_out", "out", dtype, out)]
    ia3_args = (Ptr("ia3_tasks"), Ptr("ia3_k"), Ptr("ia3_v")) if ia3 else (NULL, NULL, NULL)
    ints = (Int(batch, "batch_size"), Int(seq, "seq_len"), Int(heads, "head_num"),
            Int(sph, "size_per_head"))
    if bias:
        args = (Ptr("q_out"), Ptr("k_out"), Ptr("v_out"), Ptr("q_in"), Ptr("bias_q"), Ptr("k_in"),
                Ptr("bias_k"), Ptr("v_in"), Ptr("bias_v"), *ia3_args, *ints)
    else:
        args = (Ptr("q_out"), Ptr("k_out"), Ptr("v_out"), Ptr("q_in"), Ptr("k_in"), Ptr("v_in"),
                *ia3_args, *ints)
    b, w = cta
    kernel = "22addQKVBiasIA3Transpose" if bias else "15QKVIA3Transpose"
    return Case(
        name=name,
        description=f"{kernel[2:]}, {dtype}{'x2' if packed else ''}, batch {batch} x seq {seq} x "
                    f"{heads} heads of {size}, {'bias' if bias else 'no bias'}, "
                    f"{'IA3 tasks ' + str(ia3) if ia3 else 'no IA3'}, block (batch {b}, word {w}){note}",
        source=f"{UNFUSED}:{42 if bias else 85}, host invokeAddQKVBiasIA3Transpose :127",
        unit=UNFUSED,
        symbol=f"{kernel}I{t}E",
        args=args,
        arrays=tuple(arrays),
        grid=(batch, seq, 1),
        block=block,
        check=check,
        spec="qkv_transpose.spec",
        dims={"B": batch, "S": seq, "H": heads, "D": size, "CB": b, "CS": w, "NT": IA3_TASKS,
              "TASK": ia3[b] if ia3 else 0, "BIAS": int(bias), "IA3": int(bool(ia3))},
        cta=(b, w, 0),
    )


def rebuild_padding(name, seq_lens, seq, heads, size, bid, bias=True, ia3=None, dtype="bf16",
                    check="ACCEPT", note=""):
    """`invokeAddQKVBiasIA3RebuildPadding(Q, bias_Q, K, bias_K, V, bias_V, q_buf, k_buf, v_buf,
    batch, seq, heads, size, valid_word_num, mask_offset, ia3...)` from packed tokens (sequence
    lengths `seq_lens`, padded to `seq`): grid valid_word_num, block heads * size halved while
    over 512 in the packed path (host :982). Block `bid` moves packed token `bid`."""
    batch, valid = len(seq_lens), sum(seq_lens)
    padded = [b * seq + s for b, n in enumerate(seq_lens) for s in range(n)]
    mask_offset = tuple(p - i for i, p in enumerate(padded))
    packed = dtype in ("bf16", "f16") and size % 2 == 0
    block = heads * size
    if packed:
        while block > 512:
            if block % 2:
                packed, block = False, min(block, 512)
                break
            block //= 2
    else:
        block = min(block, 512)
    t = T2_MANGLED[dtype] if packed else T_MANGLED[dtype]
    sph = size // 2 if packed else size
    tb, ts = divmod(padded[bid], seq)
    io, out = (valid, heads, size), (batch, heads, seq, size)
    arrays = [Array("Q", "in", dtype, io), Array("K", "in", dtype, io), Array("V", "in", dtype, io),
              Array("bias_q", "in", dtype, (heads, size)), Array("bias_k", "in", dtype, (heads, size)),
              Array("bias_v", "in", dtype, (heads, size)),
              Array("ia3_k", "in", dtype, (IA3_TASKS, heads, size)),
              Array("ia3_v", "in", dtype, (IA3_TASKS, heads, size)),
              Array("ia3_tasks", "index", "i32", (batch,), contents=ia3 or (0,) * batch),
              Array("mask_offset", "index", "i32", (valid,), contents=mask_offset),
              Array("q_buf", "out", dtype, out), Array("k_buf", "out", dtype, out),
              Array("v_buf", "out", dtype, out)]
    ia3_args = (Ptr("ia3_tasks"), Ptr("ia3_k"), Ptr("ia3_v")) if ia3 else (NULL, NULL, NULL)
    ints = (Int(batch, "batch_size"), Int(seq, "seq_len"), Int(heads, "head_num"),
            Int(sph, "size_per_head"), Ptr("mask_offset"))
    if bias:
        args = (Ptr("Q"), Ptr("bias_q"), Ptr("K"), Ptr("bias_k"), Ptr("V"), Ptr("bias_v"),
                Ptr("q_buf"), Ptr("k_buf"), Ptr("v_buf"), *ia3_args, *ints)
    else:
        args = (Ptr("Q"), Ptr("K"), Ptr("V"), Ptr("q_buf"), Ptr("k_buf"), Ptr("v_buf"),
                *ia3_args, *ints)
    kernel = "32add_QKV_bias_rebuild_padding_ia3" if bias else "19rebuild_padding_ia3"
    return Case(
        name=name,
        description=f"{kernel[2:]}, {dtype}{'x2' if packed else ''}, lengths {seq_lens} padded to "
                    f"{seq}, {heads} heads of {size}, {'IA3 tasks ' + str(ia3) if ia3 else 'no IA3'}, "
                    f"block {block} threads, packed token {bid} -> (batch {tb}, pos {ts}){note}",
        source=f"{UNFUSED}:{897 if bias else 940}, host invokeAddQKVBiasIA3RebuildPadding :982",
        unit=UNFUSED,
        symbol=f"{kernel}I{t}E",
        args=args,
        arrays=tuple(arrays),
        grid=(valid, 1, 1),
        block=block,
        check=check,
        spec="rebuild_padding.spec",
        dims={"VALID": valid, "B": batch, "S": seq, "H": heads, "D": size, "BID": bid, "TB": tb,
              "TS": ts, "NT": IA3_TASKS, "TASK": ia3[tb] if ia3 else 0, "BIAS": int(bias),
              "IA3": int(bool(ia3))},
        cta=(bid, 0, 0),
    )


def transpose_4d(name, local_batch, seq, size, heads, batch, ite, cta, check="ACCEPT", note=""):
    """`invokeTranspose4d<half>(dst, src, local_batch, seq, size, hidden, heads, batch, ite)`:
    grid local_batch * seq * hidden / 512, block 256 half2 lanes, the kernel's dims (local_batch,
    heads, seq, size, batch, ite) (host :1629). Block `cta` copies source half2s
    [256 cta, 256 cta + 256) once (the grid's threads cover the tensor)."""
    hidden = heads * size
    grid = local_batch * seq * hidden // 512
    return Case(
        name=name,
        description=f"transpose_4d<half>, [{local_batch}, {heads}, {seq}, {size}] into batch slot "
                    f"{ite} of {batch}, grid {grid}, block {cta}{note}",
        source=f"{UNFUSED}:1604 (transpose_4d<half>), host invokeTranspose4d :1629",
        unit=UNFUSED,
        symbol="12transpose_4dI6__halfE",
        args=(Ptr("dst"), Ptr("src"), Int(local_batch, "dim0"), Int(heads, "dim1"), Int(seq, "dim2"),
              Int(size, "dim3"), Int(batch, "dim0_leading_dim"), Int(ite, "ite")),
        arrays=(Array("src", "in", "f16", (local_batch, heads, seq, size)),
                Array("dst", "out", "f16", (seq, batch, heads, size))),
        grid=(grid, 1, 1),
        block=256,
        check=check,
        spec="transpose_4d.spec",
        dims={"B0": local_batch, "H": heads, "S": seq, "D": size, "BL": batch, "ITE": ite,
              "G": cta, "CH": 512},
        cta=(cta, 0, 0),
    )


def masked_softmax(name, batch, heads, q_len, k_len, cta, check="ACCEPT", note=""):
    """`invokeMaskedSoftmax<bf16, float>` (no ALiBi, no softcapping, dense mask, qk_scale 1/8):
    grid (q_len, batch, heads) (q_len / 32 blocks past 360 batch x heads), block ceil(k_len / 32)
    32, then divided by ITEMS_PER_THREAD (1 up to 1024 columns) and rounded up to 32 (host :681).
    Block `cta` = (query row, batch, head)."""
    block = -(-k_len // 32) * 32
    items = next(i for b, i in ((16384, 32), (8192, 16), (4096, 8), (2048, 4), (1024, 2), (0, 1))
                 if block > b)
    block = -(-(block // items) // 32) * 32
    q, b, h = cta
    sparse = Struct(tuple({"offset": 4 * k, "u32": v} for k, v in enumerate((1, 0, 0, 0))),
                    "block_sparse_params")
    return Case(
        name=name,
        description=f"softmax_kernel<bf16, float, {items}>, batch {batch} x {heads} heads, "
                    f"{q_len} x {k_len} scores, {block} threads, block (row {q}, batch {b}, head {h}){note}",
        source=f"{UNFUSED}:183 (softmax_kernel), host invokeMaskedSoftmax<bf16, float> :681",
        unit=UNFUSED,
        symbol=f"14softmax_kernelI13__nv_bfloat16fLi{items}EE",
        args=(Ptr("out"), Ptr("qk"), Ptr("mask"), NULL, Int(batch, "batch_size"),
              Int(heads, "head_num"), Int(q_len, "q_length"), Int(k_len, "k_length"),
              Float(0.125, "qk_scale"), Float(0.0, "softcapping_scale"),
              Float(0.0, "softcapping_inverse_scale"), Int(0, "block_sparse_attn"), sparse,
              NULL),
        arrays=(Array("qk", "in", "f32", (batch, heads, q_len, k_len)),
                Array("mask", "in", "bf16", (batch, q_len, k_len)),
                Array("out", "out", "bf16", (batch, heads, q_len, k_len))),
        grid=(q_len, batch, heads),
        block=block,
        check=check,
        spec="masked_softmax.spec",
        dims={"BS": batch, "HN": heads, "QL": q_len, "KL": k_len, "B": b, "H": h, "Q": q},
        cta=cta,
    )


# ===== Small data movement / reductions =====

LOOKUP = KERNELS + "lookupKernels.cu"
CUMSUM = KERNELS + "cumsumLastDim.cu"
GPT = KERNELS + "gptKernels.cu"


def lookup(name, ids, n_embed, offset, size, cta, dtype="bf16", check="ACCEPT", note=""):
    """`invokeLookUp(out, input, weight, token_num, offset, size, n_embed, nullptr)` (a TP shard
    [offset, offset + size) of the vocabulary): grid min(tokens, 65536), block min(n_embed, 512),
    a grid-stride loop over tokens * n_embed (host :70)."""
    tokens = len(ids)
    assert tokens <= 4
    block = min(n_embed, 512)
    grid = min(tokens, 65536)
    if n_embed == block:
        mode, ng, bs = 1, 1, n_embed  # one pass: block g is token g
    else:
        assert n_embed % (block * grid) == 0 and (n_embed // block) % grid == 0
        mode, ng, bs = 0, n_embed // block, block
        assert grid == 1 or ng == grid
    dims = {"T": tokens, "N": n_embed, "SIZE": size, "G": cta, "BS": bs, "NG": ng, "MODE": mode}
    for k in range(4):
        i = ids[k] - offset if k < tokens else 0
        inside = 0 <= i < size
        dims[f"I{k}"], dims[f"W{k}"] = (i if inside else 0), int(inside)
    if grid == 1:  # the one block writes everything: token 0 whole
        dims["MODE"], dims["G"], dims["NG"], dims["BS"] = 1, 0, 1, n_embed
    return Case(
        name=name,
        description=f"lookup_kernel, {dtype}, ids {ids} in shard [{offset}, {offset + size}), "
                    f"hidden {n_embed}, grid {grid} x {block}, block {cta}{note}",
        source=f"{LOOKUP}:44 (lookup_kernel), host invokeLookUp :70",
        unit=LOOKUP,
        symbol=f"13lookup_kernelI{T_MANGLED[dtype]}S3_iE",
        args=(Ptr("out"), Ptr("ids"), Ptr("weight"), Int(tokens, "token_num"), Int(offset, "offset"),
              Int(size, "size"), Int(n_embed, "n_embed"), NULL),
        arrays=(Array("ids", "index", "i32", (tokens,), contents=tuple(ids)),
                Array("weight", "in", dtype, (size, n_embed)),
                Array("out", "out", dtype, (tokens, dims["NG"], dims["BS"]))),
        grid=(grid, 1, 1),
        block=block,
        check=check,
        spec="lookup.spec",
        dims=dims,
        cta=(cta, 0, 0),
    )


CUMSUM_MANGLED = {"bf16": "13__nv_bfloat16", "f16": "6__half", "f32": "f"}


def cumsum(name, batch, length, cta, dtype="f32", check="ACCEPT", note=""):
    """`invokeCumsumLastDim(batch, length, input, output, nullptr, 0)`: grid batch; 32 threads x 1
    item up to 64, 64 x 2 below 512, else 256 x 8 (host :127)."""
    tpb, itp = (32, 1) if length <= 64 else (64, 2) if length < 512 else (256, 8)
    width = 4 if dtype == "f32" else 2
    return Case(
        name=name,
        description=f"cumsum_last_dim, {dtype}, {batch} rows of {length}, {tpb} threads x {itp} "
                    f"(tile {tpb * itp}), block {cta}{note}",
        source=f"{CUMSUM}:52 (cumsum_last_dim), host invokeCumsumLastDim :127",
        unit=CUMSUM,
        symbol=f"15cumsum_last_dimI{CUMSUM_MANGLED[dtype]}Li{tpb}ELi{itp}E",
        args=(Ptr("input"), Ptr("out"), Int(length, "length")),
        arrays=(Array("input", "in", dtype, (batch, length)), Array("out", "out", dtype, (batch, length))),
        grid=(batch, 1, 1),
        block=tpb,
        check=check,
        spec="cumsum_last_dim.spec",
        dims={"B": batch, "L": length, "P": cta},
        cta=(cta, 0, 0),
        smem=width * tpb * itp,
    )


def update_padding_count(name, batch, block, max_q, check="ACCEPT"):
    """`updatePaddingCountKernel(paddingPerSeq, seqLengths, maxQSeqLength, batchSize)`: one block
    striding over the batch; no launch of it is left in this checkout, so the block is a guess."""
    return Case(
        name=name,
        description=f"updatePaddingCountKernel, batch {batch}, {block} threads, max length {max_q}",
        source=f"{GPT}:374 (no host launch in the checkout)",
        unit=GPT,
        symbol="24updatePaddingCountKernel",
        args=(Ptr("padding"), Ptr("seq"), Int(max_q, "maxQSeqLength"), Int(batch, "batchSize")),
        arrays=(Array("seq", "in", "i32", (batch,)), Array("padding", "out", "i32", (batch,))),
        grid=(1, 1, 1),
        block=block,
        check=check,
        spec="update_padding_count.spec",
        dims={"N": batch, "M": max_q},
    )


CASES = (
    general_norm("rms_norm_bf16_4096", RMSNORM, 4096),
    general_norm("rms_norm_bf16_4096_beta", RMSNORM, 4096, beta=True),
    general_norm("layer_norm_bf16_2048", LAYERNORM, 2048, layer=True, beta=True),
    # DeepSeek-V3 q: 128 nope + 64 rope, 16 heads per rank; k_pe: 1 head, no nope.
    mla_rope("mla_rope_neox_q", 2, 16, 128, 64, cta=(1, 0)),
    mla_rope("mla_rope_gptj_q", 2, 16, 128, 64, cta=(0, 0), neox=False),
    mla_rope("mla_rope_neox_q_inverse", 2, 16, 128, 64, cta=(1, 0), inverse=True),
    mla_rope("mla_rope_gptj_q_inverse_f16", 2, 16, 128, 64, cta=(1, 0), neox=False,
             inverse=True, dtype="f16"),
    mla_rope("mla_rope_neox_kpe", 3, 1, 0, 64, cta=(2, 0)),
    mla_rope("mla_rope_gptj_kpe", 3, 1, 0, 64, cta=(2, 0), neox=False),
    mla_rope("mla_rope_neox_40heads", 2, 40, 128, 64, cta=(0, 2), note=" (last, partial head block)"),
    mla_rope("mla_rope_gptj_rope32", 2, 6, 64, 32, cta=(1, 0), neox=False),
    mla_rope("mla_rope_neox_rope48_f16", 2, 5, 16, 48, cta=(0, 0), dtype="f16"),
    # Llama-7B-like 32 heads x 128 and GPT-2-like 12 x 64 heads.
    qkv_transpose("qkv_bias_transpose_bf16", 2, 4, 32, 128, cta=(1, 2)),
    qkv_transpose("qkv_bias_transpose_gpt2", 2, 3, 12, 64, cta=(0, 2)),
    qkv_transpose("qkv_bias_transpose_ia3", 3, 2, 4, 64, cta=(2, 1), ia3=(2, 0, 1)),
    qkv_transpose("qkv_transpose_no_bias", 2, 2, 8, 128, cta=(1, 1), bias=False),
    qkv_transpose("qkv_transpose_no_bias_ia3_f16", 2, 2, 8, 80, cta=(1, 0), bias=False,
                  ia3=(1, 2), dtype="f16"),
    rebuild_padding("rebuild_padding_bias", (3, 2), 4, 8, 64, bid=3),
    rebuild_padding("rebuild_padding_bias_ia3", (1, 4, 2), 4, 16, 128, bid=5, ia3=(0, 2, 1),
                    note=" (block halved twice)"),
    rebuild_padding("rebuild_padding_no_bias", (3, 2), 4, 8, 64, bid=4, bias=False),
    rebuild_padding("rebuild_padding_no_bias_ia3_f16", (2, 3), 3, 4, 96, bid=2, bias=False,
                    ia3=(1, 0), dtype="f16"),
    transpose_4d("transpose_4d_half", 2, 4, 64, 4, 4, 1, cta=3),
    transpose_4d("transpose_4d_half_first", 1, 8, 128, 2, 2, 0, cta=0),
    lookup("lookup_decode_4096", (17,), 4096, 0, 64, cta=0),
    lookup("lookup_tp_shard_2x1024", (70, 130), 1024, 64, 64, cta=1, note=" (token 1 off shard)"),
    lookup("lookup_tp_shard_3x100", (5, 33, 40), 100, 32, 16, cta=1, note=" (odd hidden)"),
    lookup("lookup_tp_shard_3x100_off", (5, 33, 40), 100, 32, 16, cta=0, dtype="f16"),
    cumsum("cumsum_f32_50", 2, 50, cta=1, note=" (two tiles, partial)"),
    cumsum("cumsum_f32_64", 2, 64, cta=0),
    cumsum("cumsum_f32_100", 2, 100, cta=1),
    cumsum("cumsum_bf16_500", 1, 500, cta=0, dtype="bf16"),
    cumsum("cumsum_f32_1000", 1, 1000, cta=0),
    # Volta gap, not a kernel bug: the 256 x 8 16-bit instantiation reduces each thread's items
    # with `add.bf16x2`/`add.f16x2` and takes the low half by `and.b32 %r, %pair, 65535` before
    # the warp scan's shfl (cumsumLastDim.ptx, cub's ThreadReduce); Volta aborts on a packed pair
    # read as a 32-bit scalar. Its true verdict is expected to be ACCEPT (the 32 x 1 / 64 x 2 16-bit
    # and the f32 256 x 8 instantiations are ACCEPTed).
    cumsum("cumsum_f16_2048", 2, 2048, cta=1, dtype="f16", check="UNKNOWN"),
    cumsum("cumsum_bf16_2048", 2, 2048, cta=1, dtype="bf16", check="UNKNOWN"),
    cumsum("cumsum_f16_100", 2, 100, cta=1, dtype="f16"),
    cumsum("cumsum_f16_64", 1, 64, cta=0, dtype="f16"),
    # Volta incompleteness, not a kernel bug: race free, and the numeric oracle does not refute any
    # element, but the canonicalizer proves none of exp(x - m) * (1 / (sum + 1e-6)) with m the
    # max tree seeded by -1e20 -- even against a spec that copies the kernel's expression
    # verbatim at k_length 1. True verdict: ACCEPT. (k_length 2000 takes over 10 minutes.)
    masked_softmax("masked_softmax_128", 2, 4, 8, 128, cta=(5, 1, 2), check="UNKNOWN"),
    masked_softmax("masked_softmax_100", 1, 2, 3, 100, cta=(2, 0, 1), check="UNKNOWN",
                   note=" (partial warp tail)"),
    update_padding_count("update_padding_count_200", 200, 128, 512),
)
