"""The PTX frameworks' evaluation table: per framework, kernels tested, verified, findings and
incomplete, from the case registries (`<framework>/cases.py`, each case's expected verdict) and
the race sweeps' outcomes (`output/<framework>.csv`, written by `races.py`).

    python3 external/ptx/eval_table.py            # markdown table on stdout

A kernel is one PTX entry (a case's unit and symbol; a race-sweep launch's PTX stem). A kernel
with a triaged finding counts under Findings only; any other is *verified* when one of its runs is ACCEPT (race free and equal to its spec) or VERIFIED/RACE-FREE
(race free, no spec), *incomplete* when none is and some run stopped at a Volta gap (ABORT,
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
    "TensorRT-LLM": {"in-place MLA merge softmax-stats race, latent (4e)": ["mergeAttnWithSoftmaxKernel"]},
    "flashinfer": {"MergeStateInPlace LSE race, latent (4d)": ["MergeStateInPlaceKernel"]},
    "flash-attention": {"split-KV combine out-of-bounds LSE write (4b)": ["splitkv_combine"]},
    "DeepGEMM": {"tcgen05.ld lane-quadrant UB, latent (4)": ["sm100_"]},
    "Gluon": {"missing tcgen05 fences between cross-warp st and mma, latent (1)":
              ["06-tcgen05/small_mma", "11-tcgen05-mma-scaled/mma_scaled_packed_block",
               "11-tcgen05-mma-scaled/mma_scaled_contig", "11-tcgen05-mma-scaled/simple_mma_scaled"],
              "CLC get_first_ctaid on a declined response, latent (7)":
              ["=12-cluster-launch-control/persistent_matmul_kernel"]},
    "ThunderKittens": {"level_06 parity-aliasing hang, latent (5)": ["level_06"]},
    "AI compiler": {"Mamba2ChunkScanForward missing fence.proxy.async, latent (3)":
                    ["Mamba2ChunkScanForward"],
                    "FusedGEMMAddSiLU parity-aliasing hang, latent (6)":
                    ["=sm_100a/FusedGEMMAddSiLUFloat16Kernel/kernel_1"]},
    "TileLang": {"warp-specialize copy race (2)": ["matmul_warp_specialize_copy_gemm_0_1"],
                 "tcgen05 pipeliner stage-reuse race (2b)": ["gemm_sm100/matmul_kernel"]},
}

# Triaged rejections that are not findings, per row: category -> kernel markers (as FINDINGS).
# "benign": a formal race of equal values (Volta has no equal-store exception by design) or a
# formal cross-lane race harmless in practice; "open": a verdict resting on an open modeling
# question of volta_findings.txt ((a) happens-before through tracked async ops, (c) the
# proxy-order pair named); "lead": a defect read in the code before Volta reported it, which
# the evaluation does not count. A rejection under no marker is "untriaged".
REJECTIONS = {
    "FlashInfer": {"benign": ["MergeStatesLargeNumIndexSetsKernel",
                              "PersistentVariableLengthMergeStatesKernel"]},
    "TensorRT-LLM": {"lead": ["prepareAttentionMaskIiLNS1_17AttentionMaskTypeE2EE"]},
    "ThunderKittens": {"open": ["level_07", "level_08"]},
    "TileLang": {"benign": ["gemv/naive_gemv", "gemv/splitk_gemv_vectorized_tvm"]},
    "Gluon": {"benign": ["04-tma/", "06-tcgen05/tmem_example", "10-tcgen05-copy/tcgen05_copy"],
              "open": ["06-tcgen05/blocked_matmul", "07-persistence/",
                       "11-tcgen05-mma-scaled/mma_scaled_tcgen05_copy",
                       "12-cluster-launch-control/persistent_matmul_kernel_v2",
                       "13-conv-im2col/"]},
    "AI compiler": {"benign": ["sm_89/MatrixVectorMultiplicationFloat8Kernel"],
                    "open": ["sm_100a/FusedGEMMAddGELUFloat8Kernel"]},
}

ROWS = [  # (table row, case registry, race sweep csv)
    ("CUTLASS", None, None),
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
MANUAL = {"DeepGEMM": {"sm100_bf16_gemm": "ACCEPT", "sm100_fp8_gemm": "VERIFIED",
                       "sm100_mqa_logits": "UNKNOWN"}}

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
    kernels = defaultdict(set)
    for row in csv.DictReader(path.open()):
        kernels[row["launch"].split(".")[0]].add(row["outcome"])
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
        found = {name: sorted(k for k in kernels if any(covers(m, k) for m in marks))
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
