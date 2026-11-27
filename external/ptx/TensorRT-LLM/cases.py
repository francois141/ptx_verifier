"""TensorRT-LLM kernels checked by Volta: what each case compiles, launches and checks.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`cpp/tensorrt_llm/kernels/` unit of TensorRT-LLM at the commit
`external/ptx/sources/frameworks.txt` pins, compiled for sm_100a by
`external/ptx/extraction/survey.py`; `symbol` is a substring of its mangled name. The launch
(grid, block, arguments) is the one the unit's host code makes for the case's shape, read from
the source cited in `source`.
"""

from dataclasses import dataclass, field
from pathlib import Path

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


# A masked logit is the constant -inf on both sides (equal infinite constants), and the scalar
# path's 0xff800000 store reads back as the f32 -inf.
def logits_bitmask(name, batch, vocab, masked, cta, dtype="f32", d2t=None, token_mask=None,
                   check="ACCEPT", note=""):
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
# op (OP 2) and separate buffers have no conflict. A bf16 merge packs its two halves by
# `cvt.u32.u16; shl.b32 16; or.b32` (:4436-:4440) into one stored word, read back as its halves.
_MERGE_VERDICTS = ("REJECT", "ACCEPT", "ACCEPT", "ACCEPT", "REJECT")
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


# ===== Round 3: kernel subdirectories =====

DSV3 = KERNELS + "dsv3MinLatencyKernels/"
FUSED_A = DSV3 + "dsv3FusedAGemm.cu"


# A unit under this directory: `verify.py` reads `survey/TensorRT-LLM/<unit>.ptx`. Each patched
# PTX is a finding's control (the kernel with one diagnosed defect fixed), kept as a diff of the
# survey's PTX (`patched/<name>.ptx.patch`) and written beside it when this module loads.
PATCHED = "../../TensorRT-LLM/patched/"
_PATCH_SOURCES = {"attnResFwd_tmem_fixed": "kimiK3AttnRes/attnResFwd.ptx",
                  "attnResFwd_tmem_lane": "kimiK3AttnRes/attnResFwd.ptx",
                  "dsv3FusedAGemm_fixed": "dsv3MinLatencyKernels/dsv3FusedAGemm.ptx",
                  "dsv3FusedAGemm_shared_arrive": "dsv3MinLatencyKernels/dsv3FusedAGemm.ptx"}


def _write_patched():
    import subprocess
    here = Path(__file__).resolve().parent
    survey = here.parent / "survey" / "TensorRT-LLM" / "cpp" / "tensorrt_llm" / "kernels"
    for name, source in _PATCH_SOURCES.items():
        out = here / "patched" / f"{name}.ptx"
        if not out.exists() and (survey / source).exists():
            subprocess.run(["patch", "-s", "-o", str(out), str(survey / source),
                            str(here / "patched" / f"{name}.ptx.patch")], check=True)


_write_patched()


def fused_a_gemm(name, hd_in, hd_out, tile_n, tile_m, tokens, cta, patched=None, check="ACCEPT",
                 note=""):
    """`invokeFusedAGemm<bf16, hd_in, hd_out, tile_n, tile_m>(out, hidden, weight, tokens)`
    (dsv3FusedAGemm.cu:648): operands swapped (kernel mat_a = weight [hd_out, hd_in], mat_b =
    hidden [tokens, hd_in]), tile_k = max(256, 1024 / tile_n), stage_cnt = min(hd_in / tile_k,
    192 KiB / ((tile_m + tile_n) tile_k 2)), grid (hd_out / tile_m, ceil(tokens / tile_n)),
    block 256, dynamic smem ((tile_m + tile_n) 2 tile_k stages + barrier bytes) rounded to 1 KiB."""
    tile_k = max(256, 1024 // tile_n)
    k_iters = hd_in // tile_k
    stages = min(k_iters, 1024 * 192 // ((tile_m + tile_n) * tile_k * 2))
    barrier = (stages * 16 + 1023) // 1024 * 1024
    smem = ((tile_m * 2 + tile_n * 2) * tile_k * stages + barrier + 1023) // 1024 * 1024
    bx, by = cta
    return Case(
        name=name,
        description=f"fused_a_gemm_kernel<{hd_out}, {hd_in}, tile {tile_m} x {tile_n} x {tile_k}, "
                    f"{stages} stages>, {tokens} tokens, {k_iters} k-iterations (ring wraps "
                    f"{k_iters / stages:.2f}x), block {cta}{note}",
        source=f"{FUSED_A}:577 (fused_a_gemm_kernel), host invokeFusedAGemm :648 (launch :673)"
               + (f", PTX patched ({PATCHED}dsv3FusedAGemm_{patched}.ptx)" if patched else ""),
        unit=f"{PATCHED}dsv3FusedAGemm_{patched}.cu" if patched else FUSED_A,
        symbol=f"19fused_a_gemm_kernelILi1ELi{hd_out}ELi{hd_in}ELi{tile_m}ELi{tile_n}ELi{tile_k}"
               f"ELi{stages}EE",
        args=(Ptr("out"), Ptr("w"), Ptr("x"), Int(tokens, "gemm_n")),
        arrays=(Array("w", "in", "bf16", (hd_out, hd_in)), Array("x", "in", "bf16", (tokens, hd_in)),
                Array("out", "out", "bf16", (tokens, hd_out))),
        grid=(hd_out // tile_m, -(-tokens // tile_n), 1),
        block=256,
        check=check,
        spec="fused_a_gemm.spec",
        dims={"M": hd_out, "K": hd_in, "N": tokens, "M0": tile_m * bx, "M1": tile_m * bx + tile_m,
              "N0": tile_n * by, "N1": min(tokens, tile_n * by + tile_n)},
        cta=(bx, by, 0),
        smem=smem,
    )


# Volta finding (REJECT, every instantiation): MmaComputer's `::arrive_barrier` (:472) is not
# the namespaced one (:133) but cudaUtils.h:1189's (found through the file-scope `using namespace
# tensorrt_llm::common`, :28), which passes a generic pointer to `mbarrier.arrive.shared.b64 _,
# [%rd19]` after `cvta.shared.u64 %rd22, %rd21` (dsv3FusedAGemm.ptx:727): "t128: out-of-bounds
# Shared access at 0x6000000000000008 (width 8)". PTX ISA 9.7.13.15.13: an addr outside the
# .shared::cta window is undefined behavior (it works on hardware whose generic shared window
# base has zero low 32 bits). `_shared_arrive` patches the four cvta's into movs; then Volta finds
# that all 32 lanes of warp 4 run every mbarrier.init (:612-:618): "t129: mbarrier.init of the
# live mbarrier object at Shared[0x0] ... mbarrier.inval must run first" (ISA 9.7.13.15.9: init
# of a valid mbarrier object is undefined). `_fixed` also guards the init by tid 128: ACCEPT.
_FUSED_A = (
    fused_a_gemm("fused_a_gemm_dsv3_n8_3tok", 7168, 2112, 8, 16, 3, cta=(131, 0), check="REJECT",
                 note=" (last block, 3 of 8 token rows)"),
    fused_a_gemm("fused_a_gemm_dsv3_n8_3tok_shared_arrive", 7168, 2112, 8, 16, 3, cta=(131, 0),
                 patched="shared_arrive", check="REJECT", note=" (last block, 3 of 8 token rows)"),
    fused_a_gemm("fused_a_gemm_dsv3_n8_3tok_fixed", 7168, 2112, 8, 16, 3, cta=(131, 0), patched="fixed",
                 note=" (last block, 3 of 8 token rows)"),
    fused_a_gemm("fused_a_gemm_dsv3_n16_16tok_fixed", 7168, 2112, 16, 16, 16, cta=(0, 0), patched="fixed",
                 note=" (all 16 token rows)"),
    fused_a_gemm("fused_a_gemm_dsv3_n16_9tok_fixed", 7168, 2112, 16, 16, 9, cta=(131, 0), patched="fixed",
                 note=" (9 tokens: the smallest on tile_n 16)"),
    fused_a_gemm("fused_a_gemm_dsv3_n16_1tok_fixed", 7168, 2112, 16, 16, 1, cta=(50, 0), patched="fixed",
                 note=" (1 token on tile_n 16: not a host launch, the op takes tile_n 8)"),
    fused_a_gemm("fused_a_gemm_glm_n8_5tok_fixed", 6144, 2624, 8, 32, 5, cta=(81, 0), patched="fixed",
                 note=" (tile_m 32, last block)"),
    fused_a_gemm("fused_a_gemm_glm_n16_11tok_fixed", 6144, 2624, 16, 32, 11, cta=(3, 0), patched="fixed",
                 note=" (tile_m 32)"),
    fused_a_gemm("fused_a_gemm_dsv3_n16_16tok", 7168, 2112, 16, 16, 16, cta=(0, 0), check="REJECT"),
    fused_a_gemm("fused_a_gemm_glm_n8_5tok", 6144, 2624, 8, 32, 5, cta=(81, 0), check="REJECT"),
    fused_a_gemm("fused_a_gemm_glm_n16_11tok_shared_arrive", 6144, 2624, 16, 32, 11, cta=(3, 0),
                 patched="shared_arrive", check="REJECT", note=" (tile_m 32)"),
    # Not a host launch (dsv3FusedAGemmOp.cpp:71 takes tile_n 16 past 8 tokens, so grid y is 1):
    # UNKNOWN, "t96: out-of-bounds Global access at 0x1d1d800 (width 16)", x row 13 of 13. With
    # grid y 2 the B loader's predicate (:294) and the store's (:547) compare the tile-local row
    # with gemm_n, so block y 1 reads x rows 13..15 and would store out rows 13..15. A contract
    # edge of invokeFusedAGemm (its grid allows ceil(tokens / tile_n) > 1, :669), unreachable.
    fused_a_gemm("fused_a_gemm_dsv3_n8_13tok_fixed", 7168, 2112, 8, 16, 13, cta=(7, 1), patched="fixed",
                 check="UNKNOWN", note=" (second token tile, rows 8..12: not a host launch)"),
)
CASES += _FUSED_A + (negative(_FUSED_A[7], {"N1": 10}, "10 token rows"),
                     negative(_FUSED_A[6], {"M0": 2591}, "weight row 2591 too"))


ROUTER = DSV3 + "dsv3RouterGemm.cu"


def router_gemm(name, tokens, experts, hidden, cta, mma=False, check="ACCEPT", note=""):
    """`invokeRouterGemm<bf16, tokens, experts, hidden>(out, a, w)` (dsv3RouterGemm.cu:174): grid
    experts, block 128, VPT 8, one expert per block; `mma`: `invokeRouterGemmMma` (:367), grid
    experts / 8, block 448 (14 warps splitting K), 8 experts per block."""
    per = 8 if mma else 1
    if mma:
        symbol = f"22router_gemm_mma_kernelILi{tokens}ELi{experts}ELi{hidden}ELi8ELi448EE"
    else:
        symbol = f"18router_gemm_kernelI13__nv_bfloat16Li128ELi8ELi{tokens}ELi{experts}ELi{hidden}EE"
    return Case(
        name=name,
        description=f"{'router_gemm_mma_kernel' if mma else 'router_gemm_kernel'}, {tokens} tokens x "
                    f"{experts} experts x {hidden}, block {cta} = experts [{per * cta}, {per * cta + per}){note}",
        source=f"{ROUTER}:{366 if mma else 53}, host {'invokeRouterGemmMma :367' if mma else 'invokeRouterGemm :174'}",
        unit=ROUTER,
        symbol=symbol,
        args=(Ptr("out"), Ptr("a"), Ptr("w")),
        arrays=(Array("a", "in", "bf16", (tokens, hidden)), Array("w", "in", "bf16", (experts, hidden)),
                Array("out", "out", "f32", (tokens, experts))),
        grid=(experts // per, 1, 1),
        block=448 if mma else 128,
        check=check,
        spec="router_gemm.spec",
        dims={"T": tokens, "E": experts, "K": hidden, "N0": per * cta, "N1": per * cta + per, "M0": 0, "M1": tokens},
        cta=(cta, 0, 0),
    )


def router_latent_gemm(name, tokens, cta, check="ACCEPT", note=""):
    """`invokeRouterLatentGemmMma<tokens>(logits, projection, input, gate, down)` (dsv3RouterGemm.cu:392):
    columns 896 gate + 3584 latent, 8 per block, grid 560, block 448."""
    e, lat, k = 896, 3584, 7168
    return Case(
        name=name,
        description=f"router_latent_gemm_mma_kernel<{tokens}>, columns [{8 * cta}, {8 * cta + 8}) of "
                    f"{e} gate + {lat} latent{note}",
        source=f"{ROUTER}:358 (router_latent_gemm_mma_kernel), host invokeRouterLatentGemmMma :392",
        unit=ROUTER,
        symbol=f"29router_latent_gemm_mma_kernelILi{tokens}EE",
        args=(Ptr("logits"), Ptr("proj"), Ptr("a"), Ptr("gate"), Ptr("down")),
        arrays=(Array("a", "in", "bf16", (tokens, k)), Array("gate", "in", "bf16", (e, k)),
                Array("down", "in", "bf16", (lat, k)), Array("logits", "out", "f32", (tokens, e)),
                Array("proj", "out", "bf16", (tokens, lat))),
        grid=((e + lat) // 8, 1, 1),
        block=448,
        check=check,
        spec="router_latent_gemm.spec",
        dims={"T": tokens, "E": e, "L": lat, "K": k, "C0": 8 * cta, "C1": 8 * cta + 8},
        cta=(cta, 0, 0),
    )


_ROUTERS = (
    router_gemm("router_gemm_dsv3_1tok", 1, 256, 7168, cta=255),
    router_gemm("router_gemm_dsv3_16tok", 16, 256, 7168, cta=17),
    router_gemm("router_gemm_glm_7tok", 7, 256, 6144, cta=100),
    router_gemm("router_gemm_dsv4_288_5tok", 5, 288, 4096, cta=287),
    router_gemm("router_gemm_dsv41_384_3tok", 3, 384, 5120, cta=200),
    router_gemm("router_gemm_mma_k3_1tok", 1, 896, 7168, cta=111, mma=True, note=" (last block)"),
    router_gemm("router_gemm_mma_k3_9tok", 9, 896, 7168, cta=5, mma=True, note=" (two m-rows, 1 of row 2)"),
    router_gemm("router_gemm_mma_k3_16tok", 16, 896, 7168, cta=0, mma=True),
    router_latent_gemm("router_latent_gemm_3tok_gate", 3, cta=111, note=" (last gate block)"),
    router_latent_gemm("router_latent_gemm_3tok_latent", 3, cta=112, note=" (first latent block)"),
    router_latent_gemm("router_latent_gemm_12tok_latent", 12, cta=559, note=" (last block)"),
)
CASES += _ROUTERS + (negative(_ROUTERS[1], {"N0": 18, "N1": 19}, "expert 18"),
                     negative(_ROUTERS[9], {"C0": 904, "C1": 912}, "the next block's columns"))


# ===== Mamba causal conv1d (causalConv1d/causalConv1d.cu) =====

CONV = KERNELS + "causalConv1d/causalConv1d.cu"
CONV_MANGLED = {"f32": "ff", "f16": "6__halfS5_", "bf16": "13__nv_bfloat16S5_"}
# ConvParamsBase (causalConv1d.h:60) in declaration order, (name, size); alignment = size.
CONV_FIELDS = [*[(n, 4) for n in "batch dim seqlen width".split()], ("pad_slot_id", 8), ("silu_activation", 1),
               *[(n, 4) for n in ("x_batch_stride x_c_stride x_l_stride weight_c_stride weight_width_stride "
                                  "out_batch_stride out_c_stride out_l_stride conv_state_len "
                                  "conv_state_batch_stride conv_state_c_stride conv_state_l_stride").split()],
               *[(n, 8) for n in ("x_ptr weight_ptr bias_ptr out_ptr conv_state_ptr query_start_loc_ptr "
                                  "has_initial_state_ptr cache_indices_ptr cache_seqlens "
                                  "conv_state_indices_ptr seq_idx_ptr initial_states_ptr").split()],
               *[(n, 4) for n in "initial_states_batch_stride initial_states_l_stride initial_states_c_stride".split()],
               ("final_states_ptr", 8),
               *[(n, 4) for n in "final_states_batch_stride final_states_l_stride final_states_c_stride".split()],
               ("conv_states_ptr", 8),
               *[(n, 4) for n in "conv_states_batch_stride conv_states_l_stride conv_states_c_stride".split()]]


def _layout(fields):
    offsets, at = {}, 0
    for name, size in fields:
        at = -(-at // size) * size
        offsets[name] = (at, size)
        at += size
    return offsets, -(-at // 8) * 8


CONV_OFFSETS, CONV_SIZE = _layout(CONV_FIELDS)
assert CONV_SIZE == 240  # `.param .align 8 .b8 ..._param_0[240]` in causalConv1d.ptx
assert CONV_OFFSETS["conv_state_indices_ptr"][0] == 152 and CONV_OFFSETS["x_ptr"][0] == 80  # sl1's loads


def conv_params(values, pointers):
    """A ConvParamsBase: `values` ints by field (others 0), `pointers` array names by field (others null)."""
    fields = []
    for name, (offset, size) in CONV_OFFSETS.items():
        if name in pointers:
            fields.append({"offset": offset, "ptr": pointers[name]})
        else:
            kind = {1: "u8", 4: "u32", 8: "u64"}[size]
            v = values.get(name, 0)
            fields.append({"offset": offset, kind: v & ((1 << (8 * size)) - 1)})
    return Struct(tuple(fields), "params")


def conv1d_update(name, batch, dim, seqlen, width, state_len, cta, slots=None, seqlens=None, silu=True,
                  bias=True, pad=-1, dtype="bf16", check="ACCEPT", note=""):
    """`causalConv1dUpdate(x, conv_state, weight, bias, silu, cache_seqlens, conv_state_indices, pad)`
    (causalConv1dOp.cpp:346): out = x (in place), x [B, D, L], weight [D, W], state [S, D, SL], all
    contiguous; `causal_conv1d_update_launch<128, W>` (causalConv1d.cu:1305): grid (B, ceil(D / 128)),
    block 128, the _sl1 kernel when L == 1, no cache_seqlens, silu and SL == W - 1 (:1313). `slots`
    are conv_state_indices, `seqlens` cache_seqlens (the circular ring). Block `cta` = (batch, y)."""
    b, by = cta
    circular = seqlens is not None
    sl1 = seqlen == 1 and not circular and silu and state_len == width - 1
    n_slots = max(slots) + 1 if slots else batch
    slot = slots[b] if slots else b
    c0, c1 = 128 * by, min(dim, 128 * by + 128)
    pointers = {"x_ptr": "x", "weight_ptr": "w", "out_ptr": "x", "conv_state_ptr": "state"}
    if bias:
        pointers["bias_ptr"] = "bias"
    if slots:
        pointers["conv_state_indices_ptr"] = "slots"
    if circular:
        pointers["cache_seqlens"] = "seqlens"
    values = {"batch": batch, "dim": dim, "seqlen": seqlen, "width": width, "pad_slot_id": pad,
              "silu_activation": int(silu), "x_batch_stride": dim * seqlen, "x_c_stride": seqlen,
              "x_l_stride": 1, "weight_c_stride": width, "weight_width_stride": 1,
              "out_batch_stride": dim * seqlen, "out_c_stride": seqlen, "out_l_stride": 1,
              "conv_state_len": state_len, "conv_state_batch_stride": dim * state_len,
              "conv_state_c_stride": state_len, "conv_state_l_stride": 1}
    arrays = [Array("w", "in", dtype, (dim, width)), Array("bias", "in", dtype, (dim,))]
    if slots:
        arrays.append(Array("slots", "index", "i32", (batch,), contents=tuple(slots)))
    if circular:
        arrays.append(Array("seqlens", "index", "i32", (batch,), contents=tuple(seqlens)))
    arrays += [Array("x", "inout", dtype, (batch, dim, seqlen)),
               Array("state", "inout", dtype, (n_slots, dim, state_len))]
    dims = {"B": batch, "D": dim, "L": seqlen, "W": width, "NS": n_slots, "SL": state_len, "BI": b,
            "SLOT": slot, "C0": c0, "C1": c1, "SILU": int(silu)}
    if circular:
        cs = seqlens[b] % state_len
        upd = (cs - (width - 1)) % state_len
        ps = [(upd + i) % state_len for i in range(width - 1)] + [0] * (4 - width)
        dims.update({f"P{i}": p for i, p in enumerate(ps)})
        last = {}
        for i in range(seqlen):
            last[(cs + i) % state_len] = i
        qs = sorted(last.items()) + [(state_len, 0)] * (4 - len(last))
        assert len(qs) == 4
        for k, (q, i) in enumerate(qs):
            dims.update({f"Q{k}": q, f"I{k}": i})
    else:
        dims["BIAS"] = int(bias)
    skipped = slots is not None and slot == pad
    if sl1:
        symbol = (f"31causal_conv1d_update_kernel_sl1INS2_34Causal_conv1d_update_kernel_traitsILi128ELi{width}E"
                  f"{CONV_MANGLED[dtype]}EELb{int(bool(slots))}EE")
    else:
        symbol = (f"27causal_conv1d_update_kernelINS2_34Causal_conv1d_update_kernel_traitsILi128ELi{width}E"
                  f"{CONV_MANGLED[dtype]}EELb{int(circular)}ELb{int(bool(slots))}ELb{int(silu)}EE")
    return Case(
        name=name,
        description=f"causal_conv1d_update_kernel{'_sl1' if sl1 else ''}<{dtype}, width {width}>, batch {batch} "
                    f"x dim {dim} x {seqlen} tokens, state {state_len}{', circular ' + str(seqlens) if circular else ''}"
                    f"{', slots ' + str(slots) if slots else ''}{'' if silu else ', no silu'}"
                    f"{'' if bias else ', no bias'}, block {cta} = channels [{c0}, {c1}){note}",
        source=f"{CONV}:{1248 if sl1 else 1127}, host causal_conv1d_update_launch :1305 from "
               f"causalConv1dOp.cpp:346",
        unit=CONV,
        symbol=symbol,
        args=(conv_params(values, pointers),),
        arrays=tuple(arrays),
        grid=(batch, -(-dim // 128), 1),
        block=128,
        check="VERIFIED" if skipped else check,
        spec=None if skipped else "conv1d_update_circular.spec" if circular else "conv1d_update.spec",
        dims={} if skipped else dims,
        cta=(b, by, 0),
    )


_CONV_UPDATES = (
    # Mamba2 decode: width 4, state 3, one token: the _sl1 fast path.
    conv1d_update("conv1d_update_sl1_bf16", 2, 256, 1, 4, 3, cta=(1, 1)),
    conv1d_update("conv1d_update_sl1_slots_f16", 3, 200, 1, 4, 3, cta=(2, 1), slots=(4, 0, 2), dtype="f16",
                  note=" (channels 128..200: 72 of 128 threads)"),
    conv1d_update("conv1d_update_sl1_pad_slot", 3, 200, 1, 4, 3, cta=(1, 0), slots=(4, -1, 2),
                  note=" (padded entry: nothing written)"),
    # Volta gap (UNKNOWN, true verdict ACCEPT): the general kernel's silu calls the accurate expf
    # (:1219), range-reduced (`fma.rm.f32 %r54, %r51, 0f437C0000, 0f4B400001; shl.b32 %r59, %r54, 23;
    # ex2.approx.ftz.f32 %r60, %r58; fma.rn.f32 %r61, %r60, %r59, 1.0`, causalConv1d.ptx). Its output
    # reads exp((r c1 + r c2 - n) 8388608 / 12102203) exp(n log 2) with n = min(max(r c3 + 0.5, 0), 1)
    # 252 + ..., the rounding of fma.rm dropped; of the conv sum r the canonicalizer neither proves
    # nor refutes it ("not proved equivalent and not refuted"), though it proves expf of a bare input
    # (state_passing_f16_3chunks). The no-silu twins check the same paths.
    conv1d_update("conv1d_update_mtp_bf16", 2, 128, 3, 4, 6, cta=(1, 0), check="UNKNOWN",
                  note=" (3 draft tokens, state 6 shifted by 3)"),
    conv1d_update("conv1d_update_mtp_bf16_nosilu", 2, 128, 3, 4, 6, cta=(1, 0), silu=False,
                  note=" (3 draft tokens, state 6 shifted by 3)"),
    conv1d_update("conv1d_update_long_f32", 1, 130, 5, 3, 3, cta=(0, 1), dtype="f32", silu=False,
                  note=" (5 tokens > state 3, no silu, 2 channels)"),
    conv1d_update("conv1d_update_w2_nobias_bf16", 2, 64, 2, 2, 4, cta=(0, 0), bias=False, silu=False,
                  note=" (width 2, no bias)"),
    conv1d_update("conv1d_update_circular_bf16", 2, 128, 2, 4, 5, cta=(1, 0), seqlens=(3, 9), silu=False,
                  note=" (ring wraps: writes at 4, 0)"),
    conv1d_update("conv1d_update_circular_slots_f16", 2, 128, 3, 3, 4, cta=(0, 0), seqlens=(6, 1),
                  slots=(1, 0), dtype="f16", silu=False),
    conv1d_update("conv1d_update_circular_wrap_f32", 1, 64, 6, 2, 4, cta=(0, 0), seqlens=(2,), dtype="f32",
                  silu=False, note=" (6 tokens around a ring of 4: positions rewritten)"),
)
CASES += _CONV_UPDATES + (negative(_CONV_UPDATES[0], {"SLOT": 0}, "state of slot 0"),
                          negative(_CONV_UPDATES[7], {"P0": 0}, "window from ring position 0"),
                          negative(_CONV_UPDATES[5], {"BIAS": 0}, "no bias"))


def conv1d_fwd(name, lens, dim, width, cta, varlen=False, states=True, init=None, slots=None, silu=True,
               pad=-1, dtype="f32", check="ACCEPT", note=""):
    """`causalConv1dFwd(x, weight, bias, conv_states, query_start_loc, cache_indices, has_initial_state,
    silu, pad, out)` (causalConv1dOp.cpp:201) with a separate `out` of x's layout, on the channel-major
    kernel (token stride 1, :311): `causal_conv1d_fwd_launch<128, 4, W>` (causalConv1d.cu:453), grid
    (batch, ceil(dim / 4)), block 128, a warp per channel, chunks of 32 x kNElts x 4 tokens. Padded:
    x [B, D, L]; `varlen`: x [D, total] (one row of query_start_loc offsets, strides from x.stride(1)).
    conv_states [S, D, W - 1]; `init` has_initial_state per sequence; `slots` cache_indices."""
    b, by = cta
    batch = len(lens)
    cu = [0]
    for n in lens:
        cu.append(cu[-1] + n)
    if varlen:
        nb, ll, xb, s0 = 1, cu[-1], 0, cu[b]
        strides = {"x_batch_stride": 1, "x_c_stride": ll, "x_l_stride": 1,
                   "out_batch_stride": 1, "out_c_stride": ll, "out_l_stride": 1}
    else:
        assert len(set(lens)) == 1
        nb, ll, xb, s0 = batch, lens[0], b, 0
        strides = {"x_batch_stride": dim * ll, "x_c_stride": ll, "x_l_stride": 1,
                   "out_batch_stride": dim * ll, "out_c_stride": ll, "out_l_stride": 1}
    n_slots = max(slots) + 1 if slots else batch
    slot = slots[b] if slots else b
    c0, c1 = 4 * by, min(dim, 4 * by + 4)
    pointers = {"x_ptr": "x", "weight_ptr": "w", "bias_ptr": "bias", "out_ptr": "out"}
    if states:
        pointers["conv_states_ptr"] = "state"
    if varlen:
        pointers["query_start_loc_ptr"] = "qsl"
    if init:
        pointers["has_initial_state_ptr"] = "init"
    if slots:
        pointers["cache_indices_ptr"] = "slots"
    values = {"batch": batch, "dim": dim, "seqlen": ll, "width": width, "pad_slot_id": pad,
              "silu_activation": int(silu), "weight_c_stride": width, "weight_width_stride": 1, **strides,
              "conv_states_batch_stride": dim * (width - 1), "conv_states_c_stride": width - 1,
              "conv_states_l_stride": 1}
    arrays = [Array("w", "in", dtype, (dim, width)), Array("bias", "in", dtype, (dim,))]
    if varlen:
        arrays.append(Array("qsl", "index", "i32", (batch + 1,), contents=tuple(cu)))
    if init:
        # Volta gap: an index array's `contents` are read only at 4 bytes (interp.rs:2748); a u8
        # index array's element i is i, silently, and a byte of an i32 word is "unsupported
        # reinterpretation". has_initial_state (bool) so reads its sequence index: only init[b] ==
        # (b != 0) states what the run sees.
        assert bool(init[b]) == (b != 0), "has_initial_state[b] reads as b"
        arrays.append(Array("init", "index", "u8", (batch,), contents=tuple(int(v) for v in init)))
    if slots:
        arrays.append(Array("slots", "index", "i32", (batch,), contents=tuple(slots)))
    arrays += [Array("x", "in", dtype, (nb, dim, ll)), Array("out", "out", dtype, (nb, dim, ll)),
               Array("state", "inout", dtype, (n_slots, dim, width - 1))]
    skipped = slots is not None and slot == pad
    return Case(
        name=name,
        description=f"causal_conv1d_fwd_kernel<{dtype}, 128 threads, 4 passes, width {width}>, "
                    f"{'varlen ' if varlen else ''}lengths {lens} x dim {dim}"
                    f"{', conv states' if states else ''}{', initial ' + str(init) if init else ''}"
                    f"{', slots ' + str(slots) if slots else ''}{'' if silu else ', no silu'}, block {cta} = "
                    f"channels [{c0}, {c1}){note}",
        source=f"{CONV}:158 (causal_conv1d_fwd_kernel), host causal_conv1d_fwd_launch :453 from "
               f"causalConv1dOp.cpp:201",
        unit=CONV,
        symbol=f"24causal_conv1d_fwd_kernelINS2_31Causal_conv1d_fwd_kernel_traitsILi128ELi4ELi{width}E"
               f"{CONV_MANGLED[dtype]}EELb{int(bool(slots))}ELb{int(silu)}EE",
        args=(conv_params(values, pointers),),
        arrays=tuple(arrays),
        grid=(batch, -(-dim // 4), 1),
        block=128,
        check="VERIFIED" if skipped else check,
        spec=None if skipped else "conv1d_fwd.spec",
        dims={} if skipped else {
            "NB": nb, "D": dim, "LL": ll, "W": width, "WM1": width - 1, "NS": n_slots, "BI": b, "XB": xb,
            "S0": s0, "L": lens[b], "SLOT": slot, "C0": c0, "C1": c1, "SILU": int(silu),
            "INIT": int(bool(init and init[b])), "STATES": int(states)},
        cta=(b, by, 0),
    )


_CONV_FWDS = (
    conv1d_fwd("conv1d_fwd_f32_padded", (40, 40), 8, 4, cta=(1, 1)),
    conv1d_fwd("conv1d_fwd_f32_varlen_init", (5, 23, 2), 6, 4, cta=(1, 1), varlen=True, init=(0, 1, 1),
               note=" (offset 5: scalar loads, channels 4..6: 2 of 4 warps)"),
    conv1d_fwd("conv1d_fwd_f32_varlen_short", (2, 23, 5), 6, 4, cta=(0, 0), varlen=True, init=(0, 1, 1),
               note=" (2 tokens < width - 1: state keeps a zero)"),
    conv1d_fwd("conv1d_fwd_f32_varlen_short_init", (5, 2, 9), 4, 4, cta=(1, 0), varlen=True, init=(0, 1, 0),
               note=" (2 tokens: state keeps an initial value)"),
    conv1d_fwd("conv1d_fwd_f32_two_chunks", (530,), 4, 3, cta=(0, 0), silu=False,
               note=" (530 tokens: chunk 512 + 18, carry across chunks)"),
    conv1d_fwd("conv1d_fwd_f32_slots_w2", (7, 3), 5, 2, cta=(0, 1), varlen=True, init=(0, 1), slots=(3, 1)),
    conv1d_fwd("conv1d_fwd_f32_slots_init_w3", (7, 3), 5, 3, cta=(1, 1), varlen=True, init=(0, 1), slots=(3, 1),
               note=" (3 tokens from offset 7)"),
    conv1d_fwd("conv1d_fwd_f32_pad_slot", (7, 3), 5, 2, cta=(1, 0), varlen=True, slots=(3, -1),
               note=" (padded entry: nothing written)"),
    conv1d_fwd("conv1d_fwd_f32_empty_seq", (0, 4), 4, 4, cta=(0, 0), varlen=True, init=(0, 1),
               note=" (empty sequence: state zeroed)"),
    conv1d_fwd("conv1d_fwd_f32_empty_seq_init", (4, 0), 4, 4, cta=(1, 0), varlen=True, init=(0, 1),
               note=" (empty sequence with an initial state: nothing written)"),
)
# Volta gap (UNKNOWN, true verdict unknown): the 16-bit kernels exchange tail words as u32 pairs
# (:290-:296), and lane 0's choice between its carry word, the constant 0 of `carry_vals = {0}`,
# and the shuffled pair (`selp.b32 %r1028, %r1021, %r446, %p113`, causalConv1d.ptx:81720) stops
# thread 0: "value kind mismatch (packed pair selected against a scalar word)", although the
# predicate (lane_id == 0) is concrete.
CASES += _CONV_FWDS + (negative(_CONV_FWDS[1], {"INIT": 0}, "no initial state"),
    conv1d_fwd("conv1d_fwd_bf16_nosilu", (70,), 4, 4, cta=(0, 0), silu=False, dtype="bf16", check="UNKNOWN"),
    conv1d_fwd("conv1d_fwd_f16_silu", (70,), 4, 4, cta=(0, 0), dtype="f16", check="UNKNOWN"),
    conv1d_fwd("conv1d_fwd_f16_nosilu_varlen", (3, 70), 4, 3, cta=(1, 0), varlen=True, init=(0, 1), silu=False,
               dtype="f16", check="UNKNOWN"),)


# ===== Mamba2 MTP SSM cache update (mamba2MTPSSMCache/) =====

MTP_SSM = KERNELS + "mamba2MTPSSMCache/mamba2MTPSSMCacheVec{}.cu"
MTP_TYPES = {"f32": "ffffE", "bf16": "13__nv_bfloat16S3_S3_S3_E"}


def mamba2_mtp(name, batch, steps, heads, head_dim, groups, cta, slots=None, inter_slots=None, has_d=True,
               has_z=True, bias=True, update=True, n=128, dtype="f32", check="ACCEPT", note=""):
    """`mamba2_mtp_ssm_cache_update(ssm, x, dt, A, B, C, out, intermediate, D, z, dt_bias, softplus off,
    ssm_batch_indices, intermediate_indices, no parent tokens, steps, pad -1, !update)`
    (mamba2MTPSSMCacheOp.cpp:46): dt [B, T, H] broadcast over head_dim (strides (1, 0), :87), A, D and
    dt_bias per head; `invokeMamba2MTPSSMCacheUpdate` (mamba2MTPSSMCache.cu:40): VEC n / 32, grid
    (head_dim / 8, heads, batch), block 128, two head dims per warp; strides from
    launchMamba2MTPSSMCacheKernel (mamba2MTPSSMCacheKernel.cuh:597). Block `cta` = (x, head, batch)."""
    vec = n // 32
    bx, hi, bi = cta
    n_slots = max(slots) + 1 if slots else batch
    n_inter = max(inter_slots) + 1 if inter_slots else n_slots
    slot = slots[bi] if slots else bi
    islot = inter_slots[bi] if inter_slots else slot
    arrays = [Array("x", "in", dtype, (batch, steps, heads, head_dim)), Array("dt", "in", dtype, (batch, steps, heads)),
              Array("A", "in", dtype, (heads,)), Array("Bm", "in", dtype, (batch, steps, groups, n)),
              Array("Cm", "in", dtype, (batch, steps, groups, n)), Array("Dv", "in", dtype, (heads,)),
              Array("z", "in", dtype, (batch, steps, heads, head_dim)), Array("dt_bias", "in", dtype, (heads,))]
    if slots:
        arrays.append(Array("slots", "index", "i32", (batch,), contents=tuple(slots)))
    if inter_slots:
        arrays.append(Array("islots", "index", "i32", (batch,), contents=tuple(inter_slots)))
    arrays += [Array("state", "inout", dtype, (n_slots, heads, head_dim, n)),
               Array("inter", "out", dtype, (n_inter, steps, heads, head_dim, n)),
               Array("out", "out", dtype, (batch, steps, heads, head_dim))]
    flags = f"ILi{vec}ELb{int(has_d)}ELb{int(has_z)}ELb{int(bias)}ELb0ELb0E{MTP_TYPES[dtype]}"
    return Case(
        name=name,
        description=f"mamba2MTPSSMCacheKernel<VEC {vec}, {dtype}{', D' if has_d else ''}{', z' if has_z else ''}"
                    f"{', dt_bias' if bias else ''}>, batch {batch} x {steps} steps x {heads} heads x {head_dim} x "
                    f"ssm {n}, {groups} groups{', slots ' + str(slots) if slots else ''}"
                    f"{', intermediate slots ' + str(inter_slots) if inter_slots else ''}"
                    f"{'' if update else ', state update disabled'}, block {cta}{note}",
        source=f"{KERNELS}mamba2MTPSSMCache/mamba2MTPSSMCacheKernel.cuh:290, host invokeMamba2MTPSSMCacheUpdate "
               f"mamba2MTPSSMCache.cu:40 from mamba2MTPSSMCacheOp.cpp:46",
        unit=MTP_SSM.format(vec),
        symbol=("23mamba2MTPSSMCacheKernel", flags),
        args=(Ptr("state"), Ptr("x"), Ptr("dt"), Ptr("A"), Ptr("Bm"), Ptr("Cm"), Ptr("out"), Ptr("inter"),
              Ptr("Dv") if has_d else NULL, Ptr("z") if has_z else NULL, Ptr("dt_bias") if bias else NULL,
              Ptr("slots") if slots else NULL, Ptr("islots") if inter_slots else NULL, NULL,
              Int(steps, "cache_steps"), Int(int(bool(slots)), "has_ssm_batch_indices"),
              Int(int(bool(inter_slots)), "has_intermediate_ssm_batch_indices"), Int(-1, "pad_slot_id"),
              Int(int(not update), "disable_state_update"), Int(heads, "nheads"), Int(head_dim, "head_dim"),
              Int(n, "ssm_dim"), Int(heads // groups, "heads_groups_ratio"),
              Int(heads * head_dim * n, "ssm_batch_stride"), Int(heads * head_dim * n, "stride_nheads_hdim_ssm_dim"),
              Int(head_dim * n, "stride_hdim_ssm_dim"), Int(steps * heads * head_dim, "stride_cache_nheads_hdim"),
              Int(heads * head_dim, "stride_nheads_hdim"), Int(steps * groups * n, "stride_cache_ngroups_ssm_dim"),
              Int(groups * n, "stride_ngroups_ssm_dim")),
        arrays=tuple(arrays),
        grid=(head_dim // 8, heads, batch),
        block=128,
        check=check,
        spec="mamba2_mtp.spec",
        dims={"NS": n_slots, "NI": n_inter, "B": batch, "T": steps, "H": heads, "HD": head_dim, "N": n, "G": groups,
              "RATIO": heads // groups, "GI": hi // (heads // groups), "SLOT": slot, "ISLOT": islot, "BI": bi, "HI": hi, "D0": 8 * bx,
              "D1": 8 * bx + 8, "BIAS": int(bias), "HASD": int(has_d), "HASZ": int(has_z), "UPDATE": int(update),
              "TM1": steps - 1},
        cta=(bx, hi, bi),
    )


_MTPS = (
    mamba2_mtp("mamba2_mtp_f32_3steps", 2, 3, 2, 16, 1, cta=(1, 1, 1)),
    mamba2_mtp("mamba2_mtp_f32_slots", 3, 2, 4, 8, 2, cta=(0, 3, 2), slots=(5, 0, 3), inter_slots=(1, 2, 0),
               note=" (head 3 in group 1)"),
    mamba2_mtp("mamba2_mtp_f32_plain_no_update", 2, 2, 2, 8, 2, cta=(0, 0, 1), has_d=False, has_z=False, bias=False,
               update=False),
    mamba2_mtp("mamba2_mtp_f32_1step_vec8", 1, 1, 1, 8, 1, cta=(0, 0, 0), n=256),
    mamba2_mtp("mamba2_mtp_f32_2steps_vec16", 1, 2, 1, 8, 1, cta=(0, 0, 0), n=512, has_z=False),
    mamba2_mtp("mamba2_mtp_bf16_2steps", 2, 2, 2, 16, 1, cta=(1, 0, 1), dtype="bf16"),
)
CASES += _MTPS + (negative(_MTPS[0], {"HASD": 0}, "no D skip term"),
                  negative(_MTPS[1], {"ISLOT": 1}, "intermediate slot 1"))


# ===== Mamba2 chunked scan: state passing (selectiveScan/statepassing.h) =====

SSD = KERNELS + "selectiveScan/instantiation/"


def state_passing(name, lens, heads, n, p, cta, q=128, slots=None, dtype="f16", check="ACCEPT", note=""):
    """`state_passing<<<bds[2], tds[2]>>>(B, L, H, P, G, N, Os, Fs, St, dA, removePadding, lastTokenIds,
    slotMapping)` (selectiveScan.cu:434) with packed tokens (remove_padding): getStatePassingKernel
    (statepassing.h:226) tile 512, grid (H N P / 512, 1, B), block (32, 4). Sequence b's tokens end at
    lastTokenIds[b]; its chunks start at ceil(start / Q) + b - 1 (:93). Block `cta` = (x, b)."""
    assert n * p == 512
    bx, b = cta
    ends = [sum(lens[:i + 1]) for i in range(len(lens))]
    start = ends[b - 1] if b else 0
    cs = -(-start // q) + b - 1 if b else 0
    c = -(-lens[b] // q)
    ct = max((-(-(ends[i - 1] if i else 0) // q) + i - 1 if i else 0) + -(-lens[i] // q) for i in range(len(lens)))
    n_slots = max(slots) + 1 if slots else len(lens)
    t = {"f16": "6__half", "bf16": "13__nv_bfloat16"}[dtype]
    return Case(
        name=name,
        description=f"state_passing_kernel<Q {q}, 512, 4, {dtype}>, packed lengths {lens}, {heads} heads x N {n} x "
                    f"P {p}{', slots ' + str(slots) if slots else ''}, block {cta}: chunks [{cs}, {cs + c}){note}",
        source=f"{KERNELS}selectiveScan/statepassing.h:48 (state_passing_kernel), host getStatePassingKernel "
               f":226, launch invokeChunkScan selectiveScan.cu:434",
        unit=SSD + f"statepassing_{'fp16' if dtype == 'f16' else 'bf16'}.cu",
        symbol=f"20state_passing_kernelILi{q}ELi512ELi4E{t}E",
        args=(Int(len(lens), "B"), Int(max(lens), "L"), Int(heads, "H"), Int(p, "P"), Int(1, "G"), Int(n, "N"),
              Ptr("Os"), Ptr("Fs"), Ptr("St"), Ptr("dA"), Int(1, "removePadding"), Ptr("ends"),
              Ptr("slots") if slots else NULL),
        arrays=(Array("ends", "index", "i32", (len(lens),), contents=tuple(ends)),
                *((Array("slots", "index", "i32", (len(lens),), contents=tuple(slots)),) if slots else ()),
                Array("St", "in", "f32", (ct, heads, n * p)), Array("dA", "in", "f32", (ct, heads, q)),
                Array("Os", "out", dtype, (ct, heads, n * p)), Array("Fs", "out", dtype, (n_slots, heads, n * p))),
        grid=(heads * n * p // 512, 1, len(lens)),
        block=(32, 4, 1),
        check=check,
        spec="state_passing.spec",
        dims={"CT": ct, "H": heads, "E": n * p, "Q": q, "QM1": q - 1, "NS": n_slots, "CS": cs, "C": c, "HI": bx,
              "SLOT": slots[b] if slots else b},
        cta=(bx, 0, b),
    )


_STATE_PASSINGS = (
    state_passing("state_passing_f16_1chunk", (100, 60), 2, 16, 32, cta=(1, 1), slots=(3, 0)),
    # The chunk scale is the accurate expf(dA) (:166, range-reduced through `fma.rm.f32`, `shl.b32
    # 23` and `ex2.approx.ftz.f32`): of an input element Volta proves it (contrast conv1d_update_mtp).
    state_passing("state_passing_f16_3chunks", (300, 60), 2, 16, 32, cta=(0, 0),
                  note=" (3 chunks, the last partial)"),
    state_passing("state_passing_bf16_q256_1chunk", (40, 200, 7), 1, 32, 16, cta=(0, 2), q=256, dtype="bf16"),
)
CASES += _STATE_PASSINGS + (negative(_STATE_PASSINGS[0], {"SLOT": 3}, "slot of sequence 0"),)


# ===== CUDA-core GEMM for small M (cudaCoreGemm/cudaCoreGemm.cu) =====

CORE_GEMM = KERNELS + "cudaCoreGemm/cudaCoreGemm.cu"
CORE_MANGLED = {("f16", "f16"): "6__halfS4_", ("f16", "f32"): "6__halff", ("bf16", "bf16"): "13__nv_bfloat16S4_",
                ("bf16", "f32"): "13__nv_bfloat16f", ("f32", "f32"): "ff", ("e4m3", "bf16"): "13__nv_fp8_e4m313__nv_bfloat16",
                ("e4m3", "f16"): "13__nv_fp8_e4m36__half", ("e4m3", "f32"): "13__nv_fp8_e4m3f"}


def cuda_core_gemm(name, m, n, k, cta, scaled=False, din="bf16", dout="bf16", check="ACCEPT", note=""):
    """`cudaCoreGemmDispatcher(Params)` (cudaCoreGemm.cu:228): n even, k a multiple of 16 bytes'
    elements, TILE_M = m (1..16), TILE_N 2, block 128, grid (n / 2, m / m = 1) (:151);
    cudaCoreGemmV2 when scale_a and scale_b are given (the torch flow), else cudaCoreGemm with alpha."""
    kernel = "14cudaCoreGemmV2" if scaled else "12cudaCoreGemm"
    return Case(
        name=name,
        description=f"{kernel[2:]}<{din} -> {dout}, TILE_M {m}, TILE_N 2, 128>, {m} x {n} x {k}, block {cta} = columns "
                    f"[{2 * cta}, {2 * cta + 2}){note}",
        source=f"{CORE_GEMM}:{134 if scaled else 144}, host cudaCoreGemmKernel :151 via cudaCoreGemmDispatcher :228",
        unit=CORE_GEMM,
        symbol=f"{kernel}I{CORE_MANGLED[(din, dout)]}Li{m}ELi2ELi128EE",
        args=((Ptr("act"), Ptr("w"), Ptr("sa"), Ptr("sb")) if scaled else (Ptr("act"), Ptr("w"), Float(1.0, "alpha")))
             + (Ptr("out"), Int(m, "m"), Int(n, "n"), Int(k, "k")),
        arrays=(Array("act", "in", din, (m, k)), Array("w", "in", din, (n, k)), Array("sa", "in", "f32", (1,)),
                Array("sb", "in", "f32", (1,)), Array("out", "out", dout, (m, n))),
        grid=(n // 2, 1, 1),
        block=128,
        check=check,
        spec="cuda_core_gemm.spec",
        dims={"M": m, "N": n, "K": k, "N0": 2 * cta, "N1": 2 * cta + 2, "SCALED": int(scaled), "ONE": 1},
        cta=(cta, 0, 0),
    )


# Volta gap (UNKNOWN, true verdict unknown): cutlass's bf16 -> f32 NumericArrayConverter widens a
# loaded pair by bits (`ld.global.nc.v4.b32 {%r13, ...}; shl.b32 %r17, %r13, 16; and.b32 %r18,
# %r13, -65536`, cudaCoreGemm.ptx) and feeds the words to fma.rn.f32: "value kind mismatch (packed
# pair used as a scalar)" on thread 0. f16, f32 and fp8 inputs convert by cvt and are decided.
_CORE_GEMMS = (
    cuda_core_gemm("cuda_core_gemm_bf16_m1", 1, 64, 4096, cta=31, check="UNKNOWN"),
    cuda_core_gemm("cuda_core_gemm_bf16_f32_m3_scaled", 3, 10, 1032, cta=4, scaled=True, dout="f32", check="UNKNOWN",
                   note=" (k 1032: the last k-tile 8 of 128 threads)"),
    cuda_core_gemm("cuda_core_gemm_f16_f32_m3_scaled", 3, 10, 1032, cta=4, scaled=True, din="f16", dout="f32",
                   note=" (k 1032: the last k-tile 8 of 128 threads)"),
    cuda_core_gemm("cuda_core_gemm_f16_m16", 16, 4, 256, cta=1, din="f16", dout="f16", note=" (k 256 < one k-tile)"),
    cuda_core_gemm("cuda_core_gemm_f32_m5", 5, 6, 132, cta=2, din="f32", dout="f32"),
    cuda_core_gemm("cuda_core_gemm_fp8_bf16_m2_scaled", 2, 8, 2048, cta=3, scaled=True, din="e4m3", dout="bf16"),
)
CASES += _CORE_GEMMS + (negative(_CORE_GEMMS[2], {"SCALED": 0}, "unscaled"),
                        negative(_CORE_GEMMS[5], {"N0": 4, "N1": 6}, "columns 4..6"))


# ===== Group RMSNorm (groupRmsNormKernels/groupRmsNormKernels.cu) =====

GROUP_RMS = KERNELS + "groupRmsNormKernels/groupRmsNormKernels.cu"


def group_rms_fields(n):
    """GroupRMSParams<n> (groupRmsNormKernels.h:32) in declaration order: (name, size, count)."""
    return [("inputs", 8, n), ("outputs", 8, n), ("weights", 8, n), ("input_last_dims", 4, n),
            ("input_strides", 4, n), ("output_strides", 4, n), ("warp_input_idx", 4, 32),
            ("warp_prefix_sum", 4, n + 1), ("batch_size", 4, 1), ("num_inputs", 4, 1), ("eps", 4, 1),
            ("weight_bias", 4, 1), ("enable_weights", 1, 1), ("dtype", 4, 1), ("stream", 8, 1)]


def _f32_bits(v):
    import struct
    return struct.unpack("<I", struct.pack("<f", v))[0]


def group_rms_layout(n):
    offsets, at = {}, 0
    for name, size, count in group_rms_fields(n):
        at = -(-at // size) * size
        offsets[name] = (at, size, count)
        at += size * count
    return offsets, -(-at // 8) * 8


assert group_rms_layout(1)[1] == 208 and group_rms_layout(2)[1] == 248  # `.b8 ..._param_0[208]` / `[248]`


def group_rms_norm(name, batch, dims, cta, weights=True, weight_bias=0.0, dtype="bf16", check="ACCEPT", note=""):
    """`GroupRMSNormBaseKernelLauncher<n>` (groupRmsNormKernels.cu:647; the heuristic's choice for one input,
    :806) -> `GroupRMSNormBaseKernel<DType, n, weights>(params)` (:600): rounded dims to 32 x kPacked,
    warps = min(32, total / (32 kPacked)), rounds = ceil(needed / warps), warps per input round(rounded_i
    x warps / total) (at least 1), grid batch, block (32, warps). Rows contiguous; eps f32(1e-6)."""
    n = len(dims)
    packed = 16 // (4 if dtype == "f32" else 2)
    chunk = 32 * packed
    rounded = [-(-d // chunk) * chunk for d in dims]
    needed = sum(rounded) // chunk
    warps = min(32, needed)
    rounds = -(-needed // warps)
    per_token = warps / sum(rounded)
    prefix, idx = [0], []
    for i, r in enumerate(rounded):
        k = max(1, int(round(r * per_token)))
        idx += [i] * k
        prefix.append(prefix[-1] + k)
    idx = (idx + [0] * 32)[:32]
    offsets, _ = group_rms_layout(n)
    names = ("a", "b") if n == 2 else ("",)
    values = {"input_last_dims": dims, "input_strides": dims, "output_strides": dims, "warp_input_idx": idx,
              "warp_prefix_sum": prefix, "batch_size": [batch], "num_inputs": [n], "enable_weights": [int(weights)],
              "dtype": [{"f32": 0, "f16": 1, "bf16": 7}[dtype]]}
    floats = {"eps": EPS, "weight_bias": weight_bias}
    pointers = {"inputs": [f"x{s}" for s in names], "outputs": [f"out{s}" for s in names],
                "weights": [f"w{s}" for s in names] if weights else None}
    fields = []
    for fname, (off, size, count) in offsets.items():
        for k in range(count):
            at = off + size * k
            if fname in pointers:
                ptrs = pointers[fname]
                fields.append({"offset": at, "ptr": ptrs[k]} if ptrs else {"offset": at, "u64": 0})
            elif fname in floats:
                fields.append({"offset": at, "u32": _f32_bits(floats[fname])})
            else:
                fields.append({"offset": at, {1: "u8", 4: "u32", 8: "u64"}[size]: values.get(fname, [0] * count)[k]})
    arrays = []
    for s, d in zip(names, dims):
        arrays += [Array(f"x{s}", "in", dtype, (batch, d)), Array(f"w{s}", "in", dtype, (d,)),
                   Array(f"out{s}", "out", dtype, (batch, d))]
    t = {"f32": "f", "f16": "6__half", "bf16": "13__nv_bfloat16"}[dtype]
    spec_dims = {"B": batch, "BI": cta, "WEIGHTS": int(weights), "WB": int(weight_bias)}
    spec_dims.update({"D": dims[0]} if n == 1 else {"DA": dims[0], "DB": dims[1]})
    return Case(
        name=name,
        description=f"GroupRMSNormBaseKernel<{dtype}, float4, {n}, {'weights' if weights else 'no weights'}, "
                    f"{rounds} round(s)>, batch {batch}, dims {dims}, {warps} warps (input of warp: {idx[:warps]}), "
                    f"weight bias {weight_bias}, block {cta}{note}",
        source=f"{GROUP_RMS}:91 (GroupRMSNormBaseKernel), host GroupRMSNormBaseKernel :600 (launch :619)",
        unit=GROUP_RMS,
        symbol=f"22GroupRMSNormBaseKernelI{t}6float4Li{n}ELb{int(weights)}ELb{int(rounds > 1)}EE",
        args=(Struct(tuple(fields), "params"), Int(rounds, "rounds")),
        arrays=tuple(arrays),
        grid=(batch, 1, 1),
        block=(32, warps, 1),
        check=check,
        spec=f"group_rms_norm{n}.spec",
        dims=spec_dims,
        cta=(cta, 0, 0),
    )


# REJECT, a memory conflict in every launch of more than one warp (a lead: noticed while reading
# the kernel to write the spec, so uncounted): warp 0 clears smem_warp_sum_sqs[] and
# smem_input_mask[] (:105-:109) while each other warp's lane 0 stores its own slot (:176, :184),
# with no barrier between: "WriteWrite, Shared addr 260: t1 line 4051 `st.shared.b32 [%r4], 0` /
# t32 line 4158 `st.shared.b32 [%r54], %r9`" (groupRmsNormKernels.ptx) and likewise addr 132 (33
# against input_idx). If warp 0 lags, a warp's partial sum of squares is zeroed and its input's
# RMS is wrong. The outputs match the spec in Volta's schedule (init first). One warp: ACCEPT.
_GROUP_RMS = (
    group_rms_norm("group_rms_norm_bf16_128", 2, (128,), cta=1, note=" (one warp)"),
    group_rms_norm("group_rms_norm_f16_256_noweights", 1, (256,), cta=0, dtype="f16", weights=False,
                   note=" (one warp)"),
    group_rms_norm("group_rms_norm_bf16_2048", 2, (2048,), cta=1, weight_bias=1.0, check="REJECT"),
    group_rms_norm("group_rms_norm_f32_4224_rounds", 1, (4224,), cta=0, dtype="f32", weights=False, check="REJECT",
                   note=" (33 warp chunks on 32 warps: 2 rounds)"),
    group_rms_norm("group_rms_norm_bf16_qk_2in", 3, (1536, 512), cta=2, check="REJECT", note=" (q_a and kv_a norms)"),
    group_rms_norm("group_rms_norm_f32_2in_odd", 1, (96, 1056), cta=0, dtype="f32", check="REJECT",
                   note=" (dims not multiples of a warp chunk)"),
)
CASES += _GROUP_RMS + (negative(_GROUP_RMS[0], {"WEIGHTS": 0}, "no weights"),)


# ===== Llama 4 min-latency router GEMM (llama4MinLatencyKernels/llama4Bf16Bf16Gemm.cu) =====

LLAMA4_BF16 = KERNELS + "llama4MinLatencyKernels/llama4Bf16Bf16Gemm.cu"


def llama4_bf16_gemm(name, tokens, cta, check="ACCEPT", note=""):
    """`llama4_bf16_bf16_gemm_launcher(num_tokens, A, B, C)` (llama4Bf16Bf16Gemm.cu:115): grid 128 x tokens
    (block = token x 128 + expert), block 256, K 5120 (llama4Utils.cuh:32), bf16 out [tokens, 128]."""
    t, e = divmod(cta, 128)
    return Case(
        name=name,
        description=f"llama4_bf16_bf16_gemm_kernel, {tokens} tokens x 128 experts x 5120, block {cta} = "
                    f"(token {t}, expert {e}){note}",
        source=f"{LLAMA4_BF16}:31 (llama4_bf16_bf16_gemm_kernel), host llama4_bf16_bf16_gemm_launcher :115",
        unit=LLAMA4_BF16,
        symbol="28llama4_bf16_bf16_gemm_kernel",
        args=(Int(tokens, "num_tokens"), Ptr("a"), Ptr("w"), Ptr("out")),
        arrays=(Array("a", "in", "bf16", (tokens, 5120)), Array("w", "in", "bf16", (128, 5120)),
                Array("out", "out", "bf16", (tokens, 128))),
        grid=(128 * tokens, 1, 1),
        block=256,
        check=check,
        spec="router_gemm.spec",
        dims={"T": tokens, "E": 128, "K": 5120, "N0": e, "N1": e + 1, "M0": t, "M1": t + 1},
        cta=(cta, 0, 0),
    )


_LLAMA4 = (
    llama4_bf16_gemm("llama4_bf16_gemm_3tok", 3, cta=2 * 128 + 127, note=" (last block)"),
    llama4_bf16_gemm("llama4_bf16_gemm_1tok", 1, cta=5),
)
CASES += _LLAMA4 + (negative(_LLAMA4[0], {"M0": 1, "M1": 2}, "token 1"),)


# ===== MTP speculative decoding (speculativeDecoding/mtpKernels.cu) =====

MTP = KERNELS + "speculativeDecoding/mtpKernels.cu"
PAST_HIDDEN, PAST_TOKENS = 0x40000000, 0x50000000  # placed so the pointer arrays can name rows


def mtp_prepare_drafter(name, modules, ctx_lens, n_gen, hidden, cta, past_rows=None, accepted=None, dtype="bf16",
                        check="ACCEPT", note=""):
    """`invokeMTPPrepareDrafterInputs<T>(params)` (mtpKernels.cu:161): grid batchSize (context requests
    first), block 512, float4 copies (hidden * sizeof(T) % 16 == 0). seqLens: a context request's
    prompt length, a generation request's numMTPModules + 1 (:73). mtpPastHiddenStatesPtrs[b] /
    mtpPastTokensPtrs[b] point at row past_rows[b] of one [R, M, H] / [R, M] pool."""
    batch = len(ctx_lens) + n_gen
    lens = list(ctx_lens) + [modules + 1] * n_gen
    past_rows = past_rows or list(range(batch))
    accepted = accepted or [1 + b % (modules + 1) for b in range(batch)]
    rows = max(past_rows) + 1
    width = 4 if dtype == "f32" else 2
    io = sum(lens[:cta])
    ro = sum(lens[i] if i < len(ctx_lens) else modules for i in range(cta))
    n = sum(lens)
    nr = sum(ctx_lens) + n_gen * modules
    return Case(
        name=name,
        description=f"mtpPrepareDrafterInputsKernel<{dtype}>, {modules} MTP modules, context prompts {ctx_lens} + "
                    f"{n_gen} generation requests, hidden {hidden}, past rows {past_rows}, accepted counts {accepted}, "
                    f"block {cta} ({'context' if cta < len(ctx_lens) else 'generation'}){note}",
        source=f"{MTP}:67 (mtpPrepareDrafterInputsKernel), host invokeMTPPrepareDrafterInputs :161",
        unit=MTP,
        symbol=f"29mtpPrepareDrafterInputsKernelI{T_MANGLED.get(dtype, 'f')}E",
        args=(Int(modules, "numMTPModules"), Int(len(ctx_lens), "numContextRequest"), Int(hidden, "hiddenSize"),
              Ptr("input_ids"), Ptr("seq_lens"), Ptr("hidden_ptrs"), Ptr("token_ptrs"), Ptr("hidden"),
              Ptr("accepted"), Ptr("num_accepted"), Ptr("ret_ids"), Ptr("ret_hidden")),
        arrays=(Array("seq_lens", "index", "i32", (batch,), contents=tuple(lens)),
                Array("num_accepted", "index", "i32", (batch,), contents=tuple(accepted)),
                i64_index("hidden_ptrs", [PAST_HIDDEN + r * modules * hidden * width for r in past_rows]),
                i64_index("token_ptrs", [PAST_TOKENS + r * modules * 4 for r in past_rows]),
                Array("input_ids", "in", "i32", (n,)), Array("accepted", "in", "i32", (batch, modules + 1)),
                Array("past_tokens", "in", "i32", (rows, modules), base=PAST_TOKENS),
                Array("hidden", "in", dtype, (n, hidden)),
                Array("past_hidden", "in", dtype, (rows, modules, hidden), base=PAST_HIDDEN),
                Array("ret_ids", "out", "i32", (nr,)), Array("ret_hidden", "out", dtype, (nr, hidden))),
        grid=(batch, 1, 1),
        block=512,
        check=check,
        spec="mtp_prepare_drafter.spec",
        dims={"N": n, "NR": nr, "B": batch, "M": modules, "M1": modules + 1, "HS": hidden, "R": rows, "BI": cta,
              "IO": io, "RO": ro, "L": lens[cta], "CTX": int(cta < len(ctx_lens)), "PR": past_rows[cta],
              "NA": accepted[cta]},
        cta=(cta, 0, 0),
    )


_MTP_PREPARE = (
    mtp_prepare_drafter("mtp_prepare_ctx_bf16", 1, (5, 3), 2, 256, cta=1, note=" (prompt of 3)"),
    mtp_prepare_drafter("mtp_prepare_gen_bf16", 3, (5,), 3, 256, cta=2, past_rows=(4, 0, 2, 1), accepted=(1, 4, 2, 3),
                        note=" (past row 2, 2 accepted)"),
    mtp_prepare_drafter("mtp_prepare_gen_f32_7168", 1, (), 2, 7168, cta=1, dtype="f32",
                        note=" (DeepSeek hidden 7168: 1792 float4 over 512 threads)"),
)
CASES += _MTP_PREPARE + (negative(_MTP_PREPARE[1], {"NA": 1}, "first accepted token"),)


# ===== Speculative decoding: move accepted draft tokens in the KV cache (kvCacheUpdateKernels.cu) =====

KV_UPDATE = KERNELS + "speculativeDecoding/kvCacheUpdateKernels.cu"
KV_POOL = 0x60000000


def kv_draft_update(name, accepted, past_lens, heads, head_dim, max_len, cta, layers=1, rewind=0, remap=None,
                    dtype="bf16", check="ACCEPT", note=""):
    """`updateLinearKVCacheDraftTokenLocation(offsets, packedIndices, pastLens, pastKeyValueList, layers,
    seqs, heads, headBytes, rewind, nullptr, remap, maxKVCacheLen)` (kvCacheUpdateKernels.cu:449):
    KVLinearBuffer(seqs, maxLen, heads x headBytes, ...) per layer (:458); the batched kernel
    (:297) with the widest MoveEltType dividing headBytes (int4 here), grid (seqs, heads, layers),
    block 128, std::array<KVLinearBuffer, 32> by value. `accepted[s]` = sequence s's accepted draft
    indices (packed); pastLens by slot; layer l's cache at KV_POOL + l x its bytes."""
    width = 2 if dtype in ("bf16", "f16") else 4
    head_bytes = head_dim * width
    assert head_bytes % 16 == 0
    elts = head_bytes // 16
    seqs = len(accepted)
    slots = max(remap) + 1 if remap else seqs
    offsets = [0]
    for a in accepted:
        offsets.append(offsets[-1] + len(a))
    packed = [i for a in accepted for i in a]
    bytes_per_seq = max_len * heads * head_bytes
    layer_bytes = slots * 2 * bytes_per_seq
    fields = []
    for l in range(32):
        base = 48 * l
        vals = (slots, max_len, bytes_per_seq, max_len, 0, max_len, 0, 2) if l < layers else (0,) * 8
        fields += [{"offset": base + 4 * k, "u32": v} for k, v in enumerate(vals)]
        fields += [{"offset": base + 32, "u8": 0}, {"offset": base + 40, "u64": KV_POOL + l * layer_bytes if l < layers else 0}]
    s, hi, li = cta
    slot = remap[s] if remap else s
    return Case(
        name=name,
        description=f"updateKVCacheDraftTokenLocationBatchedKernel<KVLinearBuffer, 32, int4>, {layers} layer(s), "
                    f"{seqs} sequences accepting {accepted}, past lengths {past_lens}, rewind {rewind}, {heads} heads "
                    f"x {head_dim} {dtype}, max length {max_len}{', slots ' + str(remap) if remap else ''}, block {cta}"
                    f"{note}{HIDDEN}",
        source=f"{KV_UPDATE}:37 (updateKVCacheDraftTokenLocationBatchedKernel), host "
               f"updateLinearKVCacheDraftTokenLocation :449 -> updateKVCacheDraftTokenLocationBatched :297",
        unit=KV_UPDATE,
        symbol="44updateKVCacheDraftTokenLocationBatchedKernelINS1_14KVLinearBufferELi32E4int4EE",
        args=(Struct(tuple(fields), "kvCacheBuffers"), Ptr("offsets"), Ptr("packed"), Ptr("past_lens"),
              Int(rewind, "rewindDraftTokenCommonCount"), NULL, Ptr("remap") if remap else NULL, NULL,
              Int(elts, "eltCountPerHead")),
        arrays=(Array("offsets", "index", "i32", (seqs + 1,), contents=tuple(offsets)),
                Array("packed", "index", "i32", (max(1, len(packed)),), contents=tuple(packed) or (0,)),
                Array("past_lens", "index", "i32", (slots,), contents=tuple(past_lens)),
                *((Array("remap", "index", "i32", (seqs,), contents=tuple(remap)),) if remap else ()),
                Array("cache", "inout", dtype, (layers, slots, 2, heads, max_len, head_dim), base=KV_POOL)),
        grid=(seqs, heads, layers),
        block=128,
        check=check,
        spec="kv_draft_update.spec",
        dims={"NL": layers, "S": slots, "TWO": 2, "H": heads, "ML": max_len, "D": head_dim, "LI": li, "SLOT": slot,
              "HI": hi, "ST": past_lens[slot] - rewind, "CNT": len(accepted[s]),
              **{f"P{j}": past_lens[slot] - rewind + (list(accepted[s]) + [0] * 4)[j] for j in range(4)}},
        cta=cta,
    )


_KV_UPDATES = (
    kv_draft_update("kv_draft_update_bf16", ((0, 2, 3), (1, 3)), (10, 7), 2, 64, 16, cta=(0, 1, 0), rewind=4,
                    note=" (accepted 0, 2, 3 of 4 drafts)"),
    kv_draft_update("kv_draft_update_remap_layer1", ((0, 2, 3), (1, 3)), (9, 6, 11), 2, 128, 16, cta=(1, 0, 1),
                    layers=2, rewind=5, remap=(2, 0), note=" (slot 0, layer 1)"),
    kv_draft_update("kv_draft_update_overlap_f32", ((1, 0, 2),), (8,), 1, 32, 12, cta=(0, 0, 0), rewind=3,
                    dtype="f32", note=" (permuted: destination 5 is source 6, 6 is 5)"),
)
CASES += tuple(hidden(c, c.check) for c in _KV_UPDATES) + (
    hidden(negative(_KV_UPDATES[0], {"ST": 7}, "one token earlier"), "REJECT"),
    # ABORT, a Volta limit, not a kernel bug: maxEltCountPerMove divides by seqDraftCount (:52) before
    # the seqDraftCount == 0 return (:54), "unsupported at pc:34: division by zero (thread t0)". PTX ISA
    # integer div (isa.txt:4212): division by zero "yields an unspecified, machine-specific value",
    # and the value is unused, so the kernel is fine. (Noticed while reading: an uncounted lead.)
    hidden(dataclasses.replace(kv_draft_update("kv_draft_update_none_accepted", ((0, 1), ()), (6, 5), 1, 64, 8,
                                               cta=(1, 0, 0), note=" (sequence 1 accepted none: writes nothing)"),
                               spec=None, dims={}), "ABORT"),)


# ===== DeepSeek-V4 KV compressor, decode (compressorKernels/compressorKernels.cu) =====

COMPRESSOR = KERNELS + "compressorKernels/compressorKernels.cu"


def paged_kv_compress(name, kv_lens, next_n, page_size, tables, cta, hd=128, check="ACCEPT", note=""):
    """`pagedKvCompressLaunch(kv_score, ape, paged_kv, paged_score, bt_kv, bt_score, out, kv_lens, cu_seq_lens,
    cu_kv_comp, batch, page_size, max_blocks, hd, CR 2, next_n, 4, 4, 4, nullptr)` (compressorKernels.cu:727):
    fp32 everywhere, VEC 4, one 32-thread warp per batch (grid (batch, 1, 1)). `tables[b]` = (kv pages,
    score pages) per logical block. cu_seq_lens = b x next_n, cu_kv_comp = the compressions before b."""
    cr = 2
    batch = len(kv_lens)
    b = cta
    sp = [k - next_n for k in kv_lens]
    ncomp = [(sp[i] + next_n) // cr - sp[i] // cr for i in range(batch)]
    cu_comp = [sum(ncomp[:i]) for i in range(batch)]
    max_blocks = max(len(t[0]) for t in tables)
    n_pages = 1 + max(max(max(kv), max(sc)) for kv, sc in tables)
    bt_kv = sum((list(kv) + [0] * (max_blocks - len(kv)) for kv, _ in tables), [])
    bt_sc = sum((list(sc) + [0] * (max_blocks - len(sc)) for _, sc in tables), [])
    dims = {"NT": batch * next_n, "SD2": 2 * hd, "SD": hd, "NP": n_pages, "PS": page_size, "NO": max(1, sum(ncomp)),
            "CR": cr, "NW": next_n, "NC": ncomp[b], "OUT": cu_comp[b]}
    for u in range(2):
        tok = sp[b] + u
        valid = u < next_n
        dims.update({f"WT{u}": b * next_n + u if valid else 0,
                     f"WK{u}": tables[b][0][tok // page_size] if valid else 0,
                     f"WQ{u}": tables[b][1][tok // page_size] if valid else 0,
                     f"WO{u}": tok % page_size if valid else 0, f"WA{u}": tok % cr if valid else 0})
    start = (sp[b] // cr) * cr
    for r in range(2):
        pos = start + r
        new = pos >= sp[b]
        dims.update({f"N{r}": int(new), f"T{r}": b * next_n + pos - sp[b] if new else 0,
                     f"K{r}": tables[b][0][pos // page_size], f"Q{r}": tables[b][1][pos // page_size],
                     f"O{r}": pos % page_size})
    return Case(
        name=name,
        description=f"pagedKvCompressKernel<{hd}, f32, f32, CR 2, 1 warp>, kv lengths {kv_lens}, next_n {next_n}, "
                    f"page size {page_size}, block tables {tables}, block {cta}: {ncomp[b]} compression(s){note}",
        source=f"{COMPRESSOR}:304 (pagedKvCompressKernel), host pagedKvCompressLaunch :727",
        unit=COMPRESSOR,
        symbol=f"21pagedKvCompressKernelILi{hd}ELi4ELi4ELi2ELi1ELb0EE",
        args=(Ptr("kvs"), Ptr("ape"), Ptr("pkv"), Ptr("psc"), Ptr("bt_kv"), Ptr("bt_sc"), Ptr("out"), Ptr("kv_lens"),
              Ptr("cu_seq"), Ptr("cu_comp"), Int(next_n, "next_n"), Int(page_size, "page_size"),
              Int(max_blocks, "max_blocks"), Int(4, "out_elem_bytes"), NULL),
        arrays=(Array("bt_kv", "index", "i32", (batch, max_blocks), contents=tuple(bt_kv)),
                Array("bt_sc", "index", "i32", (batch, max_blocks), contents=tuple(bt_sc)),
                Array("kv_lens", "index", "i32", (batch,), contents=tuple(kv_lens)),
                Array("cu_seq", "index", "i32", (batch,), contents=tuple(b2 * next_n for b2 in range(batch))),
                Array("cu_comp", "index", "i32", (batch,), contents=tuple(cu_comp)),
                Array("kvs", "in", "f32", (batch * next_n, 2 * hd)), Array("ape", "in", "f32", (cr, hd)),
                Array("pkv", "inout", "f32", (n_pages, page_size, hd)),
                Array("psc", "inout", "f32", (n_pages, page_size, hd)),
                Array("out", "out", "f32", (max(1, sum(ncomp)), hd))),
        grid=(batch, 1, 1),
        block=32,
        check=check,
        spec="paged_kv_compress_cr2.spec",
        dims=dims,
        cta=(cta, 0, 0),
    )


# Volta gap (UNKNOWN, true verdict ACCEPT expected; the graph checks pass): a compression's output
# is the online softmax of decodeSoftmaxVec (:290), nm = fmaxf(rmax, s), rescales expf(rmax - nm)
# and expf(s - nm) through the accurate expf (`fma.rm.f32; shl.b32 23; ex2.approx.ftz.f32`), which
# the canonicalizer neither proves nor refutes against the max-shifted softmax ("not proved
# equivalent and not refuted", every out element); the paged-state writes in the same runs prove.
_COMPRESS = (
    paged_kv_compress("paged_kv_compress_cr2_decode", (8, 5), 1, 4, (((3, 1), (2, 0)), ((4, 5), (6, 7))), cta=0,
                      check="UNKNOWN", note=" (old position 6 + new 7)"),
    paged_kv_compress("paged_kv_compress_cr2_decode_partial", (8, 5), 1, 4, (((3, 1), (2, 0)), ((4, 5), (6, 7))),
                      cta=1, note=" (token 4 opens a chunk: no compression)"),
    paged_kv_compress("paged_kv_compress_cr2_mtp_page_cross", (6,), 2, 2, (((1, 0, 2), (3, 4, 5)),), cta=0,
                      check="UNKNOWN", note=" (tokens 4, 5 on page 2)"),
)
CASES += _COMPRESS + (negative(_COMPRESS[1], {"WA0": 1}, "ape row 1"),)


# ===== Kimi K3 attention residual, N = 1 (kimiK3AttnRes/attnResFwd.cu) =====

ATTN_RES = KERNELS + "kimiK3AttnRes/attnResFwd.cu"
B200_SMS = 148


def attn_res_n1(name, tokens, hidden, cta, patched=None, check="ACCEPT", note=""):
    """`invokeAttnResFwd` (attnResFwd.cu:1769) with N = 1: `launch_n1_ttile<H, TB_TILE>` (H 8192: tile 2,
    4096: tile 4; :1797, :1863, launch :1714): grid 2 x SMs, block 288 (1 producer + 8 consumer warps),
    smem 2 x TB_TILE x H bf16 + FwdSmemPlan<1> (224 bytes). Block b's tiles start at rows b x TB_TILE +
    k x grid x TB_TILE; the two-slot ring (CHUNK_DEPTH 2) holds two of them."""
    tile = {8192: 2, 4096: 4}[hidden]
    grid = 2 * B200_SMS
    smem = (2 * tile * hidden * 2 + 224 + 15) & ~15
    tiles = [(r, min(tokens, r + tile)) for r in range(cta * tile, tokens, grid * tile)]
    assert len(tiles) <= 3
    (r0, r1), (r2, r3), (r4, r5) = (tiles + [(0, 0)] * 3)[:3]
    return Case(
        name=name,
        description=f"attn_res_fwd_n1_ttile_kernel<{hidden}, {tile}>, {tokens} tokens, grid {grid}, block {cta}: "
                    f"tiles {tiles}{note}{HIDDEN}",
        source=f"{ATTN_RES}:819 (attn_res_fwd_n1_ttile_kernel), host launch_n1_ttile :1714 from invokeAttnResFwd :1769"
               + (f", PTX patched ({PATCHED}attnResFwd_{patched}.ptx)" if patched else ""),
        unit=f"{PATCHED}attnResFwd_{patched}.cu" if patched else ATTN_RES,
        symbol=f"28attn_res_fwd_n1_ttile_kernelILi{hidden}ELi{tile}ELb1EE",
        args=(Ptr("layer"), Ptr("res_w"), Ptr("rms_w"), Ptr("output"), Ptr("rsigma"), Ptr("probs"), Ptr("logits"),
              Int(tokens, "T"), Int(1, "B"), Float(EPS, "rms_eps")),
        arrays=(Array("layer", "in", "bf16", (tokens, hidden)), Array("res_w", "in", "bf16", (hidden,)),
                Array("rms_w", "in", "bf16", (hidden,)), Array("output", "out", "bf16", (tokens, hidden)),
                Array("rsigma", "out", "f32", (tokens,)), Array("probs", "out", "f32", (tokens,)),
                Array("logits", "out", "f32", (tokens,))),
        grid=(grid, 1, 1),
        block=288,
        check=check,
        spec="attn_res_n1.spec",
        dims={"TB": tokens, "H": hidden, "R0": r0, "R1": r1, "R2": r2, "R3": r3, "R4": r4, "R5": r5},
        cta=(cta, 0, 0),
        smem=smem,
    )


# Volta finding (UNKNOWN: the run stops): every consumer warp's TMEM address is tmem_base plus a
# column offset (my_tmem, :870; `add.s32 %r547, %r97, %r98`, attnResFwd.ptx:46935), lane 0, so warp 1
# stores rows of lanes 0-31: "t32: tcgen05.ld/.st at pc:146 addresses tensor-memory lane quadrant 0 -
# the issuing warp may only access its own quadrant, starting at lane 32". PTX ISA 9.7.16.8.1: warp w
# of a warpgroup accesses lanes 32 (w % 4) .. + 31 only; the kernel is correct only if the hardware
# substitutes the warp's quadrant for the address's lane field. `_tmem_lane` adds ((warpid % 4) 32)
# << 16 to the address; then Volta finds (REJECT, resource lifetime) that no tcgen05.ld is ordered
# before the tcgen05.dealloc (:1002): "UseNotBeforeDeallocation: async op 17 line 47256
# `tcgen05.ld.sync.aligned.32x32b.x8.b32 {%r118, ...}, [%r547]` / t32 line 48156 `tcgen05.dealloc`",
# the kernel having no tcgen05.wait::ld and no tcgen05.fence::before/after_thread_sync around its last
# __syncthreads (:998; ISA 9.7.16.6.4.5: only register dependencies are ordered without wait::ld).
# `_tmem_fixed` adds both: ACCEPT.
_ATTN_RES = (
    attn_res_n1("attn_res_n1_4096_3tok", 3, 4096, cta=0, check="UNKNOWN", note=" (one partial tile, 3 of 4 rows)"),
    attn_res_n1("attn_res_n1_4096_3tok_tmem_lane", 3, 4096, cta=0, patched="tmem_lane", check="REJECT",
                note=" (one partial tile, 3 of 4 rows)"),
    attn_res_n1("attn_res_n1_4096_3tok_tmem_fixed", 3, 4096, cta=0, patched="tmem_fixed",
                note=" (one partial tile, 3 of 4 rows)"),
    attn_res_n1("attn_res_n1_4096_2tiles_tmem_fixed", 1187, 4096, cta=0, patched="tmem_fixed",
                note=" (both ring slots: rows 0..4 and 1184..1187)"),
    # A third tile (the ring's wrap: 2369 tokens, rows 0, 1184 and 2368 for block 0 of the 296-block grid)
    # is MEMORY at 3 GB (a 2369 x 4096 output), so the wrap is not covered here.
)
CASES += (negative(_ATTN_RES[2], {"R1": 2}, "2 rows"),)
CASES += _ATTN_RES


def attn_res_online(name, n, tokens, hidden, nc, cta, release=True, check="VERIFIED", note=""):
    """`launch_fwd<H, NC, RELEASE_TMEM>` (attnResFwd.cu:1011) from invokeAttnResFwd (:1868 for H 4096, N <= 4):
    grid 2 x SMs (RELEASE_TMEM) else SMs, block 288, smem 2 x NC x H bf16 + FwdSmemPlan<NC>
    (32 + 128 NC + 48 + 4, to 16). Race check only (the N-way online softmax)."""
    plan = (32 + 128 * nc + 48 + 4 + 15) & ~15
    smem = (2 * nc * hidden * 2 + plan + 15) & ~15
    return Case(
        name=name,
        description=f"attn_res_fwd_online_v2_kernel<{hidden}, NC {nc}, release {release}>, N {n}, {tokens} tokens, "
                    f"block {cta}{note}{HIDDEN}",
        source=f"{ATTN_RES}:238 (attn_res_fwd_online_v2_kernel), host launch_fwd :1011 from invokeAttnResFwd :1868",
        unit=ATTN_RES,
        symbol=f"29attn_res_fwd_online_v2_kernelILi{hidden}ELi{nc}ELb{int(release)}ELb0EE",
        args=(Ptr("block"), Ptr("layer"), Ptr("res_w"), Ptr("rms_w"), Ptr("output"), Ptr("rsigma"), Ptr("probs"),
              Ptr("logits"), Int(n, "N"), Int(tokens, "T"), Int(1, "B"), Float(EPS, "rms_eps")),
        arrays=(Array("block", "in", "bf16", (n - 1, tokens, hidden)), Array("layer", "in", "bf16", (tokens, hidden)),
                Array("res_w", "in", "bf16", (hidden,)), Array("rms_w", "in", "bf16", (hidden,)),
                Array("output", "out", "bf16", (tokens, hidden)), Array("rsigma", "out", "f32", (n, tokens)),
                Array("probs", "out", "f32", (n, tokens)), Array("logits", "out", "f32", (n, tokens))),
        grid=(2 * B200_SMS if release else B200_SMS, 1, 1),
        block=288,
        check=check,
        cta=(cta, 0, 0),
        smem=smem,
    )


# ABORT, the n1_ttile kernel's TMEM finding in the N > 1 kernel too (my_v_tmem = tmem_base + group
# x TMEM_V_COLS_PER_GROUP, :301): "t32: tcgen05.ld/.st at pc:249 addresses tensor-memory lane quadrant 0 - the issuing warp
# may only access its own quadrant, starting at lane 32".
CASES += (attn_res_online("attn_res_online_4096_n3", 3, 2, 4096, 2, cta=0, check="ABORT"),)
