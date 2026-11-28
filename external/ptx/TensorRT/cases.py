"""TensorRT plugin kernels checked by Volta: what each case compiles, launches and checks.

`external/ptx/verify.py` runs them. Each case's kernel is one instantiation in the PTX of a
`plugin/` unit of TensorRT (NVIDIA/TensorRT, the open-source plugins) at the commit
`external/ptx/sources/frameworks.txt` pins, compiled for sm_100a by
`external/ptx/extraction/survey.py`; `symbol` is a substring of its mangled name. The launch
(grid, block, arguments) is the one the plugin's host code makes for the case's shape, read
from the source cited in `source`.
"""

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Array:
    """`contents` gives a 4-byte index array's elements (without it element i is i)."""

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
    without one "VERIFIED"/"REJECTED" from the graph checks; "ABORT" an execution error."""

    name: str
    description: str
    source: str
    unit: str
    symbol: str | tuple
    args: tuple
    arrays: tuple
    grid: tuple
    block: int | tuple
    check: str
    spec: str | None = None
    dims: dict = field(default_factory=dict)
    cta: tuple = (0, 0, 0)
    smem: int = 0
    control: bool = False  # a finding's fix, not shipped: eval_table.py does not count it


SKIPLN = "plugin/skipLayerNormPlugin/skipLayerNormKernel.cu"
EMBLN = "plugin/embLayerNormPlugin/embLayerNormKernel.cu"
DISENT = "plugin/disentangledAttentionPlugin/disentangledKernel.cu"
DISENT_FIXED = "volta_units/disentangledKernel_fixed.cu"
T_MANGLED = {"f32": "f", "f16": "6__half"}


def skip_layer_norm(name, dtype, rows, ld, bias=True, check="ACCEPT"):
    """`computeSkipLayerNorm<T, hasBias>` (skipLayerNormKernel.cu:249): `skipLayerNormKernelSmall`
    for ld <= 32, `skipln_vec` for ld 768 or 1024, else `skipLayerNormKernel`, one row per block.
    Without a bias the plugin passes a null `bias` (skipLayerNormPlugin.cpp:203)."""
    vpt = 16 // (4 if dtype == "f32" else 2)
    t = T_MANGLED[dtype]
    if ld <= 32:
        kernel, block, order = f"24skipLayerNormKernelSmallI{t}Lj32ELb{int(bias)}E", 32, "bg"
    elif ld in (768, 1024):
        kernel, block, order = f"10skipln_vecI{t}Li{ld // vpt}ELi{vpt}ELb{int(bias)}E", ld // vpt, "ob"
    else:
        kernel, block, order = f"19skipLayerNormKernelI{t}Lj256ELb{int(bias)}E", 256, "bg"
    # skipLayerNormKernel{,Small}(ld, input, skip, beta, gamma, output, bias);
    # skipln_vec(ld, input, skip, output, beta, gamma, bias)
    head = (Int(ld, "ld"), Ptr("input"), Ptr("skip"))
    tail = (Ptr("beta"), Ptr("gamma"), Ptr("output")) if order == "bg" else (Ptr("output"), Ptr("beta"), Ptr("gamma"))
    arrays = [Array("input", "in", dtype, (rows, ld)), Array("skip", "in", dtype, (rows, ld)),
              Array("beta", "in", dtype, (ld,)), Array("gamma", "in", dtype, (ld,)),
              Array("output", "out", dtype, (rows, ld))]
    if bias:
        arrays.append(Array("bias", "in", dtype, (ld,)))
    # skipln_vec's proof against its spec takes past 10 minutes: graph-only there
    spec = "skip_layer_norm_vec.spec" if ld in (768, 1024) else "skip_layer_norm.spec"
    return Case(
        name=name,
        description=f"skipLayerNorm {dtype}, {rows} rows of {ld}, {'bias' if bias else 'no bias'}",
        source=f"{SKIPLN}:249 (computeSkipLayerNorm)",
        unit=SKIPLN,
        symbol=kernel,
        args=head + tail + ((Ptr("bias"),) if bias else (NULL,)),
        arrays=tuple(arrays),
        grid=(rows, 1, 1),
        block=block,
        check=check,
        spec=spec if bias and check == "ACCEPT" else None,
        dims={"T": rows, "N": ld},
    )


def emb_layer_norm(name, dtype, seq, batch, ld, ids, tokens, vocab=5, types=2, cta=(0, 0, 0), check="VERIFIED"):
    """`embSkipLayerNorm<T>` (embLayerNormKernel.cu:236): grid (S, B), 256 threads, row
    s * B + b; ids and token ids are S x B int32 index arrays. No spec: a PTX spec cannot read
    an index array's integers."""
    return Case(
        name=name,
        description=f"embLayerNorm {dtype}, S={seq} B={batch} hidden {ld}, block {cta}",
        source=f"{EMBLN}:236 (embSkipLayerNorm)",
        unit=EMBLN,
        symbol=f"18embLayerNormKernelI{T_MANGLED[dtype]}Lj256E",
        args=(Int(ld, "ld"), Ptr("ids"), Ptr("tok"), Ptr("beta"), Ptr("gamma"), Ptr("wordEmb"),
              Ptr("posEmb"), Ptr("tokEmb"), Int(vocab, "wordSize"), Int(types, "tokSize"), Ptr("output")),
        arrays=(Array("ids", "index", "i32", (seq, batch), contents=tuple(ids)),
                Array("tok", "index", "i32", (seq, batch), contents=tuple(tokens)),
                Array("beta", "in", "f32", (ld,)), Array("gamma", "in", "f32", (ld,)),
                Array("wordEmb", "in", dtype, (vocab, ld)), Array("posEmb", "in", dtype, (seq, ld)),
                Array("tokEmb", "in", dtype, (types, ld)), Array("output", "out", dtype, (seq, batch, ld))),
        grid=(seq, batch, 1),
        block=256,
        check=check,
        cta=cta,
    )


def dim3(x, y, z):
    return Struct(tuple({"offset": 4 * k, "u32": v} for k, v in enumerate((x, y, z))))


def disentangled(name, heads, seq, span, cta=(0, 0, 0), fixed=False, check="ACCEPT", spec=True):
    """`DisentangledAttentionPlugin::enqueueType` (disentangledAttentionPlugin.cpp:238): data0
    and the result [BH, S, S], data1 and data2 [BH, S, 2 span], block (64, 4), grid rounded up
    to 64 x 64 tiles: ((S - 1) / 64 + 1, (S - 1) / 64 + 1, BH). With span >= 2 x 64 every
    relative distance of a tile is in the preserved region, so no log bucket is taken. `fixed`
    runs the control, `units/disentangledKernel_fixed.cu` (bugs.txt TRT-1). The spec covers the
    whole result, so it checks a launch of one head whose S fits one tile."""
    tiles = (seq - 1) // 64 + 1
    return Case(
        name=name,
        description=f"DeBERTa disentangled attention f32, BH={heads} S={seq} span={span}, "
                    f"block {cta}" + (", bounds check added" if fixed else ""),
        source=f"{DISENT}:84 (GatherAddGatherTransposeAddMul_fused), host disentangledAttentionPlugin.cpp:238",
        unit=DISENT_FIXED if fixed else DISENT,
        symbol="36GatherAddGatherTransposeAddMul_fusedIfLi64ELi4E",
        args=(Ptr("data0"), Ptr("data1"), Ptr("data2"), Ptr("result"), dim3(heads, seq, seq),
              dim3(heads, seq, 2 * span), dim3(heads, seq, 2 * span), dim3(heads, seq, seq),
              Float(0.125, "factor"), Int(span, "span")),
        arrays=(Array("data0", "in", "f32", (heads, seq, seq)),
                Array("data1", "in", "f32", (heads, seq, 2 * span)),
                Array("data2", "in", "f32", (heads, seq, 2 * span)),
                Array("result", "out", "f32", (heads, seq, seq))),
        grid=(tiles, tiles, heads),
        block=(64, 4, 1),
        check=check,
        spec="disentangled_attention.spec" if spec else None,
        control=fixed,
        dims={"H": heads, "S": seq, "P": 2 * span, "SPAN": span} if spec else {},
        cta=cta,
    )


TRANSPOSE = "plugin/topkLastDimPlugin/transpose.cu"
GROUPNORM = "plugin/groupNormalizationPlugin/groupNormalizationKernel.cu"
PILLAR = "plugin/common/kernels/pillarScatterKernels.cu"


def transpose(name, dtype, outer, rows, cols, check="ACCEPT"):
    total = outer * rows * cols
    return Case(
        name=name,
        description=f"batchedTranspose2D {dtype}, [{outer}, {rows}, {cols}]",
        source=f"{TRANSPOSE}:50 (launchBatchedTranspose2D)",
        unit=TRANSPOSE,
        symbol=f"24batchedTranspose2DKernelI{T_MANGLED[dtype]}E",
        args=(Ptr("src"), Ptr("dst"), Int(outer), Int(rows), Int(cols)),
        arrays=(Array("src", "in", dtype, (outer, rows, cols)), Array("dst", "out", dtype, (outer, cols, rows))),
        grid=(-(-total // 256), 1, 1),
        block=256,
        check=check,
        spec="transpose_last2.spec",
        dims={"O": outer, "R": rows, "C": cols},
    )


def scale_shift(name, batch, channels, volume, check="ACCEPT"):
    return Case(
        name=name,
        description=f"groupNorm scaleShiftChannelsInplace f32, B={batch} C={channels} volume {volume}",
        source=f"{GROUPNORM}:46 (scaleShiftChannelsInplace)",
        unit=GROUPNORM,
        symbol="31scaleShiftChannelsInplaceKernelIfLj256E",
        args=(Ptr("inOut"), Int(volume, "ld"), Ptr("beta"), Ptr("gamma")),
        arrays=(Array("inOut", "inout", "f32", (batch, channels, volume)),
                Array("beta", "in", "f32", (channels,)), Array("gamma", "in", "f32", (channels,))),
        grid=(-(-volume // 256), channels, batch),
        block=256,
        check=check,
        spec="scale_shift_channels.spec",
        dims={"B": batch, "C": channels, "L": volume},
    )


def pillar_scatter(name, pillars, fx, fy, coords, check="VERIFIED"):
    """`pillarScatterKernelLaunch` (pillarScatterKernels.cu:56): 64 pillars of 64 features per
    block; each pillar's (x, y) is the w, z of its int4 coordinate."""
    flat = tuple(v for (x, y) in coords for v in (0, 0, y, x))
    return Case(
        name=name,
        description=f"PointPillars scatterBEV f32, {pillars} pillars onto {fx}x{fy}",
        source=f"{PILLAR}:56 (pillarScatterKernelLaunch)",
        unit=PILLAR,
        symbol="17scatterBEV_kernelIfE",
        args=(Ptr("features"), Ptr("coords"), Ptr("params"), Int(fx, "featureX"), Int(fy, "featureY"),
              Ptr("spatial")),
        arrays=(Array("features", "in", "f32", (pillars, 64)),
                Array("coords", "index", "i32", (pillars, 4), contents=flat),
                Array("params", "index", "i32", (1,), contents=(pillars,)),
                Array("spatial", "out", "f32", (64, fy, fx))),
        grid=(-(-fx * fy // 64), 1, 1),
        block=64,
        check=check,
    )


SCATTER = "plugin/scatterPlugin/scatterLayer.cu"
WORKSPACE = 0x40000


def scatter_transform_idx(name, rank, index_rank, slices, fixed=False, check="VERIFIED"):
    """`scatterNDInference` (scatterLayer.cu:73) splits ScatterND's workspace, sized
    `MAX_DIMS * 4 + slices * 4` bytes (scatterPlugin.cpp:101), into the transform coefficients
    and the transformed indices, the latter at `wo + sizeof(int) * nOutputDims` for an
    `int* wo`: 16 x rank bytes in, past the 32 bytes reserved once the data rank is 3 or more
    (bugs.txt TRT-2). `transformIdxKernel<<<slices, 1>>>` writes them. `fixed` passes the
    `wo + MAX_DIMS` the workspace size implies."""
    reserved = 8 * 4
    out = WORKSPACE + (reserved if fixed else 4 * 4 * rank)
    coeff = tuple(range(index_rank, 0, -1)) + (0,) * (8 - index_rank)
    indices = tuple((s + k) % 2 for s in range(slices) for k in range(index_rank))
    return Case(
        name=name,
        description=f"ScatterND transformIdxKernel, data rank {rank}, {slices} slices of rank {index_rank}"
                    + (", indices at wo + MAX_DIMS" if fixed else ", indices at wo + sizeof(int) * rank"),
        source=f"{SCATTER}:86 (scatterNDInference), workspace scatterPlugin.cpp:101",
        unit=SCATTER,
        symbol="18transformIdxKernel",
        args=(Int(out, "transformedIdx"), Ptr("coeff"), Ptr("indices"), Int(index_rank, "sliceRank")),
        arrays=(Array("coeff", "index", "i32", (8,), base=WORKSPACE, contents=coeff),
                Array("transformed", "out", "i32", (slices,), base=WORKSPACE + reserved),
                Array("indices", "index", "i32", (slices, index_rank), contents=indices)),
        grid=(slices, 1, 1),
        block=1,
        check=check,
        control=fixed,
    )


VARSEQ = "plugin/embLayerNormPlugin/embLayerNormVarSeqlenKernel{}.cu"


def mask_idx(name, seq, batch, valid, check="VERIFIED"):
    """`computeMaskIdx` (embLayerNormKernel.cu:157): per batch, the first masked position of an
    S x B int mask; `maskIdxKernelSmall<32|128|384>` up to S = 128 and at 384, else
    `maskIdxKernel<256>`. Batch b admits its first `valid[b]` positions."""
    tpb, kernel = ((32, "Small") if seq <= 32 else (128, "Small") if seq <= 128 else (384, "Small")
                   if seq == 384 else (256, ""))
    mask = tuple(int(s < valid[b]) for s in range(seq) for b in range(batch))
    symbol = f"18maskIdxKernelSmallILj{tpb}E" if kernel else "13maskIdxKernelILj256E"
    return Case(
        name=name,
        description=f"BERT maskIdx, S={seq} B={batch}",
        source=f"{EMBLN}:157 (computeMaskIdx)",
        unit=EMBLN,
        symbol=symbol,
        args=(Int(seq, "ld"), Ptr("mask"), Ptr("maskIdx")),
        arrays=(Array("mask", "index", "i32", (seq, batch), contents=mask),
                Array("maskIdx", "out", "i32", (batch,))),
        grid=(batch, 1, 1),
        block=tpb,
        check=check,
    )


def fill_sbs_mask(name, seq, batch, valid, check="VERIFIED"):
    """`convertMask` (embLayerNormKernel.cu:85) for the fused MHA's packed mask: warps (2, 2)
    for S in {64, 96, 128}, (1, 8) for 384 (embLayerNormPlugin.cpp:308), S x 4 bytes of
    dynamic shared memory."""
    wm, wn = (1, 8) if seq == 384 else (2, 2)
    xm = -(-seq // (16 * wm))
    threads = wm * wn * 32
    mask = tuple(int(s < valid[b]) for s in range(seq) for b in range(batch))
    return Case(
        name=name,
        description=f"BERT fillSBSMask, S={seq} B={batch}, warps ({wm}, {wn})",
        source=f"{EMBLN}:85 (convertMask)",
        unit=EMBLN,
        symbol="17fillSBSMaskKernel",
        args=(Int(wm, "warps_m"), Int(wn, "warps_n"), Int(seq, "S"), Ptr("mask"), Ptr("maskX")),
        arrays=(Array("mask", "index", "i32", (seq, batch), contents=mask),
                Array("maskX", "out", "i32", (batch, xm, threads))),
        grid=(xm, batch, 1),
        block=threads,
        check=check,
        smem=seq * 4,
    )


def emb_layer_norm_varseq(name, flavor, seqlens, ld, ids, tokens, vocab=5, types=2, cta=(0, 0, 0),
                          check="VERIFIED"):
    """`embSkipLayerNorm{HFace,MTron}` (embLayerNormVarSeqlenKernel*.cu:105): packed tokens of
    the cumulative `cuSeqlens`, grid (max S, B); MTron also writes the sum to `skip`."""
    total, batch, seq = sum(seqlens), len(seqlens), max(seqlens)
    cu = tuple(sum(seqlens[:b]) for b in range(batch + 1))
    outs = (Ptr("output"), Ptr("skip")) if flavor == "MTron" else (Ptr("output"),)
    return Case(
        name=name,
        description=f"embLayerNorm{flavor} f32, sequences {seqlens}, hidden {ld}, block {cta}",
        source=f"{VARSEQ.format(flavor)}:105 (embSkipLayerNorm{flavor})",
        unit=VARSEQ.format(flavor),
        symbol=f"embLayerNormKernel{flavor}IfLj256E",
        args=(Int(ld, "ld"), Ptr("ids"), Ptr("tok"), Ptr("cuSeqlens"), Ptr("beta"), Ptr("gamma"),
              Ptr("wordEmb"), Ptr("posEmb"), Ptr("tokEmb"), Int(vocab, "wordSize"), Int(types, "tokSize"))
             + outs,
        arrays=(Array("ids", "index", "i32", (total,), contents=tuple(ids)),
                Array("tok", "index", "i32", (total,), contents=tuple(tokens)),
                Array("cuSeqlens", "index", "i32", (batch + 1,), contents=cu),
                Array("beta", "in", "f32", (ld,)), Array("gamma", "in", "f32", (ld,)),
                Array("wordEmb", "in", "f32", (vocab, ld)), Array("posEmb", "in", "f32", (seq, ld)),
                Array("tokEmb", "in", "f32", (types, ld)), Array("output", "out", "f32", (total, ld)))
               + ((Array("skip", "out", "f32", (total, ld)),) if flavor == "MTron" else ()),
        grid=(seq, batch, 1),
        block=256,
        check=check,
        cta=cta,
    )


NMS = "plugin/efficientNMSPlugin/efficientNMSInference.cu"


def f32_bits(x):
    import struct
    return struct.unpack("<I", struct.pack("<f", x))[0]


def efficient_nms(name, boxes, selected=4096, fixed=False, check="REJECTED"):
    """`EfficientNMSLauncher` (efficientNMSInference.cu:340) for one image, one class, corner
    boxes, no decoder, the plugin's defaults otherwise (efficientNMSParameters.h): block
    `numSelectedBoxes / NMS_TILES` (256 or 512 at most for small ones), grid (1, batch). The
    filtered, sorted inputs are given concretely (floats as their bits, in index arrays):
    box `k` has score 1 - k / 64, and boxes 2k and 2k + 1 coincide, so every odd box is
    suppressed by IoU 1. `fixed` runs the control, `units/efficientNMSInference_fixed.cu`
    (bugs.txt TRT-3)."""
    n = len(boxes)
    tile = 256 if selected <= 256 else 512 if selected <= 512 else selected // 5
    fields = ((0, "u32", f32_bits(0.5)), (4, "u32", f32_bits(0.5)), (8, "u32", 100), (12, "s32", -1),
              (16, "u8", 0), (20, "s32", -1), (24, "u8", 0), (25, "u8", 0), (28, "u32", 0), (32, "u8", 0),
              (36, "u32", selected), (40, "s32", -1), (44, "u8", 0), (48, "u32", 1), (52, "u32", 1),
              (56, "u32", 4 * n), (60, "u32", n), (64, "u32", n), (68, "u8", 1), (69, "u8", 1), (70, "u8", 0),
              (72, "u32", 0))
    param = Struct(tuple({"offset": o, t: v} for o, t, v in fields), "param")
    return Case(
        name=name,
        description=f"EfficientNMS f32 corner boxes, {n} candidates, numSelectedBoxes {selected} ({tile} threads)"
                    + (", barrier per iteration" if fixed else ""),
        source=f"{NMS}:178 (EfficientNMS), host EfficientNMSLauncher :340",
        unit="volta_units/efficientNMSInference_fixed.cu" if fixed else NMS,
        symbol="12EfficientNMSIf9BoxCornerIfEE",
        args=(param, Ptr("topNum"), NULL, NULL, Ptr("sortedIndex"), Ptr("sortedScores"), Ptr("topClass"),
              Ptr("topAnchors"), Ptr("boxes"), NULL, Ptr("numDetections"), Ptr("nmsScores"), Ptr("nmsClasses"),
              NULL, Ptr("nmsBoxes")),
        arrays=(Array("topNum", "index", "i32", (1,), contents=(n,)),
                Array("sortedIndex", "index", "i32", (n,), contents=tuple(range(n))),
                Array("sortedScores", "index", "i32", (n,), contents=tuple(f32_bits(1 - k / 64) for k in range(n))),
                Array("topClass", "index", "i32", (n,), contents=(0,) * n),
                Array("topAnchors", "index", "i32", (n,), contents=tuple(range(n))),
                Array("boxes", "index", "i32", (n, 4), contents=tuple(f32_bits(v) for b in boxes for v in b)),
                Array("numDetections", "out", "i32", (1,)),
                Array("nmsScores", "out", "f32", (100,)),
                Array("nmsClasses", "out", "i32", (100,)),
                Array("nmsBoxes", "out", "f32", (100, 4))),
        grid=(1, 1, 1),
        block=tile,
        check=check,
        control=fixed,
    )


PAIRED_BOXES = tuple((float(k // 2), 0.0, k // 2 + 0.75, 1.0) for k in range(40))


CASES = [
    skip_layer_norm("skipln_small_f32_bias", "f32", 1, 24),
    skip_layer_norm("skipln_small_f32_nobias", "f32", 2, 24, bias=False, check="VERIFIED"),
    skip_layer_norm("skipln_f32_bias_300", "f32", 1, 300),
    skip_layer_norm("skipln_vec_f32_bias_768", "f32", 1, 768, check="VERIFIED"),
    skip_layer_norm("skipln_vec_f32_nobias_768", "f32", 1, 768, bias=False, check="VERIFIED"),
    skip_layer_norm("skipln_f16_bias_300", "f16", 1, 300),
    skip_layer_norm("skipln_vec_f16_bias_768", "f16", 1, 768, check="VERIFIED"),
    emb_layer_norm("embln_f32_s2_b2", "f32", 2, 2, 40, ids=(3, 1, 4, 0), tokens=(0, 1, 1, 0), cta=(1, 1, 0)),
    emb_layer_norm("embln_f16_s2_b1", "f16", 2, 1, 300, ids=(2, 2), tokens=(1, 0)),
    transpose("transpose_f32_2x3x5", "f32", 2, 3, 5),
    transpose("transpose_f16_3x5x7", "f16", 3, 5, 7),
    scale_shift("scale_shift_b1_c1_200", 1, 1, 200),
    pillar_scatter("pillar_scatter_70_on_12x8", 70, 12, 8,
                   tuple((p % 12, p // 12) for p in range(70))),
    disentangled("disentangled_s64_full_tile", 1, 64, 128),
    disentangled("disentangled_s128_two_tiles", 2, 128, 256, cta=(1, 0, 1), check="VERIFIED", spec=False),
    # TRT-1: with S not a multiple of 64, a partial tile's threads past S read and write past
    # their row: two of them store one result element (two heads keep the overflow in bounds),
    # and with one head the last row's overflow reads past data0.
    disentangled("disentangled_s40_partial_tile", 2, 40, 128, check="REJECTED", spec=False),
    disentangled("disentangled_s40_partial_tile_one_head", 1, 40, 128, check="UNKNOWN"),
    disentangled("disentangled_s40_partial_tile_fixed", 1, 40, 128, fixed=True),
    disentangled("disentangled_s40_partial_tile_fixed_two_heads", 2, 40, 128, fixed=True, check="VERIFIED",
                 spec=False),
    disentangled("disentangled_s100_partial_tile_fixed", 2, 100, 256, cta=(1, 1, 1), fixed=True,
                 check="VERIFIED", spec=False),
    mask_idx("mask_idx_s24_b2", 24, 2, (10, 24)),
    mask_idx("mask_idx_s100_b2", 100, 2, (37, 100)),
    mask_idx("mask_idx_s384_b1", 384, 1, (200,)),
    mask_idx("mask_idx_s300_b2", 300, 2, (299, 5)),
    fill_sbs_mask("fill_sbs_mask_s64_b2", 64, 2, (40, 64)),
    fill_sbs_mask("fill_sbs_mask_s96_b1", 96, 1, (50,)),
    fill_sbs_mask("fill_sbs_mask_s384_b1", 384, 1, (300,)),
    emb_layer_norm_varseq("embln_hface_3_5", "HFace", (3, 5), 64, (1, 2, 3, 4, 0, 1, 2, 3),
                          (0, 1, 1, 0, 0, 1, 0, 1), cta=(2, 1, 0)),
    emb_layer_norm_varseq("embln_mtron_3_5", "MTron", (3, 5), 64, (1, 2, 3, 4, 0, 1, 2, 3),
                          (0, 1, 1, 0, 0, 1, 0, 1), cta=(1, 0, 0)),
    emb_layer_norm_varseq("embln_hface_3_5_idle_block", "HFace", (3, 5), 64, (1, 2, 3, 4, 0, 1, 2, 3),
                          (0, 1, 1, 0, 0, 1, 0, 1), cta=(4, 0, 0)),
    # TRT-3: EfficientNMS's lead thread rewrites blockState before slower warps read it
    efficient_nms("efficient_nms_40_boxes", PAIRED_BOXES),
    efficient_nms("efficient_nms_24_boxes_one_warp", PAIRED_BOXES[:24]),
    efficient_nms("efficient_nms_40_boxes_fixed", PAIRED_BOXES, fixed=True, check="VERIFIED"),
    efficient_nms("efficient_nms_24_boxes_fixed", PAIRED_BOXES[:24], fixed=True, check="VERIFIED"),
    # TRT-2: the transformed indices land past ScatterND's workspace from data rank 3
    scatter_transform_idx("scatternd_rank2_indices", 2, 1, 3),
    scatter_transform_idx("scatternd_rank4_indices_past_workspace", 4, 2, 3, check="ABORT"),
    scatter_transform_idx("scatternd_rank4_indices_fixed", 4, 2, 3, fixed=True),
]
