"""FlashMLA kernels checked by Volta (`external/ptx/verify.py FlashMLA`), at the commit
`external/ptx/sources/frameworks.txt` pins, compiled for sm_100a by
`external/ptx/extraction/survey.py`. The case classes are TensorRT-LLM's (`Struct` included)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
_spec = importlib.util.spec_from_file_location("trt_cases", HERE.parent / "TensorRT-LLM" / "cases.py")
_trt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_trt)
Array, Ptr, Int, Struct, Case = _trt.Array, _trt.Ptr, _trt.Int, _trt.Struct, _trt.Case
import layout  # noqa: E402

COMBINE = "csrc/cuda_kernels/smxx/decode/combine/combine.cu"
HEAD_DIM_V = 512
BLOCK_M = 8  # heads per CTA, one warp each (run_flash_mla_combine_kernel :214)


def params(values: dict, pointers: dict) -> Struct:
    """SparseAttnDecodeParams: `values` integer fields, `pointers` array names; others zero."""
    fields = []
    for name, (offset, size) in layout.OFFSETS.items():
        if name in pointers:
            fields.append({"offset": offset, "ptr": pointers[name]})
        else:
            fields.append({"offset": offset, f"u{8 * size}": values.get(name, 0)})
    return Struct(tuple(fields), "params")


def combine(name, splits, h_q, s_q=1, cta=(0, 0, 0), check="ACCEPT", note=""):
    """`run_flash_mla_combine_kernel` (:212) for per-batch split counts `splits`: grid
    [b, s_q, ceil(h_q / 8)], block 256, MAX_SPLITS the switch's bucket (:189), the incomplete-
    head-block kernel when h_q % 8 != 0. num_splits_ptr is the cumulative split count."""
    b = len(splits)
    cumulative = [0]
    for n in splits:
        cumulative.append(cumulative[-1] + n)
    total = cumulative[-1]
    max_splits = next(m for m in (32, 64, 96, 128, 160) if max(splits) <= m)
    incomplete = h_q % BLOCK_M != 0
    b0, q0, hb = cta
    heads = min(BLOCK_M, h_q - hb * BLOCK_M)
    values = {
        "b": b, "s_q": s_q, "h_q": h_q, "num_sm_parts": max_splits,
        "stride_lse_b": s_q * h_q, "stride_lse_s_q": h_q,
        "stride_o_b": s_q * h_q * HEAD_DIM_V, "stride_o_s_q": h_q * HEAD_DIM_V,
        "stride_o_h_q": HEAD_DIM_V,
        "stride_lse_accum_split": s_q * h_q, "stride_lse_accum_s_q": h_q,
        "stride_o_accum_split": s_q * h_q * HEAD_DIM_V, "stride_o_accum_s_q": h_q * HEAD_DIM_V,
        "stride_o_accum_h_q": HEAD_DIM_V,
    }
    pointers = {"lse_accum": "lse_accum", "o_accum": "o_accum", "lse": "lse", "out": "out",
                "num_splits_ptr": "num_splits"}
    single = splits[b0] == 1
    return Case(
        name=name,
        description=f"combine of {splits} splits, h_q {h_q}, s_q {s_q}, block {cta}{note}",
        source=f"{COMBINE}:45 (flash_fwd_mla_combine_kernel), run_flash_mla_combine_kernel :212",
        unit=COMBINE,
        symbol=f"28flash_fwd_mla_combine_kernelIN7cutlass10bfloat16_tELi512ELi8ELi{max_splits}"
               f"ELi256ELb{int(incomplete)}E",
        args=(params(values, pointers),),
        arrays=(Array("num_splits", "index", "i32", (b + 1,), contents=tuple(cumulative)),
                Array("lse_accum", "in", "f32", (total, s_q, h_q)),
                Array("o_accum", "in", "f32", (total, s_q, h_q, HEAD_DIM_V)),
                Array("lse", "out", "f32", (b, s_q, h_q)),
                Array("out", "out", "bf16", (b, s_q, h_q, HEAD_DIM_V))),
        grid=(b, s_q, -(-h_q // BLOCK_M)),
        block=BLOCK_M * 32,
        check="VERIFIED" if single else check,
        spec=None if single else "combine.spec",
        dims={"T": total, "B": b, "SQ": s_q, "HQ": h_q, "D": HEAD_DIM_V, "B0": b0, "Q0": q0,
              "S0": cumulative[b0], "NS": splits[b0], "H0": hb * BLOCK_M, "HB": heads},
        cta=cta,
    )


CASES = (
    combine("combine_2splits_h16", (3, 2), 16, cta=(1, 0, 1)),
    combine("combine_3splits_h16_b0", (3, 2), 16, cta=(0, 0, 0)),
    combine("combine_h12_incomplete", (2, 4), 12, cta=(1, 0, 1), note=" (warps 4-7 exit)"),
    combine("combine_mtp_sq2", (2, 3), 16, s_q=2, cta=(1, 1, 0), note=" (s_q 2, token 1)"),
    combine("combine_single_split", (1, 3), 16, cta=(0, 0, 1), note=" (one split: early return)"),
    combine("combine_40splits", (40, 2), 8, cta=(0, 0, 0), note=" (MAX_SPLITS 64)"),
)


def _dropping_last_split(case):
    """`case` against a spec that leaves out its last split: must be refuted."""
    import dataclasses
    dims = {**case.dims, "NS": case.dims["NS"] - 1}
    return dataclasses.replace(case, name=case.name + "_negative", dims=dims, check="REJECT",
                               description=case.description + " (negative: spec drops a split)")


CASES += (_dropping_last_split(CASES[0]),)


SCHED = "csrc/cuda_kernels/smxx/decode/get_decoding_sched_meta/get_decoding_sched_meta.cu"
SCHED_PARAMS = {"b": 0, "s_q": 4, "block_size_topk": 8, "fixed_overhead_num_blocks": 12,
                "num_sm_parts": 16, "topk": 20, "extra_topk": 24}  # GetDecodeSchedMetaParams
SCHED_POINTERS = {"topk_length": 32, "extra_topk_length": 40,
                  "tile_scheduler_metadata_ptr": 48, "num_splits_ptr": 56}  # 72 bytes


def sched_reference(lengths, block, overhead, parts, extra_lengths=None, extra=0):
    """get_mla_metadata_kernel (:23) in Python: each partition's 7 metadata ints, and the
    cumulative split counts."""
    seqlens = []
    for i, s in enumerate(lengths):
        s = s or 1
        if extra_lengths is not None or extra:
            s = -(-s // block) * block + (extra_lengths[i] if extra_lengths else extra)
        seqlens.append(s)
    last = [(s - 1) // block for s in seqlens]
    blocks = [x + 1 for x in last]
    total = sum(n + overhead for n in blocks)
    payload = -(-total // parts) + overhead
    req = block_now = split = cum = 0
    splits = [0] * (len(lengths) + 1)
    metas = []
    for _ in range(parts):
        meta = {"begin_req": req, "begin_block": block_now, "begin_split": split,
                "first_split": int(block_now != 0)}
        remain = payload
        while req < len(lengths):
            left = blocks[req] - block_now
            if remain >= left + overhead:
                cum += split + 1
                splits[req + 1] = cum
                remain -= left + overhead
                req, block_now, split = req + 1, 0, 0
            else:
                if remain - overhead > 0:
                    block_now += remain - overhead
                    split += 1
                break
        end_req = req if block_now > 0 else req - 1
        end_block = block_now if block_now > 0 else last[req - 1] + 1
        last_split = int(end_block != last[end_req] + 1)
        first_split = meta["first_split"]
        if meta["begin_req"] == end_req:
            first_split = last_split = int(first_split or last_split)
        metas.append([meta["begin_req"], end_req, meta["begin_block"], end_block,
                      meta["begin_split"], first_split, last_split])
    assert req == len(lengths) and block_now == 0 and split == 0
    return metas, splits


def _nested(values: dict, default) -> str:
    text = str(default)
    for i, v in sorted(values.items(), reverse=True):
        text = f"where(i == {i}, {v}, {text})"
    return text


def sched_meta(name, lengths, block=64, overhead=5, parts=8, with_lengths=True, note=""):
    """`run_get_decoding_sched_meta_kernel` (:121): one CTA of 32 threads, dynamic shared
    (4 b + 1) ints, the <topk_length != nullptr, false, false> kernel. The expected metadata and
    splits come from `sched_reference`; each 32-byte DecodingSchedMeta's `_pad` int is never
    assigned, so the spec leaves it unwritten."""
    b = len(lengths)
    metas, splits = sched_reference(lengths, block, overhead, parts)
    meta_values = {p * 8 + k: v for p, m in enumerate(metas) for k, v in enumerate(m)}
    spec = HERE / f"sched_meta_{name}.spec"
    spec.write_text(
        f"// Generated by cases.py (sched_meta) for {name}: sched_reference's metadata and splits.\n"
        "dim P; dim S;\narray meta[P];\narray splits[S];\n"
        f"meta[i] = {_nested(meta_values, 'unwritten')};\n"
        f"splits[i] = {_nested(dict(enumerate(splits)), 'unwritten')};\n")
    fields = [{"offset": o, "u32": v} for o, v in zip(SCHED_PARAMS.values(), (
        b, 1, block, overhead, parts, 0 if with_lengths else max(lengths), 0))]
    fields += [{"offset": SCHED_POINTERS["topk_length"], "ptr": "topk_length"},
               {"offset": SCHED_POINTERS["extra_topk_length"], "u64": 0},
               {"offset": SCHED_POINTERS["tile_scheduler_metadata_ptr"], "ptr": "meta"},
               {"offset": SCHED_POINTERS["num_splits_ptr"], "ptr": "splits"},
               {"offset": 64, "u64": 0}]
    return Case(
        name=name,
        description=f"decode schedule of topk lengths {lengths}, block {block}, overhead "
                    f"{overhead}, {parts} SM parts{note}",
        source=f"{SCHED}:23 (get_mla_metadata_kernel), run_get_decoding_sched_meta_kernel :121",
        unit=SCHED,
        symbol="23get_mla_metadata_kernelILb1ELb0ELb0EE",
        args=(Struct(tuple(fields), "params"),),
        arrays=(Array("topk_length", "index", "i32", (b,), contents=tuple(lengths)),
                Array("meta", "out", "i32", (parts * 8,)),
                Array("splits", "out", "i32", (b + 1,))),
        grid=(1, 1, 1),
        block=32,
        smem=(4 * b + 1) * 4,
        # Volta gap: each DecodingSchedMeta's `_pad` int is stored uninitialized (KU_STG_256 of the
        # whole 32-byte struct), and an undefined output element fails the read-back, so the
        # generated spec cannot be checked yet; race-only until outputs can mark padding.
        spec=None,
        dims={"P": parts * 8, "S": b + 1},
        check="VERIFIED",
    )


CASES += (
    sched_meta("sched_meta_4req", (2048, 512, 64, 1000), note=" (uneven requests)"),
    sched_meta("sched_meta_empty_req", (0, 300, 4096), parts=16, note=" (a zero topk length)"),
    sched_meta("sched_meta_40req", tuple(64 * (i % 7) + 17 for i in range(40)), parts=32,
               note=" (more requests than threads)"),
)
