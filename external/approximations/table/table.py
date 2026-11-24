"""Fill the paper's table of GEMMs fused with activations: kernels verified and mean times.

    uv run --reinstall-package volta --package volta python \
        external/approximations/table/table.py [--force] [--no-lean] [COLUMN...]

Each column is one kernel of `../` on the same domain, the 64 x 256 tile of C = act(A @ B^T)
with K = 256 (16,384 outputs), checked two ways against its `../specs/` spec:

- Rewrites: `volta.solve`, the canonical solver with the activation rewrites (ACCEPT verifies).
- Lean: `volta.prove_lean`, every output claimed within TOLERANCE of the spec and proved by a
  Claude Code agent into `target/lean/approximations-table/<column>/`; timed from extraction to
  the final check, with the agent's cost in dollars.

Results go to `target/approximations-table/results.json`; a later run reuses them and runs only
the missing measurements, unless `--force` (which also discards the column's earlier proof, so
the agent starts from scratch). Every run writes `table.md` and `table.tex` beside this file. Lean
needs Claude Code and `$VOLTA_LEAN_PROJECT` (or the repository's `.env`).
"""

import argparse
import json
import math
import os
import shutil
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import volta

HERE = Path(__file__).resolve().parent
APPROXIMATIONS = HERE.parent
REPO_ROOT = APPROXIMATIONS.parents[1]
RESULTS = REPO_ROOT / "target" / "approximations-table" / "results.json"
LEAN_DIR = REPO_ROOT / "target" / "lean" / "approximations-table"
SAVED_LEAN = HERE / "lean"
TOLERANCE = "1/1000"
ARRAY_ALIGN = 0x10000
ELEMENT_BYTES = {"f32": 4}
ARRAY_KINDS = {"in": volta.ArrayKind.Input, "out": volta.ArrayKind.Output}
# The OpenCL kernel takes M, N and K as arguments; one workgroup computes all of C.
OPENCL_TILE = {"M": 64, "N": 256, "K": 256}


@dataclass(frozen=True)
class Column:
    key: str
    lines: tuple[str, str]
    kernel: Path
    launch: Path
    # The public Volta release has no spec language and models no cp.async (both PTX GEMMs use
    # it); AMD's assembly is not its target at all.
    original_volta: str
    sizes: dict[str, int] | None = None

    @property
    def header(self) -> str:
        return " ".join(self.lines)


COLUMNS = (
    Column("cutlass_gelu_tanh", ("CUTLASS GELU", "(tanh)"), APPROXIMATIONS / "cutlass/gelu_tanh.ptx",
           APPROXIMATIONS / "cutlass/gelu_tanh.launch.json", "unsupported"),
    Column("amd_sigmoid", ("AMD", "sigmoid"), APPROXIMATIONS / "composable_kernel/sigmoid.s",
           APPROXIMATIONS / "composable_kernel/sigmoid.launch.json", "n/a"),
    Column("opencl_silu", ("OpenCL", "SiLU"), APPROXIMATIONS / "opencl/silu.s",
           APPROXIMATIONS / "opencl/silu.launch.json", "unsupported", OPENCL_TILE),
    Column("triton_gelu_tanh", ("Triton GELU", "(tanh)"), APPROXIMATIONS / "triton/gelu_tanh.ptx",
           APPROXIMATIONS / "triton/gelu_tanh.launch.json", "unsupported"),
)


@dataclass(frozen=True)
class Launch:
    kernel: str
    config: volta.Config
    spec: str
    dims: dict[str, int]
    outputs: int


def load_launch(column: Column) -> Launch:
    launch = json.loads(column.launch.read_text(encoding="utf-8"))
    if column.sizes is not None:
        launch = resized(launch, **column.sizes)
    block = launch["block"] if isinstance(launch["block"], list) else [launch["block"]]
    grid = launch.get("grid", [1])
    config = volta.Config(
        block=tuple(block + [1] * (3 - len(block))),
        grid=tuple(grid + [1] * (3 - len(grid))),
        dynamic_shared_bytes=launch.get("dynamic_shared_bytes", 0),
    )
    base = ARRAY_ALIGN
    for array in launch["arrays"]:
        width = ELEMENT_BYTES[array["dtype"]]
        length = math.prod(array["shape"])
        config.add_array(volta.ArrayDef(array["name"], base, width, length,
                                        ARRAY_KINDS[array["kind"]]))
        base += -(-width * length // ARRAY_ALIGN) * ARRAY_ALIGN
    for param in launch["params"]:
        if "int" in param:
            config.add_param(volta.Param.int(param["int"]))
        else:
            config.add_param(volta.Param.array_ptr(param["ptr"]))
    spec = (column.launch.parent / launch["spec"]).read_text(encoding="utf-8")
    outputs = sum(math.prod(a["shape"]) for a in launch["arrays"] if a["kind"] == "out")
    return Launch(launch["kernel"], config, spec, launch["dims"], outputs)


def resized(launch: dict, M: int, N: int, K: int) -> dict:
    """An OpenCL launch (`opencl/compile.py`'s) at A M x K, B N x K and C M x N."""
    shapes = {"a": [M, K], "b": [N, K], "c": [M, N]}
    sizes = {"M": M, "N": N, "K": K}
    return {
        **launch,
        "arrays": [{**array, "shape": shapes[array["name"]]} for array in launch["arrays"]],
        "params": [{**param, "int": sizes[param["name"]]} if param.get("name") in sizes else param
                   for param in launch["params"]],
        "dims": {**sizes, "TM": M},
    }


def rewrites(column: Column, launch: Launch) -> dict:
    start = time.monotonic()
    try:
        result = volta.solve(column.kernel, launch.config, kernel=launch.kernel,
                             spec=launch.spec, dims=launch.dims)
    except volta.VoltaError as error:
        return {"verdict": "ERROR", "seconds": time.monotonic() - start, "evidence": str(error)}
    return {
        "verdict": result.verdict,
        "seconds": time.monotonic() - start,
        "evidence": result.evidence[0] if result.evidence else "",
    }


def lean(column: Column, launch: Launch) -> dict:
    directory = LEAN_DIR / column.key
    shutil.rmtree(directory, ignore_errors=True)
    start = time.monotonic()
    try:
        result = volta.prove_lean(
            column.kernel, launch.config, kernel=launch.kernel, spec=launch.spec,
            dims=launch.dims, tolerance=TOLERANCE, equivalence=False, output_dir=directory,
            verbose=True,
        )
    except volta.VoltaError as error:
        return {"proved": False, "seconds": time.monotonic() - start, "cost_usd": None,
                "detail": str(error)}
    seconds = time.monotonic() - start
    save_lean(column, directory)
    return {
        "proved": result.proved,
        "seconds": seconds,
        "agent_seconds": result.duration_seconds,
        "cost_usd": result.cost_usd,
        "turns": result.turns,
        "statements": result.statements,
        "proved_statements": result.proved_statements,
        "detail": f"{result.proved_statements} of {result.statements} statements proved",
        "proof": str(result.proof),
    }


def save_lean(column: Column, directory: Path) -> None:
    """Keep the column's challenge and proof in the repository, beside this script."""
    saved = SAVED_LEAN / column.key
    saved.mkdir(parents=True, exist_ok=True)
    for name in ("challenge.lean", "proof.lean"):
        if (directory / name).exists():
            shutil.copyfile(directory / name, saved / name)


def load_dotenv(path: Path) -> None:
    """Set each `NAME=value` line of `path` that the environment does not already set."""
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        name, separator, value = line.partition("=")
        if separator and not name.lstrip().startswith("#"):
            os.environ.setdefault(name.strip(), os.path.expanduser(value.strip()))


def verified_by_rewrites(entry: dict) -> bool:
    return entry.get("rewrites", {}).get("verdict") == "ACCEPT"


def verified_by_lean(entry: dict) -> bool:
    return entry.get("lean", {}).get("proved") is True


def mean_times(entry: dict) -> tuple[float, float] | None:
    """Both paths' seconds, when both verified the kernel (the caption's averaging rule)."""
    if verified_by_rewrites(entry) and verified_by_lean(entry):
        return entry["rewrites"]["seconds"], entry["lean"]["seconds"]
    return None


def cells(results: dict) -> dict[str, list[str]]:
    rows = {"Volta": [], "Ours": [], "Rewrites": [], "Lean": []}
    for column in COLUMNS:
        entry = results.get(column.key, {})
        rows["Volta"].append(column.original_volta)
        measured = "rewrites" in entry and ("lean" in entry or entry.get("lean_skipped"))
        verified = verified_by_rewrites(entry) or verified_by_lean(entry)
        rows["Ours"].append(f"{int(verified)}/1" if measured else "-")
        times = mean_times(entry)
        rows["Rewrites"].append(f"{times[0]:.1f}" if times else "-")
        rows["Lean"].append(f"{times[1]:.0f}" if times else "-")
    return rows


def write_markdown(results: dict) -> None:
    rows = cells(results)
    lines = [
        "# GEMMs fused with activations",
        "",
        "Written by `table.py`. Each column is one kernel on the 64 x 256 tile of C = act(A @ B^T),"
        f" K = 256; Lean claims every output within {TOLERANCE} of the spec.",
        "",
        "| System / method | " + " | ".join(c.header for c in COLUMNS) + " |",
        "|---|" + "---:|" * len(COLUMNS),
        "| **Kernels verified** |" + " |" * len(COLUMNS),
        *(f"| {name} | " + " | ".join(rows[name]) + " |" for name in ("Volta", "Ours")),
        "| **Mean verification time (s)** |" + " |" * len(COLUMNS),
        *(f"| {name} | " + " | ".join(rows[name]) + " |" for name in ("Rewrites", "Lean")),
        "",
        "`unsupported`: the public Volta release cannot check the kernel (no `.spec` language, no "
        "`cp.async`, reads only PTX); `n/a`: an AMD-only target. A time is shown only for a kernel both paths "
        "verified.",
        "",
        "## Each kernel",
        "",
        "| Column | Kernel | Rewrites | Rewrites (s) | Lean | Lean (s) | Agent (s) | Turns "
        "| Cost (USD) |",
        "|---|---|---|---:|---|---:|---:|---:|---:|",
    ]
    for column in COLUMNS:
        entry = results.get(column.key, {})
        solved, proof = entry.get("rewrites", {}), entry.get("lean", {})
        lean_detail = "skipped" if entry.get("lean_skipped") and not proof else (
            ("proved" if proof.get("proved") else "not proved") + f": {proof.get('detail', '')}"
            if proof else "-")
        number = lambda value, digits: "-" if value is None else f"{value:.{digits}f}"  # noqa: E731
        kernel = column.kernel.relative_to(APPROXIMATIONS)
        lines.append(
            f"| {column.header} | [`{kernel}`](../{kernel}) | {solved.get('verdict', '-')} "
            f"| {number(solved.get('seconds'), 1)} | {lean_detail} "
            f"| {number(proof.get('seconds'), 0)} | {number(proof.get('agent_seconds'), 0)} "
            f"| {proof.get('turns', '-')} | {number(proof.get('cost_usd'), 2)} |"
        )
    evidence = [(c.header, results.get(c.key, {}).get("rewrites", {})) for c in COLUMNS]
    notes = [f"- {header}: {r['evidence']}" for header, r in evidence
             if r.get("verdict") not in (None, "ACCEPT") and r.get("evidence")]
    if notes:
        lines += ["", "Why the rewrites did not verify a kernel:", "", *notes]
    (HERE / "table.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_latex(results: dict) -> None:
    rows = cells(results)
    tex = {"unsupported": r"\ding{55}", "-": "--"}
    top = " & ".join(c.lines[0] for c in COLUMNS)
    second = " & ".join(c.lines[1] for c in COLUMNS)
    body = lambda name: f"{name} & " + " & ".join(tex.get(v, v) for v in rows[name]) + r" \\"  # noqa: E731
    lines = [
        r"% Written by external/approximations/table/table.py; \ding needs \usepackage{pifont}.",
        r"\begin{tabular}{l" + "c" * len(COLUMNS) + "}",
        r"\toprule",
        f" & {top} \\\\",
        f"System / method & {second} \\\\",
        r"\midrule",
        r"\multicolumn{" + str(len(COLUMNS) + 1) + r"}{l}{\textbf{Kernels verified}} \\",
        body("Volta"),
        body("Ours"),
        r"\midrule",
        r"\multicolumn{" + str(len(COLUMNS) + 1) + r"}{l}{\textbf{Mean verification time (s)}} \\",
        body("Rewrites"),
        body("Lean"),
        r"\bottomrule",
        r"\end{tabular}",
    ]
    (HERE / "table.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("columns", nargs="*", help="column keys to run (default: every column)")
    parser.add_argument("--force", action="store_true", help="measure again what results.json holds")
    parser.add_argument("--no-lean", action="store_true", help="run the rewrites only")
    args = parser.parse_args()
    unknown = set(args.columns) - {c.key for c in COLUMNS}
    if unknown:
        parser.error(f"unknown column(s) {sorted(unknown)}; choose from {[c.key for c in COLUMNS]}")
    load_dotenv(REPO_ROOT / ".env")

    results = json.loads(RESULTS.read_text()) if RESULTS.exists() else {}
    for column in COLUMNS:
        if args.columns and column.key not in args.columns:
            continue
        entry = results.setdefault(column.key, {})
        launch = load_launch(column)
        if args.force or "rewrites" not in entry:
            print(f"[{column.key}] rewrites on {launch.outputs} outputs ...", flush=True)
            entry["rewrites"] = rewrites(column, launch)
        print(f"[{column.key}] rewrites: {entry['rewrites']['verdict']} "
              f"in {entry['rewrites']['seconds']:.1f} s", flush=True)
        if args.no_lean:
            entry.setdefault("lean_skipped", True)
        elif args.force or "lean" not in entry:
            print(f"[{column.key}] Lean within {TOLERANCE} ...", flush=True)
            entry["lean"] = lean(column, launch)
            entry.pop("lean_skipped", None)
        if "lean" in entry:
            proof = entry["lean"]
            cost = proof.get("cost_usd")
            print(f"[{column.key}] Lean: {'proved' if proof['proved'] else 'not proved'} in "
                  f"{proof['seconds']:.0f} s" + (f", ${cost:.2f}" if cost is not None else "")
                  + f" ({proof['detail']})", flush=True)
        RESULTS.parent.mkdir(parents=True, exist_ok=True)
        RESULTS.write_text(json.dumps(results, indent=2) + "\n")

    write_markdown(results)
    write_latex(results)
    print(f"wrote {HERE / 'table.md'} and {HERE / 'table.tex'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
