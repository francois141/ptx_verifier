"""Fill the paper's table of GEMMs fused with activations: kernels tested and verified per framework.

    uv run --reinstall-package volta --package volta python \
        external/approximations/table/table.py [--force] [--no-lean] [--jobs N] [KERNEL...]

Every kernel of `../` (CUTLASS, Composable Kernel, OpenCL, Triton) is the tile of C = act(A @ B^T)
its launch file names, checked against its `../specs/` spec three ways:

- Volta: `volta.solve` without the activation rewrites (`rewrites=False`), the canonical solver
  alone, counted only for PTX kernels, the inputs the original Volta reads.
- Rewrites: `volta.solve` with them; ACCEPT verifies.
- Lean, only for a kernel the rewrites do not verify: `volta.prove_lean`, every output claimed
  within TOLERANCE of the spec and proved by a Claude Code agent into
  `target/lean/approximations-table/<framework>/<kernel>/`.

Ours counts a kernel verified by the rewrites or by Lean once. Results go to
`target/approximations-table/kernels.json`; a later run reuses them and runs only the missing
measurements, unless `--force` (which also discards the kernel's earlier proof). Every run writes
`table.md` and `table.tex` beside this file. Lean needs Claude Code and `$VOLTA_LEAN_PROJECT` (or
the repository's `.env`).
"""

import argparse
import json
import math
import os
import shutil
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

import volta

HERE = Path(__file__).resolve().parent
APPROXIMATIONS = HERE.parent
REPO_ROOT = APPROXIMATIONS.parents[1]
RESULTS = REPO_ROOT / "target" / "approximations-table" / "kernels.json"
LEAN_DIR = REPO_ROOT / "target" / "lean" / "approximations-table"
SAVED_LEAN = HERE / "lean"
TOLERANCE = "1/1000"
ARRAY_ALIGN = 0x10000
ELEMENT_BYTES = {"f32": 4}
ARRAY_KINDS = {"in": volta.ArrayKind.Input, "out": volta.ArrayKind.Output}
# An OpenCL kernel takes M, N and K as arguments and one workgroup computes all of C: launched at
# the other frameworks' 64 x 256 tile with K = 256.
OPENCL_TILE = {"M": 64, "N": 256, "K": 256}
# Inputs within 1/2 keep a pre-activation, a sum of K = 256 products, within 64: below the 88.7
# past which an f32 exp overflows, and where f32 ln 2 and 1/ln 2 (a relative error of 1e-8 in
# log) stay far within TOLERANCE, which they pass over all reals once log(1 + e^x) nears 1e5.
INPUT_BOUNDS = {"triton/softplus": "1/2", "composable_kernel/softrelu": "1/2",
                "opencl/softrelu": "1/2"}


@dataclass(frozen=True)
class Framework:
    folder: str
    name: str
    extension: str
    # The original Volta reads only PTX; `n/a` marks the frameworks compiled to AMD assembly.
    reads_ptx: bool
    sizes: dict[str, int] | None = None


FRAMEWORKS = (
    Framework("cutlass", "CUTLASS", ".ptx", True),
    Framework("composable_kernel", "AMD", ".s", False),
    Framework("opencl", "OpenCL", ".s", False, OPENCL_TILE),
    Framework("triton", "Triton", ".ptx", True),
)


@dataclass(frozen=True)
class Kernel:
    framework: Framework
    name: str

    @property
    def key(self) -> str:
        return f"{self.framework.folder}/{self.name}"

    @property
    def path(self) -> Path:
        return APPROXIMATIONS / self.framework.folder / (self.name + self.framework.extension)

    @property
    def launch(self) -> Path:
        return APPROXIMATIONS / self.framework.folder / f"{self.name}.launch.json"


def kernels(framework: Framework) -> list[Kernel]:
    launches = sorted((APPROXIMATIONS / framework.folder).glob("*.launch.json"))
    return [Kernel(framework, launch.name[: -len(".launch.json")]) for launch in launches]


@dataclass(frozen=True)
class Launch:
    kernel: str
    config: volta.Config
    spec: str
    dims: dict[str, int]
    outputs: int


def load_launch(kernel: Kernel) -> Launch:
    launch = json.loads(kernel.launch.read_text(encoding="utf-8"))
    if kernel.framework.sizes is not None:
        launch = resized(launch, **kernel.framework.sizes)
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
        elif "float" in param:
            config.add_param(volta.Param.float(param["float"]))
        else:
            config.add_param(volta.Param.array_ptr(param["ptr"]))
    spec = (kernel.launch.parent / launch["spec"]).read_text(encoding="utf-8")
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


def solve(kernel: Kernel, launch: Launch, rewrites: bool) -> dict:
    start = time.monotonic()
    try:
        result = volta.solve(kernel.path, launch.config, kernel=launch.kernel, spec=launch.spec,
                             dims=launch.dims, rewrites=rewrites)
    except volta.VoltaError as error:
        return {"verdict": "ERROR", "seconds": time.monotonic() - start, "evidence": str(error)}
    return {
        "verdict": result.verdict,
        "seconds": time.monotonic() - start,
        "evidence": result.evidence[0] if result.evidence else "",
    }


def lean(kernel: Kernel, launch: Launch) -> dict:
    directory = LEAN_DIR / kernel.key
    shutil.rmtree(directory, ignore_errors=True)
    start = time.monotonic()
    try:
        result = volta.prove_lean(
            kernel.path, launch.config, kernel=launch.kernel, spec=launch.spec,
            dims=launch.dims, tolerance=TOLERANCE, input_bound=INPUT_BOUNDS.get(kernel.key),
            equivalence=False, output_dir=directory,
        )
    except volta.VoltaError as error:
        return {"proved": False, "seconds": time.monotonic() - start, "cost_usd": None,
                "detail": str(error)}
    if result.proved:
        save_lean(kernel, directory)
    return {
        "proved": result.proved,
        "seconds": time.monotonic() - start,
        "agent_seconds": result.duration_seconds,
        "cost_usd": result.cost_usd,
        "turns": result.turns,
        "input_bound": INPUT_BOUNDS.get(kernel.key),
        "detail": f"{result.proved_statements} of {result.statements} statements proved",
        "proof": str(result.proof),
    }


def save_lean(kernel: Kernel, directory: Path) -> None:
    """Keep a proved kernel's challenge and proof in the repository, beside this script."""
    saved = SAVED_LEAN / kernel.key
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


def accepted(entry: dict, solver: str) -> bool:
    return entry.get(solver, {}).get("verdict") == "ACCEPT"


def proved(entry: dict) -> bool:
    return entry.get("lean", {}).get("proved") is True


def needs_lean(entry: dict) -> bool:
    return "rewrites" in entry and not accepted(entry, "rewrites")


def verified_by(entry: dict) -> str:
    if accepted(entry, "rewrites"):
        return "rewrites"
    return "Lean" if proved(entry) else "-"


def cells(results: dict) -> dict[str, list[str]]:
    rows = {"Kernels tested": [], "Volta": [], "Ours": []}
    for framework in FRAMEWORKS:
        entries = [results.get(k.key, {}) for k in kernels(framework)]
        rows["Kernels tested"].append(str(len(entries)))
        if not framework.reads_ptx:
            rows["Volta"].append("n/a")
        elif all("plain" in e for e in entries):
            rows["Volta"].append(str(sum(accepted(e, "plain") for e in entries)))
        else:
            rows["Volta"].append("-")
        settled = all("rewrites" in e and (not needs_lean(e) or "lean" in e
                                           or e.get("lean_skipped")) for e in entries)
        verified = sum(verified_by(e) != "-" for e in entries)
        rows["Ours"].append(str(verified) if settled else "-")
    return rows


def write_markdown(results: dict) -> None:
    rows = cells(results)
    number = lambda value, digits: "-" if value is None else f"{value:.{digits}f}"  # noqa: E731
    lines = [
        "# GEMMs fused with activations",
        "",
        "Written by `table.py`. Each kernel is its launch file's tile of C = act(A @ B^T) (OpenCL's "
        f"at M = 64, N = K = 256); Lean claims every output within {TOLERANCE} of the spec.",
        "",
        "| System / method | " + " | ".join(f.name for f in FRAMEWORKS) + " |",
        "|---|" + "---:|" * len(FRAMEWORKS),
        f"| Kernels tested | " + " | ".join(rows["Kernels tested"]) + " |",
        "| **Kernels verified** |" + " |" * len(FRAMEWORKS),
        *(f"| {name} | " + " | ".join(rows[name]) + " |" for name in ("Volta", "Ours")),
        "",
        "Volta: the canonical solver without the activation rewrites, on PTX inputs only (`n/a`: "
        "AMD assembly). Ours: verified by the rewrites or, failing them, by Lean, counted once.",
        "",
        "## Each kernel",
        "",
        "| Kernel | Volta | Rewrites | Rewrites (s) | Lean | Lean (s) | Cost (USD) | Verified by "
        "| Why not by the rewrites |",
        "|---|---|---|---:|---|---:|---:|---|---|",
    ]
    for framework in FRAMEWORKS:
        for kernel in kernels(framework):
            entry = results.get(kernel.key, {})
            plain, solved, proof = (entry.get(k, {}) for k in ("plain", "rewrites", "lean"))
            if proof:
                bound = f", inputs within {proof['input_bound']}" if proof.get("input_bound") else ""
                lean_cell = ("proved" if proof["proved"] else "not proved") + bound
            else:
                lean_cell = "skipped" if entry.get("lean_skipped") and needs_lean(entry) else "-"
            why = "" if accepted(entry, "rewrites") else solved.get("evidence", "")
            if proof and not proof["proved"]:
                why += f" Lean: {proof.get('detail', '')}"
            path = kernel.path.relative_to(APPROXIMATIONS)
            lines.append(
                f"| [`{kernel.key}`](../{path}) | {plain.get('verdict', '-')} "
                f"| {solved.get('verdict', '-')} | {number(solved.get('seconds'), 1)} "
                f"| {lean_cell} | {number(proof.get('seconds'), 0)} "
                f"| {number(proof.get('cost_usd'), 2)} | {verified_by(entry)} "
                f"| {why.strip().replace('|', '/')} |"
            )
    (HERE / "table.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_latex(results: dict) -> None:
    rows = cells(results)
    tex = {"-": "--"}
    body = lambda name: f"{name} & " + " & ".join(tex.get(v, v) for v in rows[name]) + r" \\"  # noqa: E731
    columns = len(FRAMEWORKS) + 1
    lines = [
        r"% Written by external/approximations/table/table.py.",
        r"\begin{tabular}{l" + "c" * len(FRAMEWORKS) + "}",
        r"\toprule",
        "System / method & " + " & ".join(f.name for f in FRAMEWORKS) + r" \\",
        r"\midrule",
        body("Kernels tested"),
        r"\midrule",
        r"\multicolumn{" + str(columns) + r"}{l}{\textbf{Kernels verified}} \\",
        body("Volta"),
        body("Ours"),
        r"\bottomrule",
        r"\end{tabular}",
    ]
    (HERE / "table.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def measure_solvers(kernel: Kernel, entry: dict, force: bool) -> None:
    launch = load_launch(kernel)
    if force or "rewrites" not in entry:
        entry["rewrites"] = solve(kernel, launch, rewrites=True)
    if kernel.framework.reads_ptx and (force or "plain" not in entry):
        entry["plain"] = solve(kernel, launch, rewrites=False)
    plain = entry.get("plain", {}).get("verdict", "n/a")
    print(f"[{kernel.key}] Volta {plain}, rewrites {entry['rewrites']['verdict']}", flush=True)


def measure_lean(kernel: Kernel, entry: dict, save) -> None:
    print(f"[{kernel.key}] Lean within {TOLERANCE} ...", flush=True)
    proof = lean(kernel, load_launch(kernel))
    save(lambda: (entry.__setitem__("lean", proof), entry.pop("lean_skipped", None)))
    cost = proof.get("cost_usd")
    print(f"[{kernel.key}] Lean: {'proved' if proof['proved'] else 'not proved'} in "
          f"{proof['seconds']:.0f} s" + (f", ${cost:.2f}" if cost is not None else "")
          + f" ({proof['detail'][:200]})", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("kernels", nargs="*", help="kernels to run, as cutlass/gelu_tanh "
                        "(default: every kernel)")
    parser.add_argument("--force", action="store_true", help="measure again what kernels.json holds")
    parser.add_argument("--no-lean", action="store_true", help="run the solvers only")
    parser.add_argument("--jobs", type=int, default=4, help="Lean proofs run at once")
    args = parser.parse_args()
    every = [k for f in FRAMEWORKS for k in kernels(f)]
    unknown = set(args.kernels) - {k.key for k in every}
    if unknown:
        parser.error(f"unknown kernel(s) {sorted(unknown)}")
    chosen = [k for k in every if not args.kernels or k.key in args.kernels]
    load_dotenv(REPO_ROOT / ".env")

    results = json.loads(RESULTS.read_text()) if RESULTS.exists() else {}

    lock = threading.Lock()

    def save(update=lambda: None) -> None:
        with lock:
            update()
            RESULTS.parent.mkdir(parents=True, exist_ok=True)
            RESULTS.write_text(json.dumps(results, indent=2) + "\n")

    for kernel in chosen:
        entry = results.setdefault(kernel.key, {})
        measure_solvers(kernel, entry, args.force)
        save()

    pending = [k for k in chosen if needs_lean(results[k.key])
               and (args.force or "lean" not in results[k.key])]
    if args.no_lean:
        for kernel in pending:
            results[kernel.key].setdefault("lean_skipped", True)
    else:
        with ThreadPoolExecutor(max(1, args.jobs)) as pool:
            futures = [pool.submit(measure_lean, k, results[k.key], save) for k in pending]
        for future in futures:
            future.result()
    save()

    write_markdown(results)
    write_latex(results)
    print(f"wrote {HERE / 'table.md'} and {HERE / 'table.tex'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
