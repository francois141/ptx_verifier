"""Check the external kernels for data races with Volta, one framework after the other.

    python3 external/ptx/races.py                               # every framework
    python3 external/ptx/races.py --framework thunderkittens    # one of `FRAMEWORKS`
    python3 external/ptx/races.py --framework tritonbench -k add_example --timeout 300
    python3 external/ptx/races.py --framework thunderkittens -k units/ --jobs 4 --mem-gb 2

Builds the release `volta` CLI, then analyzes each launch file
`<framework>/**/<stem>.<case>.launch.json`, in name order, with
`volta analyze <stem>.ptx --config <launch file>` (the `<stem>.ptx` beside
it), or `volta solve` when the launch file names a `spec`, whose verdict (ACCEPT,
REJECT or UNKNOWN: race free and equal to the spec, refuted or racy, undecided)
fills the `spec` column. A run is RACE-FREE when the graph checks verify it, a RACE-CONDITION
when a memory-conflict, proxy-order or tensor-order check fails, CHECK-FAILED
or DEADLOCK when another check fails, UNSUPPORTED when it reaches a construct
Volta does not model (a cluster of several CTAs included), and UNKNOWN when it has no
verdict within `--timeout`. Every run goes through `memcap.py`, MEMORY when killed past
`--mem-gb` (default 6), and `--jobs` is lowered so that jobs x cap stays within half the
machine's memory.
Each framework's outcomes go to `output/<framework>.csv` (a `-k` run updates only its rows);
the exit status is 1
if any run is a RACE-CONDITION, CHECK-FAILED, DEADLOCK or ERROR.
"""

import argparse
import csv
import enum
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import memcap  # noqa: E402

EXTERNAL_ROOT = Path(__file__).resolve().parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
OUTPUT_DIR = EXTERNAL_ROOT / "output"
VOLTA = REPO_ROOT / "target" / "release" / "volta"

# TritonBench-G (`extraction/tritonbench.py`), ThunderKittens' educational GEMMs (`extraction/thunderkittens.py`),
# Triton's Gluon tutorials (`extraction/gluon.py`), TileLang's examples (`extraction/tilelang_kernels.py`),
# the AI compiler's PTX for PTX Gym's operators (`extraction/ai_compiler.py`) and CUTLASS's kernel
# configurations (`extraction/cutlass.py`).
FRAMEWORKS = ("tritonbench", "thunderkittens", "gluon", "tilelang", "ai_compiler", "cutlass")


class Outcome(enum.Enum):
    RACE_FREE = "RACE-FREE"
    RACE_CONDITION = "RACE-CONDITION"
    CHECK_FAILED = "CHECK-FAILED"
    DEADLOCK = "DEADLOCK"
    UNSUPPORTED = "UNSUPPORTED"
    UNKNOWN = "UNKNOWN"
    MEMORY = "MEMORY"
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
SPEC_VERDICT_LINE = re.compile(r"^VERDICT: (ACCEPT|REJECT|UNKNOWN)")
# A launch Volta cannot model, rejected while reading the launch file.
LAUNCH_UNSUPPORTED = re.compile(r"(a cluster of [^:]*?one CTA per cluster[^.]*)")
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
    Outcome.MEMORY: (BOLD, YELLOW),
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
    """What `volta analyze` or `volta solve` printed; `verdict` is None when it stopped
    before one, `spec` the spec verdict of a `solve`."""

    verdict: str | None
    spec: str | None
    checks: tuple[tuple[str, str, str], ...]  # (check, PASS|FAIL|UNKNOWN, first finding)
    written: int
    no_outputs: str | None
    deadlock: bool
    reasons: tuple[str, ...]


def parse_cli(stdout: str) -> CliReport:
    verdict, spec, checks, written, no_outputs, deadlock, reasons = None, None, [], 0, None, False, []
    for line in stdout.splitlines():
        if m := SPEC_VERDICT_LINE.match(line):
            spec = m[1]
        elif spec and line.startswith("  "):
            reasons.append(line.strip())
        elif checks and checks[-1][2] == "" and line.startswith("      "):
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
    if verdict is None and checks:  # `solve` prints the checks but no conclusion line
        verdicts = {v for _, v, _ in checks}
        verdict = "REJECTED" if "FAIL" in verdicts else \
            "UNKNOWN" if "UNKNOWN" in verdicts or no_outputs is not None else "VERIFIED"
    return CliReport(verdict, spec, tuple(checks), written, no_outputs, deadlock, tuple(reasons))


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
        if m := LAUNCH_UNSUPPORTED.search(error):
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
    with tempfile.TemporaryFile("w+") as err:
        status, note = memcap.run(
            ["cargo", "build", "--release", "--quiet", "-p", "volta_cli", "--features", "logging"],
            12.0, None, cwd=REPO_ROOT, stdout=subprocess.DEVNULL, stderr=err, text=True,
        )
        err.seek(0)
        build = subprocess.CompletedProcess([], status, "", err.read() + note)
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


def physical_memory_gb() -> float:
    out = subprocess.run(["sysctl", "-n", "hw.memsize"], capture_output=True, text=True).stdout
    return int(out) / 2**30 if out.strip().isdigit() else 16.0


@dataclass(frozen=True)
class Run:
    name: str
    kernel: str
    outcome: Outcome
    spec: str  # the spec verdict, "" without a spec
    seconds: float
    detail: str


def check(launch: Path, root: Path, timeout: float, mem_gb: float) -> Run:
    name = str(launch.relative_to(root)).removesuffix(".launch.json")
    ptx = launch.with_name(launch.name.split(".")[0] + ".ptx")
    config = json.loads(launch.read_text())
    kernel, has_spec = config.get("kernel", ""), "spec" in config
    # Rendering outputs can cost GBs (shared subterms print as trees); counts suffice.
    command = [str(VOLTA), "--no-log-file", "solve" if has_spec else "analyze", str(ptx),
               "--config", str(launch), "--print-outputs", "0", *([] if has_spec else ["--no-profile"])]
    start = time.perf_counter()
    with tempfile.TemporaryFile("w+") as out, tempfile.TemporaryFile("w+") as err:
        status, note = memcap.run(command, mem_gb, timeout, stdout=out, stderr=err, text=True)
        out.seek(0)
        err.seek(0)
        done = subprocess.CompletedProcess(command, status, out.read(), err.read())
    pending = "UNKNOWN" if has_spec else ""
    if status == memcap.KILLED_FOR_TIME:
        return Run(name, kernel, Outcome.UNKNOWN, pending, timeout, f"no verdict within {timeout:.0f}s")
    if status == memcap.KILLED_FOR_MEMORY:
        return Run(name, kernel, Outcome.MEMORY, pending, time.perf_counter() - start, note)
    report = parse_cli(done.stdout)
    try:
        outcome, detail = classify(report, done.stderr)
    except VoltaFailure as failure:
        outcome, detail = Outcome.ERROR, str(failure)
    spec = (report.spec or "UNKNOWN") if has_spec else ""
    if spec == "REJECT" and outcome == Outcome.RACE_FREE:
        detail = next((r for r in report.reasons if r.startswith("equivalence:")), detail)
    return Run(name, kernel, outcome, spec, time.perf_counter() - start, detail)


def check_framework(framework: str, match: str, timeout: float, mem_gb: float, jobs: int,
                    style: Style) -> bool:
    """Run every matching launch file of `framework`, reporting in order; whether any run failed."""
    root = EXTERNAL_ROOT / framework
    launches = [p for p in sorted(root.rglob("*.launch.json")) if match in str(p.relative_to(root))]
    print(style.paint(f"== {framework}: {len(launches)} launches", BOLD), flush=True)
    width = max((len(str(p.relative_to(root))) for p in launches), default=0) - len(".launch.json")
    runs = []
    with ThreadPoolExecutor(jobs) as pool:
        for run in pool.map(lambda launch: check(launch, root, timeout, mem_gb), launches):
            runs.append(run)
            painted = style.paint(f"{run.outcome.value:<{OUTCOME_WIDTH}}", *OUTCOME_CODES[run.outcome])
            spec = f"{run.spec:<6}  " if run.spec else " " * 8
            print(f"{run.name:<{width}}  {painted}  {spec}{run.seconds:6.1f}s  {run.detail}", flush=True)

    OUTPUT_DIR.mkdir(exist_ok=True)
    csv_path = OUTPUT_DIR / f"{framework}.csv"
    # A filtered run (`-k`) replaces only its own launches' rows; the others are kept.
    rows = {}
    if match and csv_path.exists():
        rows = {row["launch"]: row for row in csv.DictReader(csv_path.open())}
    for r in runs:
        rows[r.name] = {"launch": r.name, "kernel": r.kernel, "outcome": r.outcome.value,
                        "spec": r.spec, "seconds": f"{r.seconds:.3f}", "detail": r.detail}
    with csv_path.open("w", newline="") as out:
        writer = csv.DictWriter(out, restval="", extrasaction="ignore",
                                fieldnames=["launch", "kernel", "outcome", "spec", "seconds", "detail"])
        writer.writeheader()
        writer.writerows(rows[name] for name in sorted(rows))
    outcomes = [r.outcome for r in runs]
    failed = any(o in FAILURES for o in outcomes)
    counts = ", ".join(f"{outcomes.count(o)} {o.value}" for o in Outcome if o in outcomes) or "no launches"
    specs = [r.spec for r in runs if r.spec]
    if specs:
        counts += "; against a spec: " + ", ".join(
            f"{specs.count(v)} {v}" for v in ("ACCEPT", "REJECT", "UNKNOWN") if v in specs)
    print(f"\n{framework}: {style.paint(counts, BOLD, RED if failed else GREEN)}\nwrote {csv_path}\n", flush=True)
    return failed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--framework", choices=FRAMEWORKS, help="check only this framework (default: all, in order)")
    parser.add_argument("-k", dest="match", default="", help="only launches whose name contains this")
    parser.add_argument("--timeout", type=float, default=60, help="seconds per run (default 60)")
    parser.add_argument("--mem-gb", type=float, default=6.0, help="kill a run past this resident memory (GiB)")
    parser.add_argument("--jobs", type=int, default=1, help="runs at a time (default 1)")
    parser.add_argument("--volta", type=Path, help="a volta binary to run (default: build the release one)")
    args = parser.parse_args()

    global VOLTA
    style = Style(sys.stdout.isatty() and not os.environ.get("NO_COLOR"))
    if args.volta:
        VOLTA = args.volta.resolve()
    else:
        build_volta()
    budget = physical_memory_gb() / 2
    jobs = max(1, min(args.jobs, int(budget // args.mem_gb)))
    if jobs < args.jobs:
        print(f"running {jobs} jobs: {args.jobs} x {args.mem_gb} GB would exceed {budget:.0f} GB")
    frameworks = (args.framework,) if args.framework else FRAMEWORKS
    failed = [check_framework(f, args.match, args.timeout, args.mem_gb, jobs, style) for f in frameworks]
    return 1 if any(failed) else 0


if __name__ == "__main__":
    sys.exit(main())
