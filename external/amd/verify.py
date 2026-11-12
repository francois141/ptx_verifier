"""Check the Composable Kernel examples against their specs, one after the other.

    uv run --reinstall-package volta --package volta python external/amd/verify.py

Each case is a kernel `composable_kernel/<kernel>.s` (compiled from the `.hip` beside it) and a
launch file `composable_kernel/<case>.launch.json` naming its spec; Volta's log of each case
prints as it runs. The canonical solver must reach each solved case's expected verdict. CK's
fused GEMM-sigmoid is not exactly its formula over the reals (its exp rescales by f32(e^-64)
past the underflow bound), so it is verified in Lean within a tolerance instead, with no
canonical solver: Claude Code writes the proof into `target/lean/<case>/`, which later runs
recheck without the agent while the challenge is unchanged. That case needs Claude Code and
`$VOLTA_LEAN_PROJECT`, a Lake project with Mathlib built, which the environment or the
repository's untracked `.env` (a `VOLTA_LEAN_PROJECT=<path>` line) gives. The exit status is 1
if any case fails.
"""

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
    """Every output must be proved in Lean within `tolerance` of the spec."""

    tolerance: str


@dataclass(frozen=True)
class Case:
    launch: str
    kernel: str
    check: Solve | Prove

    def describe(self) -> str:
        if isinstance(self.check, Solve):
            return f"canonical solver, expecting {self.check.expected}"
        return f"Lean proof within {self.check.tolerance}"


CASES = (
    Case("ck_gemm", "ck_gemm", Solve("ACCEPT")),
    # Case("ck_fmha", "ck_fmha", Solve("ACCEPT")),
    # Case("ck_fmha_swapped_qk", "ck_fmha", Solve("REJECT")),
    Case("ck_rmsnorm2d", "ck_rmsnorm2d", Solve("ACCEPT")),
    Case("ck_avgpool2d", "ck_avgpool2d", Solve("ACCEPT")),
    # CK's output buffer bound drops four of the nine outputs' stores.
    Case("ck_avgpool2d_larger_output", "ck_avgpool2d", Solve("REJECT")),
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


def solve(kernel: Path, launch: Launch, check: Solve) -> tuple[bool, str]:
    result = volta.solve(
        kernel, launch.config, kernel=launch.kernel, spec=launch.spec, dims=launch.dims
    )
    outputs = sum(len(elements) for _, elements in result.outputs)
    detail = f"{result.verdict} by the canonical solver, {outputs} outputs"
    if result.verdict != "ACCEPT" and result.evidence:
        detail += f"; {result.evidence[0]}"
    return result.verdict == check.expected, detail


def prove(case: Case, kernel: Path, launch: Launch, check: Prove) -> tuple[bool, str]:
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
                return (
                    True,
                    f"{detail} within {check.tolerance} (rechecked {directory})",
                )

    LOG.info("[lean] proving with Claude Code into %s", directory)
    result = volta.prove_lean(
        kernel, launch.config, output_dir=directory, equivalence=False, **arguments
    )
    detail = f"{result.proved_statements} of {result.statements} proved in Lean"
    return result.proved, f"{detail} within {check.tolerance} (proof {result.proof})"


def load_dotenv(path: Path) -> None:
    """Set each `NAME=value` line of `path` that the environment does not already set."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        name, separator, value = line.partition("=")
        if separator and not name.lstrip().startswith("#"):
            os.environ.setdefault(name.strip(), os.path.expanduser(value.strip()))


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s  %(message)s",
        datefmt="%H:%M:%S",
        stream=sys.stdout,
    )
    load_dotenv(REPO_ROOT / ".env")

    results = []
    for case in CASES:
        print(f"\n== {case.launch}: {case.describe()}", flush=True)
        kernel = CK_ROOT / f"{case.kernel}.s"
        launch = load_launch(CK_ROOT / f"{case.launch}.launch.json")
        start = time.monotonic()
        try:
            if isinstance(case.check, Solve):
                passed, detail = solve(kernel, launch, case.check)
            else:
                passed, detail = prove(case, kernel, launch, case.check)
        except volta.VoltaError as error:
            passed, detail = False, f"{type(error).__name__}: {error}"

        seconds = time.monotonic() - start
        line = (
            f"{'PASS' if passed else 'FAIL'} {case.launch}: {detail} ({seconds:.1f}s)"
        )
        print(line, flush=True)
        results.append((passed, line))

    print("\n== summary", flush=True)
    for _, line in results:
        print(line, flush=True)
    return 0 if all(passed for passed, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
