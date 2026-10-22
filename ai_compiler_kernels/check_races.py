"""Check the kernels under `ai_compiler_kernels/` for data races with Volta.

Builds the release `volta` CLI, then runs `volta analyze` on each kernel:

    python3 ai_compiler_kernels/check_races.py                    # every kernel
    python3 ai_compiler_kernels/check_races.py softmax matvec     # whole families
    python3 ai_compiler_kernels/check_races.py --kernel PATH.ptx  # one kernel
    python3 ai_compiler_kernels/check_races.py --list             # what is configured
    python3 ai_compiler_kernels/check_races.py --debug            # stream volta's stage log
    python3 ai_compiler_kernels/check_races.py --color always     # color even through a pipe
    python3 ai_compiler_kernels/check_races.py --mutate                    # remove each sync of every kernel
    python3 ai_compiler_kernels/check_races.py --mutate --kernel PATH.ptx  # ... of one kernel
    python3 ai_compiler_kernels/check_races.py --mutate --list             # the removable statements
    python3 ai_compiler_kernels/check_races.py --mutate --kernel PATH.ptx --site 160   # one statement

Volta analyzes CTA 0 only (`%ctaid` reads 0), so each array is sized to
what CTA 0 can reach: an access outside it is an `OutOfBounds` error rather
than a silently accepted read.

`--mutate` is the negative test. From each kernel Volta verifies race-free it
removes one `bar.sync`, `tcgen05.fence::before_thread_sync`,
`tcgen05.fence::after_thread_sync`, `tcgen05.alloc` or `tcgen05.dealloc`
statement at a time (its label and guard stay, line numbers do not move) and
analyzes the mutant. A mutant Volta rejects (a race condition, another failed
check or a deadlock) is caught. One whose execution stops without a verdict
proves nothing and is listed as such (removing a `tcgen05.alloc` leaves the
tensor-memory address symbolic, for instance). One still verified RACE-FREE
has SURVIVED: a missing synchronization Volta did not notice. One volta itself
failed to run is NOT RUN. The exit status is 1 if any survived or was not run.
"""

import argparse
import enum
import json
import os
import re
import subprocess
import sys
import tempfile
import threading
import time
from collections.abc import Callable
from dataclasses import dataclass
from functools import partial
from pathlib import Path

KERNEL_ROOT = Path(__file__).resolve().parent
REPO_ROOT = KERNEL_ROOT.parent
VOLTA = REPO_ROOT / "target" / "release" / "volta"
ARRAY_ALIGN = 0x10000
DUMMY_PARAMS = 2  # dummy_ptr1, dummy_ptr2: declared, never dereferenced
# The JSON files give no shared size: grant each target's opt-in maximum.
MAX_DYNAMIC_SHARED = {"sm_89": 99 * 1024, "sm_90a": 227 * 1024, "sm_100a": 227 * 1024}
F32 = 4
U32 = 4
F16 = 2
E4M3 = 1
I8 = 1


class Kind(enum.Enum):
    INPUT = "in"
    OUTPUT = "out"
    INPUT_OUTPUT = "inout"
    INDEX = "index"


@dataclass(frozen=True)
class Array:
    name: str
    elem_width: int
    len: int
    kind: Kind


@dataclass(frozen=True)
class Int:
    value: int


@dataclass(frozen=True)
class Reduction:
    """The K loop cut to `iterations` of `full_iterations` by rewriting its trip constants.

    Each patch replaces one exact, unique source line; addresses and strides are untouched.
    """

    iterations: int
    full_iterations: int
    patches: tuple[tuple[str, str], ...]


@dataclass(frozen=True)
class Variant:
    folder: str
    stem: str
    block: tuple[int, int, int]
    # Bound in order to the kernel's parameters before the two dummy pointers.
    params: tuple[Array | Int, ...]
    expected_outputs: int
    # Only CTA 0 runs whatever the grid; it sets what `%nctaid` reads.
    grid: tuple[int, int, int] = (1, 1, 1)
    # Set only where the full kernel cannot be analyzed in this machine's memory.
    reduction: Reduction | None = None

    @property
    def name(self) -> str:
        return f"{self.folder}/{self.stem}"

    @property
    def path(self) -> Path:
        return KERNEL_ROOT / self.folder / f"{self.stem}.ptx"


class Outcome(enum.Enum):
    RACE_FREE = "RACE-FREE"
    REDUCED_RACE_FREE = "RACE-FREE*"
    RACE_CONDITION = "RACE-CONDITION"
    CHECK_FAILED = "CHECK-FAILED"
    DEADLOCK = "DEADLOCK"
    UNSUPPORTED = "UNSUPPORTED"
    UNKNOWN = "UNKNOWN"
    ERROR = "ERROR"


OUTCOME_WIDTH = max(len(outcome.value) for outcome in Outcome)
# `Property::name`s of the checks whose failure is a race condition: an unordered
# conflicting access (Algorithm 2 on global/shared memory, Algorithm 4 on Tensor Memory) or
# a cross-proxy pair no proxy fence orders (Algorithm 3).
RACE_CHECKS = ("memory-conflict freedom", "proxy ordering", "tensor-operation ordering")
# A construct Volta does not model, rejected at lowering or when the execution reaches it.
LOWERING_FAILED = re.compile(r"\blowering failed: (.*)")
EXECUTION_UNSUPPORTED = re.compile(r"^the execution stopped: (unsupported at .*)")
CHECK_LINE = re.compile(r"^  (\S.*?) \(Algorithms? [^)]*\)\s+(PASS|FAIL|UNKNOWN)$")
VERDICT_LINE = re.compile(r"^GRAPH VERIFICATION: (VERIFIED|REJECTED|UNKNOWN)")
WRITTEN_LINE = re.compile(r"^  output '[^']*': (\d+) element\(s\) written$")
NO_OUTPUTS_LINE = re.compile(r"^  no outputs: (.*)$")
DEADLOCK_LINE = re.compile(r"^  trace: deadlock")
LOG_LINE = re.compile(r"^\[(ERROR|WARN|INFO|DEBUG|TRACE) *\] ")

# ANSI SGR codes.
BOLD, DIM, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN = "1", "2", "31", "32", "33", "34", "35", "36"
LEVEL_CODES = {
    "ERROR": (BOLD, RED),
    "WARN": (BOLD, YELLOW),
    "INFO": (DIM,),
    "DEBUG": (DIM,),
    "TRACE": (DIM,),
}
STAGE_TAG = re.compile(r"\[(analysis|graph|equivalence)\]")
STAGE_CODES = {"analysis": (BOLD, CYAN), "graph": (BOLD, BLUE), "equivalence": (BOLD, MAGENTA)}
VERDICT_CODES = {
    "PASS": (BOLD, GREEN),
    "EQUIVALENT": (BOLD, GREEN),
    "FAIL": (BOLD, RED),
    "FAILED": (BOLD, RED),
    "REFUTED": (BOLD, RED),
    "UNKNOWN": (BOLD, YELLOW),
    "UNPROVEN": (BOLD, YELLOW),
    "skipped": (YELLOW,),
}
VERDICT_WORD = re.compile(r"\b(" + "|".join(VERDICT_CODES) + r")\b")
OUTCOME_CODES = {
    Outcome.RACE_FREE: (BOLD, GREEN),
    Outcome.REDUCED_RACE_FREE: (BOLD, YELLOW),
    Outcome.RACE_CONDITION: (BOLD, RED),
    Outcome.CHECK_FAILED: (BOLD, RED),
    Outcome.DEADLOCK: (BOLD, RED),
    Outcome.UNSUPPORTED: (BOLD, YELLOW),
    Outcome.UNKNOWN: (BOLD, YELLOW),
    Outcome.ERROR: (BOLD, RED),
}


@dataclass(frozen=True)
class Style:
    """ANSI colors when `enabled`, plain text otherwise."""

    enabled: bool

    def paint(self, text: str, *codes: str) -> str:
        return f"\033[{';'.join(codes)}m{text}\033[0m" if self.enabled else text

    def log_line(self, line: str) -> str:
        """One line of volta's stderr: a log record, or (unprefixed) an error message."""
        level = LOG_LINE.match(line)
        if level is None:
            return self.paint(line, RED)
        body = STAGE_TAG.sub(lambda m: self.paint(m[0], *STAGE_CODES[m[1]]), line[level.end():])
        body = VERDICT_WORD.sub(lambda m: self.paint(m[0], *VERDICT_CODES[m[1]]), body)
        return f"{self.paint(level[0].rstrip(), *LEVEL_CODES[level[1]])} {body}"


@dataclass(frozen=True)
class CliReport:
    """What `volta analyze` printed; `verdict` is None when it stopped before one."""

    verdict: str | None
    checks: tuple[tuple[str, str, str], ...]  # (check, PASS|FAIL|UNKNOWN, first finding)
    written: int
    no_outputs: str | None
    deadlock: bool
    reasons: tuple[str, ...]


def parse_cli(stdout: str) -> CliReport:
    verdict, checks, written, no_outputs, deadlock, reasons = None, [], 0, None, False, []
    for line in stdout.splitlines():
        if checks and checks[-1][2] == "" and line.startswith("      "):
            checks[-1] = (*checks[-1][:2], line.strip())
        elif m := CHECK_LINE.match(line):
            checks.append((m[1], m[2], ""))
        elif m := VERDICT_LINE.match(line):
            verdict = m[1]
        elif verdict and line.startswith("  "):
            reasons.append(line.strip())
        elif m := WRITTEN_LINE.match(line):
            written += int(m[1])
        elif m := NO_OUTPUTS_LINE.match(line):
            no_outputs = m[1]
        elif DEADLOCK_LINE.match(line):
            deadlock = True
    return CliReport(verdict, tuple(checks), written, no_outputs, deadlock, tuple(reasons))


class VoltaFailure(Exception):
    """volta stopped before any verdict: a command-line, configuration or internal error."""


def classify(report: CliReport, stderr: str, expected_outputs: int) -> tuple[Outcome, str]:
    if report.verdict is None:
        errors = "\n".join(line for line in stderr.splitlines() if not LOG_LINE.match(line))
        error = " ".join(errors.split()) or "volta produced no verdict"
        if m := LOWERING_FAILED.search(error):
            return Outcome.UNSUPPORTED, m[1]
        raise VoltaFailure(error)
    coverage = f"{report.written}/{expected_outputs} tile outputs written"
    findings = [f"{check}: {finding}" for check, verdict, finding in report.checks if verdict != "PASS"]
    if report.verdict == "VERIFIED":
        return Outcome.RACE_FREE, coverage
    if report.verdict == "REJECTED":
        failed = [(check, finding) for check, verdict, finding in report.checks if verdict == "FAIL"]
        if any(check in RACE_CHECKS for check, _ in failed):
            outcome = Outcome.RACE_CONDITION
        else:
            outcome = Outcome.DEADLOCK if report.deadlock else Outcome.CHECK_FAILED
        return outcome, "; ".join([f"{check}: {finding}" for check, finding in failed] or report.reasons)
    if report.no_outputs is not None:
        if m := EXECUTION_UNSUPPORTED.match(report.no_outputs):
            return Outcome.UNSUPPORTED, m[1]
        return Outcome.ERROR, report.no_outputs
    return Outcome.UNKNOWN, "; ".join([coverage, *(findings or report.reasons)])


@dataclass(frozen=True)
class Report:
    variant: Variant
    outcome: Outcome
    detail: str
    seconds: float


def input_width(stem: str) -> int:
    if "_Float8_" in stem:
        return E4M3
    if "_Float16_" in stem:
        return F16
    raise ValueError(f"{stem}: no Float8/Float16 dtype in the name")


def load_launch(folder: str, stem: str) -> dict:
    return json.loads((KERNEL_ROOT / folder / f"{stem}.json").read_text())


def block_dims(launch: dict) -> tuple[int, int, int]:
    return (launch["num_threads_x"], launch["num_threads_y"], launch["num_threads_z"])


def inp(name: str, elem_width: int, len: int) -> Array:
    return Array(name, elem_width, len, Kind.INPUT)


def out(name: str, elem_width: int, len: int) -> Array:
    return Array(name, elem_width, len, Kind.OUTPUT)


def inout(name: str, elem_width: int, len: int) -> Array:
    return Array(name, elem_width, len, Kind.INPUT_OUTPUT)


def elementwise_variants(
    folder: str, tiles: dict[str, int], inputs: tuple[str, ...]
) -> list[Variant]:
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                *(inp(name, input_width(stem), tile) for name in inputs),
                out("output", F16, tile),
            ),
            expected_outputs=tile,
        )
        for stem, tile in tiles.items()
    ]


# Elementwise tiles: elements per CTA, from each kernel's `%ctaid.x` stride.
# Every variant stores f16, Float8 ones included.
RELU_TILES = {
    "NVIDIA_B200_Float16_1.0000x": 1024,
    "NVIDIA_B200_Float8_1.0000x": 2048,
}
SIGMOID_TILES = {
    "NVIDIA_B200_Float16_1.0001x": 1024,
    "NVIDIA_B200_Float8_1.0000x": 1024,
}
SILU_TILES = {
    "NVIDIA_B200_Float16_1.0000x": 512,
    "NVIDIA_B200_Float8_1.0000x": 1024,
}
SWIGLU_TILES = {
    "NVIDIA_B200_Float16_1.0001x": 1024,
    "NVIDIA_B200_Float8_1.0000x": 2048,
}


# Rows of 4096 elements (one per ctaid.y), cut into tiles over ctaid.x; each tile adds its
# sum into output[ctaid.y] atomically, so output is read-modify-write. CTA 0 reads row 0's
# first tile.
REDUCTION_SUM_TILES = {
    "NVIDIA_B200_Float16_1.0828x": 256,
    "NVIDIA_B200_Float8_1.0017x": 2048,
}


def reduction_sum_variants() -> list[Variant]:
    folder = "ReductionSumKernel"
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (inp("x", input_width(stem), tile), inout("output", F32, 1)),
            expected_outputs=1,
        )
        for stem, tile in REDUCTION_SUM_TILES.items()
    ]


# Every variant hardcodes one problem: NCHW x[N, 64, 56, 56], weight[128, 64, 3, 3],
# out[N, 128, 54, 54]. CTA 0's pixels all lie in image 0, so one image suffices.
CONV_C_IN, CONV_C_OUT, CONV_H_IN, CONV_H_OUT, CONV_TAPS = 64, 128, 56, 54, 9
CONV2D_STEMS = [
    "NVIDIA_B200_Float16_1.3590x",
    "NVIDIA_B200_Float8_2.0810x",
]


def conv2d_variants() -> list[Variant]:
    folder = "Convolution2DKernel"
    variants = []
    for stem in CONV2D_STEMS:
        launch = load_launch(folder, stem)
        width = input_width(stem)
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                (
                    inp("x", width, CONV_C_IN * CONV_H_IN**2),
                    inp("weight", width, CONV_C_OUT * CONV_C_IN * CONV_TAPS),
                    out("out", F16, CONV_C_OUT * CONV_H_OUT**2),
                ),
                expected_outputs=launch["block_m"] * launch["block_n"],
            )
        )
    return variants


# One 4096-element row per CTA (the 1/4096 mean factor 0f39800000). Every variant
# offsets weight by the CTA's row like x, so CTA 0 reads the first 4096 weights.
RMSNORM_ROW = 4096
RMSNORM_STEMS = [
    "NVIDIA_B200_Float16_1.0000x",
    "NVIDIA_B200_Float8_1.0206x",
]


def rmsnorm_variants() -> list[Variant]:
    folder = "RMSNormKernel"
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                inp("x", input_width(stem), RMSNORM_ROW),
                inp("weight", input_width(stem), RMSNORM_ROW),
                out("output", F16, RMSNORM_ROW),
            ),
            expected_outputs=RMSNORM_ROW,
        )
        for stem in RMSNORM_STEMS
    ]


# Rows of 128 features; the cos/sin tables (input dtype) repeat every 256 rows,
# so CTA 0's rows index the tables' first rows directly.
ROPE_FEATURES = 128
ROPE_ROWS_PER_CTA = {
    "NVIDIA_B200_Float16_1.0000x": 1,
    "NVIDIA_B200_Float8_1.0000x": 1,
}


def rope_variants() -> list[Variant]:
    folder = "RoPEKernel"
    variants = []
    for stem, rows in ROPE_ROWS_PER_CTA.items():
        width, elems = input_width(stem), rows * ROPE_FEATURES
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(load_launch(folder, stem)),
                (
                    inp("input", width, elems),
                    inp("cos", width, elems),
                    inp("sin", width, elems),
                    out("output", F16, elems),
                ),
                expected_outputs=elems,
            )
        )
    return variants


# Every variant hardcodes K = 4096 with no split-K: CTA 0 reads block_m full rows
# of A and all of x, and stores block_m f16 outputs.
MATVEC_K = 4096
MATVEC_STEMS = [
    "NVIDIA_B200_Float16_1.0103x",
    "NVIDIA_B200_Float8_1.0002x",
]


def matvec_variants() -> list[Variant]:
    folder = "MatrixVectorMultiplicationKernel"
    variants = []
    for stem in MATVEC_STEMS:
        launch = load_launch(folder, stem)
        width, rows = input_width(stem), launch["block_m"]
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                (
                    inp("a", width, rows * MATVEC_K),
                    inp("x", width, MATVEC_K),
                    out("y", F16, rows),
                ),
                expected_outputs=rows,
            )
        )
    return variants


# Every variant hardcodes 256 unmasked columns and reads strides (in elements) and
# n_rows at runtime. With one CTA the grid-stride loop runs CTA 0 over all n_rows;
# CTAs own 4, 8 or 16 rows, so 16 rows give every variant whole row batches.
SOFTMAX_ROWS, SOFTMAX_COLS = 16, 256
SOFTMAX_STEMS = [
    "NVIDIA_B200_Float16_1.2702x",
    "NVIDIA_B200_Float8_1.2811x",
]


def softmax_variants() -> list[Variant]:
    folder = "SoftmaxKernel"
    elems = SOFTMAX_ROWS * SOFTMAX_COLS
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                out("output", F16, elems),
                inp("input", input_width(stem), elems),
                Int(SOFTMAX_COLS),  # input_row_stride
                Int(SOFTMAX_COLS),  # output_row_stride
                Int(SOFTMAX_ROWS),  # n_rows
                Int(SOFTMAX_COLS),  # n_cols
            ),
            expected_outputs=elems,
        )
        for stem in SOFTMAX_STEMS
    ]


# CTAs 0-31 update f over x's 32-row blocks (CTAs 32-63 update g over y's), so CTA 0
# reduces all M = 1024 rows of y against x rows 0-31, both f16 with D = 64. It never
# dereferences log_a, g_out, the labels or W, so those stay null.
SINKHORN_M, SINKHORN_D = 1024, 64
SINKHORN_STEMS = ["NVIDIA_B200_Unknown_1.5491x"]
NULL_PTR = Int(0)


def flash_sinkhorn_variants() -> list[Variant]:
    folder = "FlashSinkhornFusedSchurMatvec"
    variants = []
    for stem in SINKHORN_STEMS:
        launch = load_launch(folder, stem)
        rows = launch["block_m"]
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                (
                    inp("x", F16, rows * SINKHORN_D),
                    inp("y", F16, SINKHORN_M * SINKHORN_D),
                    inp("f_hat", F32, rows),
                    inp("g_hat", F32, SINKHORN_M),
                    NULL_PTR,  # log_a
                    inp("log_b", F32, SINKHORN_M),
                    out("f_out", F32, rows),
                    NULL_PTR,  # g_out
                    NULL_PTR,  # label_x
                    NULL_PTR,  # label_y
                    NULL_PTR,  # W
                ),
                expected_outputs=rows,
            )
        )
    return variants


# Heads (ctaid.z * 16 + ctaid.y) hold 1024 unmasked keys of head_dim 64 (f16 q/k/v/o,
# f32 log_lambda/l), so CTA 0 reads head 0's whole k, v and log_lambda and writes
# block_m rows of both l and o.
FORGETTING_SEQ, FORGETTING_HEAD_DIM = 1024, 64
FORGETTING_ATTENTION_STEMS = ["NVIDIA_B200_Unknown_1.0139x"]


def forgetting_attention_variants() -> list[Variant]:
    folder = "ForgettingAttentionICLR2025Forward"
    head = FORGETTING_SEQ * FORGETTING_HEAD_DIM
    variants = []
    for stem in FORGETTING_ATTENTION_STEMS:
        launch = load_launch(folder, stem)
        rows = launch["block_m"]
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                (
                    inp("q", F16, rows * FORGETTING_HEAD_DIM),
                    inp("k", F16, head),
                    inp("v", F16, head),
                    inp("log_lambda", F32, FORGETTING_SEQ),
                    out("l", F32, rows),
                    out("o", F16, rows * FORGETTING_HEAD_DIM),
                ),
                expected_outputs=rows * (1 + FORGETTING_HEAD_DIM),
            )
        )
    return variants


# Q/K/V/Out are [batch * heads, T, 64] f16 and Lse [batch * heads, T] f32, with
# T = block_m * %nctaid.x read at runtime: grid.x = 16 gives T = 1024. Odd CTAs exit,
# and CTA 0 owns query rows 0..127 against all T keys.
FLASH_ATTENTION_HEAD_DIM = 64
FLASH_ATTENTION_NCTAID_X = 16
FLASH_ATTENTION_STEMS = ["NVIDIA_B200_Unknown_1.2610x"]


def flash_attention_variants() -> list[Variant]:
    folder = "FlashAttentionNeurIPS2022Forward"
    variants = []
    for stem in FLASH_ATTENTION_STEMS:
        launch = load_launch(folder, stem)
        seq_len = launch["block_m"] * FLASH_ATTENTION_NCTAID_X
        rows, dim = min(2 * launch["block_m"], seq_len), FLASH_ATTENTION_HEAD_DIM
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                (
                    inp("q", F16, rows * dim),
                    inp("k", F16, seq_len * dim),
                    inp("v", F16, seq_len * dim),
                    NULL_PTR,  # Bias_ptr: never loaded
                    out("out", F16, rows * dim),
                    out("lse", F32, rows),
                    NULL_PTR,  # TMP_ptr: never loaded
                ),
                expected_outputs=rows * dim + rows,
                grid=(FLASH_ATTENTION_NCTAID_X, 1, 1),
            )
        )
    return variants


# Every GEMM variant hardcodes M = N = K = 4096, all row-major: A[M, K] and B[K, N] in
# the input dtype, the fused epilogue's add operand (d_ptr) [M, N] likewise, C[M, N] in
# f16. CTA 0 reads block_m rows of A (and of add) and every row of B, and writes its tile.
GEMM_N = GEMM_K = 4096
MATMUL_STEMS = [
    "NVIDIA_B200_Float16_1.0017x",
    "NVIDIA_B200_Float8_0.9979x",
]
GEMM_ADD_SILU_STEMS = [
    "NVIDIA_B200_Float16_1.1140x",
    "NVIDIA_B200_Float8_1.1642x",
]
GEMM_REDUCTIONS: dict[tuple[str, str], Reduction] = {}


def gemm_variants(folder: str, stems: list[str], fused_add: bool) -> list[Variant]:
    variants = []
    for stem in stems:
        launch = load_launch(folder, stem)
        width, rows = input_width(stem), launch["block_m"]
        operands = [inp("a", width, rows * GEMM_K), inp("b", width, GEMM_K * GEMM_N)]
        if fused_add:
            operands.append(inp("add", width, rows * GEMM_N))
        operands.append(out("c", F16, rows * GEMM_N))
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(launch),
                tuple(operands),
                expected_outputs=rows * launch["block_n"],
                reduction=GEMM_REDUCTIONS.get((folder, stem)),
            )
        )
    return variants


# BitDelta multiplies f16 A[M, K] by sign bits packed 32 K values per u32, B[K / 32, N],
# with M = N = K = 4096 (the batched kernel: per ctaid.y). CTA 0 reads its tile's block_m
# rows of A and, per packed row, its block_n columns of B, and writes that C[M, N] tile.
BITDELTA_K = BITDELTA_N = 4096
BITDELTA_TILES = {
    ("BitDeltaNeurIPS2024Matmul", "NVIDIA_B200_Unknown_3.3438x"): (64, 128),
    ("BitDeltaNeurIPS2024BatchedMatmul", "NVIDIA_B200_Unknown_2.5096x"): (128, 256),
}


def bitdelta_variants() -> list[Variant]:
    variants = []
    for (folder, stem), (rows, cols) in BITDELTA_TILES.items():
        variants.append(
            Variant(
                folder,
                stem,
                block_dims(load_launch(folder, stem)),
                (
                    inp("a", F16, rows * BITDELTA_K),
                    inp("b", U32, BITDELTA_K // 32 * BITDELTA_N),
                    out("c", F16, rows * BITDELTA_N),
                ),
                expected_outputs=rows * cols,
            )
        )
    return variants


# Int8 Q[heads, T, 64] and K/V[kv_heads, 128, 64] (eight query heads per KV head), f16 V and
# Out: CTA 0 attends query rows 0-127 of head 0 to all 128 keys. It never loads mask or Lse.
SAGE_ROWS, SAGE_KEYS, SAGE_HEAD_DIM = 128, 128, 64
SAGE_STEMS = ["NVIDIA_B200_Unknown_1.4104x"]


def sage_attention_variants() -> list[Variant]:
    folder = "SageAttentionICLR2025"
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                inp("q", I8, SAGE_ROWS * SAGE_HEAD_DIM),
                inp("k", I8, SAGE_KEYS * SAGE_HEAD_DIM),
                inp("v", F16, SAGE_KEYS * SAGE_HEAD_DIM),
                inp("q_scale", F32, 1),
                inp("k_scale", F32, 2),
                out("out", F16, SAGE_ROWS * SAGE_HEAD_DIM),
                NULL_PTR,  # mask_ptr
                NULL_PTR,  # Lse_ptr
            ),
            expected_outputs=SAGE_ROWS * SAGE_HEAD_DIM,
        )
        for stem in SAGE_STEMS
    ]


# Chunk state: f16 x[256, 8 heads x 64] and B[256, 4 groups x 128] per chunk of 256 time
# steps; CTA 0 reduces head 0's 64 dims and group 0's 128 states over all 256 steps into a
# 64 by 128 f32 state. It never loads seq_idx.
MAMBA2_STATE_STEMS = ["NVIDIA_B200_Unknown_1.0984x"]
MAMBA2_STATE_STEPS, MAMBA2_STATE_ROW = 256, 512


def mamba2_chunk_state_variants() -> list[Variant]:
    folder = "Mamba2ChunkStateForward"
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                inp("x", F16, MAMBA2_STATE_STEPS * MAMBA2_STATE_ROW),
                inp("b", F16, MAMBA2_STATE_STEPS * MAMBA2_STATE_ROW),
                out("states", F32, 64 * 128),
                inp("dt", F32, MAMBA2_STATE_STEPS),
                inp("dA_cumsum", F32, MAMBA2_STATE_STEPS),
                NULL_PTR,  # seq_idx_ptr
            ),
            expected_outputs=64 * 128,
        )
        for stem in MAMBA2_STATE_STEMS
    ]


# Chunk scan: f16 x[128, 8 heads x 128] per chunk of 128 time steps, C[128, 2 groups x 32]
# and f32 prev_states[128, 32]; CTA 0 writes 32 time steps of head 0 (ctaid.x picks them)
# into out and out_x [128, 1024]. It never loads z, seq_idx or D.
MAMBA2_SCAN_STEMS = ["NVIDIA_B200_Unknown_1.0740x"]
MAMBA2_SCAN_STEPS, MAMBA2_SCAN_ROWS, MAMBA2_SCAN_ROW = 128, 32, 1024


def mamba2_chunk_scan_variants() -> list[Variant]:
    folder = "Mamba2ChunkScanForward"
    rows, steps = MAMBA2_SCAN_ROWS, MAMBA2_SCAN_STEPS
    return [
        Variant(
            folder,
            stem,
            block_dims(load_launch(folder, stem)),
            (
                inp("cb", F32, rows * steps),
                inp("x", F16, steps * MAMBA2_SCAN_ROW),
                NULL_PTR,  # z_ptr
                out("out", F16, rows * MAMBA2_SCAN_ROW),
                out("out_x", F16, rows * MAMBA2_SCAN_ROW),
                inp("dt", F32, steps),
                inp("dA_cumsum", F32, steps),
                NULL_PTR,  # seq_idx_ptr
                inp("C", F16, rows * 64),
                inp("prev_states", F32, 128 * 32),
                NULL_PTR,  # D_ptr
            ),
            expected_outputs=2 * rows * 128,
        )
        for stem in MAMBA2_SCAN_STEMS
    ]


FAMILIES = {
    "relu": partial(elementwise_variants, "ReLUKernel", RELU_TILES, ("x",)),
    "sigmoid": partial(elementwise_variants, "SigmoidKernel", SIGMOID_TILES, ("x",)),
    "silu": partial(elementwise_variants, "SiLUKernel", SILU_TILES, ("x",)),
    "swiglu": partial(elementwise_variants, "SwiGLUKernel", SWIGLU_TILES, ("gate", "value")),
    "rope": rope_variants,
    "rmsnorm": rmsnorm_variants,
    "softmax": softmax_variants,
    "matvec": matvec_variants,
    "reduction_sum": reduction_sum_variants,
    "conv2d": conv2d_variants,
    "flash_sinkhorn": flash_sinkhorn_variants,
    "forgetting_attention": forgetting_attention_variants,
    "flash_attention": flash_attention_variants,
    "sage_attention": sage_attention_variants,
    "mamba2_chunk_state": mamba2_chunk_state_variants,
    "mamba2_chunk_scan": mamba2_chunk_scan_variants,
    "matmul": partial(gemm_variants, "MatrixMultiplication", MATMUL_STEMS, fused_add=False),
    "gemm_add_silu": partial(
        gemm_variants, "FusedGEMMAddSiLUKernel", GEMM_ADD_SILU_STEMS, fused_add=True
    ),
    "bitdelta": bitdelta_variants,
}


def target_of(source: str) -> str:
    match = re.search(r"^\s*\.target\s+(\w+)", source, re.MULTILINE)
    if match is None:
        raise ValueError("no .target directive")
    return match.group(1)


def launch_args(variant: Variant, source: str) -> list[str]:
    args = [
        "--block", ",".join(map(str, variant.block)),
        "--grid", ",".join(map(str, variant.grid)),
        "--dyn-shared", str(MAX_DYNAMIC_SHARED[target_of(source)]),
    ]
    base = ARRAY_ALIGN
    for param in variant.params:
        match param:
            case Array():
                spec = f"{param.name}:{base:#x}:{param.elem_width}:{param.len}:{param.kind.value}"
                args += ["--array", spec, "--param", f"ptr:{param.name}"]
                base += -(-param.elem_width * param.len // ARRAY_ALIGN) * ARRAY_ALIGN
            case Int():
                args += ["--param", f"int:{param.value}"]
    for _ in range(DUMMY_PARAMS):
        args += ["--param", "int:0"]
    return args


def apply_reduction(source: str, reduction: Reduction) -> str:
    lines = source.split("\n")
    for old, new in reduction.patches:
        hits = [i for i, line in enumerate(lines) if line == old]
        if len(hits) != 1:
            raise ValueError(f"reduction patch matches {len(hits)} lines, not 1: {old!r}")
        lines[hits[0]] = new
    return "\n".join(lines)


# A synchronization statement `--mutate` removes: optional `label:`s and a `@%p` guard, then
# the instruction (`tcgen05.alloc` and not `tcgen05.relinquish_alloc_permit`, `bar.sync` and
# not `bar.warp.sync`).
SYNC_STATEMENT = re.compile(
    r"\A(?P<labels>(?:\s*\w+:)*)(?P<body>\s*(?:@!?%\w+\s+)?"
    r"(?P<instr>bar\.sync|bar\.cta\.sync|barrier\.sync|barrier\.cta\.sync"
    r"|tcgen05\.fence::before_thread_sync|tcgen05\.fence::after_thread_sync"
    r"|tcgen05\.alloc|tcgen05\.dealloc)(?=[\s.;]))"
)
STATEMENT = re.compile(r"[^;{}]*;")


@dataclass(frozen=True)
class Mutation:
    """The `nth` (from 1) removable statement on source line `line` (1-based)."""

    line: int
    nth: int
    instr: str

    @property
    def name(self) -> str:
        return f"-{self.instr}@L{self.line}" + (f"#{self.nth}" if self.nth > 1 else "")


def blank_comments(source: str) -> str:
    """`source` with comments replaced by spaces, so offsets and line numbers hold."""
    blank = lambda m: re.sub(r"[^\n]", " ", m[0])
    return re.sub(r"//[^\n]*|/\*.*?\*/", blank, source, flags=re.DOTALL)


def statements(source: str) -> list[tuple[Mutation, int, int]]:
    """Each removable statement of `source` with its character span (guard to `;`)."""
    code = blank_comments(source)
    found = []
    nth: dict[int, int] = {}
    for statement in STATEMENT.finditer(code):
        m = SYNC_STATEMENT.match(statement[0])
        if m is None:
            continue
        start = statement.start() + m.start("body")
        start += len(m["body"]) - len(m["body"].lstrip())
        line = code.count("\n", 0, start) + 1
        nth[line] = nth.get(line, 0) + 1
        found.append((Mutation(line, nth[line], m["instr"]), start, statement.end()))
    return found


def mutation_sites(source: str) -> list[Mutation]:
    return [mutation for mutation, _, _ in statements(source)]


def remove_statement(source: str, mutation: Mutation) -> str:
    """`source` with `mutation`'s statement, guard included, blanked out; lines keep their numbers."""
    for found, start, end in statements(source):
        if found == mutation:
            gap = re.sub(r"[^\n]", " ", source[start:end])
            return source[:start] + gap + source[end:]
    raise ValueError(f"no {mutation.name} in the source")


class Fate(enum.Enum):
    """What became of a mutant; anything but SURVIVED means Volta no longer verifies it."""

    RACE = "race condition"
    CHECK = "check failure"
    DEADLOCK = "deadlock"
    STOPPED = "without a verdict"
    SURVIVED = "SURVIVED"
    NOT_RUN = "NOT RUN"


FATES = {
    Outcome.RACE_CONDITION: Fate.RACE,
    Outcome.CHECK_FAILED: Fate.CHECK,
    Outcome.DEADLOCK: Fate.DEADLOCK,
    Outcome.UNSUPPORTED: Fate.STOPPED,
    Outcome.UNKNOWN: Fate.STOPPED,
    Outcome.ERROR: Fate.STOPPED,
    Outcome.RACE_FREE: Fate.SURVIVED,
    Outcome.REDUCED_RACE_FREE: Fate.SURVIVED,
}
FATE_CODES = {
    Fate.RACE: (BOLD, GREEN),
    Fate.CHECK: (BOLD, GREEN),
    Fate.DEADLOCK: (BOLD, GREEN),
    Fate.STOPPED: (BOLD, YELLOW),
    Fate.SURVIVED: (BOLD, RED),
    Fate.NOT_RUN: (BOLD, RED),
}


def run_volta(command: list[str], echo: Callable[[str], None] | None) -> tuple[str, str]:
    """Run volta, passing each stderr line (the stage log) to `echo` live; return (stdout, stderr)."""
    with subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    ) as run:
        stdout: list[str] = []
        reader = threading.Thread(target=lambda: stdout.append(run.stdout.read()))
        reader.start()
        stderr = []
        for line in run.stderr:
            stderr.append(line)
            if echo is not None:
                echo(line.rstrip("\n"))
        reader.join()
    return "".join(stdout), "".join(stderr)


def analyze(variant: Variant, ptx: Path, echo: Callable[[str], None] | None) -> tuple[Outcome, str]:
    # Rendering outputs can cost GBs (shared subterms print as trees); counts suffice.
    command = [
        str(VOLTA), "--no-log-file", "--log-level", "error" if echo is None else "info",
        "analyze", str(ptx),
        "--kernel", "kernel", *launch_args(variant, ptx.read_text()),
        "--print-outputs", "0", "--no-profile",
    ]
    stdout, stderr = run_volta(command, echo)
    return classify(parse_cli(stdout), stderr, variant.expected_outputs)


def analyze_variant(
    variant: Variant,
    full: bool,
    echo: Callable[[str], None] | None,
    patch: Callable[[str], str] | None = None,
) -> tuple[Outcome, str]:
    """`variant`'s outcome, its K loop reduced unless `full`, from `patch`ed source if given."""
    reduction = None if full else variant.reduction
    if reduction is None and patch is None:
        return analyze(variant, variant.path, echo)
    source = variant.path.read_text()
    if reduction is not None:
        source = apply_reduction(source, reduction)
    if patch is not None:
        source = patch(source)
    with tempfile.TemporaryDirectory() as scratch:
        patched = Path(scratch) / variant.path.name
        patched.write_text(source)
        outcome, detail = analyze(variant, patched, echo)
    if reduction is not None:
        if outcome is Outcome.RACE_FREE:
            outcome = Outcome.REDUCED_RACE_FREE
        detail = f"K loop cut to {reduction.iterations}/{reduction.full_iterations} iterations; {detail}"
    return outcome, detail


def check(variant: Variant, full: bool, echo: Callable[[str], None] | None) -> Report:
    start = time.perf_counter()
    try:
        outcome, detail = analyze_variant(variant, full, echo)
    except VoltaFailure as failure:
        outcome, detail = Outcome.ERROR, str(failure)
    return Report(variant, outcome, detail, time.perf_counter() - start)


# The unmutated kernel's row, aligned with its mutants'.
AS_WRITTEN = "as written"


def plural(count: int, noun: str) -> str:
    return f"{count} {noun}" + ("" if count == 1 or noun.startswith("without") else "s")


def run_mutations(
    selected: list[tuple[str, Variant]],
    full: bool,
    echo: Callable[[str], None] | None,
    style: Style,
    lines: list[int],
) -> int:
    """The negative test over `selected` (the statements at `lines` only, if any are given)."""
    fates: list[Fate] = []
    skipped: list[str] = []
    for _, variant in selected:
        print(style.paint(f"== {variant.name}", BOLD), flush=True)
        sites = [
            site
            for site in mutation_sites(variant.path.read_text())
            if not lines or site.line in lines
        ]
        if not sites:
            where = f" at {', '.join(f'L{line}' for line in lines)}" if lines else ""
            print(f"   no removable statement{where}", flush=True)
            continue
        width = max(map(len, [AS_WRITTEN, *(site.name for site in sites)]))
        baseline = check(variant, full, echo)
        outcome = style.paint(
            f"{baseline.outcome.value:<{OUTCOME_WIDTH}}", *OUTCOME_CODES[baseline.outcome]
        )
        if baseline.outcome not in (Outcome.RACE_FREE, Outcome.REDUCED_RACE_FREE):
            skipped.append(variant.name)
            note = f"mutants skipped: {baseline.detail}"
        else:
            note = plural(len(sites), "removable statement")
        print(
            f"   {AS_WRITTEN:<{width}}  {outcome}  {baseline.seconds:7.1f}s  {note}",
            flush=True,
        )
        if variant.name in skipped:
            continue
        for site in sites:
            start = time.perf_counter()
            try:
                result, detail = analyze_variant(
                    variant, full, echo, partial(remove_statement, mutation=site)
                )
                fate = FATES[result]
                shown = fate.value if fate is Fate.SURVIVED else result.value
            except VoltaFailure as failure:
                fate, shown, detail = Fate.NOT_RUN, Fate.NOT_RUN.value, str(failure)
            seconds = time.perf_counter() - start
            fates.append(fate)
            print(
                f"   {site.name:<{width}}  "
                f"{style.paint(f'{shown:<{OUTCOME_WIDTH}}', *FATE_CODES[fate])}  "
                f"{seconds:7.1f}s  {detail}",
                flush=True,
            )

    caught = sum(fates.count(fate) for fate in (Fate.RACE, Fate.CHECK, Fate.DEADLOCK))
    failed = fates.count(Fate.SURVIVED) + fates.count(Fate.NOT_RUN)
    codes = (BOLD, GREEN) if failed == 0 else (BOLD, RED)
    summary = style.paint(f"{caught}/{len(fates)} mutants caught", *codes)
    seen = [
        plural(fates.count(fate), fate.value)
        for fate in (Fate.RACE, Fate.CHECK, Fate.DEADLOCK, Fate.STOPPED)
        if fates.count(fate)
    ]
    bad = [f"{fates.count(fate)} {fate.value}" for fate in (Fate.SURVIVED, Fate.NOT_RUN) if fates.count(fate)]
    tail = (f": {', '.join(seen)}" if seen else "") + (f"; {', '.join(bad)}" if bad else "")
    print(f"\n{summary}{tail}")
    if skipped:
        print(f"skipped, not race-free as written: {', '.join(skipped)}")
    return 0 if failed == 0 else 1


def build_volta() -> None:
    build = subprocess.run(
        ["cargo", "build", "--release", "--quiet", "-p", "volta_cli", "--features", "logging"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    if build.returncode == 0:
        return
    if not VOLTA.exists():
        sys.exit(f"cargo build failed and {VOLTA} does not exist:\n{build.stderr}")
    reason = next(iter(build.stderr.strip().splitlines()), f"exit status {build.returncode}")
    built = time.strftime("%Y-%m-%d %H:%M", time.localtime(VOLTA.stat().st_mtime))
    print(
        f"warning: cargo build failed ({reason}); using the existing "
        f"{VOLTA.relative_to(REPO_ROOT)} built {built}",
        file=sys.stderr,
    )


def kernel_name(arg: str) -> str:
    """A `--kernel` argument as `Folder/stem`: a `.ptx` path, or the name itself."""
    path = Path(arg)
    if path.suffix != ".ptx":
        return arg
    try:
        return path.resolve().relative_to(KERNEL_ROOT).with_suffix("").as_posix()
    except ValueError:
        return arg


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("families", nargs="*", choices=list(FAMILIES), help="default: all")
    parser.add_argument(
        "--kernel",
        action="append",
        default=[],
        metavar="PTX",
        help="run only this kernel, given as its .ptx path or Folder/stem (repeatable)",
    )
    parser.add_argument("-k", dest="match", default="", help="only kernels whose name contains this")
    parser.add_argument("--list", action="store_true", help="list the configured kernels and exit")
    parser.add_argument(
        "--debug", action="store_true", help="stream volta's per-stage log (analysis, checks)"
    )
    parser.add_argument(
        "--color",
        choices=("auto", "always", "never"),
        default="auto",
        help="color the output (auto: when stdout is a terminal and NO_COLOR is unset)",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="ignore K-loop reductions and analyze every kernel whole (some need tens of GB)",
    )
    parser.add_argument(
        "--mutate",
        action="store_true",
        help="remove one bar.sync, tcgen05.fence::{before,after}_thread_sync, tcgen05.alloc or "
        "tcgen05.dealloc at a time from each race-free kernel; every mutant must fail",
    )
    parser.add_argument(
        "--site",
        action="append",
        type=int,
        default=[],
        metavar="LINE",
        help="with --mutate: remove only the statements at these source lines (repeatable)",
    )
    args = parser.parse_args()
    if args.site and not args.mutate:
        parser.error("--site needs --mutate")

    try:
        every_family = {family: variants() for family, variants in FAMILIES.items()}
    except FileNotFoundError as missing:
        parser.error(f"a configured kernel's file is missing: {missing.filename}")
    on_disk = {
        ptx.relative_to(KERNEL_ROOT).with_suffix("").as_posix()
        for ptx in KERNEL_ROOT.glob("*/*.ptx")
    }
    unconfigured = sorted(on_disk - {v.name for vs in every_family.values() for v in vs})
    if unconfigured:
        message = f"not configured, so never checked: {', '.join(unconfigured)} (add to FAMILIES)"
        # A full run must cover every kernel; a filtered one only warns.
        if args.families or args.kernel or args.match:
            print(f"warning: {message}", file=sys.stderr)
        else:
            parser.error(message)
    families = args.families or list(FAMILIES)
    configured = [(family, v) for family in families for v in every_family[family]]
    wanted = {kernel_name(arg): arg for arg in args.kernel}
    unknown = [arg for name, arg in wanted.items() if name not in {v.name for _, v in configured}]
    if unknown:
        parser.error(f"not a configured kernel: {', '.join(unknown)} (see --list)")
    selected = [
        (family, v)
        for family, v in configured
        if args.match in v.name and (not wanted or v.name in wanted)
    ]
    if not selected:
        parser.error("no kernel matches")
    if args.list:
        width = max(len(family) for family, _ in selected)
        for family, v in selected:
            marker = "" if v.reduction is None else "  (K loop reduced unless --full)"
            print(f"{family:<{width}}  {v.name}{marker}")
            if args.mutate:
                for site in mutation_sites(v.path.read_text()):
                    print(f"{'':<{width}}    {site.name[1:]}")
        return 0

    style = Style(
        args.color == "always"
        or (args.color == "auto" and sys.stdout.isatty() and not os.environ.get("NO_COLOR"))
    )
    echo = (lambda line: print(f"    {style.log_line(line)}", flush=True)) if args.debug else None
    build_volta()
    if args.mutate:
        return run_mutations(selected, args.full, echo, style, args.site)
    width = max(len(v.name) for _, v in selected)
    reports = []
    for _, variant in selected:
        if echo is not None:
            print(style.paint(f"== {variant.name}", BOLD), flush=True)
        report = check(variant, args.full, echo)
        reports.append(report)
        outcome = style.paint(
            f"{report.outcome.value:<{OUTCOME_WIDTH}}", *OUTCOME_CODES[report.outcome]
        )
        print(
            f"{variant.name:<{width}}  {outcome}  {report.seconds:7.1f}s  {report.detail}",
            flush=True,
        )

    race_free = sum(r.outcome is Outcome.RACE_FREE for r in reports)
    others = ", ".join(
        f"{count} {outcome.value}"
        for outcome in Outcome
        if outcome is not Outcome.RACE_FREE
        and (count := sum(r.outcome is outcome for r in reports))
    )
    verdict_codes = (BOLD, GREEN) if race_free == len(reports) else (BOLD, RED)
    verified = style.paint(f"{race_free}/{len(reports)} kernels verified race-free", *verdict_codes)
    print(f"\n{verified}" + (f"; {others}" if others else ""))
    if any(r.outcome is Outcome.REDUCED_RACE_FREE for r in reports):
        print(
            f"{Outcome.REDUCED_RACE_FREE.value}: race-free with the K loop cut short, which does "
            "not verify the full kernel (--full analyzes it whole)"
        )
    return 0 if race_free == len(reports) else 1


if __name__ == "__main__":
    sys.exit(main())
