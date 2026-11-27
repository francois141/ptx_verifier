"""FlashInfer kernels checked by Volta (`external/ptx/verify.py flashinfer`), at FlashInfer
commit d0cbb47, compiled for sm_100a by `external/ptx/extraction/survey.py` from the
instantiation units `external/ptx/flashinfer/units/*.cu` (copied into the checkout as
`volta_units/`), which call the host launchers of include/flashinfer/{norm.cuh,
attention/cascade.cuh, pos_enc.cuh, page.cuh} for bf16 and f16. Each case's launch (grid,
block, dynamic shared memory, the template instantiation the launcher's dispatch picks) is
derived from the launcher its `source` cites. The case classes are TensorRT-LLM's.
"""
import dataclasses
import importlib.util
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
_spec = importlib.util.spec_from_file_location("trt_cases", HERE.parent / "TensorRT-LLM" / "cases.py")
_trt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_trt)
Array, Ptr, Int, Float, Struct, Case = _trt.Array, _trt.Ptr, _trt.Int, _trt.Float, _trt.Struct, _trt.Case
NULL = _trt.NULL
import layout  # noqa: E402

EPS = 9.999999974752427e-07  # f32(1e-6), flashinfer.norm's default eps
T_MANGLED = {"bf16": "13__nv_bfloat16", "f16": "6__half"}
B200_SMS = 148  # the SM count the persistent launchers read (cudaDevAttrMultiProcessorCount)
NORM, CASCADE, ROPE, PAGE = (f"volta_units/{u}.cu" for u in ("norm", "cascade", "rope", "page"))
NORM_H, CASCADE_H = "include/flashinfer/norm.cuh", "include/flashinfer/attention/cascade.cuh"
ROPE_H, PAGE_H = "include/flashinfer/pos_enc.cuh", "include/flashinfer/page.cuh"


def negative(case, note, check="REJECT", spec=None, **dims):
    """`case` against its spec (or `spec`) with `dims` changed: the spec must fail."""
    return dataclasses.replace(case, name=case.name + "_negative", dims={**case.dims, **dims},
                               spec=spec or case.spec, check=check,
                               description=f"{case.description} (negative: {note})")


# ===== RMSNorm family (norm.cuh) =====

def norm_launch(d, fused):
    """RMSNorm / GemmaRMSNorm (:146, :842) and FusedAddRMSNorm / GemmaFusedAddRMSNorm (:523,
    :877): VEC_SIZE = gcd(16 / sizeof(T), d), block (32, ceil(min(1024, d / VEC) / 32)),
    dynamic smem num_warps floats, plus d floats after ceil(num_warps / 4) * 4 when fused."""
    vec = math.gcd(8, d)
    warps = -(-min(1024, d // vec) // 32)
    smem = (-(-warps // 4) * 4 + d) * 4 if fused else warps * 4
    return vec, warps, smem


def rms_norm(name, d, rows=1, cta=0, stride=None, dtype="bf16", gemma=False, check="ACCEPT",
             note=""):
    """`RMSNorm(input, weight, output, batch_size=rows, d, stride_input, stride_output=d)`
    (GemmaRMSNorm with `gemma`: weight_bias 1); grid rows, block `cta` normalizes its row."""
    stride = stride or d
    vec, warps, smem = norm_launch(d, fused=False)
    launcher = "GemmaRMSNorm :842" if gemma else "RMSNorm :146"
    return Case(
        name=name,
        description=f"{'Gemma' if gemma else ''}RMSNorm, {dtype}, {rows} row(s) of d={d} (stride "
                    f"{stride}), VEC_SIZE={vec}, block (32, {warps}), row {cta}{note}",
        source=f"{NORM_H}:65 (RMSNormKernel), launcher {launcher}",
        unit=NORM,
        symbol=f"13RMSNormKernelILj{vec}E{T_MANGLED[dtype]}E",
        args=(Ptr("input"), Ptr("weight"), Ptr("out"), Int(d, "d"), Int(stride, "stride_input"),
              Int(d, "stride_output"), Float(1.0 if gemma else 0.0, "weight_bias"),
              Float(EPS, "eps")),
        arrays=(Array("input", "in", dtype, (rows, stride)), Array("weight", "in", dtype, (d,)),
                Array("out", "out", dtype, (rows, d))),
        grid=(rows, 1, 1),
        block=(32, warps, 1),
        smem=smem,
        check=check,
        spec="gemma_rms_norm.spec" if gemma else "rms_norm.spec",
        dims={"T": rows, "S": stride, "N": d, "B": cta},
        cta=(cta, 0, 0),
    )


def fused_add_rms_norm(name, d, rows=1, cta=0, dtype="bf16", gemma=False, check="ACCEPT",
                       note=""):
    """`FusedAddRMSNorm(input, residual, weight, batch_size=rows, d, d, d)` in place (input and
    residual inout); GemmaFusedAddRMSNorm with `gemma`."""
    vec, warps, smem = norm_launch(d, fused=True)
    launcher = "GemmaFusedAddRMSNorm :877" if gemma else "FusedAddRMSNorm :523"
    return Case(
        name=name,
        description=f"{'Gemma' if gemma else ''}FusedAddRMSNorm, {dtype}, {rows} row(s) of d={d}, "
                    f"VEC_SIZE={vec}, block (32, {warps}), smem {smem} B, row {cta}{note}",
        source=f"{NORM_H}:426 (FusedAddRMSNormKernel), launcher {launcher}",
        unit=NORM,
        symbol=f"21FusedAddRMSNormKernelILj{vec}E{T_MANGLED[dtype]}E",
        args=(Ptr("input"), Ptr("residual"), Ptr("weight"), Int(d, "d"), Int(d, "stride_input"),
              Int(d, "stride_residual"), Float(1.0 if gemma else 0.0, "weight_bias"),
              Float(EPS, "eps")),
        arrays=(Array("input", "inout", dtype, (rows, d)),
                Array("residual", "inout", dtype, (rows, d)),
                Array("weight", "in", dtype, (d,))),
        grid=(rows, 1, 1),
        block=(32, warps, 1),
        smem=smem,
        check=check,
        spec="gemma_fused_add_rms_norm.spec" if gemma else "fused_add_rms_norm.spec",
        dims={"T": rows, "N": d, "B": cta},
        cta=(cta, 0, 0),
    )


def qk_rms_norm(name, batch, heads, d, stride_heads, cta, dtype="bf16", check="ACCEPT", note=""):
    """`QKRMSNorm(input, weight, output, batch, heads, d, stride_input_n = stride_heads d,
    stride_input_h = d, stride_output_n = heads d, d)` (:382): VEC = gcd(16 / sizeof, d), block
    (32, 4), grid min(occupancy x SMs, ceil(batch heads / 4)) = ceil(batch heads / 4) here, so
    warp w of block `cta` takes job 4 cta + w (none past batch heads)."""
    vec = math.gcd(8, d)
    jobs = batch * heads
    grid = -(-jobs // 4)
    j0, j1 = 4 * cta, min(4 * cta + 4, jobs)
    return Case(
        name=name,
        description=f"QKRMSNorm, {dtype}, {batch} x {heads} heads of d={d} (input head stride "
                    f"{stride_heads} heads), VEC_SIZE={vec}, grid {grid}, block {cta} = jobs "
                    f"[{j0}, {j1}){note}",
        source=f"{NORM_H}:303 (QKRMSNormKernel), launcher QKRMSNorm :382",
        unit=NORM,
        symbol=f"15QKRMSNormKernelILj{vec}E{T_MANGLED[dtype]}E",
        args=(Ptr("input"), Ptr("weight"), Ptr("out"), Int(d, "d"), Int(batch, "batch_size"),
              Int(heads, "num_heads"), Int(stride_heads * d, "stride_input_n"),
              Int(d, "stride_input_h"), Int(heads * d, "stride_output_n"),
              Int(d, "stride_output_h"), Float(0.0, "weight_bias"), Float(EPS, "eps")),
        arrays=(Array("input", "in", dtype, (batch, stride_heads, d)),
                Array("weight", "in", dtype, (d,)),
                Array("out", "out", dtype, (batch, heads, d))),
        grid=(grid, 1, 1),
        block=(32, 4, 1),
        check=check,
        spec="qk_rms_norm.spec",
        dims={"BT": batch, "HS": stride_heads, "H": heads, "D": d, "J0": j0, "J1": j1},
        cta=(cta, 0, 0),
    )


NORM_CASES = (
    rms_norm("rms_norm_4096", 4096),
    rms_norm("rms_norm_strided_last_row", 2048, rows=3, cta=2, stride=2304,
             note=" (strided input, last block)"),
    rms_norm("rms_norm_d100", 100, note=" (VEC 4, 25 of 32 lanes)"),
    rms_norm("rms_norm_d33_vec1", 33, note=" (VEC 1, 2 warps, 31 idle lanes)"),
    rms_norm("rms_norm_d4100_two_rounds", 4100,
             note=" (VEC 4, 1024 threads, round 2 only thread 0)"),
    rms_norm("rms_norm_f16_2048", 2048, dtype="f16"),
    rms_norm("gemma_rms_norm_4096", 4096, gemma=True),
    rms_norm("gemma_rms_norm_d100", 100, rows=2, cta=1, gemma=True),
    fused_add_rms_norm("fused_add_rms_norm_4096", 4096),
    fused_add_rms_norm("fused_add_rms_norm_d100_last_row", 100, rows=3, cta=2),
    fused_add_rms_norm("fused_add_rms_norm_d33_vec1", 33),
    fused_add_rms_norm("fused_add_rms_norm_f16_2048", 2048, dtype="f16"),
    fused_add_rms_norm("gemma_fused_add_rms_norm_4096", 4096, gemma=True),
    qk_rms_norm("qk_rms_norm_128_odd_heads_tail", 2, 5, 128, 7, cta=2,
                note=" (warps 2-3 idle, lanes 16-31 idle)"),
    qk_rms_norm("qk_rms_norm_128_block0", 2, 5, 128, 7, cta=0),
    qk_rms_norm("qk_rms_norm_256", 1, 3, 256, 3, cta=0),
    qk_rms_norm("qk_rms_norm_f16_64", 3, 3, 64, 4, cta=2, dtype="f16", note=" (one job)"),
    qk_rms_norm("qk_rms_norm_d72_vec8", 1, 2, 72, 2, cta=0, note=" (9 lanes)"),
)
NORM_CASES += (
    negative(NORM_CASES[1], "spec normalizes row 1", B=1),
    negative(NORM_CASES[6], "plain RMSNorm spec, no + 1", spec="rms_norm.spec"),
    negative(NORM_CASES[9], "spec on row 1", B=1),
    negative(NORM_CASES[13], "spec's jobs start one later", J0=9),
)


# ===== Attention-state merges (attention/cascade.cuh) =====

def head_vec(head_dim, dtype):
    """vec_size = max(16 / sizeof(DTypeIn), HEAD_DIM / 32), bdx = HEAD_DIM / vec_size."""
    vec = max(16 // 2, head_dim // 32)
    return vec, head_dim // vec


def merge_state(name, seq, heads, head_dim, cta, dtype="bf16", in_place=False, check="ACCEPT",
                note=""):
    """`MergeState(v_a, s_a, v_b, s_b, v_merged, s_merged, seq, heads, head_dim)` (:583) or
    `MergeStateInPlace(v, s, v_other, s_other, seq, heads, head_dim, mask = nullptr)` (:615):
    grid seq, block (bdx, heads); block `cta` merges position `cta`."""
    vec, bdx = head_vec(head_dim, dtype)
    if in_place:
        arrays = (Array("v", "inout", dtype, (seq, heads, head_dim)),
                  Array("s", "inout", "f32", (seq, heads)),
                  Array("v_other", "in", dtype, (seq, heads, head_dim)),
                  Array("s_other", "in", "f32", (seq, heads)))
        args = (Ptr("v"), Ptr("s"), Ptr("v_other"), Ptr("s_other"), NULL, Int(heads, "num_heads"),
                Int(head_dim, "head_dim"))
        symbol = f"23MergeStateInPlaceKernelILj{vec}E{T_MANGLED[dtype]}E"
    else:
        arrays = (Array("v_a", "in", dtype, (seq, heads, head_dim)),
                  Array("s_a", "in", "f32", (seq, heads)),
                  Array("v_b", "in", dtype, (seq, heads, head_dim)),
                  Array("s_b", "in", "f32", (seq, heads)),
                  Array("v_merged", "out", dtype, (seq, heads, head_dim)),
                  Array("s_merged", "out", "f32", (seq, heads)))
        args = (Ptr("v_a"), Ptr("s_a"), Ptr("v_b"), Ptr("s_b"), Ptr("v_merged"), Ptr("s_merged"),
                Int(heads, "num_heads"), Int(head_dim, "head_dim"))
        symbol = f"16MergeStateKernelILj{vec}E{T_MANGLED[dtype]}S1_E"
    kernel = "MergeStateInPlaceKernel :90" if in_place else "MergeStateKernel :45"
    launcher = "MergeStateInPlace :615" if in_place else "MergeState :583"
    return Case(
        name=name,
        description=f"{kernel.split()[0]}, {dtype}, {seq} positions x {heads} heads x {head_dim}, "
                    f"vec {vec}, block ({bdx}, {heads}), position {cta}{note}",
        source=f"{CASCADE_H}:{kernel.split(':')[1]} ({kernel.split()[0]}), launcher {launcher}",
        unit=CASCADE,
        symbol=symbol,
        args=args,
        arrays=arrays,
        grid=(seq, 1, 1),
        block=(bdx, heads, 1),
        check=check,
        spec="merge_state_in_place.spec" if in_place else "merge_state.spec",
        dims={"N": seq, "H": heads, "D": head_dim, "P": cta},
        cta=(cta, 0, 0),
    )


def merge_states(name, seq, sets, heads, head_dim, cta, dtype="bf16", check="ACCEPT", note=""):
    """`MergeStates(v, s, v_merged, s_merged, sets, seq, heads, head_dim)` (:648): with
    sets >= seq, MergeStatesLargeNumIndexSetsKernel, grid (seq, heads), block (bdx, 128 / bdx),
    4 stages, smem 4 bdy head_dim sizeof + 128 floats, block `cta` = (position, head); else
    MergeStatesKernel, grid seq, block (bdx, heads), block `cta[0]` = position."""
    vec, bdx = head_vec(head_dim, dtype)
    large = sets >= seq
    pos, head = cta
    if large:
        bdy = 128 // bdx
        symbol = f"34MergeStatesLargeNumIndexSetsKernelILj{vec}ELj{bdx}ELj{bdy}ELj4E{T_MANGLED[dtype]}S1_E"
        args_tail = (Int(sets, "num_index_sets"), Int(heads, "num_heads"))
        grid, block, smem = (seq, heads, 1), (bdx, bdy, 1), 4 * bdy * head_dim * 2 + 128 * 4
        h0, h1, kernel = head, head + 1, "MergeStatesLargeNumIndexSetsKernel :287"
    else:
        symbol = f"17MergeStatesKernelILj{vec}E{T_MANGLED[dtype]}S1_E"
        args_tail = (Int(sets, "num_index_sets"), Int(heads, "num_heads"), Int(head_dim, "head_dim"))
        grid, block, smem = (seq, 1, 1), (bdx, heads, 1), 0
        h0, h1, kernel = 0, heads, "MergeStatesKernel :224"
    return Case(
        name=name,
        description=f"{kernel.split()[0]}, {dtype}, {seq} positions x {sets} index sets x {heads} "
                    f"heads x {head_dim}, block {block[:2]}, cta {cta[:2] if large else pos}{note}",
        source=f"{CASCADE_H}:{kernel.split(':')[1]} ({kernel.split()[0]}), launcher MergeStates :648",
        unit=CASCADE,
        symbol=symbol,
        args=(Ptr("V"), Ptr("S"), Ptr("v_merged"), Ptr("s_merged"), *args_tail),
        arrays=(Array("V", "in", dtype, (seq, sets, heads, head_dim)),
                Array("S", "in", "f32", (seq, sets, heads)),
                Array("v_merged", "out", dtype, (seq, heads, head_dim)),
                Array("s_merged", "out", "f32", (seq, heads))),
        grid=grid,
        block=block,
        smem=smem,
        check=check,
        spec="merge_states.spec",
        dims={"N": seq, "K": sets, "H": heads, "D": head_dim, "P": pos, "H0": h0, "H1": h1},
        cta=(pos, head if large else 0, 0),
    )


def variable_length_merge_states(name, indptr, heads, head_dim, cta, dtype="bf16",
                                 check="ACCEPT", note=""):
    """`VariableLengthMergeStates(v, s, indptr, v_merged, s_merged, max_seq_len = len(indptr) - 1,
    seq_len = nullptr, heads, head_dim, enable_pdl)` (:697; decode.cuh:845 passes nullptr):
    block (bdx, 128 / bdx), smem 4 bdy head_dim sizeof + 128 floats, grid B200_SMS x
    min(occupancy, ceil(seq heads / B200_SMS)) = 148 here, so block `cta` < seq heads does the
    one job (cta / heads, cta % heads)."""
    vec, bdx = head_vec(head_dim, dtype)
    bdy = 128 // bdx
    seq = len(indptr) - 1
    assert seq * heads <= B200_SMS
    pos, head = divmod(cta, heads)
    nnz = indptr[-1]
    return Case(
        name=name,
        description=f"PersistentVariableLengthMergeStatesKernel, {dtype}, indptr {list(indptr)}, "
                    f"{heads} heads x {head_dim}, block ({bdx}, {bdy}), cta {cta} = position {pos} "
                    f"head {head} ({indptr[pos + 1] - indptr[pos]} states){note}",
        source=f"{CASCADE_H}:378 (PersistentVariableLengthMergeStatesKernel), launcher "
               f"VariableLengthMergeStates :697",
        unit=CASCADE,
        symbol=f"41PersistentVariableLengthMergeStatesKernelILj{vec}ELj{bdx}ELj{bdy}ELj4E"
               f"{T_MANGLED[dtype]}S1_iE",
        args=(Ptr("V"), Ptr("S"), Ptr("indptr"), Ptr("v_merged"), Ptr("s_merged"),
              Int(seq, "max_seq_len"), NULL, Int(heads, "num_heads")),
        arrays=(Array("V", "in", dtype, (max(nnz, 1), heads, head_dim)),
                Array("S", "in", "f32", (max(nnz, 1), heads)),
                Array("indptr", "index", "i32", (seq + 1,), contents=tuple(indptr)),
                Array("v_merged", "out", dtype, (seq, heads, head_dim)),
                Array("s_merged", "out", "f32", (seq, heads))),
        grid=(B200_SMS, 1, 1),
        block=(bdx, bdy, 1),
        smem=4 * bdy * head_dim * 2 + 128 * 4,
        check=check,
        spec="variable_length_merge_states.spec",
        dims={"NNZ": max(nnz, 1), "N": seq, "H": heads, "D": head_dim, "P": pos, "HH": head,
              "S0": indptr[pos], "NS": indptr[pos + 1] - indptr[pos]},
        cta=(cta, 0, 0),
    )


VARLEN = (0, 3, 3, 4, 9)  # positions of 3, 0 (empty), 1 and 5 states
# Verdicts other than ACCEPT, each triaged against the source:
# RACE_IN_PLACE - real kernel race (Volta-found): MergeStateInPlaceKernel (:101, :120) has thread
#   tx == 0 of each head row store the merged s[pos, head] while the row's other threads load
#   s[pos, head] (:101) with no barrier between; Volta's schedule runs lane 0 first, so lanes
#   1.. merge against the already merged LSE and their v is wrong (the equivalence refutation).
# EQUAL_STORES - benign race (Volta-found): in the LargeNumIndexSets and persistent variable-length
#   kernels every ty row of the block stores the same merged v_merged[pos, head, tx * vec]
#   (:346, :410, :420, :469), identical values; two unordered writes conflict (PTX ISA 8.7.1)
#   and Volta has no equal-store exception, so the graph check fails by design.
# REWRITE - fixed: Volta's accurate-expf rewrite used to match the online merge's product of two
#   plain ex2.approx factors (state.cuh:58-60) and shift its exponent by ~1e-8 (an unsound rewrite,
#   since restricted to coefficients carrying the H + L split); the cases below keep the tag where
#   it was one of their causes.
# LSE_LOG - Volta gap: the two-level LSE (per-row m + log2 d, then merged again, :132, :348) nests
#   opaque logs canon cannot match with the spec's one log; s is left unproven.
# NEG_INF - Volta gap: an empty position stores s = -inf (:412) and the equivalence branch stops
#   ("non-finite constant -inf in expression").
CASCADE_CASES = (
    merge_state("merge_state_128_last", 3, 5, 128, cta=2, note=" (odd heads, last block)"),
    merge_state("merge_state_512_f16", 2, 2, 512, cta=1, dtype="f16", note=" (vec 16)"),
    merge_state("merge_state_in_place_128", 3, 3, 128, cta=1, in_place=True,
                check="REJECT"),  # RACE_IN_PLACE
    merge_state("merge_state_in_place_64_f16", 2, 4, 64, cta=0, in_place=True, dtype="f16",
                check="REJECT"),  # RACE_IN_PLACE
    merge_states("merge_states_small_3sets", 5, 3, 3, 128, cta=(4, 0), note=" (last block)"),
    merge_states("merge_states_small_1set", 2, 1, 3, 128, cta=(1, 0), note=" (copy path)"),
    merge_states("merge_states_large_9sets_64", 1, 9, 2, 64, cta=(0, 1),
                 note=" (bdy 16: rows 9-15 empty)", check="REJECT"),  # EQUAL_STORES, REWRITE, LSE_LOG
    merge_states("merge_states_large_2sets", 2, 2, 2, 256, cta=(0, 1),
                 note=" (sets == seq_len threshold, bdy 4)",
                 check="REJECT"),  # EQUAL_STORES, REWRITE, LSE_LOG
    # The s_smem reload (iteration bdx, more than 128 sets) is past Volta's memory at 4 GB.
    merge_states("merge_states_large_130sets_64", 1, 130, 1, 64, cta=(0, 0),
                 note=" (s_smem reloaded at iteration 8)", check="MEMORY"),
    variable_length_merge_states("varlen_merge_states_3", VARLEN, 2, 128, cta=0,
                                 check="REJECT"),  # EQUAL_STORES, REWRITE, LSE_LOG
    variable_length_merge_states("varlen_merge_states_empty", VARLEN, 2, 128, cta=3,
                                 note=" (empty position)", check="REJECT"),  # EQUAL_STORES, NEG_INF
    variable_length_merge_states("varlen_merge_states_single", VARLEN, 2, 128, cta=4,
                                 note=" (one state: copy)", check="REJECT"),  # EQUAL_STORES only
    variable_length_merge_states("varlen_merge_states_5_last", VARLEN, 2, 128, cta=7,
                                 note=" (last job)", check="REJECT"),  # EQUAL_STORES, REWRITE, LSE_LOG
    variable_length_merge_states("varlen_merge_states_f16_64", (0, 2, 6), 3, 64, cta=5,
                                 dtype="f16", check="REJECT"),  # EQUAL_STORES, REWRITE, LSE_LOG
)
CASCADE_CASES += (
    negative(CASCADE_CASES[0], "spec merges position 1", P=1),
    negative(CASCADE_CASES[1], "spec merges position 0", P=0),
    negative(CASCADE_CASES[5], "spec copies position 0", P=0),
    # Rejected by EQUAL_STORES anyway; its equivalence branch also refutes the shifted row.
    negative(CASCADE_CASES[11], "spec copies state row 4", S0=4),
)


# ===== RoPE with a cos/sin cache (pos_enc.cuh) =====

Q_BASE, K_BASE, QR_BASE, KR_BASE = 0x1000000, 0x2000000, 0x3000000, 0x4000000
CACHE_BASE, POS_BASE = 0x5000000, 0x6000000


def rope(name, nnz, hq, hk, head_dim, rotary, interleave, cta, kernel="head", split=1,
         dtype="bf16", check="ACCEPT", note=""):
    """`BatchQKApplyRotaryPosIdsCosSinCache(q, k, q_rope, k_rope, cos_sin_cache, pos_ids, nnz,
    hq, hk, rotary, head_dim, contiguous strides, interleave)` (:1678; csrc/rope.cu:153): head_dim
    in {64, 128, 256, 512} and the vector path's limits met, so vec = max(16 / sizeof,
    head_dim / 32), bdx = head_dim / vec, bdy = max(128, bdx) / bdx, grid x ceil(nnz / bdy).
    `kernel`: "head" - fewer token blocks than resident CTAs, the HeadParallelism kernel, grid
    y hq + hk (:1763); "unsplit" - at least that many (nnz >= 2368 bdy: 148 SMs x 16 CTAs of
    128 threads), RopeHeadSplit keeps split 1 in one wave (:1754); "split" / "two" - the test
    override `rope_set_launch_override` (rope.cu:682, :1751) forcing gridDim.y = `split`, one
    or two heads per step (two heads is also the default on sm_107, :1315). pos_ids[t] = t;
    only block `cta`'s tokens are registered (bases), with cos_sin_cache rows for their positions
    (the registered cache is [tokens, rotary], its last row the block's last position)."""
    vec = max(8, head_dim // 32)
    bdx = head_dim // vec
    bdy = max(128, bdx) // bdx
    bx, by = cta
    t0, t1 = bx * bdy, min(bx * bdy + bdy, nnz)
    tokens = t1 - t0
    grid_x = -(-nnz // bdy)
    il = int(interleave)
    tm = T_MANGLED[dtype]
    if kernel == "head":
        grid_y = hq + hk
        symbol = f"56BatchQKApplyRotaryPosIdsCosSinCacheHeadParallelismKernelILb{il}ELj{head_dim}ELj{vec}ELj{bdx}E{tm}lE"
        g, yq, yk = 1, 0, 0
        qa = (by, by + 1) if by < hq else (0, 0)
        ka = (by - hq, by - hq + 1) if by >= hq else (0, 0)
        src = ":352 (BatchQKApplyRotaryPosIdsCosSinCacheHeadParallelismKernel), launcher :1763"
    else:
        hps, sp = {"unsplit": (1, 0), "split": (1, 1), "two": (2, 1)}[kernel]
        grid_y = split
        symbol = f"41BatchQKApplyRotaryPosIdsCosSinCacheKernelILb{il}ELj{head_dim}ELj{vec}ELj{bdx}E{tm}lLj{hps}ELb{sp}E"
        g = split
        assert hq % g == 0 and hk % g == 0
        yq = by
        yk = by if kernel != "two" else (by - hq) % g  # two heads step through q then kv as one range
        qa, ka = (0, hq // g), (0, hk // g)
        src = (f":419 (BatchQKApplyRotaryPosIdsCosSinCacheKernel<heads_per_step {hps}, split_heads "
               f"{bool(sp)}>), launcher :1754")
    e = head_dim // 2
    view = (lambda h: (tokens, h // g, g, e, 2)) if interleave else (lambda h: (tokens, h // g, g, head_dim))
    row = lambda h: h * head_dim * 2
    arrays = (Array("q", "in", dtype, view(hq), base=Q_BASE + t0 * row(hq)),
              Array("k", "in", dtype, view(hk), base=K_BASE + t0 * row(hk)),
              Array("cache", "in", "f32", (tokens, rotary), base=CACHE_BASE),
              Array("pos_ids", "index", "i64", (tokens,), base=POS_BASE + t0 * 8),
              Array("q_rope", "out", dtype, view(hq), base=QR_BASE + t0 * row(hq)),
              Array("k_rope", "out", dtype, view(hk), base=KR_BASE + t0 * row(hk)))
    dims = {"T": tokens, "QA": hq // g, "KA": hk // g, "G": g, "R": rotary, "RH": rotary // 2,
            "YQ": yq, "YK": yk, "QA0": qa[0], "QA1": qa[1], "KA0": ka[0], "KA1": ka[1]}
    dims.update({"E": e, "TWO": 2} if interleave else {"D": head_dim})
    return Case(
        name=name,
        description=f"BatchQKApplyRotaryPosIdsCosSinCache ({kernel}), {'interleave' if interleave else 'NeoX'}, "
                    f"{dtype}, nnz {nnz}, {hq} q / {hk} kv heads of {head_dim}, rotary {rotary}, "
                    f"block ({bdx}, {bdy}), grid ({grid_x}, {grid_y}), cta {cta} = tokens "
                    f"[{t0}, {t1}){note}",
        source=f"{ROPE_H}{src}",
        unit=ROPE,
        symbol=symbol,
        args=(Int(Q_BASE, "q"), Int(K_BASE, "k"), Int(QR_BASE, "q_rope"), Int(KR_BASE, "k_rope"),
              Int(CACHE_BASE, "cos_sin_cache"), Int(POS_BASE, "pos_ids"), Int(nnz, "nnz"),
              Int(hq, "num_qo_heads"), Int(hk, "num_kv_heads"), Int(rotary, "rotary_dim"),
              Int(hq * head_dim, "q_stride_n"), Int(head_dim, "q_stride_h"),
              Int(hk * head_dim, "k_stride_n"), Int(head_dim, "k_stride_h"),
              Int(hq * head_dim, "q_rope_stride_n"), Int(head_dim, "q_rope_stride_h"),
              Int(hk * head_dim, "k_rope_stride_n"), Int(head_dim, "k_rope_stride_h")),
        arrays=arrays,
        grid=(grid_x, grid_y, 1),
        block=(bdx, bdy, 1),
        check=check,
        spec="rope_interleave.spec" if interleave else "rope.spec",
        dims=dims,
        cta=(bx, by, 0),
    )


UNSPLIT_NNZ = 2367 * 8 + 3  # 2368 token blocks of 8 (one wave), the last with 3 tokens
ROPE_CASES = (
    rope("rope_head_neox_128", 10, 4, 2, 128, 128, False, cta=(0, 1)),
    rope("rope_head_neox_128_last_k", 10, 4, 2, 128, 128, False, cta=(1, 5),
         note=" (last block: 2 of 8 tokens, k head 1)"),
    rope("rope_head_neox_partial_64", 10, 5, 1, 128, 64, False, cta=(1, 2),
         note=" (rotary 64 < head_dim 128)"),
    rope("rope_head_interleave_128", 10, 4, 2, 128, 128, True, cta=(0, 4)),
    rope("rope_head_interleave_partial_64", 10, 5, 1, 128, 64, True, cta=(1, 0),
         note=" (rotary 64, last block)"),
    rope("rope_head_neox_64_f16", 20, 3, 1, 64, 64, False, cta=(1, 3), dtype="f16",
         note=" (bdy 16, last block: 4 tokens)"),
    rope("rope_head_neox_512", 3, 2, 1, 512, 256, False, cta=(0, 2),
         note=" (vec 16, rotary 256)"),
    rope("rope_unsplit_neox_128_last", UNSPLIT_NNZ, 4, 2, 128, 128, False, cta=(2367, 0),
         kernel="unsplit", note=" (last block)"),
    rope("rope_unsplit_interleave_partial", UNSPLIT_NNZ, 4, 2, 128, 64, True, cta=(5, 0),
         kernel="unsplit"),
    rope("rope_split3_neox_128", 10, 6, 3, 128, 128, False, cta=(1, 2), kernel="split", split=3,
         note=" (forced split 3, heads 2, 5 / kv 2)"),
    rope("rope_two_heads_neox_128", 10, 4, 2, 128, 128, False, cta=(0, 0), kernel="two", split=2,
         note=" (forced split 2: heads 0, 2 then 4 alone, the odd tail)"),
    rope("rope_two_heads_interleave_128", 10, 4, 2, 128, 128, True, cta=(1, 1), kernel="two",
         split=2, note=" (heads 1, 3 then 5 alone)"),
)
ROPE_CASES += (
    negative(ROPE_CASES[2], "spec rotates 128 dims", R=128, RH=64),
    negative(ROPE_CASES[4], "spec rotates 128 dims", R=128, RH=64),
)


# ===== Paged KV-cache append (page.cuh) =====

KD_BASE, VD_BASE = 0x7000000, 0x8000000  # k_data / v_data


def paged_kv(heads, page_size, head_dim, batch, hnd, pointers):
    """paged_kv_t(num_heads, page_size, head_dim, batch_size, layout, k_data, v_data, indices,
    indptr, last_page_len) (page.cuh:96): contiguous strides, the fastdiv of page_size."""
    stride_page = heads * page_size * head_dim
    stride_n, stride_h = (head_dim, page_size * head_dim) if hnd else (heads * head_dim, head_dim)
    fd = layout.fastdiv(page_size)
    values = {"page_size.divisor": fd["divisor"], "page_size.multiplier": fd["multiplier"],
              "page_size.add": fd["add"], "page_size.shift": fd["shift"], "page_size.d": fd["d"],
              "num_heads": heads, "head_dim": head_dim, "batch_size": batch,
              "stride_page": stride_page, "stride_n": stride_n, "stride_h": stride_h,
              "v_stride_page": stride_page, "v_stride_n": stride_n, "v_stride_h": stride_h}
    fields = []
    for name, (offset, size) in layout.OFFSETS.items():
        if name in pointers:
            fields.append({"offset": offset, "ptr": pointers[name]})
        else:
            fields.append({"offset": offset, f"u{8 * size}": values.get(name, 0)})
    return Struct(tuple(fields), "paged_kv")


def kv_arrays(pages, heads, page_size, head_dim, hnd, dtype):
    shape = (pages, heads, page_size, head_dim) if hnd else (pages, page_size, heads, head_dim)
    return (Array("k_data", "out", dtype, shape), Array("v_data", "out", dtype, shape))


def append_decode(name, indptr, last, indices, heads, page_size, head_dim, cta, hnd=True,
                  dtype="bf16", check="ACCEPT", note=""):
    """`AppendPagedKVCacheDecode(paged_kv, key, value)` (:457): grid batch, block (bdx, heads);
    block `cta` writes request `cta`'s new token at seq_len - 1 = (pages - 1) page_size +
    last_page_len - 1: entry last_page_len - 1 of its last page."""
    vec, bdx = head_vec(head_dim, dtype)
    batch = len(indptr) - 1
    page = indices[indptr[cta + 1] - 1]
    pointers = {"k_data": "k_data", "v_data": "v_data", "indices": "indices", "indptr": "indptr",
                "last_page_len": "last_page_len"}
    return Case(
        name=name,
        description=f"AppendPagedKVCacheDecodeKernel, {dtype}, {'HND' if hnd else 'NHD'}, page size "
                    f"{page_size}, {heads} heads x {head_dim}, indptr {list(indptr)}, last "
                    f"{list(last)}, request {cta} -> page {page} entry {last[cta] - 1}{note}",
        source=f"{PAGE_H}:383 (AppendPagedKVCacheDecodeKernel), launcher AppendPagedKVCacheDecode :457",
        unit=PAGE,
        symbol=f"30AppendPagedKVCacheDecodeKernelILj{head_dim}ELj{vec}E{T_MANGLED[dtype]}iE",
        args=(paged_kv(heads, page_size, head_dim, batch, hnd, pointers), Ptr("key"), Ptr("value")),
        arrays=(Array("indptr", "index", "i32", (batch + 1,), contents=tuple(indptr)),
                Array("last_page_len", "index", "i32", (batch,), contents=tuple(last)),
                Array("indices", "index", "i32", (len(indices),), contents=tuple(indices)),
                Array("key", "in", dtype, (batch, heads, head_dim)),
                Array("value", "in", dtype, (batch, heads, head_dim)),
                *kv_arrays(len(indices), heads, page_size, head_dim, hnd, dtype)),
        grid=(batch, 1, 1),
        block=(bdx, heads, 1),
        check=check,
        spec=f"append_paged_kv_{'hnd' if hnd else 'nhd'}.spec",
        dims={"NP": len(indices), "H": heads, "PS": page_size, "D": head_dim, "NT": batch,
              "HS": heads, "I": cta, "PAGE": page, "ENTRY": last[cta] - 1},
        cta=(cta, 0, 0),
    )


def append(name, indptr, indices, batch_indices, positions, heads, page_size, head_dim, cta,
           stride_heads=None, hnd=True, dtype="bf16", check="ACCEPT", note=""):
    """`AppendPagedKVCache(paged_kv, key, value, batch_indices, positions, nnz, k strides
    (stride_heads head_dim, head_dim), same for v)` (:489): grid B200_SMS x min(occupancy,
    ceil(nnz / B200_SMS)) = 148 for nnz <= 148, block (bdx, heads); block `cta` < nnz appends
    token `cta` at page indices[indptr[b] + pos / page_size], entry pos % page_size."""
    vec, bdx = head_vec(head_dim, dtype)
    batch, nnz = len(indptr) - 1, len(positions)
    assert nnz <= B200_SMS
    hs = stride_heads or heads
    b, pos = batch_indices[cta], positions[cta]
    page, entry = indices[indptr[b] + pos // page_size], pos % page_size
    pointers = {"k_data": "k_data", "v_data": "v_data", "indices": "indices", "indptr": "indptr"}
    return Case(
        name=name,
        description=f"AppendPagedKVCacheKernel, {dtype}, {'HND' if hnd else 'NHD'}, page size "
                    f"{page_size}, {heads} heads x {head_dim} (append head stride {hs}), indptr "
                    f"{list(indptr)}, {nnz} tokens, token {cta} (request {b} position {pos}) -> page "
                    f"{page} entry {entry}{note}",
        source=f"{PAGE_H}:419 (AppendPagedKVCacheKernel), launcher AppendPagedKVCache :489",
        unit=PAGE,
        symbol=f"24AppendPagedKVCacheKernelILj{head_dim}ELj{vec}E{T_MANGLED[dtype]}iE",
        args=(paged_kv(heads, page_size, head_dim, batch, hnd, pointers), Ptr("key"), Ptr("value"),
              Ptr("batch_indices"), Ptr("positions"), Int(nnz, "nnz"),
              Int(hs * head_dim, "append_k_stride_n"), Int(head_dim, "append_k_stride_h"),
              Int(hs * head_dim, "append_v_stride_n"), Int(head_dim, "append_v_stride_h")),
        arrays=(Array("indptr", "index", "i32", (batch + 1,), contents=tuple(indptr)),
                Array("indices", "index", "i32", (len(indices),), contents=tuple(indices)),
                Array("batch_indices", "index", "i32", (nnz,), contents=tuple(batch_indices)),
                Array("positions", "index", "i32", (nnz,), contents=tuple(positions)),
                Array("key", "in", dtype, (nnz, hs, head_dim)),
                Array("value", "in", dtype, (nnz, hs, head_dim)),
                *kv_arrays(len(indices), heads, page_size, head_dim, hnd, dtype)),
        grid=(B200_SMS, 1, 1),
        block=(bdx, heads, 1),
        check=check,
        spec=f"append_paged_kv_{'hnd' if hnd else 'nhd'}.spec",
        dims={"NP": len(indices), "H": heads, "PS": page_size, "D": head_dim, "NT": nnz, "HS": hs,
              "I": cta, "PAGE": page, "ENTRY": entry},
        cta=(cta, 0, 0),
    )


# Three requests over six shuffled pages: 2 pages (last 3 of 5 full), 1 page (full), 3 pages
# (last holds 1). Appended tokens: request 0 positions 5..7, request 2 positions 10, 11.
INDPTR, LAST, INDICES = (0, 2, 3, 6), (3, 5, 1), (4, 0, 5, 2, 1, 3)
BATCH_IDX, POSITIONS = (0, 0, 0, 2, 2), (5, 6, 7, 10, 11)
PAGE_CASES = (
    append_decode("append_decode_hnd_ps5", INDPTR, LAST, INDICES, 3, 5, 128, cta=0,
                  note=" (fastdiv by 5, partial last page)"),
    append_decode("append_decode_hnd_full_page", INDPTR, LAST, INDICES, 3, 5, 128, cta=1,
                  note=" (last page full)"),
    append_decode("append_decode_nhd_ps16_last", (0, 1, 3), (16, 1), (1, 2, 0), 2, 16, 64, cta=1,
                  hnd=False, note=" (power-of-2 page, one-entry last page)"),
    append_decode("append_decode_f16_512", (0, 2), (4,), (1, 0), 1, 8, 512, cta=0, dtype="f16",
                  note=" (vec 16)"),
    append("append_hnd_ps5_tok2", INDPTR, INDICES, BATCH_IDX, POSITIONS, 3, 5, 128, cta=2,
           note=" (crosses into page 2 of request 0)"),
    append("append_nhd_ps5_tok4_strided", INDPTR, INDICES, BATCH_IDX, POSITIONS, 3, 5, 128, cta=4,
           stride_heads=7, hnd=False, note=" (k/v from a fused qkv, last token)"),
    append("append_hnd_ps16_256", (0, 1, 2), (1, 0), (0, 1, 1), (15, 0, 1), 1, 16, 256, cta=0,
           note=" (last entry of a page)"),
    append("append_nhd_f16_64", (0, 3), (2, 1, 0), (0, 0), (7, 12), 4, 6, 64, cta=1, hnd=False,
           dtype="f16", note=" (fastdiv by 6)"),
)
PAGE_CASES += (
    negative(PAGE_CASES[0], "spec writes entry 1", ENTRY=1),
    negative(PAGE_CASES[4], "spec writes the next page", PAGE=5),
    negative(PAGE_CASES[5], "spec takes token 3", I=3),
)

CASES = NORM_CASES + CASCADE_CASES + ROPE_CASES + PAGE_CASES
