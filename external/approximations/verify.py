#!/usr/bin/env python3
"""Check every fused GEMM + activation kernel here against its spec with Volta's canonical solver.

    cargo build --release -p volta_cli
    python3 external/approximations/verify.py [--sample N] [--filter TEXT] [--timeout S] [--markdown]
                                              [--report FILE]

Each case is a kernel `<compiler>/<case>.ptx` (CUTLASS, Triton) or `.s` (Composable Kernel, OpenCL)
with the launch file `<compiler>/<case>.launch.json` beside it, run with `volta solve`. A line per
case gives its verdict (ACCEPT, UNKNOWN or REJECT; TIMEOUT once `--timeout` seconds pass), the
symbolic execution and solver times, and the solver's first piece of evidence when it is not ACCEPT;
`--markdown` also prints the README's table at the end, and `--report FILE` writes a markdown report
of every case (its kernel, spec, outputs checked, graph checks, verdict and why). EXPECTED holds
each case's verdict, explained in README.md; the exit status is 1 when a verdict differs from it.
"""
import argparse
import datetime
import json
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VOLTA = ROOT.parents[1] / "target" / "release" / "volta"
COMPILERS = {"cutlass": ".ptx", "triton": ".ptx", "composable_kernel": ".s", "opencl": ".s"}

EXPECTED = {
    "cutlass/celu": "ACCEPT",
    "cutlass/elu": "ACCEPT",
    "cutlass/gelu_erf": "UNKNOWN",
    "cutlass/gelu_tanh": "ACCEPT",
    "cutlass/hardsigmoid": "ACCEPT",
    "cutlass/hardswish": "ACCEPT",
    "cutlass/hardtanh": "ACCEPT",
    "cutlass/leaky_relu": "ACCEPT",
    "cutlass/relu": "ACCEPT",
    "cutlass/selu": "ACCEPT",
    "cutlass/sigmoid": "ACCEPT",
    "cutlass/sigmoid_precise": "REJECT",
    "cutlass/sigmoid_tanh": "ACCEPT",
    "cutlass/silu": "ACCEPT",
    "cutlass/softplus": "ACCEPT",
    "cutlass/softplus_threshold": "UNKNOWN",
    "cutlass/softshrink": "ACCEPT",
    "cutlass/tanh": "ACCEPT",
    "triton/celu": "ACCEPT",
    "triton/elu": "ACCEPT",
    "triton/gelu_erf": "UNKNOWN",
    "triton/gelu_tanh": "ACCEPT",
    "triton/gelu_tanh_libdevice": "UNKNOWN",
    "triton/hardsigmoid": "ACCEPT",
    "triton/hardswish": "ACCEPT",
    "triton/hardtanh": "ACCEPT",
    "triton/leaky_relu": "ACCEPT",
    "triton/relu": "ACCEPT",
    "triton/selu": "ACCEPT",
    "triton/sigmoid": "ACCEPT",
    "triton/silu": "ACCEPT",
    "triton/softplus": "UNKNOWN",
    "triton/softplus_fast": "ACCEPT",
    "triton/softplus_threshold": "UNKNOWN",
    "triton/softshrink": "ACCEPT",
    "triton/tanh": "ACCEPT",
    "composable_kernel/celu": "ACCEPT",
    "composable_kernel/elu": "UNKNOWN",
    "composable_kernel/fast_gelu": "ACCEPT",
    "composable_kernel/gelu": "UNKNOWN",
    "composable_kernel/hardsigmoid": "ACCEPT",
    "composable_kernel/hardswish": "ACCEPT",
    "composable_kernel/hardtanh": "ACCEPT",
    "composable_kernel/leaky_relu": "UNKNOWN",
    "composable_kernel/relu": "ACCEPT",
    "composable_kernel/selu": "ACCEPT",
    "composable_kernel/sigmoid": "ACCEPT",
    "composable_kernel/sigmoid_precise": "UNKNOWN",
    "composable_kernel/silu": "ACCEPT",
    "composable_kernel/softrelu": "ACCEPT",
    "composable_kernel/softshrink": "ACCEPT",
    "composable_kernel/swish": "ACCEPT",
    "composable_kernel/tanh": "UNKNOWN",
    "opencl/celu": "UNKNOWN",
    "opencl/elu": "UNKNOWN",
    "opencl/fast_gelu": "REJECT",
    "opencl/gelu": "UNKNOWN",
    "opencl/hardsigmoid": "ACCEPT",
    "opencl/hardswish": "ACCEPT",
    "opencl/hardtanh": "ACCEPT",
    "opencl/leaky_relu": "ACCEPT",
    "opencl/relu": "ACCEPT",
    "opencl/selu": "UNKNOWN",
    "opencl/sigmoid": "UNKNOWN",
    "opencl/silu": "UNKNOWN",
    "opencl/softrelu": "UNKNOWN",
    "opencl/softshrink": "ACCEPT",
    "opencl/tanh": "UNKNOWN",
}


def cases(text: str):
    for compiler, extension in COMPILERS.items():
        for launch in sorted((ROOT / compiler).glob("*.launch.json")):
            name = launch.name[: -len(".launch.json")]
            if text in f"{compiler}/{name}":
                yield compiler, name, launch.with_name(name + extension), launch


def solve(kernel: Path, launch: Path, sample: int, timeout: float | None) -> dict:
    command = [str(VOLTA), "--no-log-file", "solve", str(kernel), "--config", str(launch),
               "--print-outputs", "0", "--sample", str(sample)]
    start = time.monotonic()
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout)
        out = result.stdout + result.stderr
    except subprocess.TimeoutExpired as expired:
        out = (expired.stdout or b"").decode() + f"\nVERDICT: TIMEOUT\n"
    seconds = time.monotonic() - start
    verdict = re.search(r"^VERDICT: (\w+)", out, re.M)
    exec_time = re.search(r"^\s+time: ([\d.]+)s", out, re.M)
    check_time = re.search(r"^VC check: ([\d.]+)s", out, re.M)
    evidence = re.search(r"^\s+equivalence: (.+)$", out, re.M)
    error = re.search(r"^error: (.+)$", out, re.M)
    checked = re.search(r"elements: (\d+)", out)
    written = re.search(r"(\d+) element\(s\) written", out)
    checks = re.findall(r"^  (.+?)\s+(PASS|FAIL|UNKNOWN)$", out, re.M)
    if re.search(r"^\s+kernel: the trace generator aborted", out, re.M):
        graph = "aborted (partial graph)"
    elif checks:
        failing = [f"{name} {status}" for name, status in checks if status != "PASS"]
        graph = "; ".join(failing) if failing else f"all {len(checks)} pass"
    else:
        graph = "-"
    return dict(
        elements=(f"{checked[1] if checked else 0} / {written[1]}" if written else "-"),
        graph=graph,
        verdict=verdict[1] if verdict else "ERROR",
        exec=float(exec_time[1]) if exec_time else None,
        check=float(check_time[1]) if check_time else None,
        evidence=(evidence or error)[1] if (evidence or error) else "",
        seconds=seconds,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--sample", type=int, default=0, help="check at most N outputs (0 = all)")
    parser.add_argument("--filter", default="", help="run the cases whose compiler/name contains it")
    parser.add_argument("--timeout", type=float, help="give up on a case after this many seconds")
    parser.add_argument("--markdown", action="store_true", help="also print a markdown table")
    parser.add_argument("--report", type=Path, help="write a markdown report of every case to FILE")
    args = parser.parse_args()
    if not VOLTA.exists():
        print(f"error: {VOLTA} is missing; run cargo build --release -p volta_cli", file=sys.stderr)
        return 1

    mismatches = 0
    report = []
    rows = ["| Compiler | Case | Verdict | Execution (s) | Solver (s) |", "|---|---|---|---:|---:|"]
    for compiler, name, kernel, launch in cases(args.filter):
        if not kernel.exists():
            print(f"{compiler}/{name}: {kernel.name} is missing; run {compiler}/extract.py")
            mismatches += 1
            continue
        result = solve(kernel, launch, args.sample, args.timeout)
        expected = EXPECTED.get(f"{compiler}/{name}")
        if expected is not None and result["verdict"] != expected:
            mismatches += 1
        note = "" if expected in (None, result["verdict"]) else f" (expected {expected})"
        times = (
            f"{result['exec']:.1f}" if result["exec"] is not None else "-",
            f"{result['check']:.1f}" if result["check"] is not None else "-",
        )
        rows.append(f"| {compiler} | `{name}` | {result['verdict']}{note} | {times[0]} | {times[1]} |")
        line = f"{result['verdict']}{note} {compiler}/{name}: exec {times[0]}s, solver {times[1]}s"
        if result["verdict"] != "ACCEPT" and result["evidence"]:
            line += f"; {result['evidence']}"
        print(line, flush=True)
        report.append((compiler, name, launch, expected, result))
    if args.report:
        write_report(args.report, report, args.sample)
        print(f"wrote {args.report}")
    if args.markdown:
        print("\n" + "\n".join(rows))
    return 1 if mismatches else 0


def cell(text: str) -> str:
    return text.replace("|", "\\|").replace("\n", " ")


def write_report(path: Path, report: list, sample: int) -> None:
    commit = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                            capture_output=True, text=True).stdout.strip() or "unknown"
    dirty = subprocess.run(["git", "status", "--porcelain", "--", "."], cwd=ROOT.parents[1],
                           capture_output=True, text=True).stdout.strip()
    counts = {}
    for *_, result in report:
        counts[result["verdict"]] = counts.get(result["verdict"], 0) + 1
    mismatched = [f"{c}/{n}" for c, n, _, e, r in report if e not in (None, r["verdict"])]
    lines = [
        "# Fused GEMM + activation: verification report",
        "",
        f"Generated by `just approximations` on {datetime.date.today()} at commit `{commit}`"
        + (" (with uncommitted changes)" if dirty else "")
        + f", {'every output' if sample == 0 else f'the first {sample} outputs'} of each tile.",
        "",
        f"**{len(report)} kernels**: " + ", ".join(f"{n} {v}" for v, n in sorted(counts.items()))
        + (f"; differs from the expected verdict: {', '.join(mismatched)}" if mismatched else
           "; every verdict is the expected one") + ".",
        "",
        "| # | Compiler | Kernel | Spec | Outputs checked | Graph checks | Verdict | Expected "
        "| Execution (s) | Solver (s) | Evidence |",
        "|---:|---|---|---|---:|---|---|---|---:|---:|---|",
    ]
    for i, (compiler, name, launch, expected, result) in enumerate(report, 1):
        launch_file = json.loads(launch.read_text())
        spec = Path(launch_file.get("spec", "?")).stem
        times = [f"{result[k]:.1f}" if result[k] is not None else "-" for k in ("exec", "check")]
        kernel = f"[`{name}`]({compiler}/{name}{COMPILERS[compiler]})"
        lines.append(
            f"| {i} | {compiler} | {kernel} | [`{spec}`](specs/{spec}.spec) | {result['elements']} "
            f"| {cell(result['graph'])} | **{result['verdict']}** | {expected or '-'} | {times[0]} "
            f"| {times[1]} | {cell(result['evidence'])} |"
        )
    lines += ["", "## Kernels", "", "| Compiler | Kernel | Description |", "|---|---|---|"]
    for compiler, name, launch, *_ in report:
        description = json.loads(launch.read_text()).get("description", "")
        lines.append(f"| {compiler} | `{name}` | {cell(description)} |")
    lines += ["", "README.md explains each UNKNOWN and REJECT verdict.", ""]
    path.write_text("\n".join(lines))


if __name__ == "__main__":
    sys.exit(main())
