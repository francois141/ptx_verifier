"""Time Volta on an n x n matrix multiplication for PTX, AMD and Trainium, writing `report.md`.

    just benchmark                               # every accelerator and size
    just benchmark --sizes 128 256 --isa ptx amd
    python3 external/benchmark/benchmark.py --keep  # keep the .vexpr files in target/benchmark/

Each run computes the first 64 x 64 tile of C = A @ B over f32 n x n inputs, every output a sum
of n products, so the work grows linearly in n: `matmul.ptx` (from `matmul.cu`) and `matmul.s`
(from `matmul.hip`) run one 16 x 16 block, `matmul.py`'s `matmul_<n>` the NKI tile. For each,
`volta solve` runs the kernel (its symbolic execution, plus the graph checks on PTX and AMD) and
writes the outputs as `.vexpr`; `volta compare --exprs` then checks those outputs against
themselves with the canonical decision procedure. The table reports the times both commands
print for those phases, file I/O excluded. A phase that fails (a rejected run, an exhausted
decision procedure) shows as --- in its cell with its reason as a note, and the exit status is 1.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

BENCHMARK_ROOT = Path(__file__).resolve().parent
REPO_ROOT = BENCHMARK_ROOT.parent.parent
VOLTA = REPO_ROOT / "target" / "release" / "volta"
WORK_DIR = REPO_ROOT / "target" / "benchmark"
REPORT = BENCHMARK_ROOT / "report.md"

SIZES = (128, 256, 512, 1024, 2048, 4096, 8192)
TILE = 64
CLANG = os.environ.get("CLANG", "/opt/homebrew/opt/llvm@21/bin/clang")
CUDA_FLAGS = ["-x", "cuda", "--cuda-device-only", "--cuda-gpu-arch=sm_80", "-nocudainc", "-nocudalib", "-O2", "-S"]


@dataclass(frozen=True)
class Isa:
    key: str
    title: str
    kernel_file: str
    output_array: str

    def solve_args(self, n: int) -> list[str]:
        if self.key == "trainium":
            return ["-k", f"matmul_{n}"]
        return ["--config", str(write_launch(self.key, n))]


ISAS = (
    Isa("ptx", "PTX", "matmul.ptx", "C"),
    Isa("amd", "AMD", "matmul.s", "C"),
    Isa("trainium", "Trainium", "matmul.py", "out"),
)


@dataclass(frozen=True)
class Failed:
    reason: str


@dataclass(frozen=True)
class Timing:
    exec_secs: float | Failed
    equiv_secs: float | Failed
    peak_bytes: int


def compile_ptx() -> None:
    """`external/**/*.ptx` is git-ignored, so `matmul.ptx` is rebuilt from `matmul.cu` when stale."""
    source, ptx = BENCHMARK_ROOT / "matmul.cu", BENCHMARK_ROOT / "matmul.ptx"
    if ptx.exists() and ptx.stat().st_mtime >= source.stat().st_mtime:
        return
    if not Path(CLANG).exists():
        sys.exit(f"{CLANG} is missing: set $CLANG to an LLVM clang with the NVPTX target (Homebrew llvm@21)")
    subprocess.run([CLANG, *CUDA_FLAGS, str(source), "-o", str(ptx)], check=True)


def write_launch(isa: str, n: int) -> Path:
    """One 16 x 16 block, the (0, 0) one, computing C's first 64 x 64 tile."""
    matrix = {"dtype": "f32", "shape": [n, n]}
    launch = {
        "description": f"C = A @ B over f32 {n} x {n} matrices; C's first {TILE} x {TILE} tile",
        "kernel": "matmul",
        "block": [16, 16, 1],
        "grid": 1,
        "arrays": [
            {"name": "A", "kind": "in", **matrix},
            {"name": "B", "kind": "in", **matrix},
            {"name": "C", "kind": "out", **matrix},
        ],
        "params": [{"ptr": "A"}, {"ptr": "B"}, {"ptr": "C"}, {"name": "n", "int": n}],
    }
    path = WORK_DIR / f"{isa}.n{n}.launch.json"
    path.write_text(json.dumps(launch, indent=2) + "\n")
    return path


def run_volta(args: list[str]) -> tuple[str | Failed, int]:
    """Run the CLI: its output, or why it failed, and its peak resident bytes."""
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
    if process.returncode != 0:
        errors = [line for line in output.splitlines() if line.startswith("error:")]
        reason = errors[0] if errors else (output.splitlines() or ["no output"])[-1]
        return Failed(f"volta {args[0]}: {reason.removeprefix('error: ')}"), peak
    return output, peak


def seconds(pattern: str, output: str, command: str) -> float:
    found = re.search(pattern, output)
    if found is None:
        sys.exit(f"no {pattern!r} line in the output of {command}:\n{output[-2000:]}")
    return float(found.group(1))


def benchmark(isa: Isa, n: int, keep: bool) -> Timing:
    """A failed phase is reported in its cell; a failed run has no outputs to self-check."""
    exprs = WORK_DIR / f"{isa.key}.n{n}.vexpr"
    kernel = BENCHMARK_ROOT / isa.kernel_file
    solve = ["solve", str(kernel), *isa.solve_args(n), "--print-outputs", "0", "--emit-exprs", str(exprs)]
    solved, solve_peak = run_volta(solve)
    if isinstance(solved, Failed):
        return Timing(solved, Failed("no outputs to check"), solve_peak)
    exec_secs = seconds(r"time: ([0-9.]+)s", solved, "volta solve")

    compare = ["compare", "--exprs", str(exprs), str(exprs), "--check-array", isa.output_array]
    compared, compare_peak = run_volta(compare)
    if isinstance(compared, Failed):
        equiv_secs = compared
    elif "\nEQUIVALENT" not in compared:
        equiv_secs = Failed("the outputs are not proved equivalent to themselves")
    else:
        equiv_secs = seconds(r"VC check: ([0-9.]+)s", compared, "volta compare")
    if not keep:
        exprs.unlink(missing_ok=True)
    return Timing(exec_secs, equiv_secs, max(solve_peak, compare_peak))


def cell(phase: float | Failed, notes: list[str]) -> str:
    """Seconds, or a dash marked with the number of the failure's note."""
    if not isinstance(phase, Failed):
        return f"{phase:.2f}"
    if phase.reason not in notes:
        notes.append(phase.reason)
    return f"—<sup>{notes.index(phase.reason) + 1}</sup>"


def markdown_report(isas: list[Isa], sizes: list[int], timings: dict[tuple[str, int], Timing]) -> str:
    heads = ["n"] + [f"{isa.title} {phase} (s)" for isa in isas for phase in ("exec", "equiv")]
    memory_heads = ["n"] + [f"{isa.title} (GiB)" for isa in isas]
    rows, memory_rows, notes = [], [], []
    for n in sizes:
        cells, peaks = [str(n)], [str(n)]
        for isa in isas:
            timing = timings[(isa.key, n)]
            cells += [cell(timing.exec_secs, notes), cell(timing.equiv_secs, notes)]
            peaks.append(f"{timing.peak_bytes / 2**30:.1f}")
        rows.append(cells)
        memory_rows.append(peaks)

    def table(heads: list[str], rows: list[list[str]]) -> list[str]:
        return [
            "| " + " | ".join(heads) + " |",
            "|" + "|".join("---:" for _ in heads) + "|",
            *("| " + " | ".join(row) + " |" for row in rows),
        ]

    return "\n".join(
        [
            "# Matmul benchmark",
            "",
            f"Volta on the first {TILE} x {TILE} tile of `C = A @ B` over f32 n x n matrices, each",
            "output a sum of n products (`just benchmark`; see `README.md`). *exec* is the symbolic",
            "execution `volta solve` times, with the race and deadlock graph checks on PTX and AMD;",
            "*equiv* is `volta compare --exprs` checking the outputs against themselves.",
            "",
            *table(heads, rows),
            "",
            *(f"<sup>{i + 1}</sup> {note}  " for i, note in enumerate(notes)),
            *([""] if notes else []),
            "## Peak memory",
            "",
            "The larger of the two commands' peak resident sets.",
            "",
            *table(memory_heads, memory_rows),
            "",
        ]
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--sizes", type=int, nargs="+", default=list(SIZES), choices=SIZES, metavar="N")
    parser.add_argument("--isa", nargs="+", default=[isa.key for isa in ISAS], choices=[isa.key for isa in ISAS])
    parser.add_argument("--keep", action="store_true", help="keep the .vexpr files in target/benchmark/")
    args = parser.parse_args()

    if not VOLTA.exists():
        sys.exit(f"{VOLTA} is missing: build it with `cargo build --release -p volta_cli`")
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    isas = [isa for isa in ISAS if isa.key in args.isa]
    if any(isa.key == "ptx" for isa in isas):
        compile_ptx()
    timings = {}
    for isa in isas:
        for n in args.sizes:
            timing = benchmark(isa, n, args.keep)
            timings[(isa.key, n)] = timing
            phases = "  ".join(
                f"{name} " + (phase.reason if isinstance(phase, Failed) else f"{phase:8.2f}s")
                for name, phase in (("exec", timing.exec_secs), ("equiv", timing.equiv_secs))
            )
            print(f"{isa.title:>8}  n = {n:>4}  {phases}  peak {timing.peak_bytes / 2**30:5.1f} GiB", file=sys.stderr, flush=True)
    REPORT.write_text(markdown_report(isas, args.sizes, timings))
    print(f"Wrote {REPORT.relative_to(REPO_ROOT)}")
    failed = any(isinstance(phase, Failed) for t in timings.values() for phase in (t.exec_secs, t.equiv_secs))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
