"""Prove in Lean that each polynomial-approximation kernel here is within TOLERANCE of its spec.

    uv run --reinstall-package volta --package volta python \
        external/triton_polynomial_approximation/prove.py [--max-turns N] [CASE...]

Each case is `<case>.ptx` with `<case>.launch.json` beside it, its spec the exact function the
kernel approximates. Volta runs the kernel (if-converting libdevice's branches on the argument and
reading logf's exponent and mantissa as reals), states every output within TOLERANCE of the spec
(for `softplus`, on inputs within INPUT_BOUNDS, where the hardware's exp does not overflow),
and a Claude Code agent proves it into `target/lean/activation_triton/<case>/`; a later run
rechecks that proof without the agent while the challenge is unchanged. Each proved case's
`challenge.lean` and `proof.lean` are copied to `lean/<case>/` here, every agent attempt is
appended to `lean/<case>/attempts.json`, and REPORT.md is written from them (`--report` writes
only the report). Lean needs `$VOLTA_LEAN_PROJECT` (or the repository's `.env`) and Claude Code.
The exit status is 1 unless every case is proved.
"""

import argparse
import datetime
import json
import os
import shutil
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import volta

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[1]
LEAN_DIR = REPO_ROOT / "target" / "lean" / "activation_triton"
CASES = ("tanh", "softplus", "gelu_erf_as", "gelu_erf")
TOLERANCE = "1/1000"
# Past |x| = 88.72 an f32 exp overflows to +inf; over the reals logf's f32 ln 2 times the
# exponent drifts from log by 1.9e-9 per unit, past TOLERANCE beyond x = 364,000.
INPUT_BOUNDS = {"softplus": "88"}
ARRAY_ALIGN = 0x10000
# What each case computes and the approximation the kernel substitutes, for REPORT.md.
DESCRIPTIONS = {
    "tanh": ("tanh(x)", "libdevice `tanhf`: odd polynomial below 0.6, `1 - 2/(e^2x + 1)` above"),
    "softplus": ("log(1 + e^x)", "libdevice `logf`: exponent/mantissa split, degree-10 polynomial"),
    "gelu_erf_as": ("GELU with erf", "Abramowitz-Stegun 7.1.26 `erf` (the AI compiler's)"),
    "gelu_erf": ("GELU with erf", "libdevice `erff`: two degree-6 polynomials split at 1.003"),
}


def load_launch(case: str) -> tuple[volta.Config, dict]:
    launch = json.loads((ROOT / f"{case}.launch.json").read_text())
    config = volta.Config(block=tuple(launch["block"]), grid=tuple(launch["grid"]),
                          dynamic_shared_bytes=launch.get("dynamic_shared_bytes", 0))
    base = ARRAY_ALIGN
    for array in launch["arrays"]:
        kind = volta.ArrayKind.Input if array["kind"] == "in" else volta.ArrayKind.Output
        config.add_array(volta.ArrayDef(array["name"], base, 4, array["shape"][0], kind))
        base += ARRAY_ALIGN
    for param in launch["params"]:
        config.add_param(volta.Param.array_ptr(param["ptr"]) if "ptr" in param
                         else volta.Param.int(param["int"]))
    return config, launch


def prove(case: str, max_turns: int) -> tuple[str, bool, str]:
    config, launch = load_launch(case)
    arguments = dict(kernel=launch["kernel"], spec=(ROOT / launch["spec"]).read_text(),
                     dims=launch["dims"], tolerance=TOLERANCE,
                     input_bound=INPUT_BOUNDS.get(case))
    directory = LEAN_DIR / case
    challenge = directory / "challenge.lean"
    kernel = ROOT / f"{case}.ptx"

    if challenge.exists() and (directory / "proof.lean").exists():
        extraction = volta.extract_lean(kernel, config, **arguments)
        if extraction.lean == challenge.read_text():
            recheck = volta.check_lean_proof(directory)
            if recheck.proved:
                keep(case, directory)
                return case, True, f"rechecked {directory}"

    result = volta.prove_lean(kernel, config, output_dir=directory, equivalence=False,
                              max_turns=max_turns, **arguments)
    record(case, {
        "date": datetime.date.today().isoformat(),
        "proved": result.proved,
        "statements": result.statements,
        "seconds": round(result.duration_seconds),
        "turns": result.turns,
        "cost_usd": result.cost_usd,
    })
    if result.proved:
        keep(case, directory)
    cost = f", ${result.cost_usd:.2f}" if result.cost_usd is not None else ""
    detail = (f"{result.proved_statements} of {result.statements} proved in "
              f"{result.duration_seconds:.0f} s, {result.turns} turns{cost}")
    return case, result.proved, detail


def keep(case: str, directory: Path) -> None:
    saved = ROOT / "lean" / case
    saved.mkdir(parents=True, exist_ok=True)
    for name in ("challenge.lean", "proof.lean"):
        shutil.copyfile(directory / name, saved / name)


def record(case: str, attempt: dict) -> None:
    path = ROOT / "lean" / case / "attempts.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    attempts = json.loads(path.read_text()) if path.exists() else []
    path.write_text(json.dumps(attempts + [attempt], indent=2) + "\n")


def write_report() -> None:
    lines = [
        "# Triton polynomial approximations: Lean proofs",
        "",
        f"Written by `prove.py`. Each kernel's 64 outputs are claimed within {TOLERANCE} of the "
        "exact function it approximates; `softplus` for inputs within "
        f"{INPUT_BOUNDS['softplus']} in absolute value. Every proof was written by a Claude Code "
        "agent and checked by Lean and `leanchecker`.",
        "",
        "| Kernel | Function | Approximation | Statements | Proof (lines) | Proof (bytes) "
        "| Time (s) | Turns | Cost (USD) | All attempts (USD) |",
        "|---|---|---|---:|---:|---:|---:|---:|---:|---:|",
    ]
    total, total_all = 0.0, 0.0
    for case in CASES:
        proof = ROOT / "lean" / case / "proof.lean"
        path = ROOT / "lean" / case / "attempts.json"
        attempts = json.loads(path.read_text()) if path.exists() else []
        proved = [a for a in attempts if a["proved"]]
        function, approximation = DESCRIPTIONS[case]
        if not proved or not proof.exists():
            lines.append(f"| `{case}` | {function} | {approximation} | - | - | - | - | - | - "
                         "| - |")
            continue
        last = proved[-1]
        spent = sum(a["cost_usd"] or 0 for a in attempts)
        total += last["cost_usd"] or 0
        total_all += spent
        text = proof.read_text()
        lines.append(
            f"| [`{case}`]({case}.ptx) | {function} | {approximation} | {last['statements']} "
            f"| [{len(text.splitlines())}](lean/{case}/proof.lean) | {len(text.encode())} "
            f"| {last['seconds']} | {last['turns']} | {last['cost_usd']:.2f} | {spent:.2f} |"
        )
    lines += [
        f"| **Total** | | | | | | | | **{total:.2f}** | **{total_all:.2f}** |",
        "",
        "Time, turns and cost are the proving attempt's; the last column adds the earlier "
        "attempts that did not prove the case (`lean/<case>/attempts.json` lists each).",
        "",
    ]
    (ROOT / "REPORT.md").write_text("\n".join(lines))


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        name, separator, value = line.partition("=")
        if separator and not name.lstrip().startswith("#"):
            os.environ.setdefault(name.strip(), os.path.expanduser(value.strip()))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", default=list(CASES))
    parser.add_argument("--max-turns", type=int, default=150)
    parser.add_argument("-j", "--jobs", type=int, default=4)
    parser.add_argument("--report", action="store_true", help="only write REPORT.md")
    args = parser.parse_args()
    if args.report:
        write_report()
        return 0
    load_dotenv(REPO_ROOT / ".env")

    with ThreadPoolExecutor(args.jobs) as pool:
        results = list(pool.map(lambda case: prove(case, args.max_turns), args.cases))
    for case, proved, detail in results:
        print(f"{'PROVED' if proved else 'NOT PROVED'} {case}: {detail}", flush=True)
    write_report()
    return 0 if all(proved for _, proved, _ in results) else 1


if __name__ == "__main__":
    sys.exit(main())
