"""The PTX frameworks' evaluation table: per framework, kernels tested, verified, findings and
incomplete, from the case registries (`<framework>/cases.py`, each case's expected verdict) and
the race sweeps' outcomes (`output/<framework>.csv`, written by `races.py`).

    python3 external/ptx/eval_table.py            # markdown table on stdout

A kernel is one PTX entry (a case's unit and symbol; a race-sweep launch's PTX stem, with its
`kernel` when one PTX holds several launched entries, as ThunderKittens' unit tests do). A kernel
with a failing run (not ACCEPT/VERIFIED) covered by a triaged finding counts under Findings only; any other is *verified* when one of its runs is ACCEPT (race free and equal to its spec) or VERIFIED/RACE-FREE
(race free, no spec; a sweep run checked against a spec that refutes it is rejected), *incomplete* when none is and some run stopped at a Volta gap (ABORT,
UNKNOWN, ERROR, UNSUPPORTED, MEMORY), and otherwise rejected. Rejections are not all findings, so `FINDINGS` lists the triaged bugs
by hand, with `bugs_PTX/volta_findings.txt`'s numbering, and `REJECTIONS` the other rejected
kernels by category (benign race, open question, uncounted lead); any left over is untriaged.
"""

import csv
import importlib.util
import sys
from collections import defaultdict
from pathlib import Path

PTX_ROOT = Path(__file__).resolve().parent
OUTPUT = PTX_ROOT / "output"

# Volta-found findings per framework (volta_findings.txt), each independently verified as real
# (bugs_PTX/verification/SUMMARY.md, which also records upstream status, irrelevant here: a
# finding counts if Volta detects it). "latent": real per the ISA or memory model, unlikely to
# misbehave on today's hardware.
FINDINGS = {  # finding -> substrings of the kernels (registry unit:symbol, or sweep stem) it covers
    "vllm": {"hadacore cp.async race, latent (4c)": ["hadamard_transform_kernel"],
             "fused-A GEMM mbarrier re-init, latent (4f)": ["csrc/dsv3_fused_a_gemm.cu:"]},
    "TensorRT-LLM": {"in-place MLA merge softmax-stats race, latent (4e)": ["mergeAttnWithSoftmaxKernel"],
                     "fused-A GEMM generic-address arrive and mbarrier re-init, latent (8, 9)":
                     ["dsv3FusedAGemm.cu:"],
                     "Kimi-K3 TMEM lane quadrant and ld-before-dealloc order, latent (10, 11)":
                     ["kimiK3AttnRes/attnResFwd"],
                     "GroupRMSNorm shared-memory race (12)": ["groupRmsNormKernels.cu:"],
                     "per-channel scale past the last row, latent (13)": ["preQuantScaleKernel.cu:"]},
    "flashinfer": {"MergeStateInPlace LSE race, latent (4d)": ["MergeStateInPlaceKernel"]},
    "flash-attention": {"split-KV combine out-of-bounds LSE write (4b)": ["splitkv_combine"]},
    "DeepGEMM": {"tcgen05.ld lane-quadrant UB, latent (4)": ["sm100_"]},
    "Gluon": {"missing tcgen05 fences between cross-warp st and mma, latent (1)":
              ["06-tcgen05/small_mma", "11-tcgen05-mma-scaled/mma_scaled_packed_block",
               "11-tcgen05-mma-scaled/mma_scaled_contig", "11-tcgen05-mma-scaled/simple_mma_scaled"],
              "CLC get_first_ctaid on a declined response, latent (7)":
              ["=12-cluster-launch-control/persistent_matmul_kernel"]},
    "ThunderKittens": {"level_06 parity-aliasing hang, latent (5)": ["level_06"],
                       # thunderkittens/bugs.txt's numbering; each fix verifies (thunderkittens/patched/)
                       "TMA unit tests reuse smem without a warp sync (TK-2, TK-3, TK-6)":
                       ["units/thread_memory_tile_tma", "units/thread_memory_vec_tma"],
                       "tcgen05 unit test per-warp mbarrier init, parity reuse (TK-4, TK-7)":
                       ["units/group_mma_tensor_mma"],
                       "managed tensor_allocator deallocs before other warps' TMEM reads (TK-5)":
                       ["units/group_memory_tile_tensor_to_register"]},
    "AI compiler": {"Mamba2ChunkScanForward missing fence.proxy.async, latent (3)":
                    ["Mamba2ChunkScanForward"],
                    "FusedGEMMAddSiLU parity-aliasing hang, latent (6)":
                    ["=sm_100a/FusedGEMMAddSiLUFloat16Kernel/kernel_1"]},
    "TileLang": {"warp-specialize copy race (2)": ["matmul_warp_specialize_copy_gemm_0_1"],
                 "tcgen05 pipeliner stage-reuse race (2b)": ["gemm_sm100/matmul_kernel"]},
    # tritonbench/bugs.txt's numbering; each reproducing size has a control size that verifies
    "Triton": {"relu, softmax, layer-norm and masked-softmax outputs unwritten or wrong (TB-1 to TB-4)":
               ["relu_triton_kernel/", "triton_softmax/", "layer_norm_liger/", "ksoftmax_triton/"],
               "kldiv chunk sums stored past the output (TB-5)": ["kldiv_triton/"],
               "l2-norm output indexed with the input's row stride (TB-6, TB-7)":
               ["l2_norm_triton1/", "l2_norm_triton2/"],
               "nested3 pointer walk out of bounds, overlapping stores (TB-8)":
               ["nested_loops_processing/nested3"],
               "chunk_gla A_intra allocated with BT rows, not T (TB-9)":
               ["chunk_gla_fwd/chunk_gla_fwd_A_kernel_intra_sub_intra_merge"],
               "backward kernels read a stride-0 output gradient as dense (TB-10 to TB-13)":
               ["chunk_linear_attn/chunk_linear_attn_bwd", "fused_recurrent_hgrn/fused_recurrent_hgrn_bwd",
                "fused_recurrent_retention/fused_recurrent_retention_bwd",
                "parallel_attention/parallel_rebased_bwd"],
               "attention block pointers without boundary checks (TB-14)":
               ["=attention_fwd_triton1/attention_fwd_kernel_v5"]},
}

# Triaged rejections that are not findings, per row: category -> kernel markers (as FINDINGS).
# "benign": a formal race of equal values (Volta has no equal-store exception by design) or a
# formal cross-lane race harmless in practice; "open": a verdict resting on an open modeling
# question of volta_findings.txt ((a) happens-before through tracked async ops, (c) the
# proxy-order pair named); "lead": a defect read in the code before Volta reported it, which
# the evaluation does not count; "gap": a rejection that is Volta's own error (a false refutation
# from its exact-real model, a false deadlock from matching warp collectives at one pc), counted
# as incomplete. A rejection under no marker is "untriaged".
REJECTIONS = {
    "FlashInfer": {"benign": ["MergeStatesLargeNumIndexSetsKernel",
                              "PersistentVariableLengthMergeStatesKernel"]},
    "vLLM": {"gap": ["topk_softplus_sqrt_f16_int64.cu:22topkGatingSoftplusSqrtILi8ELi32ELi4ELi16ELi32ELb1Ell6__halfEE"]},
    "TensorRT-LLM": {"lead": ["prepareAttentionMaskIiLNS1_17AttentionMaskTypeE2EE"],
                     "gap": ["mhcHcHeadApply"]},
    "ThunderKittens": {"open": ["level_07", "level_08"]},
    "TileLang": {"benign": ["gemv/naive_gemv", "gemv/splitk_gemv_vectorized_tvm"]},
    # tritonbench/bugs.txt's B-1: replicas store a reduction's one value to one shared slot
    "Triton": {"benign": ["chunk_gla_fwd/chunk_gla_fwd_A_kernel_intra_sub_intra",
                          "fused_recurrent_retention/fused_recurrent_retention_fwd",
                          "parallel_attention/parallel_rebased_fwd"]},
    "Gluon": {"benign": ["04-tma/", "06-tcgen05/tmem_example", "10-tcgen05-copy/tcgen05_copy"],
              "open": ["06-tcgen05/blocked_matmul", "07-persistence/",
                       "11-tcgen05-mma-scaled/mma_scaled_tcgen05_copy",
                       "12-cluster-launch-control/persistent_matmul_kernel_v2",
                       "13-conv-im2col/"]},
    # cutlass/bugs.txt's CL-1 (NVIDIA/cutlass#3946): every lane of the storing warp issues the same
    # TMA store, a race of equal values; each fixed copy (cutlass/patched/) is race free
    "CUTLASS": {"benign": ["=gemm_bf16_tn_128x128", "gemm_bf16_nt_", "gemm_f16_nn_", "gemm_bf16_tn_colmajor_d",
                           "gemm_bf16_tn_64x128", "gemm_f16_tn_128x256", "gemm_e4m3_tn_", "gemm_bf16_tn_2stage",
                           "gemm_bf16_tn_batched", "gemm_bf16_tn_clc", "gemm_f16_tn_raster", "gemm_bf16_tn_relu",
                           "gemm_bf16_tn_silu", "gemm_bf16_tn_gelu"]},
    "AI compiler": {"benign": ["sm_89/MatrixVectorMultiplicationFloat8Kernel"],
                    "open": ["sm_100a/FusedGEMMAddGELUFloat8Kernel"]},
}

ROWS = [  # (table row, case registry, race sweep csv)
    ("CUTLASS", None, "cutlass"),
    ("DeepGEMM", None, None),
    ("FlashAttention", "flash-attention", None),
    ("FlashInfer", "flashinfer", None),
    ("FlashMLA", "FlashMLA", None),
    ("TensorRT-LLM", "TensorRT-LLM", None),
    ("ThunderKittens", None, "thunderkittens"),
    ("TileLang", None, "tilelang"),
    ("TIRx", None, None),
    ("Triton", None, "tritonbench"),
    ("Gluon", None, "gluon"),
    ("vLLM", "vllm", None),
    ("AI compiler", None, "ai_compiler"),  # LLM-written PTX (sm_100a, sm_90a, sm_89), not a framework
]
FINDING_KEYS = {"FlashAttention": "flash-attention", "vLLM": "vllm", "FlashInfer": "flashinfer"}
# DeepGEMM's three kernels are run by hand from external/ptx/deepgemm/ (no registry yet).
# Their shipped PTX stops at the lane-quadrant finding (4); with the lane offset patched in,
# bf16 is ACCEPT and fp8 VERIFIED.
MANUAL = {"DeepGEMM": {"sm100_bf16_gemm": "ABORT", "sm100_fp8_gemm": "ABORT",
                       "sm100_mqa_logits": "ABORT"}}

VERIFIED = {"ACCEPT", "VERIFIED", "RACE-FREE"}
INCOMPLETE = {"ABORT", "UNKNOWN", "ERROR", "UNSUPPORTED", "MEMORY"}


def registry_verdicts(framework: str) -> dict[str, set[str]]:
    path = PTX_ROOT / framework / "cases.py"
    if not path.exists():
        return {}
    spec = importlib.util.spec_from_file_location(f"{framework}_eval", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    kernels = defaultdict(set)
    for case in module.CASES:
        if "patched/" in case.unit:  # a fixed copy of a kernel (a finding's control), not shipped
            continue
        symbol = case.symbol if isinstance(case.symbol, str) else "+".join(case.symbol)
        kernels[f"{case.unit}:{symbol}"].add(case.check)
    return kernels


def sweep_verdicts(name: str) -> dict[str, set[str]]:
    path = OUTPUT / f"{name}.csv"
    if not path.exists():
        return {}
    rows = list(csv.DictReader(path.open()))
    entries = defaultdict(set)
    for row in rows:
        entries[row["launch"].split(".")[0]].add(row.get("kernel", ""))
    kernels = defaultdict(set)
    for row in rows:
        stem = row["launch"].split(".")[0]
        if stem.startswith("patched/"):  # a fixed copy of a kernel (a finding's control), not shipped
            continue
        key = stem if len(entries[stem]) == 1 else f"{stem}:{row['kernel']}"
        refuted = row.get("spec") == "REJECT" and row["outcome"] in VERIFIED
        kernels[key].add("REJECT" if refuted else row["outcome"])
    return kernels


def covers(mark: str, kernel: str) -> bool:
    """Whether a FINDINGS/REJECTIONS marker covers `kernel`: "=stem" one kernel exactly."""
    return kernel == mark[1:] if mark.startswith("=") else mark in kernel


def classify(verdicts: set[str]) -> str:
    if verdicts & VERIFIED:
        return "verified"
    if verdicts & INCOMPLETE:
        return "incomplete"
    return "rejected"


def main() -> int:
    lines = ["| Framework | Tested | Verified | Findings (kernels) | Incomplete | Benign race | "
             "Open question | Uncounted lead | Untriaged |", "|---|---:|---:|---|---:|---:|---:|---:|---:|"]
    for row, registry, sweep in ROWS:
        kernels = {}
        if registry:
            kernels.update(registry_verdicts(registry))
        if sweep:
            kernels.update(sweep_verdicts(sweep))
        kernels.update({k: {v} for k, v in MANUAL.get(row, {}).items()})
        findings = FINDINGS.get(FINDING_KEYS.get(row, row), {})
        found = {name: sorted(k for k in kernels if any(covers(m, k) for m in marks)
                              and kernels[k] - VERIFIED)
                 for name, marks in findings.items()}
        with_finding = {k for ks in found.values() for k in ks}
        triage = REJECTIONS.get(row, {})
        counts = defaultdict(int)
        for kernel, verdicts in kernels.items():
            if kernel in with_finding:
                continue
            outcome = classify(verdicts)
            if outcome == "rejected":
                outcome = next((category for category, marks in triage.items()
                                if any(covers(m, kernel) for m in marks)), "untriaged")
                outcome = "incomplete" if outcome == "gap" else outcome
            counts[outcome] += 1
        text = "; ".join(f"{name} ({len(ks)})" for name, ks in found.items()) or "—"
        cells = [counts[c] or "—" for c in
                 ("verified", "incomplete", "benign", "open", "lead", "untriaged")]
        lines.append(f"| {row} | {len(kernels) or '—'} | {cells[0]} | {text} | "
                     + " | ".join(str(c) for c in cells[1:]) + " |")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
