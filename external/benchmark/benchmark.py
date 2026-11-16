"""Time Volta on the 256 x 64 tile of a matrix multiplication for PTX, AMD and Trainium, checking it
against its spec with the canonical solver and with Lean, and write `report.md`.

    just benchmark                               # every accelerator and contraction length
    just benchmark --sizes 128 256 --isa ptx amd
    just benchmark --no-lean                     # the canonical solver only
    just benchmark --resume                      # reuse the rows target/benchmark/results.json holds

Each run computes C = A @ B for A 256 x K and B K x 64 over f32, the tile one block computes, every
output a sum of K products, so the work grows linearly in K: `matmul.ptx` (from `matmul.cu`) and
`matmul.s` (from `matmul.hip`) run one 16 x 16 block, `matmul.py`'s `matmul_<K>` the same tile on
one NeuronCore. Per run:

- `volta solve --spec` runs the kernel (its symbolic execution, plus the graph checks on PTX and
  AMD) and decides all 16,384 outputs against the spec with the canonical solver;
- `volta extract lean` states the same outputs as Lean propositions, and Volta's Lean check
  (`volta.check_lean_proof`) accepts a proof of each, the same `unfold`, `intros`, `ring`. Past
  K = 128 (`--lean-max-k`) Lean is not run and reported as infinite: its time grows faster than K.

The table reports the times the commands print for those phases, file I/O excluded, and the Lean
check's wall time. A phase that fails (a rejected run, an exhausted decision procedure, a proof Lean
does not accept) shows as --- in its cell with its reason as a note, and the exit status is 1.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

BENCHMARK_ROOT = Path(__file__).resolve().parent
REPO_ROOT = BENCHMARK_ROOT.parent.parent
VOLTA = REPO_ROOT / "target" / "release" / "volta"
WORK_DIR = REPO_ROOT / "target" / "benchmark"
REPORT = BENCHMARK_ROOT / "report.md"
RESULTS = WORK_DIR / "results.json"

SIZES = (128, 256, 512, 1024, 2048, 4096, 8192)
TILE_M, TILE_N = 256, 64
OUTPUTS = TILE_M * TILE_N
LEAN_MAX_K = 128
CLANG = os.environ.get("CLANG", "/opt/homebrew/opt/llvm@21/bin/clang")
CUDA_FLAGS = ["-x", "cuda", "--cuda-device-only", "--cuda-gpu-arch=sm_80", "-nocudainc", "-nocudalib", "-O2", "-S"]
PROOF_STEPS = ("unfold VoltaChallenge.{name}", "intros", "ring")
LEAN_CHECK = """
import sys, time, volta
start = time.perf_counter()
check = volta.check_lean_proof(sys.argv[1])
print(f"lean check: {time.perf_counter() - start:.3f}s proved {check.proved_statements}/{check.statements}")
if not check.proved:
    print(check.report[-3000:])
    print(f"error: {check.proved_statements} of {check.statements} statements proved")
    sys.exit(1)
"""


@dataclass(frozen=True)
class Isa:
    key: str
    title: str
    kernel_file: str
    spec_file: str

    def kernel_args(self, k: int) -> list[str]:
        if self.key == "trainium":
            dims = [f"--dim=M={TILE_M}", f"--dim=N={TILE_N}", f"--dim=K={k}"]
            return ["-k", f"matmul_{k}", "--spec", str(BENCHMARK_ROOT / self.spec_file), *dims]
        return ["--config", str(write_launch(self, k))]


ISAS = (
    Isa("ptx", "PTX", "matmul.ptx", "matmul.spec"),
    Isa("amd", "AMD", "matmul.s", "matmul.spec"),
    Isa("trainium", "Trainium", "matmul.py", "matmul_nki.spec"),
)


@dataclass(frozen=True)
class Failed:
    reason: str


Phase = float | Failed
NOT_RUN = Failed("not run (--no-lean)")
SKIPPED = float("inf")


@dataclass(frozen=True)
class Timing:
    exec_secs: Phase
    canonical_secs: Phase
    lean_secs: Phase
    peak_bytes: int


def compile_ptx() -> None:
    """`external/**/*.ptx` is git-ignored, so `matmul.ptx` is rebuilt from `matmul.cu` when stale."""
    source, ptx = BENCHMARK_ROOT / "matmul.cu", BENCHMARK_ROOT / "matmul.ptx"
    if ptx.exists() and ptx.stat().st_mtime >= source.stat().st_mtime:
        return
    if not Path(CLANG).exists():
        sys.exit(f"{CLANG} is missing: set $CLANG to an LLVM clang with the NVPTX target (Homebrew llvm@21)")
    subprocess.run([CLANG, *CUDA_FLAGS, str(source), "-o", str(ptx)], check=True)


def write_launch(isa: Isa, k: int) -> Path:
    """One 16 x 16 block, computing all of C, checked against the spec at its dims."""
    launch = {
        "description": f"C = A @ B over f32, A {TILE_M} x {k}, B {k} x {TILE_N}: one block's tile",
        "kernel": "matmul",
        "block": [16, 16, 1],
        "grid": 1,
        "arrays": [
            {"name": "A", "kind": "in", "dtype": "f32", "shape": [TILE_M, k]},
            {"name": "B", "kind": "in", "dtype": "f32", "shape": [k, TILE_N]},
            {"name": "C", "kind": "out", "dtype": "f32", "shape": [TILE_M, TILE_N]},
        ],
        "params": [{"ptr": "A"}, {"ptr": "B"}, {"ptr": "C"}, {"name": "N", "int": TILE_N}, {"name": "K", "int": k}],
        "spec": str(BENCHMARK_ROOT / isa.spec_file),
        "dims": {"M": TILE_M, "N": TILE_N, "K": k},
    }
    path = WORK_DIR / f"{isa.key}.k{k}.launch.json"
    path.write_text(json.dumps(launch, indent=2) + "\n")
    return path


def failure(name: str, output: str) -> Failed:
    errors = [line for line in output.splitlines() if line.startswith("error:")]
    reason = errors[0] if errors else (output.splitlines() or ["no output"])[-1]
    return Failed(f"{name}: {reason.removeprefix('error: ')}")


def run_volta(args: list[str]) -> tuple[str, Failed | None, int]:
    """Run the CLI: its output, why it failed if it did, and its peak resident bytes."""
    process = subprocess.Popen(
        [str(VOLTA), "--no-log-file", *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=REPO_ROOT,
    )
    output = process.stdout.read()
    _, status, usage = os.wait4(process.pid, 0)
    process.returncode = os.waitstatus_to_exitcode(status)
    peak = usage.ru_maxrss if sys.platform == "darwin" else usage.ru_maxrss * 1024
    failed = process.returncode != 0
    return output, failure(f"volta {args[0]}", output) if failed else None, peak


def run_timed(command: list[str], name: str, timeout: float) -> str | Failed:
    """Run a command to completion within `timeout` seconds: its output, or why it failed."""
    try:
        done = subprocess.run(command, capture_output=True, text=True, cwd=REPO_ROOT, timeout=timeout)
    except subprocess.TimeoutExpired:
        return Failed(f"{name}: timed out after {timeout:.0f}s")
    output = done.stdout + done.stderr
    return failure(name, output) if done.returncode != 0 else output


def seconds(pattern: str, output: str, command: str) -> float:
    found = re.search(pattern, output)
    if found is None:
        sys.exit(f"no {pattern!r} line in the output of {command}:\n{output[-2000:]}")
    return float(found.group(1))


def canonical(isa: Isa, k: int) -> tuple[Phase, Phase, int]:
    """`volta solve` against the spec: the execution's and the canonical solver's seconds."""
    kernel = BENCHMARK_ROOT / isa.kernel_file
    command = ["solve", str(kernel), *isa.kernel_args(k), "--print-outputs", "0"]
    solved, failed, peak = run_volta(command)
    executed = re.search(r"time: ([0-9.]+)s", solved)
    exec_secs = float(executed.group(1)) if executed else (failed or Failed("volta solve: no time line"))
    if failed is not None:
        return exec_secs, failed, peak
    if "\nEQUIVALENT" not in solved:
        if any(line.startswith("error:") for line in solved.splitlines()):
            return exec_secs, failure("volta solve", solved), peak
        return exec_secs, Failed("volta solve: the outputs are not proved equal to the spec"), peak
    return exec_secs, seconds(r"VC check: ([0-9.]+)s", solved, "volta solve"), peak


def proof(challenge: str) -> str:
    """One proof per statement, all alike: each is a sum of products reassociated. A K-term sum
    nests K deep, past Lean's default recursion depth, and `ring` on it past the default heartbeats."""
    names = re.findall(r"^def (\S+) : Prop", challenge, re.M)
    steps = "".join(f"  {step}\n" for step in PROOF_STEPS)
    limits = "set_option maxRecDepth 1000000 in\nset_option maxHeartbeats 0 in\n"
    theorems = "".join(f"{limits}theorem {n} : VoltaChallenge.{n} := by\n{steps.format(name=n)}\n" for n in names)
    return f"import challenge\n\nnamespace VoltaProofs\n\n{theorems}end VoltaProofs\n"


def lean(isa: Isa, k: int, timeout: float, keep: bool) -> tuple[Phase, int]:
    """`volta extract lean` of every output, then Volta's Lean check of the fixed proof."""
    directory = WORK_DIR / "lean" / f"{isa.key}.k{k}"
    shutil.rmtree(directory, ignore_errors=True)
    directory.mkdir(parents=True)
    challenge = directory / "challenge.lean"
    kernel = BENCHMARK_ROOT / isa.kernel_file
    extract = ["extract", "lean", str(kernel), *isa.kernel_args(k)]
    _, failed, peak = run_volta([*extract, "--print-outputs", "0", "-o", str(challenge)])
    if failed is not None:
        return failed, peak
    (directory / "proof.lean").write_text(proof(challenge.read_text()))
    command = ["uv", "run", "--no-sync", "--project", str(REPO_ROOT), "python", "-c", LEAN_CHECK, str(directory)]
    checked = run_timed(command, "Lean check", timeout)
    if not keep:
        shutil.rmtree(directory, ignore_errors=True)
    if isinstance(checked, Failed):
        return checked, peak
    return seconds(r"lean check: ([0-9.]+)s", checked, "the Lean check"), peak


def benchmark(isa: Isa, k: int, with_lean: bool, lean_max_k: int, lean_timeout: float, keep: bool) -> Timing:
    """Lean past `lean_max_k` is not run and reported as infinite."""
    exec_secs, canonical_secs, peak = canonical(isa, k)
    if not with_lean:
        lean_secs, lean_peak = NOT_RUN, 0
    elif k > lean_max_k:
        lean_secs, lean_peak = SKIPPED, 0
    else:
        lean_secs, lean_peak = lean(isa, k, lean_timeout, keep)
    return Timing(exec_secs, canonical_secs, lean_secs, max(peak, lean_peak))


def cell(phase: Phase, notes: list[str]) -> str:
    """Seconds, ∞ for a phase not run for taking too long, or a dash marked with the number of
    the failure's note."""
    if phase == SKIPPED:
        return "∞"
    if not isinstance(phase, Failed):
        return f"{phase:.2f}"
    if phase.reason not in notes:
        notes.append(phase.reason)
    return f"—<sup>{notes.index(phase.reason) + 1}</sup>"


def table(heads: list[str], rows: list[list[str]]) -> list[str]:
    return [
        "| " + " | ".join(heads) + " |",
        "|" + "|".join("---:" for _ in heads) + "|",
        *("| " + " | ".join(row) + " |" for row in rows),
    ]


def phase_json(phase: Phase) -> float | str | dict:
    if phase == SKIPPED:
        return "inf"
    return {"failed": phase.reason} if isinstance(phase, Failed) else phase


def phase_from_json(value: float | str | dict) -> Phase:
    if value == "inf":
        return SKIPPED
    return Failed(value["failed"]) if isinstance(value, dict) else value


def load_results() -> dict[tuple[str, int], Timing]:
    """The rows earlier runs measured, keyed by ISA and K."""
    if not RESULTS.exists():
        return {}
    rows = json.loads(RESULTS.read_text())
    return {
        (row["isa"], row["k"]): Timing(
            *(phase_from_json(row[name]) for name in ("exec", "canonical", "lean")),
            row["peak_bytes"],
        )
        for row in rows
    }


def save_results(timings: dict[tuple[str, int], Timing]) -> None:
    rows = [
        {
            "isa": isa,
            "k": k,
            "exec": phase_json(t.exec_secs),
            "canonical": phase_json(t.canonical_secs),
            "lean": phase_json(t.lean_secs),
            "peak_bytes": t.peak_bytes,
        }
        for (isa, k), t in sorted(timings.items())
    ]
    RESULTS.write_text(json.dumps(rows, indent=2) + "\n")


def markdown_report(
    isas: list[Isa], sizes: list[int], timings: dict[tuple[str, int], Timing], lean_max_k: int
) -> str:
    heads = ["K", "exec (s)", "canonical (s)", "Lean (s)"]
    notes: list[str] = []
    sections = []
    for isa in isas:
        rows = []
        for k in sizes:
            t = timings[(isa.key, k)]
            phases = (t.exec_secs, t.canonical_secs, t.lean_secs)
            rows.append([str(k), *(cell(phase, notes) for phase in phases)])
        sections += [f"## {isa.title}", "", *table(heads, rows), ""]
    memory_rows = [[str(k)] + [f"{timings[(isa.key, k)].peak_bytes / 2**30:.1f}" for isa in isas] for k in sizes]
    steps = "`, `".join(step.format(name="<name>") for step in PROOF_STEPS)
    return "\n".join(
        [
            "# Matmul benchmark",
            "",
            f"Volta on C = A @ B over f32, A {TILE_M} x K and B K x {TILE_N}: the tile one PTX or AMD block",
            f"computes, and the same tile on one Trainium NeuronCore, each of the {OUTPUTS} outputs a sum of K",
            "products (`just benchmark`; see `README.md`). *exec* is the symbolic execution `volta solve`",
            "times, with the race and deadlock graph checks on PTX and AMD. The outputs are checked against",
            f"the spec two ways, over all {OUTPUTS} outputs:",
            "",
            "- *canonical* is the canonical solver (`volta solve --spec`), spec unfolding included;",
            "- *Lean* is Volta's Lean check (`volta.check_lean_proof`) of a proof of the statements",
            f"  `volta extract lean` writes, each `{steps}`: Lean elaborates the statements",
            "  and the proof, then `leanchecker` replays them in the kernel. Each Lean process imports Mathlib.",
            f"  ∞ marks a K past {lean_max_k}, where Lean is not run: its time grows faster than K.",
            "",
            *sections,
            *(f"<sup>{i + 1}</sup> {note}  " for i, note in enumerate(notes)),
            *([""] if notes else []),
            "## Peak memory",
            "",
            "The largest peak resident set of the run's `volta` commands (the Lean check's processes excluded).",
            "",
            *table(["K"] + [f"{isa.title} (GiB)" for isa in isas], memory_rows),
            "",
        ]
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--sizes", type=int, nargs="+", default=list(SIZES), choices=SIZES, metavar="K")
    parser.add_argument("--isa", nargs="+", default=[isa.key for isa in ISAS], choices=[isa.key for isa in ISAS])
    parser.add_argument("--no-lean", action="store_true", help="skip the Lean check")
    parser.add_argument("--lean-timeout", type=float, default=4 * 3600, metavar="SECS", help="per Lean check")
    parser.add_argument(
        "--lean-max-k", type=int, default=LEAN_MAX_K, metavar="K", help="report Lean past this K as infinite"
    )
    parser.add_argument("--keep", action="store_true", help="keep the Lean files in target/benchmark/lean/")
    parser.add_argument(
        "--resume", action="store_true", help=f"reuse the rows {RESULTS.relative_to(REPO_ROOT)} holds"
    )
    args = parser.parse_args()

    if not VOLTA.exists():
        sys.exit(f"{VOLTA} is missing: build it with `cargo build --release -p volta_cli`")
    if not args.no_lean and "VOLTA_LEAN_PROJECT" not in os.environ:
        sys.exit("$VOLTA_LEAN_PROJECT is unset: point it at a Lake project with Mathlib built, or pass --no-lean")
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    isas = [isa for isa in ISAS if isa.key in args.isa]
    if any(isa.key == "ptx" for isa in isas):
        compile_ptx()
    saved = load_results() if args.resume else {}
    timings = {}
    for isa in isas:
        for k in args.sizes:
            if (isa.key, k) in saved:
                timing = saved[(isa.key, k)]
            else:
                timing = benchmark(isa, k, not args.no_lean, args.lean_max_k, args.lean_timeout, args.keep)
            timings[(isa.key, k)] = timing
            save_results({**saved, **timings})
            named = (
                ("exec", timing.exec_secs),
                ("canonical", timing.canonical_secs),
                ("lean", timing.lean_secs),
            )
            phases = "  ".join(
                f"{name} " + (phase.reason if isinstance(phase, Failed) else f"{phase:7.2f}s".replace("inf", "∞"))
                for name, phase in named
            )
            print(f"{isa.title:>8}  K = {k:>4}  {phases}  peak {timing.peak_bytes / 2**30:5.1f} GiB", file=sys.stderr, flush=True)
    REPORT.write_text(markdown_report(isas, args.sizes, timings, args.lean_max_k))
    print(f"Wrote {REPORT.relative_to(REPO_ROOT)}")
    phases = [p for t in timings.values() for p in (t.exec_secs, t.canonical_secs, t.lean_secs)]
    sys.exit(1 if any(isinstance(p, Failed) and p is not NOT_RUN for p in phases) else 0)


if __name__ == "__main__":
    main()
