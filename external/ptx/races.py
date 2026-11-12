"""Check the external kernels for data races with Volta, one framework after the other.

    python3 external/ptx/races.py                               # every framework
    python3 external/ptx/races.py --framework thunderkittens    # one of `FRAMEWORKS`
    python3 external/ptx/races.py --framework tritonbench -k add_example --timeout 300

Builds the release `volta` CLI, then analyzes each launch file
`<framework>/**/<stem>.<case>.launch.json`, in name order, with
`volta analyze <stem>.ptx --config <launch file>` (the `<stem>.ptx` beside
it). A run is RACE-FREE when the graph checks verify it, a RACE-CONDITION
when a memory-conflict, proxy-order or tensor-order check fails, CHECK-FAILED
or DEADLOCK when another check fails, UNSUPPORTED when it reaches a construct
Volta does not model, and UNKNOWN when it has no verdict within `--timeout`.
Each framework's outcomes go to `output/<framework>.csv`; the exit status is 1
if any run is a RACE-CONDITION, CHECK-FAILED, DEADLOCK or ERROR.
"""

import argparse
import csv
import enum
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
OUTPUT_DIR = EXTERNAL_ROOT / "output"
VOLTA = REPO_ROOT / "target" / "release" / "volta"

# TritonBench-G (`extraction/tritonbench.py`), ThunderKittens' educational GEMMs (`extraction/thunderkittens.py`),
# Triton's Gluon tutorials (`extraction/gluon.py`), TileLang's examples (`extraction/tilelang_kernels.py`) and
# the AI compiler's PTX for PTX Gym's operators (`extraction/ai_compiler.py`).
FRAMEWORKS = ("tritonbench", "thunderkittens", "gluon", "tilelang", "ai_compiler")


class Outcome(enum.Enum):
    RACE_FREE = "RACE-FREE"
    RACE_CONDITION = "RACE-CONDITION"
    CHECK_FAILED = "CHECK-FAILED"
    DEADLOCK = "DEADLOCK"
    UNSUPPORTED = "UNSUPPORTED"
    UNKNOWN = "UNKNOWN"
    ERROR = "ERROR"


FAILURES = {Outcome.RACE_CONDITION, Outcome.CHECK_FAILED, Outcome.DEADLOCK, Outcome.ERROR}
OUTCOME_WIDTH = max(len(outcome.value) for outcome in Outcome)
# `Property::name`s of the checks whose failure is a race condition: an unordered conflicting
# access (global/shared or Tensor Memory) or a cross-proxy pair no proxy fence orders.
RACE_CHECKS = ("memory-conflict freedom", "proxy ordering", "tensor-operation ordering")
# A construct Volta does not model, rejected at lowering or when the execution reaches it.
LOWERING_FAILED = re.compile(r"\blowering failed: (.*)")
# A directive or instruction form the frontend does not know (the parse report's last line).
PARSE_FAILED = re.compile(r"\b(Invalid [a-z ]+: \S+)$")
EXECUTION_UNSUPPORTED = re.compile(r"^the execution stopped: (unsupported at .*)")
CHECK_LINE = re.compile(r"^  (\S.*?) \((?:Algorithms? |PTX ISA |phase chain)[^)]*\)\s+(PASS|FAIL|UNKNOWN)$")
VERDICT_LINE = re.compile(r"^GRAPH VERIFICATION: (VERIFIED|REJECTED|UNKNOWN)")
WRITTEN_LINE = re.compile(r"^  output '[^']*': (\d+) element\(s\) written$")
NO_OUTPUTS_LINE = re.compile(r"^  no outputs: (.*)$")
DEADLOCK_LINE = re.compile(r"^  trace: deadlock")
LOG_LINE = re.compile(r"^\[(ERROR|WARN|INFO|DEBUG|TRACE) *\] ")

# ANSI SGR codes.
BOLD, RED, GREEN, YELLOW = "1", "31", "32", "33"
OUTCOME_CODES = {
    Outcome.RACE_FREE: (BOLD, GREEN),
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


def classify(report: CliReport, stderr: str) -> tuple[Outcome, str]:
    if report.verdict is None:
        errors = "\n".join(line for line in stderr.splitlines() if not LOG_LINE.match(line))
        error = " ".join(errors.split()) or "volta produced no verdict"
        if m := LOWERING_FAILED.search(error):
            return Outcome.UNSUPPORTED, m[1]
        if m := PARSE_FAILED.search(error):
            return Outcome.UNSUPPORTED, m[1]
        raise VoltaFailure(error)
    coverage = f"{report.written} outputs written"
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
    findings = [f"{check}: {finding}" for check, verdict, finding in report.checks if verdict != "PASS"]
    return Outcome.UNKNOWN, "; ".join([coverage, *(findings or report.reasons)])


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
        f"warning: cargo build failed ({reason}); using the existing {VOLTA.relative_to(REPO_ROOT)} built {built}",
        file=sys.stderr,
    )


@dataclass(frozen=True)
class Run:
    name: str
    outcome: Outcome
    seconds: float
    detail: str


def check(launch: Path, root: Path, timeout: float) -> Run:
    name = str(launch.relative_to(root)).removesuffix(".launch.json")
    ptx = launch.with_name(launch.name.split(".")[0] + ".ptx")
    # Rendering outputs can cost GBs (shared subterms print as trees); counts suffice.
    command = [
        str(VOLTA), "--no-log-file", "analyze", str(ptx), "--config", str(launch),
        "--print-outputs", "0", "--no-profile",
    ]
    start = time.perf_counter()
    try:
        done = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return Run(name, Outcome.UNKNOWN, timeout, f"no verdict within {timeout:.0f}s")
    try:
        outcome, detail = classify(parse_cli(done.stdout), done.stderr)
    except VoltaFailure as failure:
        outcome, detail = Outcome.ERROR, str(failure)
    return Run(name, outcome, time.perf_counter() - start, detail)


def check_framework(framework: str, match: str, timeout: float, style: Style) -> bool:
    """Run every matching launch file of `framework` in order; whether any run failed."""
    root = EXTERNAL_ROOT / framework
    launches = [p for p in sorted(root.rglob("*.launch.json")) if match in str(p.relative_to(root))]
    print(style.paint(f"== {framework}: {len(launches)} launches", BOLD), flush=True)
    width = max((len(str(p.relative_to(root))) for p in launches), default=0) - len(".launch.json")
    runs = []
    for launch in launches:
        run = check(launch, root, timeout)
        runs.append(run)
        painted = style.paint(f"{run.outcome.value:<{OUTCOME_WIDTH}}", *OUTCOME_CODES[run.outcome])
        print(f"{run.name:<{width}}  {painted}  {run.seconds:6.1f}s  {run.detail}", flush=True)

    OUTPUT_DIR.mkdir(exist_ok=True)
    csv_path = OUTPUT_DIR / f"{framework}.csv"
    with csv_path.open("w", newline="") as out:
        writer = csv.writer(out)
        writer.writerow(["launch", "outcome", "seconds", "detail"])
        writer.writerows((r.name, r.outcome.value, f"{r.seconds:.3f}", r.detail) for r in runs)
    outcomes = [r.outcome for r in runs]
    failed = any(o in FAILURES for o in outcomes)
    counts = ", ".join(f"{outcomes.count(o)} {o.value}" for o in Outcome if o in outcomes) or "no launches"
    print(f"\n{framework}: {style.paint(counts, BOLD, RED if failed else GREEN)}\nwrote {csv_path}\n", flush=True)
    return failed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--framework", choices=FRAMEWORKS, help="check only this framework (default: all, in order)")
    parser.add_argument("-k", dest="match", default="", help="only launches whose name contains this")
    parser.add_argument("--timeout", type=float, default=60, help="seconds per run (default 60)")
    args = parser.parse_args()

    style = Style(sys.stdout.isatty() and not os.environ.get("NO_COLOR"))
    build_volta()
    frameworks = (args.framework,) if args.framework else FRAMEWORKS
    failed = [check_framework(f, args.match, args.timeout, style) for f in frameworks]
    return 1 if any(failed) else 0


if __name__ == "__main__":
    sys.exit(main())
