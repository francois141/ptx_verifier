#!/usr/bin/env python3
"""Generate the paper's evaluation tables (Markdown or --format latex) from the volta-bench
results JSONs of the generate/solve reproduction runs in <results-dir>; newest run per kind
wins, missing runs show "-", values are medians ("*" = CV > 0.10), warp syncs per fired group.
"""

import argparse
import json
import sys
from pathlib import Path

# Table specifications: (paper row label, volta_bench registry benchmark name,
# PTX file(s) for the LOC column, threads-column entry or None).

RED = [(f"Red-{i}", f"(Red-1, Red-{i})", [f"01_reduction/Red-{i}.ptx"], None) for i in (1, 2, 3, 4)]
MATMUL = [
    (f"MatMul-{i}", f"(MatMul-1, MatMul-{i})", [f"02_matmul/MatMul-{i}.ptx"], None)
    for i in range(1, 8)
]
ATTENTION = [
    ("Attention", "(Attention, Attention)", ["03_attention/Attention.ptx"], "1"),
    ("FA1", "(Attention, FA1)", ["03_attention/FA1.ptx"], "128"),
    ("FA1-TC", "(Attention, FA1-TC)", ["03_attention/FA1-TC.ptx"], "128"),
    ("FA2-TC", "(Attention, FA2-TC)", ["03_attention/FA2-TC.ptx"], "128"),
]
CAUSAL = [
    (
        f"Causal-{k}",
        f"(Causal-{k}-naive, Causal-{k}-fused)",
        [f"04_causal_attention/Causal-{k}-fused.ptx", f"04_causal_attention/Causal-{k}-naive.ptx"],
        "1" if k == "Attention" else "128",
    )
    for k in ("Attention", "FA1", "FA1-TC", "FA2-TC")
]
CONV = [("Conv2D", "(Conv2D-ref, Conv2D-opt)", ["05_conv2d_llm/Conv2D-opt.ptx"], "256")]
GEMM = [
    (f"GEMM-{i}", f"(MatMul-1-32x32, GEMM-{i})", [f"06_agent_gemm/GEMM-{i}.ptx"], "512")
    for i in (1, 2, 3)
]
TILELANG = [
    (
        size,
        f"(TL-{size}-ref, TL-{size}-opt)",
        [f"07_tilelang/{size}-ref.ptx", f"07_tilelang/{size}-opt.ptx"],
        "(128, 128)",
    )
    for size in ("32x32x32", "64x32x32", "64x64x32")
]
RACES = [
    ("BucketPositions", "OpenMM", "08_races/BucketPositions-pre_racy.ptx"),
    ("ComputeRange", "OpenMM", "08_races/ComputeRange-pre_racy.ptx"),
    ("ReduceValue", "OpenMM", "08_races/ReduceValue-pre_racy.ptx"),
    ("LayerNorm", "MegatronLM", "08_races/LayerNorm-pre_racy.ptx"),
    ("GradInput", "MegatronLM", "08_races/GradInput-pre_racy.ptx"),
]
# Table 8 rows in paper order.
TABLE8 = RED + MATMUL + CONV + GEMM + TILELANG + ATTENTION + CAUSAL


def load_runs(results_dir: Path):
    """Discover the four runs by header; newest timestamp wins per kind."""
    runs = {}
    for path in sorted(results_dir.glob("*.json")):
        try:
            doc = json.loads(path.read_text())
        except (json.JSONDecodeError, UnicodeDecodeError):
            continue
        if "benchmarks" not in doc or "command" not in doc:
            continue
        cmd, backend, sample = doc["command"], doc.get("backend"), doc.get("sample")
        if cmd == "generate":
            kind = "generate"
        elif cmd == "solve" and backend in ("decision", "both") and sample == 0:
            kind = "full"
        elif cmd == "solve" and backend in ("decision", "both") and sample == 1:
            kind = "sample1"
        elif cmd == "solve" and backend in ("z3", "both") and sample == 1:
            kind = "z3"
        else:
            continue
        stamp = doc.get("timestamp_unix", 0)
        if kind not in runs or stamp > runs[kind][0]:
            runs[kind] = (stamp, path.name, doc)
    return {k: (name, {b["name"]: b for b in doc["benchmarks"]}, doc) for k, (_, name, doc) in runs.items()}


def fmt_secs(v):
    if v is None:
        return "-"
    if v < 0.0001:
        return f"{v*1000:.2f} ms"
    if v < 1:
        return f"{v:.4f}"
    return f"{v:.2f}" if v < 100 else f"{v:.1f}"


def median_cell(record, prefix):
    """Median of a timed phase, '*'-marked when its CV exceeds 0.10."""
    if record is None:
        return "-"
    med = record.get(f"{prefix}_median_secs")
    if med is None:
        return "-"
    cv = record.get(f"{prefix}_cv")
    return fmt_secs(med) + ("*" if cv is not None and cv > 0.10 else "")


def loc_cell(kernels_dir, files):
    if kernels_dir is None:
        return "-"
    counts = []
    for f in files:
        p = kernels_dir / f
        if not p.exists():
            return "-"
        counts.append(sum(1 for _ in p.open()))
    return str(counts[0]) if len(counts) == 1 else "(" + ", ".join(map(str, counts)) + ")"


def z3_cell(record, section):
    """Render one z3 mode: outcome@time of the first element, or counts."""
    z = (record or {}).get("z3")
    sec = z if section == "plain" else (z or {}).get("axiom")
    if not sec:
        return "-"
    els = sec.get("elements") or []
    if len(els) == 1:
        el = els[0]
        t = el["solve_secs"]
        when = f"{t*1000:.1f} ms" if t < 1 else f"{t:.1f} s"
        return f"{el['outcome']} @ {when}"
    c = sec["counts"]
    total = sec.get("solve_median_secs")
    return (
        f"eq {c['equivalent']} / df {c['not_equivalent']} / unk {c['unknown']} / to {c['timeout']}"
        + (f" @ {fmt_secs(total)} s" if total is not None else "")
    )


# --------------------------------------------------------------------------
# Document model: table building produces blocks; renderers produce text.


class Doc:
    """A linear document of headings, paragraphs, bullet lists, and tables."""

    def __init__(self):
        self.blocks = []

    def heading(self, text, level=2):
        self.blocks.append(("heading", level, text))

    def para(self, text):
        self.blocks.append(("para", text))

    def bullets(self, items):
        self.blocks.append(("bullets", list(items)))

    def table(self, title, headers, rows):
        self.blocks.append(("table", title, list(headers), [list(r) for r in rows]))


def render_markdown(doc):
    out = []
    for block in doc.blocks:
        kind = block[0]
        if kind == "heading":
            _, level, text = block
            out.append("#" * level + " " + text + "\n")
        elif kind == "para":
            out.append(block[1] + "\n")
        elif kind == "bullets":
            out.extend(f"- {item}" for item in block[1])
            out.append("")
        elif kind == "table":
            _, title, headers, rows = block
            out.append(f"## {title}\n")
            out.append("| " + " | ".join(headers) + " |")
            out.append("|" + "---|" * len(headers))
            out.extend("| " + " | ".join(row) + " |" for row in rows)
            out.append("")
    return "\n".join(out)


LATEX_SPECIALS = {
    "\\": "\\textbackslash{}",
    "#": "\\#",
    "%": "\\%",
    "&": "\\&",
    "_": "\\_",
    "$": "\\$",
    "{": "\\{",
    "}": "\\}",
    "~": "\\textasciitilde{}",
    "^": "\\textasciicircum{}",
    "<": "\\textless{}",
    ">": "\\textgreater{}",
}


def latex_escape(text):
    return "".join(LATEX_SPECIALS.get(c, c) for c in str(text))


def render_latex(doc):
    out = ["% Generated by scripts/generate_tables.py; requires \\usepackage{booktabs}.\n"]
    for block in doc.blocks:
        kind = block[0]
        if kind == "heading":
            _, level, text = block
            cmd = "section*" if level <= 1 else "subsection*"
            out.append("\\" + cmd + "{" + latex_escape(text) + "}\n")
        elif kind == "para":
            out.append(latex_escape(block[1]) + "\n")
        elif kind == "bullets":
            out.append("\\begin{itemize}")
            out.extend("  \\item " + latex_escape(item) for item in block[1])
            out.append("\\end{itemize}\n")
        elif kind == "table":
            _, title, headers, rows = block
            colspec = "l" + "r" * (len(headers) - 1)
            out.append("\\begin{table}[h]")
            out.append("\\centering")
            out.append("\\caption{" + latex_escape(title) + "}")
            out.append("\\begin{tabular}{" + colspec + "}")
            out.append("\\toprule")
            out.append(" & ".join(latex_escape(h) for h in headers) + " \\\\")
            out.append("\\midrule")
            out.extend(" & ".join(latex_escape(c) for c in row) + " \\\\" for row in rows)
            out.append("\\bottomrule")
            out.append("\\end{tabular}")
            out.append("\\end{table}\n")
    return "\n".join(out)


RENDERERS = {
    "md": render_markdown,
    "markdown": render_markdown,
    "latex": render_latex,
    "tex": render_latex,
}


def equivalence_rows(rows, columns, gen, full, kernels_dir):
    """Header + body for one paper-shaped table; the VC-generation column
    (the addition over the paper's shape) is always present."""
    headers = ["Kernel", "VC Gen (s)", "VC Time (s)", "#Block Sync"]
    if "warp" in columns:
        headers.append("#Warp Sync (groups)")
    if "loc" in columns:
        headers.append("PTX LOC")
    if "threads" in columns:
        headers.append("#Threads")
    body = []
    for label, name, files, threads in rows:
        g, f = gen.get(name), full.get(name)
        cells = [
            label,
            median_cell(g, "vc_gen"),
            median_cell(f, "solve"),
            f"{g['block_syncs']:,}" if g else "-",
        ]
        if "warp" in columns:
            cells.append(f"{g['warp_syncs']:,}" if g else "-")
        if "loc" in columns:
            cells.append(loc_cell(kernels_dir, files))
        if "threads" in columns:
            cells.append(threads or "-")
        body.append(cells)
    return headers, body


def build_doc(runs, kernels_dir):
    gen = runs.get("generate", (None, {}, None))[1]
    full = runs.get("full", (None, {}, None))[1]
    sample1 = runs.get("sample1", (None, {}, None))[1]
    z3 = runs.get("z3", (None, {}, None))[1]

    doc = Doc()
    doc.heading("Volta evaluation tables", level=1)
    doc.para("Sources (newest per kind):")
    items = []
    for kind, label in [
        ("generate", "generation"),
        ("full", "full solve"),
        ("sample1", "sample-1 solve"),
        ("z3", "z3 solve"),
    ]:
        if kind in runs:
            name, _, hdr = runs[kind]
            extra = f", z3 {hdr['z3_version']}" if hdr.get("z3_version") else ""
            items.append(f"{label}: {name} (iterations {hdr.get('iterations')}{extra})")
        else:
            items.append(f"{label}: MISSING")
    doc.bullets(items)
    failed = [
        (kind, b["name"])
        for kind, (_, by_name, _) in runs.items()
        for b in by_name.values()
        if not b.get("passed", True)
    ]
    doc.para(
        "All benchmark rows passed in every run."
        if not failed
        else "FAILED ROWS: " + ", ".join(f"{n} ({k})" for k, n in failed)
    )
    doc.para(
        "Times are medians over each run's iterations (* = CV > 0.10). VC Gen = "
        "lowering + both symbolic executions + footprint pairing; VC Time = the "
        "decision procedure over all footprint elements. Warp syncs are per fired "
        "group (x32 for the per-thread convention)."
    )

    for title, rows, columns in [
        ("Table 1: reduction (vs Red-1)", RED, {"loc"}),
        ("Table 2: matmul (vs MatMul-1)", MATMUL, {"loc"}),
        ("Table 3: attention (vs Attention)", ATTENTION, {"warp", "loc", "threads"}),
        ("Table 4: causal attention (fused vs naive); LOC = (fused, naive)", CAUSAL, {"warp", "loc", "threads"}),
        ("Conv2D (paper section 6.2)", CONV, {"warp", "loc", "threads"}),
        ("Table 5: Claude-generated GEMM (vs MatMul-1 32x32)", GEMM, {"warp", "loc", "threads"}),
        ("Table 6: TileLang (ref vs opt); LOC = (ref, opt)", TILELANG, {"warp", "loc", "threads"}),
    ]:
        headers, body = equivalence_rows(rows, columns, gen, full, kernels_dir)
        doc.table(title, headers, body)

    race_rows = []
    for label, lib, loc_file in RACES:
        pre, post = gen.get(f"{label} (pre-fix)"), gen.get(f"{label} (post-fix)")
        race_rows.append(
            [
                label,
                lib,
                loc_cell(kernels_dir, [loc_file]),
                pre["status"] if pre else "-",
                median_cell(pre, "vc_gen"),
                post["status"] if post else "-",
                median_cell(post, "vc_gen"),
            ]
        )
    doc.table(
        "Table 7: racy FaialAA benchmarks",
        ["Kernel", "Library", "PTX LOC", "pre-fix", "Check (s)", "post-fix", "Check (s)"],
        race_rows,
    )

    if z3:
        hdr = runs["z3"][2]
        rows8 = []
        for label, name, _, _ in TABLE8:
            s1, zr = sample1.get(name), z3.get(name)
            volta = f"{s1['solve_median_secs']*1000:.2f}" if s1 else "-"
            rows8.append([label, volta, z3_cell(zr, "plain"), z3_cell(zr, "axiom")])
        doc.table(
            f"Table 8: single-element VC, Volta decision procedure vs Z3 "
            f"(budget {hdr.get('z3_timeout_secs', '?')} s)",
            ["Kernel", "Volta (ms)", "Z3", "Z3 + exp axiom"],
            rows8,
        )

    known = {name for _, name, *_ in TABLE8} | {
        f"{label} ({stage}-fix)" for label, _, _ in RACES for stage in ("pre", "post")
    }
    # The racy tutorial reductions appear in the paper's prose, not a table.
    known |= {f"Red-{i} (racy)" for i in (5, 6, 7)}
    for kind, (_, by_name, _) in runs.items():
        extra = [n for n, b in by_name.items() if n not in known and b.get("status") != "SKIP"]
        if extra:
            doc.para(f"Benchmarks in the {kind} run without a table row: {', '.join(sorted(extra))}")
    return doc


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("results_dir", type=Path)
    ap.add_argument("-o", "--output", type=Path, help="write here (default stdout)")
    ap.add_argument("--format", choices=sorted(RENDERERS), default="md", help="output format (default md)")
    ap.add_argument(
        "--kernels-dir",
        type=Path,
        default=Path("crates/volta_bench/kernels"),
        help="kernel corpus for the PTX LOC columns",
    )
    args = ap.parse_args()

    runs = load_runs(args.results_dir)
    if not runs:
        sys.exit(f"no volta-bench results files found in {args.results_dir}")
    kernels_dir = args.kernels_dir if args.kernels_dir.is_dir() else None
    text = RENDERERS[args.format](build_doc(runs, kernels_dir))
    if args.output:
        args.output.write_text(text)
        print(f"wrote {args.output}", file=sys.stderr)
    else:
        print(text)


if __name__ == "__main__":
    main()
