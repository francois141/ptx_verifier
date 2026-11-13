"""Check the Composable Kernel examples against their specs, one after the other.

    uv run --reinstall-package volta --package volta python external/amd/verify.py \
        [--verbose] [PREFIX]

A PREFIX runs only the cases whose launch file starts with it (`activations`), and `--checker`
only those the canonical solver (`solver`) or Lean (`lean`) decides. Each case is a
kernel `composable_kernel/<kernel>.s` (compiled from the `.hip` beside it) and a launch file
`composable_kernel/<case>.launch.json` naming its spec, CK's activations under
`composable_kernel/activations*/`. Each case prints one line when it finishes: PASS if its
kernel verified (ACCEPT, or every output proved in Lean), else FAIL, noting when a verdict
other than ACCEPT is the case's expected one, such as a known bug's REJECT. `--verbose` also
prints Volta's log of each case as it runs, then a summary.

Some cases are verified in Lean instead, with no canonical solver. CK's fused GEMM-sigmoid is not
exactly its formula over the reals (its exp rescales by f32(e^-64) past the underflow bound), so
it is proved within a tolerance. The activations that compile to a select the canonical solver
cannot match with their spec's `min` and `max` are proved equal. Claude Code writes each proof
into `target/lean/<case>/`, which later runs recheck without the agent while the challenge is
unchanged. These cases need Claude Code and `$VOLTA_LEAN_PROJECT`, a Lake project with Mathlib
built, which the environment or the repository's untracked `.env` (a `VOLTA_LEAN_PROJECT=<path>`
line) gives. The exit status is 1 if any case's verdict is not its
expected one.
"""

import argparse
import json
import logging
import math
import os
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import volta

CK_ROOT = Path(__file__).resolve().parent / "composable_kernel"
REPO_ROOT = CK_ROOT.parents[2]
LEAN_DIR = REPO_ROOT / "target" / "lean"
LOG = logging.getLogger("verify")

# The launch-file subset these cases use, laid out as `volta_ptx_analysis::LaunchFile` lays
# out arrays without a `base`: in order from 0x10000, each on the first 64 KiB boundary past
# the arrays before it.
ARRAY_ALIGN = 0x10000
ELEMENT_BYTES = {"f32": 4}
ARRAY_KINDS = {"in": volta.ArrayKind.Input, "out": volta.ArrayKind.Output}


@dataclass(frozen=True)
class Solve:
    """The canonical solver's verdict against the spec must be `expected`."""

    expected: str


@dataclass(frozen=True)
class Prove:
    """Every output must be proved in Lean equal to the spec, or within `tolerance` of it."""

    tolerance: str | None = None

    def claim(self) -> str:
        return "exactly" if self.tolerance is None else f"within {self.tolerance}"


@dataclass(frozen=True)
class Case:
    launch: str
    kernel: str
    check: Solve | Prove

    def checker(self) -> str:
        return "solver" if isinstance(self.check, Solve) else "lean"

    def describe(self) -> str:
        if isinstance(self.check, Solve):
            return f"canonical solver, expecting {self.check.expected}"
        return f"Lean proof {self.check.claim()}"


@dataclass(frozen=True)
class Outcome:
    """Whether the kernel verified, and whether that verdict is the case's expected one."""

    verified: bool
    expected: bool
    detail: str


CASES = (
    Case("ck_gemm", "ck_gemm", Solve("ACCEPT")),
    # Case("ck_fmha", "ck_fmha", Solve("ACCEPT")),
    # Case("ck_fmha_swapped_qk", "ck_fmha", Solve("REJECT")),
    Case("ck_rmsnorm2d", "ck_rmsnorm2d", Solve("ACCEPT")),
    Case("ck_avgpool2d", "ck_avgpool2d", Solve("ACCEPT")),
    # CK's output buffer bound drops four of the nine outputs' stores.
    Case("ck_avgpool2d_larger_output", "ck_avgpool2d", Solve("REJECT")),
    Case("activations/ck_relu", "activations/ck_relu", Solve("ACCEPT")),
    Case("activations/ck_clipped_relu", "activations/ck_clipped_relu", Solve("ACCEPT")),
    Case("activations/ck_sigmoid", "activations/ck_sigmoid", Solve("ACCEPT")),
    Case("activations/ck_logistic", "activations/ck_logistic", Solve("ACCEPT")),
    Case("activations/ck_silu", "activations/ck_silu", Solve("ACCEPT")),
    Case("activations/ck_swish", "activations/ck_swish", Solve("ACCEPT")),
    Case("activations/ck_fast_gelu", "activations/ck_fast_gelu", Solve("ACCEPT")),
    # ROCm/composable_kernel#3763: FastGeluAsm's scratch register shares an input's at -O3.
    Case(
        "activations/ck_fast_gelu_asm", "activations/ck_fast_gelu_asm", Solve("REJECT")
    ),
    Case(
        "activations/ck_fast_gelu_asm_fixed",
        "activations/ck_fast_gelu_asm",
        Solve("ACCEPT"),
    ),
    Case("activations/ck_unary_abs", "activations/ck_unary_abs", Solve("ACCEPT")),
    Case("activations/ck_neg", "activations/ck_neg", Solve("ACCEPT")),
    Case("activations/ck_clamp", "activations/ck_clamp", Solve("REJECT")),
    Case("activations/ck_clamp_fixed", "activations/ck_clamp", Solve("ACCEPT")),
    # AddHardswish's select, which the canonical solver cannot match with the spec's min and max.
    Case("activations/ck_hardswish", "activations/ck_hardswish", Prove()),
    # The same ops without -ffast-math, whose exp keeps its range reduction.
    Case(
        "activations_no_fast_math/ck_relu",
        "activations_no_fast_math/ck_relu",
        Solve("ACCEPT"),
    ),
    Case(
        "activations_no_fast_math/ck_clipped_relu",
        "activations_no_fast_math/ck_clipped_relu",
        Solve("ACCEPT"),
    ),
    Case(
        "activations_no_fast_math/ck_fast_gelu_asm",
        "activations_no_fast_math/ck_fast_gelu_asm",
        Solve("REJECT"),
    ),
    Case(
        "activations_no_fast_math/ck_fast_gelu_asm_fixed",
        "activations_no_fast_math/ck_fast_gelu_asm",
        Solve("ACCEPT"),
    ),
    # Clamp<int, int> clamps through an int8_t reference, so 300 becomes 44.
    Case(
        "activations_no_fast_math/ck_clamp",
        "activations_no_fast_math/ck_clamp",
        Solve("REJECT"),
    ),
    Case(
        "activations_no_fast_math/ck_clamp_fixed",
        "activations_no_fast_math/ck_clamp",
        Solve("ACCEPT"),
    ),
    # LeakyRelu's select between x and alpha x, likewise.
    Case(
        "activations_no_fast_math/ck_leaky_relu",
        "activations_no_fast_math/ck_leaky_relu",
        Prove(),
    ),
    # i4_to_f8x4 converts its high nibbles unshifted, as zeros.
    Case("ck_i4_to_f8x4", "ck_i4_to_f8x4", Solve("REJECT")),
    Case("ck_i4_to_f8x4_fixed", "ck_i4_to_f8x4", Solve("ACCEPT")),
    # A model of PermuteWarpGemmCToA's loop, which runs four times past its buffers.
    Case("ck_permute_c_to_a", "ck_permute_c_to_a", Solve("REJECT")),
    Case("ck_permute_c_to_a_fixed", "ck_permute_c_to_a", Solve("ACCEPT")),
    Case("ck_gemm_sigmoid", "ck_gemm_sigmoid", Prove("1/1000")),
)


@dataclass(frozen=True)
class Launch:
    kernel: str | None
    config: volta.Config
    spec: str
    dims: dict[str, int]


def load_launch(path: Path) -> Launch:
    launch = json.loads(path.read_text(encoding="utf-8"))
    config = volta.Config(
        block=dims3(launch["block"]), grid=dims3(launch.get("grid", 1))
    )

    next_base = ARRAY_ALIGN
    for array in launch["arrays"]:
        width = ELEMENT_BYTES[array["dtype"]]
        length = math.prod(array["shape"])
        kind = ARRAY_KINDS[array["kind"]]
        config.add_array(volta.ArrayDef(array["name"], next_base, width, length, kind))
        next_base = -(-(next_base + width * length) // ARRAY_ALIGN) * ARRAY_ALIGN

    for param in launch["params"]:
        if "int" in param:
            config.add_param(volta.Param.int(param["int"]))
        elif "float" in param:
            config.add_param(volta.Param.float(param["float"]))
        else:
            config.add_param(volta.Param.array_ptr(param["ptr"]))

    spec = (path.parent / launch["spec"]).read_text(encoding="utf-8")
    return Launch(launch.get("kernel"), config, spec, launch["dims"])


def dims3(value: int | list[int]) -> tuple[int, int, int]:
    dims = [value] if isinstance(value, int) else value
    return tuple(dims + [1] * (3 - len(dims)))


def solve(kernel: Path, launch: Launch, check: Solve) -> Outcome:
    result = volta.solve(
        kernel, launch.config, kernel=launch.kernel, spec=launch.spec, dims=launch.dims
    )
    verified = result.verdict == "ACCEPT"
    expected = result.verdict == check.expected
    if not expected:
        note = f" (expected {check.expected})"
    elif not verified:
        note = " (expected)"
    else:
        note = ""
    outputs = sum(len(elements) for _, elements in result.outputs)
    detail = f"{result.verdict}{note} by the canonical solver, {outputs} outputs"
    if not verified and result.evidence:
        detail += f"; {result.evidence[0]}"
    return Outcome(verified, expected, detail)


def prove(case: Case, kernel: Path, launch: Launch, check: Prove) -> Outcome:
    directory = LEAN_DIR / case.launch
    arguments = {
        "kernel": launch.kernel,
        "spec": launch.spec,
        "dims": launch.dims,
        "tolerance": check.tolerance,
    }
    challenge = directory / "challenge.lean"
    if challenge.exists() and (directory / "proof.lean").exists():
        extraction = volta.extract_lean(kernel, launch.config, **arguments)
        if extraction.lean == challenge.read_text(encoding="utf-8"):
            LOG.info(
                "[lean] challenge unchanged: rechecking the proof in %s", directory
            )
            recheck = volta.check_lean_proof(directory)
            if recheck.proved:
                detail = f"{recheck.proved_statements} of {recheck.statements} proved in Lean"
                detail += f" {check.claim()} (rechecked {directory})"
                return Outcome(True, True, detail)

    LOG.info("[lean] proving with Claude Code into %s", directory)
    result = volta.prove_lean(
        kernel, launch.config, output_dir=directory, equivalence=False, **arguments
    )
    detail = f"{result.proved_statements} of {result.statements} proved in Lean"
    detail += f" {check.claim()} (proof {result.proof})"
    return Outcome(result.proved, result.proved, detail)


def load_dotenv(path: Path) -> None:
    """Set each `NAME=value` line of `path` that the environment does not already set."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        name, separator, value = line.partition("=")
        if separator and not name.lstrip().startswith("#"):
            os.environ.setdefault(name.strip(), os.path.expanduser(value.strip()))


def status(passed: bool) -> str:
    """PASS in green or FAIL in red, uncolored unless stdout is a terminal."""
    word, color = ("PASS", 32) if passed else ("FAIL", 31)
    if not sys.stdout.isatty() or "NO_COLOR" in os.environ:
        return word
    return f"\033[{color}m{word}\033[0m"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "prefix",
        nargs="?",
        default="",
        help="run only the cases whose launch file starts with it",
    )
    parser.add_argument(
        "--checker",
        choices=("solver", "lean"),
        help="run only the cases the canonical solver or Lean decides",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="print Volta's log of each case"
    )
    args = parser.parse_args()
    prefix = args.prefix

    # Volta's Rust logs reach Python's `logging` at info level.
    logging.basicConfig(
        level=logging.INFO if args.verbose else logging.WARNING,
        format="%(asctime)s  %(message)s",
        datefmt="%H:%M:%S",
        stream=sys.stdout,
    )
    load_dotenv(REPO_ROOT / ".env")

    results = []
    for case in CASES:
        if not case.launch.startswith(prefix):
            continue
        if args.checker and case.checker() != args.checker:
            continue
        if args.verbose:
            print(f"\n== {case.launch}: {case.describe()}", flush=True)
        kernel = CK_ROOT / f"{case.kernel}.s"
        launch = load_launch(CK_ROOT / f"{case.launch}.launch.json")
        start = time.monotonic()
        try:
            if isinstance(case.check, Solve):
                outcome = solve(kernel, launch, case.check)
            else:
                outcome = prove(case, kernel, launch, case.check)
        except volta.VoltaError as error:
            outcome = Outcome(False, False, f"{type(error).__name__}: {error}")

        seconds = time.monotonic() - start
        line = f"{status(outcome.verified)} {case.launch}: {outcome.detail} ({seconds:.1f}s)"
        print(line, flush=True)
        results.append((outcome.expected, line))

    if not results:
        print(f"no case's launch file starts with {prefix!r}", flush=True)
        return 1
    if args.verbose:
        print("\n== summary", flush=True)
        for _, line in results:
            print(line, flush=True)
    return 0 if all(expected for expected, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
