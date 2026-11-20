"""Check the OpenCL GEMM + activation kernels against their specs: the canonical solver, else Lean.

    uv run --reinstall-package volta --package volta python \
        external/approximations/opencl/prove.py [--extract-only] [CASE...]

Each case (every `<case>.launch.json` here by default, a 128 x 128 x 128 GEMM) is first decided by
the canonical solver; ACCEPT verifies it. Otherwise the same kernel binary, launched at LEAN_SIZE
x LEAN_SIZE x LEAN_SIZE (at 128, a challenge of 16,384 statements over 128-term sums is out of
Lean's reach), has its outputs claimed within TOLERANCE of the spec, and a Claude Code agent proves
the claim in Lean into `target/lean/opencl/<case>/`; a later run rechecks that proof without the
agent while the challenge is unchanged. Past clang's denormal guard an exp(u) is
f32(e^-64) * exp(u + 64), not exp(u) over the reals, so the guarded kernels need Lean. A kernel
whose run aborts (a branch on the data, a select between two integer constants) has no Lean
challenge. The solver gets SOLVER_TIMEOUT seconds per case (then it is TIMEOUT and Lean decides),
and the SKIPPED cases are not run unless named. `--extract-only` writes the challenges without
proving them. Every run writes REPORT.md beside this file: per case, the solver's verdict, Lean's
result and which of them verified it. Lean needs `$VOLTA_LEAN_PROJECT` (or the repository's
`.env`) and Claude Code. The exit status is 1 unless every case run is verified.
"""

import argparse
import math
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import volta

from compile import CASES, launch

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[2]
LEAN_DIR = REPO_ROOT / "target" / "lean" / "opencl"
TOLERANCE = "1/1000"
LEAN_SIZE = 8
ARRAY_ALIGN = 0x10000
VOLTA = REPO_ROOT / "target" / "release" / "volta"
SOLVER_TIMEOUT = 120
# The guard hides fast_gelu's GELU form from the rewrite, so the solver expands the cube of each
# 128-term dot product: far past SOLVER_TIMEOUT.
SKIPPED = ("fast_gelu",)


@dataclass
class Row:
    case: str
    spec: str
    solver: str = "-"
    lean: str = "-"
    verified_by: str = "not verified"


def load_launch(launch_file: dict) -> tuple[volta.Config, str, dict[str, int]]:
    config = volta.Config(block=(launch_file["block"], 1, 1), grid=(1, 1, 1))
    base = ARRAY_ALIGN
    for array in launch_file["arrays"]:
        kind = volta.ArrayKind.Input if array["kind"] == "in" else volta.ArrayKind.Output
        length = math.prod(array["shape"])
        config.add_array(volta.ArrayDef(array["name"], base, 4, length, kind))
        base = -(-(base + 4 * length) // ARRAY_ALIGN) * ARRAY_ALIGN
    for param in launch_file["params"]:
        if "ptr" in param:
            config.add_param(volta.Param.array_ptr(param["ptr"]))
        else:
            config.add_param(volta.Param.int(param["int"]))
    spec = (ROOT / launch_file["spec"]).read_text(encoding="utf-8")
    return config, spec, launch_file["dims"]


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        name, _, value = line.partition("=")
        if value and not line.startswith("#"):
            os.environ.setdefault(name.strip(), value.strip())


def solve(case: str) -> tuple[str, str]:
    """The canonical solver's verdict on the 128-cube launch file, and its first evidence."""
    command = [str(VOLTA), "--no-log-file", "solve", str(ROOT / f"{case}.s"), "--config",
               str(ROOT / f"{case}.launch.json"), "--print-outputs", "0"]
    started = time.monotonic()
    try:
        out = subprocess.run(command, capture_output=True, text=True, timeout=SOLVER_TIMEOUT)
    except subprocess.TimeoutExpired:
        return "TIMEOUT", f"no verdict within {SOLVER_TIMEOUT} s"
    seconds = time.monotonic() - started
    text = out.stdout + out.stderr
    verdict = re.search(r"^VERDICT: (\w+)", text, re.M)
    evidence = re.search(r"^\s+equivalence: (.+)$", text, re.M) or re.search(
        r"^error: (.+)$", text, re.M)
    return (f"{verdict[1] if verdict else 'ERROR'} ({seconds:.0f} s)",
            evidence[1] if evidence else "no evidence")


def check(case: str, extract_only: bool) -> Row:
    row = Row(case, CASES[case])
    verdict, reason = solve(case)
    row.solver = verdict
    if verdict.startswith("ACCEPT"):
        row.verified_by = "canonical solver (128x128x128)"
        print(f"{case}: {verdict} by the canonical solver", flush=True)
        return row
    print(f"{case}: {verdict} by the canonical solver ({reason}); trying Lean at "
          f"{LEAN_SIZE}x{LEAN_SIZE}x{LEAN_SIZE}", flush=True)
    kernel = ROOT / f"{case}.s"
    config, spec, dims = load_launch(launch(case, CASES[case], LEAN_SIZE))
    arguments = {"kernel": case, "spec": spec, "dims": dims, "tolerance": TOLERANCE}
    try:
        extraction = volta.extract_lean(kernel, config, **arguments)
    except volta.VoltaError as error:
        row.lean = "no challenge: " + str(error).split(": ")[-1]
        print(f"{case}: no Lean challenge: {error}", flush=True)
        return row
    directory = LEAN_DIR / case
    challenge = directory / "challenge.lean"
    if extract_only:
        directory.mkdir(parents=True, exist_ok=True)
        challenge.write_text(extraction.lean, encoding="utf-8")
        row.lean = "challenge written, not proved (`--extract-only`)"
        print(f"{case}: wrote {challenge}", flush=True)
        return row
    if (directory / "proof.lean").exists() and challenge.exists():
        if extraction.lean == challenge.read_text(encoding="utf-8"):
            recheck = volta.check_lean_proof(directory)
            if recheck.proved:
                return lean_row(row, recheck.proved_statements, recheck.statements, True)
    result = volta.prove_lean(
        kernel, config, output_dir=directory, equivalence=False, verbose=True, **arguments
    )
    return lean_row(row, result.proved_statements, result.statements, result.proved)


def lean_row(row: Row, proved: int, statements: int, verified: bool) -> Row:
    row.lean = f"{proved} of {statements} proved within {TOLERANCE}"
    if verified:
        row.verified_by = f"Lean ({LEAN_SIZE}x{LEAN_SIZE}x{LEAN_SIZE}, within {TOLERANCE})"
    print(f"{row.case}: {row.lean} in Lean ({LEAN_DIR / row.case / 'proof.lean'})", flush=True)
    return row


def report(rows: list[Row]) -> str:
    lines = [
        "# OpenCL GEMM + activation: verification report",
        "",
        "Written by `prove.py` (`just opencl_lean`). Each kernel is a 128x128x128 GEMM with the "
        "activation fused; the canonical solver checks it at that size, and Lean, when the solver "
        f"does not accept it, checks the same binary at {LEAN_SIZE}x{LEAN_SIZE}x{LEAN_SIZE}.",
        "",
        "| Case | Spec | Canonical solver | Lean | Verified by |",
        "|---|---|---|---|---|",
    ]
    lines += [f"| `{r.case}` | `{r.spec}` | {r.solver} | {r.lean} | {r.verified_by} |"
              for r in rows]
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--extract-only", action="store_true")
    parser.add_argument("cases", nargs="*")
    args = parser.parse_args()
    load_dotenv(REPO_ROOT / ".env")
    cases = args.cases or sorted(p.name.removesuffix(".launch.json")
                                 for p in ROOT.glob("*.launch.json"))
    rows = [check(case, args.extract_only) if args.cases or case not in SKIPPED
            else Row(case, CASES[case], solver="skipped (too long)", verified_by="skipped")
            for case in cases]
    text = report(rows)
    (ROOT / "REPORT.md").write_text(text, encoding="utf-8")
    print("\n" + text)
    run = [row for row in rows if row.verified_by != "skipped"]
    return 0 if all(row.verified_by != "not verified" for row in run) else 1


if __name__ == "__main__":
    sys.exit(main())
