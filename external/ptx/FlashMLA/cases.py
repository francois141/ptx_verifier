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
