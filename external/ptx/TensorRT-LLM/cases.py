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
    # The 256 x 8 16-bit instantiation: each thread reduces its items with `add.bf16x2`/`add.f16x2`
    # and takes the low half by `and.b32 %r, %pair, 65535` and `cvt.u16.u32` (cub's ThreadReduce).
    cumsum("cumsum_f16_2048", 2, 2048, cta=1, dtype="f16"),
    cumsum("cumsum_bf16_2048", 2, 2048, cta=1, dtype="bf16"),
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


# ===== Round 2 =====

import dataclasses  # noqa: E402

ATTENTION_MASK = KERNELS + "attentionMask.cu"
MASK_TYPES = ("PADDING", "CAUSAL", "SLIDING_WINDOW_CAUSAL", "BIDIRECTIONAL", "BIDIRECTIONALGLM",
              "BLOCKSPARSE")
MASK_MANGLED = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16", "bool": "b", "i32": "i"}
MASK_DTYPE = {"f32": "f32", "f16": "f16", "bf16": "bf16", "bool": "u8", "i32": "i32"}


def negative(case, dims, why):
    """`case` against a spec off by `dims`: must be refuted."""
    return dataclasses.replace(case, name=case.name + "_negative", dims={**case.dims, **dims},
                               check="REJECT", description=case.description + f" (negative: {why})")


def attention_mask(name, mask_type, q_lens, max_q, max_kv, cta, kv_lens=None, packed=False,
                   window=0, sparse=(1, 0, 0, 0), dtype="f32", check="ACCEPT", note=""):
    """`invokeBuildAttentionMask(params)` (attentionMask.cu:174): grid (min(1024, maxQSeqLen),
    batch), block 256, AttentionMaskParams by value (mask, cuQSeqLens, actualQSeqLens,
    actualKvSeqLens, type, BlockSparseParams{block_size, homo_head_pattern, num_local_blocks,
    vertical_stride}, batch, maxQ, maxKv, slidingWindowSize: 72 bytes). The padded mask of
    invokeBuildDecoderInfo (gptKernels.cu:341) has kv lengths = q lengths and maxKv = maxQ;
    `packed` gives cuQSeqLens (rows packed). Block `cta` = (x, batch)."""
    t = MASK_TYPES.index(mask_type)
    kv_lens = kv_lens or q_lens
    batch = len(q_lens)
    bx, b = cta
    grid_x = min(1024, max_q)
    cu = [0]
    for n in q_lens:
        cu.append(cu[-1] + n)
    rows = cu[-1] if packed else batch * max_q
    off = cu[b] if packed else b * max_q
    nr = q_lens[b] if packed else max_q
    assert nr <= bx + 2 * grid_x and (t != 5 or nr <= bx + grid_x)
    bs, homo, local, vstride = sparse
    loc = va0 = vb0 = va1 = vb1 = 0
    if t == 5:  # the analyzed row's block-local window and vertical stripes (head 0)
        br = bx // bs
        loc = max(0, (br - local + 1) * bs)
        stripes = [((k * vstride - 1) * bs, min(max_kv, k * vstride * bs))
                   for k in range(1, max_kv // (vstride * bs) + 2) if (k * vstride - 1) * bs < max_kv]
        stripes = [s for s in stripes if s[1] <= loc] + [(0, 0)] * 2
        assert len([s for s in stripes if s[1]]) <= 2
        (va0, vb0), (va1, vb1) = stripes[:2]
    fields = ({"offset": 0, "ptr": "mask"},
              {"offset": 8, "ptr": "cu"} if packed else {"offset": 8, "u64": 0},
              {"offset": 16, "ptr": "q_lens"}, {"offset": 24, "ptr": "kv_lens"},
              {"offset": 32, "u32": t}, {"offset": 36, "u32": bs}, {"offset": 40, "u32": homo},
              {"offset": 44, "u32": local}, {"offset": 48, "u32": vstride},
              {"offset": 52, "u32": batch}, {"offset": 56, "u32": max_q},
              {"offset": 60, "u32": max_kv}, {"offset": 64, "u32": window},
              {"offset": 68, "u32": 0})
    arrays = [Array("q_lens", "index", "i32", (batch,), contents=tuple(q_lens)),
              Array("kv_lens", "index", "i32", (batch,), contents=tuple(kv_lens))]
    if packed:
        arrays.append(Array("cu", "index", "i32", (batch + 1,), contents=tuple(cu)))
    arrays.append(Array("mask", "out", MASK_DTYPE[dtype], (rows, max_kv)))
    return Case(
        name=name,
        description=f"prepareAttentionMask<{dtype}, {mask_type}>, q lengths {q_lens}, kv lengths "
                    f"{kv_lens}, max {max_q} x {max_kv}, {'packed' if packed else 'padded'} rows"
                    f"{f', window {window}' if t == 2 else ''}{f', sparse {sparse}' if t == 5 else ''}"
                    f", block (x {bx}, batch {b}){note}",
        source=f"{ATTENTION_MASK}:112 (prepareAttentionMask), host invokeBuildAttentionMask :174 "
               f"(grid :185){'' if packed else ', invokeBuildDecoderInfo gptKernels.cu:341'}",
        unit=ATTENTION_MASK,
        symbol=f"20prepareAttentionMaskI{MASK_MANGLED[dtype]}LNS1_17AttentionMaskTypeE{t}EE",
        args=(Struct(fields, "params"),),
        arrays=tuple(arrays),
        grid=(grid_x, batch, 1),
        block=256,
        check=check,
        spec="attention_mask.spec",
        dims={"R": rows, "KV": max_kv, "OFF": off, "NR": nr, "BX": bx, "G": grid_x,
              "QL": q_lens[b], "KL": kv_lens[b], "W": window, "TYPE": t, "LOC": loc,
              "VA0": va0, "VB0": vb0, "VA1": va1, "VB1": vb1},
        cta=(bx, b, 0),
    )


def build_cu_q_seq_lens(name, q_lens, cta=None, check="ACCEPT", note=""):
    """`buildCuQSeqLens<256><<<batch, 256>>>(batch, actualQSeqLens, cuQSeqLens)`
    (attentionMask.cu:59, host :179): a cub BlockScan exclusive sum over the first blockIdx.x
    + 1 lengths; only the last block stores cuQSeqLens[0..batch]."""
    batch = len(q_lens)
    cta = batch - 1 if cta is None else cta
    return Case(
        name=name,
        description=f"buildCuQSeqLens<256>, batch {batch}, block {cta}{note}",
        source=f"{ATTENTION_MASK}:59 (buildCuQSeqLens), host invokeBuildAttentionMask :179",
        unit=ATTENTION_MASK,
        symbol="15buildCuQSeqLensILi256EE",
        args=(Int(batch, "batchSize"), Ptr("q_lens"), Ptr("cu")),
        arrays=(Array("q_lens", "in", "i32", (batch,)), Array("cu", "out", "i32", (batch + 1,))),
        grid=(batch, 1, 1),
        block=256,
        check=check,
        spec="cu_seq_lens.spec" if cta == batch - 1 else None,
        dims={"B": batch, "B1": batch + 1, "LAST": 1, "SHIFT": 0} if cta == batch - 1 else {},
        cta=(cta, 0, 0),
    )


_MASKS = (
    attention_mask("attention_mask_padding_f32", "PADDING", (5, 3), 6, 6, cta=(4, 1)),
    attention_mask("attention_mask_causal_f16", "CAUSAL", (5, 3), 6, 6, cta=(2, 1), dtype="f16"),
    attention_mask("attention_mask_causal_packed_bf16", "CAUSAL", (300, 7), 300, 300, cta=(6, 1),
                   kv_lens=(300, 9), packed=True, dtype="bf16", note=" (kv tail past 256 lanes)"),
    attention_mask("attention_mask_padding_rows_1100_bool", "PADDING", (1100,), 1100, 40, cta=(70, 0),
                   kv_lens=(33,), dtype="bool", note=" (rows 70 and 1094: grid capped at 1024)"),
    # Spec from the enum's meaning (gptKernels.h:38): causal AND inside the window. REJECT: the
    # kernel (:147) sets valid = col > row - W alone, so row 3 attends future cols 4 and 5
    # (mask[22], mask[23] = 1, spec 0). Noticed while reading the kernel to write the spec, so an
    # uncounted lead; whether any consumer of this mask relies on causality is not established.
    attention_mask("attention_mask_sliding_window_i32", "SLIDING_WINDOW_CAUSAL", (6, 6), 6, 6,
                   cta=(3, 0), window=2, dtype="i32", check="REJECT"),
    attention_mask("attention_mask_bidirectional_f32", "BIDIRECTIONAL", (4, 6), 6, 6, cta=(3, 0)),
    attention_mask("attention_mask_bidirectional_last_f32", "BIDIRECTIONAL", (4, 6), 6, 6, cta=(5, 1)),
    attention_mask("attention_mask_glm_f16", "BIDIRECTIONALGLM", (4, 6), 6, 6, cta=(3, 0), dtype="f16"),
    attention_mask("attention_mask_blocksparse_f32", "BLOCKSPARSE", (40,), 40, 40, cta=(37, 0),
                   sparse=(4, 1, 2, 3)),
    build_cu_q_seq_lens("build_cu_q_seq_lens_5", (3, 1, 4, 1, 5)),
    build_cu_q_seq_lens("build_cu_q_seq_lens_256", tuple(range(256)), note=" (cu[256] in a 2nd pass)"),
    build_cu_q_seq_lens("build_cu_q_seq_lens_300_not_last", tuple(range(300)), cta=4,
                        check="VERIFIED", note=" (stores nothing)"),
)
CASES += _MASKS + (
    negative(_MASKS[1], {"KL": 2}, "kv length 2"),
    negative(_MASKS[9], {"SHIFT": 1}, "inclusive sum"),
)


# ===== Grammar-constrained decoding: logits bitmask (logitsBitmask.cu) =====

BITMASK = KERNELS + "logitsBitmask.cu"
SM_COUNT = 148  # B200: getMultiProcessorCount() in the dispatch
BITMASK_SEGMENTS = 12
PACKED_MANGLED = {16: "6float4", 8: "6float2", 4: "f"}


# Volta gap: the canonicalizer refuses the -inf a masked logit becomes ("equivalence check
# failed: non-finite constant -inf in expression"), so these cases end UNKNOWN. What they still
# establish: race freedom (a failed graph check would be REJECT) and the exact footprint (the
# spec's index set is compared before any value, so a missed or extra write is REJECT, as the
# negative case shows). True verdict, once -inf is canonicalized: ACCEPT.
def logits_bitmask(name, batch, vocab, masked, cta, dtype="f32", d2t=None, token_mask=None,
                   check="UNKNOWN", note=""):
    """`invokeContiguousLogitsBitmask(logits, bitmask, tokenMask, d2t, batch, vocab, stride)`
    (logitsBitmask.cu:295): PackedT the widest of float4/float2/float/T dividing the row, then
    numBlocksPerRow = ceil(8 SMs / batch), bits = ceil(vocab / (256 numBlocksPerRow)) picks
    kBitsPerThread 4/8/16/32 (>= the vector width), grid (ceil(vocab / (256 kBits)), batch), block
    256 (:258). `masked` is the set of row CB's masked positions (bit 0, others 1). With `d2t`
    (EAGLE3's draft-to-target offsets) a position p reads target bit p + d2t[p] of a bitmask
    row twice the vocab wide; the masked target bits are those of the masked positions."""
    width = 4 if dtype == "f32" else 2
    vec = next(v for v in (16, 8, 4, width) if vocab % (v // width) == 0)
    align = vec // width
    per_row = -(-8 * SM_COUNT // batch)
    bits = -(-vocab // (256 * per_row))
    kbits = next(k for k in (4, 8, 16) if bits <= k and align <= k) if bits <= 16 and align <= 16 else 32
    grid_x = -(-vocab // (256 * kbits))
    bx, cb = cta
    v0, v1 = bx * 256 * kbits, min(vocab, (bx + 1) * 256 * kbits)
    target = 2 * vocab if d2t else vocab
    stride = -(-target // 32)
    words = [[0xFFFFFFFF] * stride for _ in range(batch)]
    offsets = [d2t(p) for p in range(vocab)] if d2t else [0] * vocab
    for p in masked:
        t = p + offsets[p]
        words[cb][t // 32] &= ~(1 << (t % 32)) & 0xFFFFFFFF
    kind = []
    for p in range(v0, v1):
        pack = range(p - (p - v0) % align, min(v1, p - (p - v0) % align + align))
        kind.append(1 if p in masked else 2 if any(q in masked for q in pack) else 0)
    if token_mask is not None and not token_mask[cb]:
        kind = [0] * len(kind)
    bounds, kinds = [], [kind[0]]
    for i in range(1, len(kind)):
        if kind[i] != kind[i - 1]:
            bounds.append(v0 + i)
            kinds.append(kind[i])
    assert len(bounds) <= BITMASK_SEGMENTS, bounds
    bounds += [v1] * (BITMASK_SEGMENTS - len(bounds))
    kinds += [0] * (BITMASK_SEGMENTS + 1 - len(kinds))
    dims = {"B": batch, "V": vocab, "CB": cb, "V0": v0, "V1": v1,
            **{f"P{k + 1}": b for k, b in enumerate(bounds)}, **{f"T{k}": t for k, t in enumerate(kinds)}}
    arrays = [Array("bitmask", "index", "i32", (batch, stride), contents=sum(words, []))]
    if token_mask is not None:
        arrays.append(Array("token_mask", "index", "i32", (batch,), contents=tuple(token_mask)))
    if d2t:
        arrays.append(Array("d2t", "index", "i32", (vocab,), contents=tuple(offsets)))
    arrays.append(Array("logits", "inout", dtype, (batch, vocab)))
    silent = all(k == 0 for k in kind)
    return Case(
        name=name,
        description=f"contiguousLogitsBitmaskKernel<{dtype}, {vec}-byte vector, {kbits} bits>, batch "
                    f"{batch} x vocab {vocab}, {len(masked)} masked in row {cb}"
                    f"{', d2t' if d2t else ''}{', token mask ' + str(token_mask) if token_mask else ''}"
                    f", block (x {bx} of {grid_x}, row {cb}) = [{v0}, {v1}){note}",
        source=f"{BITMASK}:185 (contiguousLogitsBitmaskKernel), host invokeContiguousLogitsBitmask "
               f":295, dispatch :251",
        unit=BITMASK,
        symbol=f"29contiguousLogitsBitmaskKernelI{CUMSUM_MANGLED[dtype]}"
               f"{PACKED_MANGLED.get(vec, 'S3_') if vec != width or dtype == 'f32' else 'S3_'}Li{kbits}EE",
        args=(Ptr("logits"), Ptr("bitmask"), Ptr("token_mask") if token_mask is not None else NULL,
              Ptr("d2t") if d2t else NULL, Int(vocab, "vocabSizePadded"), Int(stride, "bitmaskStride")),
        arrays=tuple(arrays),
        grid=(grid_x, batch, 1),
        block=256,
        check="VERIFIED" if silent else check,
        spec=None if silent else "logits_bitmask.spec",
        dims={} if silent else dims,
        cta=(bx, cb, 0),
    )


def _ranges(*spans):
    return frozenset(p for a, b in spans for p in range(a, b))


_BITMASKS = (
    # Masked runs: a partial vector at each end of [6, 9), whole vectors, the row's tail.
    logits_bitmask("logits_bitmask_f32_1000", 2, 1000, _ranges((6, 9), (64, 160), (997, 1000)),
                   cta=(0, 1)),
    logits_bitmask("logits_bitmask_f32_float2_1002", 2, 1002, _ranges((1, 2), (40, 75), (1001, 1002)),
                   cta=(0, 0), note=" (float2 vectors)"),
    logits_bitmask("logits_bitmask_f32_scalar_999", 1, 999, _ranges((0, 33), (500, 501), (998, 999)),
                   cta=(0, 0), note=" (scalar)"),
    logits_bitmask("logits_bitmask_f16_4096", 2, 4096, _ranges((2048, 2050), (2055, 2070), (4000, 4096)),
                   cta=(1, 1), dtype="f16", note=" (8-wide vectors, second block)"),
    logits_bitmask("logits_bitmask_bf16_batch64", 64, 32768, _ranges((16384, 16390), (18000, 18432)),
                   cta=(8, 63), dtype="bf16", note=" (batch 64: 8 bits per thread)"),
    logits_bitmask("logits_bitmask_f16_odd_1001", 1, 1001, _ranges((3, 5), (1000, 1001)),
                   cta=(0, 0), dtype="f16", note=" (half vectors, odd vocab)"),
    logits_bitmask("logits_bitmask_f32_d2t", 1, 512, _ranges((10, 20), (300, 301)), cta=(0, 0),
                   d2t=lambda p: p, note=" (d2t[p] = p)"),
    logits_bitmask("logits_bitmask_f32_token_mask_off", 2, 1000, _ranges((0, 1000)), cta=(0, 1),
                   token_mask=(1, 0), note=" (row skipped by its token mask)"),
)
CASES += _BITMASKS + (negative(_BITMASKS[0], {"P5": 60}, "masked run from 60: 4 unwritten"),)


# ===== DeepSeek no-aux-loss routing (noAuxTcKernels.cu) =====

NOAUX = KERNELS + "noAuxTcKernels.cu"
NOAUX_MANGLED = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16"}


def noaux_tc(name, tokens, experts, n_group, topk_group, topk, cta=0, dtype="f32", bias="f32",
             small_batch=True, check="VERIFIED", note=""):
    """`invokeNoAuxTc(scores, bias, topk_values, topk_indices, tokens, experts, n_group,
    topk_group, topk, 2.5)` (noAuxTcKernels.cu:453): grid tokens; grouped (n_group > 1, <= 32
    experts per group) <256, true, 8, 4 or 8 top groups> on 256 threads, else ungrouped
    <128/256/512/1024, false, 32, 4, SmallBatch> on 128 or 256 threads (:487-:541). Race check
    only: the top-k order is data-dependent and the spec language has no selection."""
    grouped = n_group > 1
    per_group = experts // n_group
    if grouped:
        max_e, threads = 256, 256
        top_groups = 4 if per_group * topk_group <= 128 else 8
        tmpl = f"Li256ELb1ELi8ELi{top_groups}ELb1EE"
    else:
        max_e = next(m for m in (128, 256, 512, 1024) if experts <= m)
        threads = 128 if max_e == 128 else 256
        tmpl = f"Li{max_e}ELb0ELi32ELi4ELb{int(small_batch)}EE"
    t_in = NOAUX_MANGLED[dtype]
    t_bias = NOAUX_MANGLED[bias] if bias != dtype else "S3_" if dtype != "f32" else "f"
    sym = f"23deepseek_v3_topk_kernelI{t_in}{t_bias}{'f' if dtype == 'f32' else 'S3_'}i"
    out = dtype  # OutputT = InputT in every instantiation (:569)
    return Case(
        name=name,
        description=f"deepseek_v3_topk_kernel, {dtype} scores, {bias} bias, {tokens} tokens x {experts} "
                    f"experts, {n_group} groups (top {topk_group}), top {topk}, "
                    f"{'grouped' if grouped else 'SmallBatch' if small_batch else 'single-warp'} path, "
                    f"{threads} threads, block {cta}{note}",
        source=f"{NOAUX}:361 (deepseek_v3_topk_kernel), host invokeNoAuxTc :453 (launch :535)",
        unit=NOAUX,
        symbol=sym + tmpl,
        args=(Ptr("scores"), Ptr("values"), Ptr("indices"), Ptr("bias"), Int(tokens, "numTokens"),
              Int(n_group, "numGroup"), Int(topk_group, "topkGroup"), Int(topk, "topk"),
              Int(experts, "numExperts"), Int(per_group, "numExpertsPerGroup"),
              Float(2.5, "routedScalingFactor")),
        arrays=(Array("scores", "in", dtype, (tokens, experts)), Array("bias", "in", bias, (experts,)),
                Array("values", "out", out, (tokens, topk)), Array("indices", "out", "i32", (tokens, topk))),
        grid=(tokens, 1, 1),
        block=threads,
        check=check,
        cta=(cta, 0, 0),
    )


# Volta gap: both paths rank experts by TopKRedType::makeCmpVal's order-preserving key, the f32
# score's bits sign-flipped (`setp.gt.s32 %p, %r_score, -1; selp; xor.b32`) and packed with the
# index into a u64 (`shl.b64; or.b64; xor.b64 %rd27, %rd50, 65535`, noAuxTcKernels.ptx:2380),
# reduced by `max.u64` over shuffles. A symbolic score is a real, not a bit pattern, so thread 0
# stops there: "value kind mismatch (packed pair used as a scalar)" (pc 77 grouped, pc 121
# single-warp). Not a kernel verdict; nothing is known about its races past that point.
CASES += (
    # DeepSeek-V3/R1: 256 experts in 8 groups, top 4 groups, top 8 experts.
    noaux_tc("noaux_tc_deepseek_v3_grouped", 2, 256, 8, 4, 8, cta=1, check="ABORT"),
    noaux_tc("noaux_tc_single_group_128", 300, 128, 1, 1, 8, cta=299, small_batch=False,
             check="ABORT", note=" (300 tokens > 256: the single-warp path)"),
)


# ===== Hidden-linkage kernels: KV slot scatter, row rotation, KV partial copy, MLA chunked merge =====
# These kernels sit in anonymous namespaces, so their PTX entries are `.entry` without
# `.visible`, and verify.py's ENTRY regex (`^\.visible \.entry`) does not see them: under
# verify.py they are "ERROR" (no kernel found), which `check` records. Each comment gives the
# verdict the same launch file gets from `volta solve` run directly (memcap 3 GB).

SCATTER = KERNELS + "scatterKvSlots.cu"
ROTATE = KERNELS + "rotateRows.cu"
PARTIAL_COPY = KERNELS + "kvCachePartialCopy.cu"
CHUNKED = KERNELS + "mlaChunkedPrefill.cu"
HIDDEN = " [hidden entry]"
VEC_MANGLED = {16: "5uint4", 8: "5uint2", 4: "j", 2: "t", 1: "h"}
def hidden(case, verdict):
    """`case`, a kernel in an anonymous namespace (`.entry` without `.visible`), expecting
    `verdict`."""
    return dataclasses.replace(case, check=verdict)


def i64_index(name, values):
    """An int64 index array as little-endian 32-bit word pairs (Volta's index `contents` are
    4-byte words), so a 64-bit load reads the value."""
    words = []
    for v in values:
        words += [v & 0xFFFFFFFF, (v >> 32) & 0xFFFFFFFF]
    return Array(name, "index", "i32", (2 * len(values),), contents=tuple(words))


def scatter_kv_slots(name, dst, heads, head_dim, pages, tpp, tokens, cta=0, dst2=None, src=None,
                     dtype="bf16", expect="ACCEPT", note=""):
    """`invokeScatterKvSlots(params, 2)` (scatterKvSlots.cu:118): the widest vector (16 bytes
    here: aligned bases, strides multiples of 8 elements) dividing the head row, vecsPerRow =
    head_dim / 8, grid ceil(entries * heads * vecsPerRow / 256), block 256, every stride in
    vectors (launch :101); pool [pages, 2, heads, tpp, head_dim], k/v [tokens, heads, head_dim]."""
    ratio = 16 // 2
    vpr = head_dim // ratio
    n = len(dst)
    total = n * heads * vpr
    grid = -(-total // 256)
    lo, hi = cta * 256, min(total, cta * 256 + 256)
    assert lo % vpr == 0 and hi % vpr == 0
    targets = []
    for e in range(n):
        rows = [r for r in range(e * heads, (e + 1) * heads) if lo // vpr <= r < hi // vpr]
        ha, hb = (rows[0] - e * heads, rows[-1] - e * heads + 1) if rows else (0, 0)
        token = src[e] if src else e
        for slots in (dst, dst2) if dst2 else (dst,):
            targets.append((slots[e], token, ha, hb))
    assert len(targets) <= 6
    targets += [(pages * tpp, 0, 0, 0)] * (6 - len(targets))
    dims = {"P": pages, "TWO": 2, "H": heads, "TPP": tpp, "D": head_dim, "NTOK": tokens}
    for j, (x, t, ha, hb) in enumerate(targets):
        dims.update({f"X{j}": x, f"T{j}": t, f"HA{j}": ha, f"HB{j}": hb})
    arrays = [i64_index("dst", dst)]
    if dst2:
        arrays.append(i64_index("dst2", dst2))
    if src:
        arrays.append(i64_index("src", src))
    arrays += [Array("k", "in", dtype, (tokens, heads, head_dim)), Array("v", "in", dtype, (tokens, heads, head_dim)),
               Array("pool", "out", dtype, (pages, 2, heads, tpp, head_dim))]
    strides = (2 * heads * tpp * head_dim, heads * tpp * head_dim, tpp * head_dim, head_dim,
               heads * head_dim, head_dim, heads * head_dim, head_dim)
    names = ("poolPageStride", "poolKvStride", "poolHeadStride", "poolSlotStride", "kTokenStride",
             "kHeadStride", "vTokenStride", "vHeadStride")
    return Case(
        name=name,
        description=f"scatterKvSlotsKernel<uint4>, {dtype}, {n} entries -> slots {dst}"
                    f"{' and ' + str(dst2) if dst2 else ''}{', src ' + str(src) if src else ''}, {heads} "
                    f"heads of {head_dim}, pool {pages} pages x {tpp}, block {cta} of {grid}{note}{HIDDEN}",
        source=f"{SCATTER}:31 (scatterKvSlotsKernel), host invokeScatterKvSlots :118, launch :101",
        unit=SCATTER,
        symbol=f"20scatterKvSlotsKernelI{VEC_MANGLED[16]}EE",
        args=(Ptr("pool"), Ptr("k"), Ptr("v"), Ptr("dst"), Ptr("dst2") if dst2 else NULL,
              Ptr("src") if src else NULL, Int(n, "numEntries"), Int(heads, "numHeads"),
              Int(vpr, "vecsPerRow"), Int(tpp, "tokensPerPage"),
              *(Int(s // ratio, nm) for s, nm in zip(strides, names))),
        arrays=tuple(arrays),
        grid=(grid, 1, 1),
        block=256,
        check="ERROR",
        spec="scatter_kv_slots.spec",
        dims=dims,
        cta=(cta, 0, 0),
    )


_SCATTERS = (
    scatter_kv_slots("scatter_kv_slots_3", (5, 0, 11), 4, 64, 3, 4, 3, src=(2, 0, 1),
                     note=" (96 of 256 threads)"),
    scatter_kv_slots("scatter_kv_slots_dst2", (5, 0, 11), 4, 64, 3, 4, 3, dst2=(9, 2, 6)),
    scatter_kv_slots("scatter_kv_slots_block1", (7, 1, 4, 10), 8, 128, 3, 4, 4, cta=1,
                     note=" (block 1: entries 2 and 3)"),
)
CASES += tuple(hidden(c, "ACCEPT") for c in _SCATTERS) + (
    hidden(negative(_SCATTERS[0], {"T0": 0}, "entry 0 from token 0"), "REJECT"),)


def reverse_rows(name, rows, cols, stride, begin, end, cta, elem=2, dtype="bf16", expect="ACCEPT",
                 note=""):
    """`reverseRows(data, rows, stride, begin, end)` (rotateRows.cu:50), a pass of
    `invokeRotateRows(data, rows, cols, stride, shift, elemSize)` (:73): half = (end - begin) / 2,
    grid (ceil(half / 256), min(rows, 65535)), block 256. Block `cta` = (x, y)."""
    half = (end - begin) // 2
    gy = min(rows, 65535)
    bx, by = cta
    assert rows <= by + 2 * gy
    i0, i1 = 256 * bx, min(half, 256 * bx + 256)
    return Case(
        name=name,
        description=f"reverseRowsKernel<{elem}-byte>, {rows} rows of {cols} (stride {stride}), "
                    f"reverse [{begin}, {end}), block ({bx}, {by}){note}{HIDDEN}",
        source=f"{ROTATE}:34 (reverseRowsKernel), host reverseRows :50 from invokeRotateRows :73",
        unit=ROTATE,
        symbol=f"17reverseRowsKernelI{VEC_MANGLED[elem]}EE",
        args=(Ptr("data"), Int(rows, "rows"), Int(stride, "rowStride"), Int(begin, "begin"), Int(end, "end")),
        arrays=(Array("data", "inout", dtype, (rows, stride)),),
        grid=(-(-half // 256), gy, 1),
        block=256,
        check="ERROR",
        spec="reverse_rows.spec",
        dims={"R": rows, "S": stride, "BEGIN": begin, "END": end, "I0": i0, "I1": i1, "Y0": by, "GY": gy},
        cta=(bx, by, 0),
    )


_REVERSES = (
    # rotateRowsLeft(shift 3) of 7 columns: passes [0, 3), [3, 7), [0, 7).
    reverse_rows("reverse_rows_first_pass", 3, 7, 8, 0, 3, cta=(0, 2), note=" (odd: middle kept)"),
    reverse_rows("reverse_rows_second_pass", 3, 7, 8, 3, 7, cta=(0, 1)),
    reverse_rows("reverse_rows_600_block1", 2, 600, 600, 0, 600, cta=(1, 0), note=" (half 300: lanes 44+ idle)"),
    reverse_rows("reverse_rows_f32_odd", 2, 9, 9, 2, 9, cta=(0, 1), elem=4, dtype="f32"),
)
CASES += tuple(hidden(c, "ACCEPT") for c in _REVERSES) + (
    hidden(negative(_REVERSES[1], {"END": 6}, "end 6"), "REJECT"),)


def _ipow2(v):
    v, n = max(v, 1) - 1, 0
    while v:
        v, n = v >> 1, n + 1
    return 1 << n


PARTIAL_MANGLED = {"i64": "l", "i32": "i", "f32": "f", "bf16": "13__nv_bfloat16", "f16": "6__half", "u8": "h"}


def kv_partial_copy(name, layers, heads, tpb, hidden_dim, ntokens, cta, kv_factor=2, dtype="bf16",
                    note=""):
    """`kvCacheBlockPartialCopy(dst, src, layers, heads, tpb, hidden, ntokens, kvFactor)`
    (kvCachePartialCopy.cu:84): block x = clamp(ipow2(hidden), 2, 32), y = ipow2(min(128 / x,
    ntokens)), z = ipow2(min(128 / (x y), heads)), grid ceil(hidden / x, ntokens / y, heads / z),
    layers * kvFactor layers (host :62)."""
    bx = max(min(_ipow2(hidden_dim), 32), 2)
    by = _ipow2(min(128 // bx, ntokens))
    bz = _ipow2(min(128 // (by * bx), heads))
    grid = (-(-hidden_dim // bx), -(-ntokens // by), -(-heads // bz))
    cx, cy, cz = cta
    nl = layers * kv_factor
    shape = (nl, heads, tpb, hidden_dim)
    return Case(
        name=name,
        description=f"cuKVCacheBlockPartialCopy<{dtype}>, {nl} layers x {heads} heads x {tpb} tokens x "
                    f"{hidden_dim}, copy {ntokens} tokens, block ({bx}, {by}, {bz}), grid {grid}, cta {cta}"
                    f"{note}{HIDDEN}",
        source=f"{PARTIAL_COPY}:30 (cuKVCacheBlockPartialCopy), host hostKVCacheBlockPartialCopy :62",
        unit=PARTIAL_COPY,
        symbol=f"25cuKVCacheBlockPartialCopyI{PARTIAL_MANGLED[dtype]}EE",
        args=(Ptr("dst"), Ptr("src"), Int(nl, "numLayers"), Int(heads, "numHeads"), Int(tpb, "tokensPerBlock"),
              Int(hidden_dim, "numHidden"), Int(ntokens, "numTokensToCopy")),
        arrays=(Array("src", "in", dtype, shape), Array("dst", "out", dtype, shape)),
        grid=grid,
        block=(bx, by, bz),
        check="ERROR",
        spec="partial_copy.spec",
        dims={"L": nl, "H": heads, "TPB": tpb, "D": hidden_dim, "X0": cx * bx, "X1": min(hidden_dim, cx * bx + bx),
              "Y0": cy * by, "Y1": min(ntokens, cy * by + by), "Z0": cz * bz, "Z1": min(heads, cz * bz + bz)},
        cta=cta,
    )


_PARTIALS = (
    kv_partial_copy("kv_partial_copy_bf16", 2, 4, 32, 128, 20, cta=(3, 4, 1), note=" (last token tile 16..20)"),
    kv_partial_copy("kv_partial_copy_f32_odd", 1, 3, 8, 6, 5, cta=(0, 0, 1), dtype="f32",
                    note=" (block 8 x 8 x 2: x 6..8, y 5..8 and head 3 idle)"),
    kv_partial_copy("kv_partial_copy_i64", 1, 2, 16, 64, 16, cta=(1, 1, 0), kv_factor=1, dtype="i64"),
)
CASES += tuple(hidden(c, "ACCEPT") for c in _PARTIALS) + (
    hidden(negative(_PARTIALS[0], {"Y1": 21}, "21 tokens"), "REJECT"),)


def merge_attn(name, q_lens, ops, heads, cta, head_size=128, dtype="bf16", in_place=True, expect="ACCEPT",
               note=""):
    """`invokeMergeAttnWithSoftmax(merged_attn, merged_stats, pre_attn, pre_stats, curr_attn,
    curr_stats, batch, cu_q_seq_len, max_q, merge_op, heads, head_size, isLse = false)`
    (mlaChunkedPrefill.cu:393) as mergeChunkedAttentionForMLAHelper calls it
    (mlaPreprocessOp.cpp:102, `in_place`: pre_* are merged_*): 16-byte vectors, kTokenPerBlock 8
    (4 for f32), block head_size * size / 16 * 8, grid (ceil(max_q / 8), batch, heads) (:332).
    Block `cta` = (x, batch, head)."""
    width = 4 if dtype == "f32" else 2
    per_block = 4 if dtype == "f32" else 8
    vec_per_head = head_size * width // 16
    cu = [0]
    for n in q_lens:
        cu.append(cu[-1] + n)
    total = cu[-1]
    bx, b, h = cta
    t0 = cu[b] + bx * per_block
    t1 = min(cu[b + 1], t0 + per_block)
    pre = ("ma", "ms") if in_place else ("pa", "ps")
    arrays = [i64_index("cu", cu), i64_index("merge_op", ops),
              Array("ca", "in", dtype, (total, heads, head_size)), Array("cs", "in", "f32", (total, heads, 2))]
    if not in_place:
        arrays += [Array("pa", "in", dtype, (total, heads, head_size)), Array("ps", "in", "f32", (total, heads, 2))]
    kind = "inout" if in_place else "out"
    arrays += [Array("ma", kind, dtype, (total, heads, head_size)), Array("ms", kind, "f32", (total, heads, 2))]
    return Case(
        name=name,
        description=f"mergeAttnWithSoftmaxKernel<{dtype}, {head_size}, max/sum stats>, q lengths {q_lens}, "
                    f"merge ops {ops}, {heads} heads, {'in place' if in_place else 'separate buffers'}, "
                    f"block {cta} = tokens [{t0}, {t1}){note}{HIDDEN}",
        source=f"{CHUNKED}:174 (mergeAttnWithSoftmaxKernel), host invokeMergeAttnWithSoftmax :393 "
               f"(launch :332) from mlaPreprocessOp.cpp:102",
        unit=CHUNKED,
        symbol=f"26mergeAttnWithSoftmaxKernelI{T_MANGLED.get(dtype, 'f')}Li{head_size}ELb0EE",
        args=(Ptr("ma"), Ptr("ms"), Ptr(pre[0]), Ptr(pre[1]), Ptr("ca"), Ptr("cs"), Ptr("cu"),
              Ptr("merge_op"), Int(heads, "num_heads"), Int(head_size, "head_size")),
        arrays=tuple(arrays),
        grid=(-(-max(q_lens) // per_block), len(q_lens), heads),
        block=vec_per_head * per_block,
        check="ERROR",
        spec="merge_attn.spec" if in_place else "merge_attn_separate.spec",
        dims={"T": total, "H": heads, "D": head_size, "TWO": 2, "HD": h, "T0": t0, "T1": max(t0, t1),
              "OP": ops[b]},
        cta=cta,
    )


_MERGES = (
    merge_attn("mla_merge_in_place_bf16", (5, 0, 9), (1, 0, 2), 2, cta=(0, 0, 1),
               note=" (5 of 8 token slots)"),
    merge_attn("mla_merge_in_place_copy_bf16", (5, 0, 9), (1, 0, 2), 2, cta=(1, 2, 0),
               note=" (copy op, last token tile)"),
    merge_attn("mla_merge_separate_bf16", (5, 0, 9), (1, 0, 2), 2, cta=(0, 0, 1), in_place=False),
    merge_attn("mla_merge_separate_f32", (3, 6), (2, 1), 1, cta=(1, 1, 0), dtype="f32", in_place=False),
    merge_attn("mla_merge_in_place_f32", (3, 6), (2, 1), 1, cta=(1, 1, 0), dtype="f32"),
)
# Directly: the in-place merges (OP 1) REJECT, a memory conflict: lane 0 of each token's lanes
# stores the merged stats (`st.global.v2.b32 [%rd39], {%r12, %r13}`, mlaChunkedPrefill.ptx:4447,
# kernel :269/:276 storeMergeNormalizer) while the token's other lanes load the same pre stats
# (`ld.global.v2.b32 {%r54, %r55}, [%rd36]`, :4246, kernel :216), with no __syncwarp between:
# with merged_softmax_stats == pre_softmax_stats (mlaPreprocessOp.cpp:102) that is a data race
# under the PTX memory model; the kernel relies on warp-synchronous execution (its static_assert,
# :41, "readers of aliased softmax stats must stay in the same warp as their writer"). The copy
# op (OP 2) and separate buffers have no conflict. Volta gap: a bf16 merge's outputs cannot be
# read back, its two halves packed by `cvt.u32.u16; shl.b32 16; or.b32` (:4436-:4440) into a
# word stored by `st.global.v4.b32` (:4443): "output array 'ma' element 1016 was written at width
# 4 (element width 2)" (an element of `ma`), so the separate-buffer bf16 merge is UNKNOWN (true
# verdict ACCEPT, as f32's).
_MERGE_VERDICTS = ("REJECT", "ACCEPT", "UNKNOWN", "ACCEPT", "REJECT")
CASES += tuple(hidden(c, v) for c, v in zip(_MERGES, _MERGE_VERDICTS)) + (
    hidden(negative(_MERGES[3], {"OP": 2}, "copy instead of merge"), "REJECT"),
    hidden(negative(_MERGES[1], {"T1": 12}, "one token short"), "REJECT"),)


# ===== Mamba causal conv1d decode step (mambaConv1dKernels.cu) =====

MAMBA = KERNELS + "mambaConv1dKernels.cu"
MAMBA_MANGLED = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16"}


def mamba_conv_step(name, batch, dim, cta, pre=0, post=0, silu=True, slots=None, dtype="bf16",
                    check="ACCEPT", note=""):
    """`invokeMambaConv1dGeneration<T>(params)` (mambaConv1dKernels.cu:1291) as mambaConv1dOp.cpp
    sets MambaConv1dParamsBase (:83): grid (ceil(dim / 256), batch), block 64, 4 channels per
    thread, dconv 4, micro batch 1. `slots` (the paged state's slot mapping) makes the state in
    place, else separate in/out buffers. Struct: 6 ints, 2 bools, 8 pointers (96 bytes)."""
    bx, s = cta
    paged = slots is not None
    n_slots = max(slots) + 1 if paged else batch
    slot = slots[s] if paged else s
    din = dim + pre + post
    fields = [{"offset": 4 * k, "u32": v} for k, v in enumerate((batch, dim, 1, 4, pre, post))]
    fields += [{"offset": 24, "u8": 1}, {"offset": 25, "u8": int(silu)}, {"offset": 26, "u16": 0},
               {"offset": 28, "u32": 0},
               {"offset": 32, "ptr": "x"}, {"offset": 40, "ptr": "st" if paged else "sin"},
               {"offset": 48, "ptr": "st" if paged else "sout"}, {"offset": 56, "ptr": "w"},
               {"offset": 64, "ptr": "bias"}, {"offset": 72, "ptr": "out"}, {"offset": 80, "u64": 0},
               {"offset": 88, "ptr": "slots"} if paged else {"offset": 88, "u64": 0}]
    arrays = [Array("x", "in", dtype, (batch, din)), Array("w", "in", dtype, (4, dim)),
              Array("bias", "in", dtype, (dim,))]
    if paged:
        arrays += [Array("slots", "index", "i32", (batch,), contents=tuple(slots)),
                   Array("st", "inout", dtype, (n_slots, 3, dim))]
    else:
        arrays += [Array("sin", "in", dtype, (n_slots, 3, dim)), Array("sout", "out", dtype, (n_slots, 3, dim))]
    arrays.append(Array("out", "out", dtype, (batch, dim)))
    return Case(
        name=name,
        description=f"mamba_conv1d_generation_kernel<{dtype}, 4, 4>, batch {batch} x dim {dim} (pre {pre}, "
                    f"post {post}), {'silu' if silu else 'no silu'}, "
                    f"{'paged state, slots ' + str(slots) if paged else 'separate state'}, block ({bx}, {s}){note}",
        source=f"{MAMBA}:1193 (mamba_conv1d_generation_kernel), host invokeMambaConv1dGeneration :1291, "
               f"params mambaConv1dOp.cpp:83",
        unit=MAMBA,
        symbol=f"30mamba_conv1d_generation_kernelI{MAMBA_MANGLED[dtype]}Li4ELi4EE",
        args=(Struct(tuple(fields), "params"), Int(1, "micro_batchsize")),
        arrays=tuple(arrays),
        grid=(-(-dim // 256), batch, 1),
        block=64,
        check=check,
        spec="mamba_conv_step_paged.spec" if paged else "mamba_conv_step.spec",
        dims={"B": batch, "D": dim, "DIN": din, "PRE": pre, "NS": n_slots, "K": 4, "KM1": 3, "S": s,
              "SLOT": slot, "C0": 256 * bx, "C1": min(dim, 256 * bx + 256), "SILU": int(silu)},
        cta=(bx, s, 0),
    )


_MAMBA_STEPS = (
    mamba_conv_step("mamba_conv_step_bf16", 2, 512, cta=(1, 1)),
    mamba_conv_step("mamba_conv_step_f32_tail", 3, 300, cta=(1, 2), dtype="f32", silu=False,
                    note=" (channels 256..300: 11 of 64 threads)"),
    mamba_conv_step("mamba_conv_step_f16_strided", 2, 256, cta=(0, 0), pre=64, post=32, dtype="f16",
                    note=" (xBC slice of a wider input row)"),
    mamba_conv_step("mamba_conv_step_paged_bf16", 3, 256, cta=(0, 2), slots=(4, 0, 2)),
)
CASES += _MAMBA_STEPS + (negative(_MAMBA_STEPS[0], {"SLOT": 0}, "state of slot 0"),
                         negative(_MAMBA_STEPS[3], {"SILU": 0}, "no silu"))


# ===== MLA paged KV-cache load (mlaKernels.cu) =====

MLA_LORA, MLA_ROPE = 512, 64
SECONDARY = 1 << 31  # KVCacheIndex::kSecondaryPoolFlag


def kv_block_array(batch, max_blocks, tpb, bytes_per_token, offsets="offsets", pool="pool", pool2="pool2",
                   window=1 << 20, sinks=0):
    """KVBlockArray (kvCacheUtils.h:103) by value, 72 bytes: mMaxSeqs, mMaxBlocksPerSeq,
    mTokensPerBlock, mTokensPerBlockLog2, mBytesPerBlock, primary pool, block offsets
    ([seq][K/V][block] KVCacheIndex), secondary pool, window, sinks, cyclic length, bubble,
    one-more-block (no sinks, no cyclic window here)."""
    return Struct(({"offset": 0, "u32": batch}, {"offset": 4, "u32": max_blocks}, {"offset": 8, "u32": tpb},
                   {"offset": 12, "u32": tpb.bit_length() - 1}, {"offset": 16, "u32": tpb * bytes_per_token},
                   {"offset": 20, "u32": 0}, {"offset": 24, "ptr": pool}, {"offset": 32, "ptr": offsets},
                   {"offset": 40, "ptr": pool2}, {"offset": 48, "u32": window}, {"offset": 52, "u32": sinks},
                   {"offset": 56, "u32": window - sinks},
                   {"offset": 60, "u32": (tpb - sinks % tpb) % tpb}, {"offset": 64, "u64": 0}),
                  "kv_cache")


def mla_load_paged_kv(name, lens, tables, tpb, cta, nb=8, dtype="bf16", expect="ACCEPT", note=""):
    """`invokeMLALoadPagedKV<T, T>(compressed_kv, k_pe, kv_cache, num_contexts, cu_ctx_cached_kv_lens,
    max_len, 512, 64, nullptr)` (mlaKernels.cu:2190): grid (ceil(max_len / 8), contexts) (4 tokens
    for f32), block kVecPerHead * 8 = 576 * size / 16 * 8 (:330). `tables[b]` lists batch b's
    blocks as (pool, block) with pool 1 the secondary pool."""
    width = 4 if dtype == "f32" else 2
    per_block = 4 if dtype == "f32" else 8
    vec_per_head = (MLA_LORA + MLA_ROPE) * width // 16
    batch = len(lens)
    cu = [0]
    for n in lens:
        cu.append(cu[-1] + n)
    max_blocks = max(len(t) for t in tables)
    words = []
    for t in tables:
        row = [b | (SECONDARY if p else 0) for p, b in t] + [0] * (max_blocks - len(t))
        words += row + [0] * max_blocks  # K blocks, then (unused) V blocks
    words = [w - (1 << 32) if w >= 1 << 31 else w for w in words]
    bx, b = cta
    dims = {"T": cu[-1], "NB": nb, "TPB": tpb, "HS": MLA_LORA + MLA_ROPE, "LORA": MLA_LORA, "ROPE": MLA_ROPE,
            "G0": cu[b] + per_block * bx}
    for k in range(8):
        local = per_block * bx + k
        valid = k < per_block and local < lens[b]
        p, blk = tables[b][local // tpb] if valid else (0, 0)
        dims.update({f"V{k}": int(valid), f"PB{k}": blk, f"SL{k}": local % tpb if valid else 0, f"PL{k}": p})
    return Case(
        name=name,
        description=f"loadPagedKVCacheForMLAKernel<{dtype}, {dtype}>, cached lengths {lens}, {tpb} tokens per "
                    f"block, block tables {tables}, block ({bx}, {b}){note}",
        source=f"{MLA}:1223 (loadPagedKVCacheForMLAKernel), host invokeMLALoadPagedKV :2190 "
               f"from mlaPreprocessOp.cpp:41",
        unit=MLA,
        symbol=f"28loadPagedKVCacheForMLAKernelI{T_MANGLED.get(dtype, 'f')}{'S3_' if dtype != 'f32' else 'f'}EE",
        args=(Ptr("ckv"), Ptr("kpe"), kv_block_array(batch, max_blocks, tpb, (MLA_LORA + MLA_ROPE) * width),
              Ptr("cu"), Int(max(lens), "max_input_seq_len"), NULL),
        arrays=(Array("offsets", "index", "i32", (batch, 2, max_blocks), contents=tuple(words)),
                i64_index("cu", cu),
                Array("pool", "in", dtype, (nb, tpb, MLA_LORA + MLA_ROPE)),
                Array("pool2", "in", dtype, (nb, tpb, MLA_LORA + MLA_ROPE)),
                Array("ckv", "out", dtype, (cu[-1], MLA_LORA)), Array("kpe", "out", dtype, (cu[-1], MLA_ROPE))),
        grid=(-(-max(lens) // per_block), batch, 1),
        block=vec_per_head * per_block,
        check=expect,
        spec="mla_load_paged_kv.spec",
        dims=dims,
        cta=(bx, b, 0),
    )


_MLA_LOADS = (
    mla_load_paged_kv("mla_load_paged_kv_bf16", (6, 13), (((0, 3), (0, 1)), ((0, 5), (0, 2), (1, 7), (0, 0))), 4,
                      cta=(1, 1), note=" (tokens 8..12: blocks 2 (secondary) and 3, 5 of 8)"),
    mla_load_paged_kv("mla_load_paged_kv_bf16_short", (6, 13), (((0, 3), (0, 1)), ((0, 5), (0, 2), (1, 7), (0, 0))),
                      4, cta=(0, 0), note=" (6 of 8 tokens)"),
    mla_load_paged_kv("mla_load_paged_kv_f32", (3,), (((1, 2),),), 8, cta=(0, 0), dtype="f32",
                      note=" (secondary pool, 3 of 4 tokens)"),
)
CASES += _MLA_LOADS + (negative(_MLA_LOADS[0], {"PL0": 0}, "token 8 from the primary pool"),)


# ===== Unfused attention: K/V into the paged cache (unfusedAttentionKernels.cu) =====


def transpose_kv_cache(name, seq_lens, max_len, heads, head_dim, tpb, tables, cta, window=None, sinks=0,
                       dtype="bf16", check="ACCEPT", note=""):
    """`invokeTranspose4dBatchMajor(k, v, kvTable, batch, seqLen, window, sizePerHead, heads,
    cache type = T, nullptr, sequence_lengths)` (unfusedAttentionKernels.cu:1716): x = 16 bytes
    of T, block (128, 2) (y 0 K, y 1 V), grid (ceil(seqLen * D / x / 128), batch, heads). A
    KVBlockArray with window `window` (cyclic length window - sinks, kvCacheUtils.h:128);
    `tables[b]` = (K blocks, V blocks) of batch b in the one pool [NB, H, TPB, D]."""
    width = 4 if dtype == "f32" else 2
    x = 16 // width
    div = head_dim // x
    bx, b, h = cta
    batch = len(seq_lens)
    window = window or 1 << 20
    nb = 1 + max(max(max(kb), max(vb)) for kb, vb in tables)
    max_blocks = max(len(kb) for kb, _ in tables)
    words = []
    for kb, vb in tables:
        words += list(kb) + [0] * (max_blocks - len(kb)) + list(vb) + [0] * (max_blocks - len(vb))
    per_block = 128 // div
    t0 = bx * per_block
    cyclic = window - sinks
    bubble = (tpb - sinks % tpb) % tpb
    dims = {"B": batch, "H": heads, "L": max_len, "D": head_dim, "NB": nb, "TPB": tpb, "HD": h, "T0": t0, "BI": b}
    never = nb * tpb
    for k in range(16):
        t = t0 + k
        kx = vx = never
        if k < per_block and max(seq_lens[b] - window, 0) <= t < seq_lens[b]:
            p = t if t < sinks else sinks + bubble + (t - sinks) % cyclic
            kx = tables[b][0][p // tpb] * tpb + p % tpb
            vx = tables[b][1][p // tpb] * tpb + p % tpb
        dims.update({f"KX{k}": kx, f"VX{k}": vx})
    return Case(
        name=name,
        description=f"transpose4dBatchMajorKVCache<{dtype}, {dtype}, KVBlockArray>, lengths {seq_lens} of {max_len}, "
                    f"{heads} heads of {head_dim}, {tpb} tokens per block"
                    f"{f', window {window}' if window < 1 << 20 else ''}{f', {sinks} sink tokens' if sinks else ''}, "
                    f"block {cta}{note}",
        source=f"{UNFUSED}:1645 (transpose4dBatchMajorKVCache), host invokeTranspose4dBatchMajor :1716",
        unit=UNFUSED,
        symbol=f"28transpose4dBatchMajorKVCacheI{T_MANGLED.get(dtype, 'f')}{'S3_' if dtype != 'f32' else 'f'}"
               f"NS1_12KVBlockArrayEE",
        args=(Ptr("k"), Ptr("v"), kv_block_array(batch, max_blocks, tpb, heads * head_dim * width, pool2="pool",
                                                 window=window, sinks=sinks),
              Int(heads, "headNum"), Int(head_dim, "sizePerHead"), Int(max_len, "seqLen"),
              Int(window, "attentionWindowSize"), NULL, Ptr("seq_lens")),
        arrays=(Array("offsets", "index", "i32", (batch, 2, max_blocks), contents=tuple(words)),
                Array("seq_lens", "index", "i32", (batch,), contents=tuple(seq_lens)),
                Array("k", "in", dtype, (batch, heads, max_len, head_dim)),
                Array("v", "in", dtype, (batch, heads, max_len, head_dim)),
                Array("pool", "out", dtype, (nb, heads, tpb, head_dim))),
        grid=(-(-max_len * head_dim // x // 128), batch, heads),
        block=(128, 2, 1),
        check=check,
        spec="transpose_kv_cache.spec",
        dims=dims,
        cta=cta,
    )


_KV_TRANSPOSES = (
    transpose_kv_cache("transpose_kv_cache_bf16", (10, 5), 10, 2, 64, 4, (((0, 3, 5), (1, 2, 4)), ((6, 7), (8, 9))),
                       cta=(0, 0, 1)),
    transpose_kv_cache("transpose_kv_cache_short_batch", (10, 5), 10, 2, 64, 4,
                       (((0, 3, 5), (1, 2, 4)), ((6, 7), (8, 9))), cta=(0, 1, 0), note=" (5 of 10 tokens)"),
    transpose_kv_cache("transpose_kv_cache_window", (10,), 10, 1, 64, 4, (((0, 1), (2, 3)),), cta=(0, 0, 0),
                       window=6, note=" (tokens 4..9 to cyclic slots t % 6)"),
    transpose_kv_cache("transpose_kv_cache_f32_block1", (40,), 40, 1, 128, 8,
                       (((0, 1, 2, 3, 4), (5, 6, 7, 8, 9)),), cta=(1, 0, 0), dtype="f32",
                       note=" (block 1: tokens 4..7 of 32 per head row)"),
)
CASES += _KV_TRANSPOSES + (negative(_KV_TRANSPOSES[2], {"KX0": 0}, "token 4 to slot 0"),)
# Not a host launch: REJECT, a write-write conflict (`st.global.v4.b32 [%rd34]`,
# unfusedAttentionKernels.ptx:287381, threads 32 and 64 = tokens 4 and 8 both to cache position
# 6). With sinks S the cyclic length is W - S (kvCacheUtils.h:140) but the kernel keeps the last
# W tokens (:1678), so S of them collide. The only host caller (attentionOp.cpp:1465) builds the
# KVBlockArray with sink length 0 (:1007), so this is a kernel-contract edge, not a reachable bug.
CASES += (
    transpose_kv_cache("transpose_kv_cache_window_sinks", (10,), 10, 1, 64, 4, (((0, 1), (2, 3)),), cta=(0, 0, 0),
                       window=6, sinks=2, check="REJECT", note=" (sinks 2, window 6 < length 10: not a host launch)"),
)


# ===== AWQ/SmoothQuant pre-quant scale (preQuantScaleKernel.cu) =====

PREQUANT = KERNELS + "preQuantScaleKernel.cu"


def per_channel_scale(name, rows, cols, cta, dtype="bf16", valid=None, check="ACCEPT", note=""):
    """`apply_per_channel_scale_kernel_launcher<T, T>(out, act, scale, rows, cols, num_valid_tokens)`
    (preQuantScaleKernel.cu:130), from the MoE prequant path (moe_kernels.cu:3724): kProcessRows
    1/4/8/16 by rows * cols below 2048^2/4096^2/8192^2, float4 access (8 elements), block 128,
    grid (ceil(rows / kProcessRows), ceil(cols / 8 / 128)) (:119)."""
    elems = rows * cols
    kpr = 1 if elems < 2048 ** 2 else 4 if elems < 4096 ** 2 else 8 if elems < 8192 ** 2 else 16
    bx, by = cta
    r0 = bx * kpr
    r1 = min(r0 + kpr, rows if valid is None else valid) if r0 < (rows if valid is None else valid) else r0
    c0, c1 = by * 128 * 8, min(cols, by * 128 * 8 + 128 * 8)
    arrays = [Array("act", "in", dtype, (rows, cols)), Array("scale", "in", dtype, (cols,)),
              Array("out", "out", dtype, (rows, cols))]
    if valid is not None:
        arrays.insert(0, i64_index("valid", (valid,)))
    return Case(
        name=name,
        description=f"apply_per_channel_scale<{dtype}, {dtype}, {kpr} rows, float4>, {rows} x {cols}"
                    f"{f', {valid} valid tokens' if valid is not None else ''}, block {cta}{note}",
        source=f"{PREQUANT}:44 (apply_per_channel_scale), host apply_per_channel_scale_kernel_launcher :130 "
               f"(launch :119) from moe_kernels.cu:3724",
        unit=PREQUANT,
        symbol=f"23apply_per_channel_scaleI{T_MANGLED[dtype]}S3_Li{kpr}E6float4EE",
        args=(Ptr("out"), Ptr("act"), Ptr("scale"), Int(rows, "rows"), Int(cols, "cols"),
              Ptr("valid") if valid is not None else NULL, NULL, Int(0, "num_experts_per_node")),
        arrays=tuple(arrays),
        grid=(-(-rows // kpr), -(-cols // 8 // 128), 1),
        block=128,
        check=check,
        spec="per_channel_scale.spec",
        dims={"R": rows, "C": cols, "R0": r0, "R1": r1, "C0": c0, "C1": c1},
        cta=(bx, by, 0),
    )


_PREQUANTS = (
    per_channel_scale("per_channel_scale_bf16", 6, 1536, cta=(5, 1), note=" (columns 1024..1536: half the lanes)"),
    per_channel_scale("per_channel_scale_f16_valid", 6, 1024, cta=(4, 0), dtype="f16", valid=4,
                      note=" (row 4 past the 4 valid tokens: nothing)"),
)
# The kProcessRows = 4 path (rows * cols >= 2048^2) on its last block when rows % 4 != 0, race
# check only (a spec would unfold 4M elements). ABORT: "out-of-bounds Global access at 0x810800
# (width 16)" = act row 4097, one past the end: the guard (:52) tests only the block's first row
# (and num_valid_tokens likewise, :54), then the loop (:58) reads and writes all kProcessRows rows.
# Noticed while reading the kernel before writing the case, so an uncounted lead.
_PREQUANT_TAIL = dataclasses.replace(
    per_channel_scale("per_channel_scale_4rows_tail", 4097, 1024, cta=(1024, 0),
                      note=" (rows 4096..4099 of 4097)"), spec=None, dims={}, check="ABORT")
CASES += _PREQUANTS + (negative(_PREQUANTS[0], {"C1": 1535}, "column 1535 unwritten"), _PREQUANT_TAIL)
