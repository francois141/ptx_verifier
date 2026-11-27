"""The PTX frameworks' evaluation table: per framework, kernels tested, verified, findings and
incomplete, from the case registries (`<framework>/cases.py`, each case's expected verdict) and
the race sweeps' outcomes (`output/<framework>.csv`, written by `races.py`).

    python3 external/ptx/eval_table.py            # markdown table on stdout

A kernel is one PTX entry (a case's unit and symbol; a race-sweep launch's PTX stem). A kernel
with a triaged finding counts under Findings only; any other is *verified* when one of its runs is ACCEPT (race free and equal to its spec) or VERIFIED/RACE-FREE
(race free, no spec), *incomplete* when none is and some run stopped at a Volta gap (ABORT,
UNKNOWN, ERROR, UNSUPPORTED, MEMORY), and otherwise rejected. Rejections are not all findings
(benign equal-value races, open modeling questions), so `FINDINGS` lists the triaged ones by
hand, with `bugs_PTX/volta_findings.txt`'s numbering.
"""

import csv
import importlib.util
import sys
from collections import defaultdict
from pathlib import Path

PTX_ROOT = Path(__file__).resolve().parent
OUTPUT = PTX_ROOT / "output"

# Volta-found, triaged findings per framework (volta_findings.txt). "latent" are UB per the ISA
# that likely works on today's hardware; "known" were reported elsewhere first.
FINDINGS = {  # finding -> substrings of the kernels (registry unit:symbol, or sweep stem) it covers
    "vllm": {"hadacore cp.async race (4c)": ["hadamard_transform_kernel"]},
    "flashinfer": {"MergeStateInPlace LSE race (4d)": ["MergeStateInPlaceKernel"]},
    "flash-attention": {"split-KV combine out-of-bounds LSE write (4b)": ["splitkv_combine"]},
    "DeepGEMM": {"tcgen05.ld lane-quadrant UB, latent (4)": ["sm100_"]},
    "Gluon": {"missing tcgen05 fences between cross-warp st and mma (1)":
              ["06-tcgen05/small_mma", "11-tcgen05-mma-scaled/mma_scaled_packed_block",
               "11-tcgen05-mma-scaled/mma_scaled_contig", "11-tcgen05-mma-scaled/simple_mma_scaled"],
              "CLC get_first_ctaid on a declined response, latent (7)":
              ["=12-cluster-launch-control/persistent_matmul_kernel"]},
    "ThunderKittens": {"level_06 parity-aliasing hang, latent (5)": ["level_06"]},
    "AI compiler": {"Mamba2ChunkScanForward missing fence.proxy.async (3)":
                    ["Mamba2ChunkScanForward"],
                    "FusedGEMMAddSiLU parity-aliasing hang, latent (6)":
                    ["=sm_100a/FusedGEMMAddSiLUFloat16Kernel/kernel_1"]},
    "TileLang": {"warp-specialize copy race, known (2)": ["matmul_warp_specialize_copy_gemm_0_1"],
                 "tcgen05 pipeliner stage-reuse race, known (2b)": ["gemm_sm100/matmul_kernel"]},
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


def classify(verdicts: set[str]) -> str:
    if verdicts & VERIFIED:
        return "verified"
    if verdicts & INCOMPLETE:
        return "incomplete"
    return "rejected"


def main() -> int:
    lines = ["| Framework | Tested | Verified | Findings (kernels) | Incomplete | "
             "Rejected, not a finding |", "|---|---:|---:|---|---:|---:|"]
    for row, registry, sweep in ROWS:
        kernels = {}
        if registry:
            kernels.update(registry_verdicts(registry))
        if sweep:
            kernels.update(sweep_verdicts(sweep))
        kernels.update({k: {v} for k, v in MANUAL.get(row, {}).items()})
        findings = FINDINGS.get(FINDING_KEYS.get(row, row), {})
        def covers(mark: str, kernel: str) -> bool:  # "=stem" matches one kernel exactly
            return kernel == mark[1:] if mark.startswith("=") else mark in kernel
        found = {name: sorted(k for k in kernels if any(covers(m, k) for m in marks))
                 for name, marks in findings.items()}
        with_finding = {k for ks in found.values() for k in ks}
        counts = defaultdict(int)
        for kernel, verdicts in kernels.items():
            if kernel in with_finding:
                continue
            counts[classify(verdicts)] += 1
        text = "; ".join(f"{name} ({len(ks)})" for name, ks in found.items()) or "—"
        lines.append(f"| {row} | {len(kernels) or '—'} | {counts['verified'] or '—'} | {text} | "
                     f"{counts['incomplete'] or '—'} | {counts['rejected'] or '—'} |")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
