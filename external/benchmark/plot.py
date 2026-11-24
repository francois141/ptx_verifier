"""Draw `benchmark.py`'s results as the solving-speed figure (`solving-speed.pdf`, `.png`): per ISA
and K, the mean over the runs of execution + canonical seconds with ±1 sample standard deviation,
and below the axis the largest peak memory of `volta solve` over the runs. A configuration with a
failed run has no bar. `benchmark.py` runs it at its end; to redraw from saved results:

    uv run --no-project --with matplotlib python external/benchmark/plot.py
"""

import argparse
import json
import math
import statistics
from dataclasses import dataclass
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

BENCHMARK_ROOT = Path(__file__).resolve().parent
RESULTS = BENCHMARK_ROOT.parent.parent / "target" / "benchmark" / "results.json"
FIGURE = BENCHMARK_ROOT / "solving-speed"
SERIES = {
    "ptx": ("PTX", "#0072B2", ""),
    "amd": ("AMD", "#009E73", "//"),
    "trainium": ("NKI", "#D55E00", ".."),
}


@dataclass(frozen=True)
class Bar:
    totals: list[float]
    peak_gib: float | None


def measured(value: object) -> bool:
    return isinstance(value, (int, float)) and math.isfinite(value)


def read_bars(path: Path) -> dict[tuple[str, int], Bar]:
    """Each configuration's per-run totals (none if a run failed) and its largest peak memory."""
    bars = {}
    for row in json.loads(path.read_text()):
        runs = row.get("runs", [])
        complete = bool(runs) and all(measured(run["exec"]) and measured(run["canonical"]) for run in runs)
        totals = [run["exec"] + run["canonical"] for run in runs] if complete else []
        peaks = [run["peak_bytes"] for run in runs if run["peak_bytes"] > 0]
        bars[(row["isa"], row["k"])] = Bar(totals, max(peaks) / 2**30 if peaks else None)
    return bars


def draw(bars: dict[tuple[str, int], Bar], isas: list[str], sizes: list[int], output: Path) -> None:
    plt.rcParams.update(
        {
            "font.family": "serif",
            "font.size": 8,
            "axes.labelsize": 8,
            "xtick.labelsize": 7,
            "ytick.labelsize": 7,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
            "axes.linewidth": 0.6,
        }
    )
    fig, ax = plt.subplots(figsize=(3.4, 2.1))
    fig.subplots_adjust(left=0.17, right=0.98, bottom=0.49, top=0.80)
    ax.set_yscale("log")
    ax.set_xlim(-0.55, len(sizes) - 0.45)
    ax.set_xticks(range(len(sizes)), [str(k) for k in sizes])
    ax.minorticks_off()
    ax.set_axisbelow(True)
    ax.grid(axis="y", color="#e5e5e5", linewidth=0.5)
    ax.tick_params(length=2.5, width=0.6, pad=2)
    ax.set_xlabel("Reduction dimension K", labelpad=4)
    ax.spines[["top", "right"]].set_visible(False)
    ax.set_ylabel("Execution +\ncanonical (s)", labelpad=5)

    width = 0.24
    lower, upper = 1.0, 1500.0
    plotted = with_spread = 0
    for index, isa in enumerate(isas):
        _, color, hatch = SERIES[isa]
        offset = (index - (len(isas) - 1) / 2) * width
        for position, k in enumerate(sizes):
            bar = bars.get((isa, k))
            if bar is None or not bar.totals:
                continue
            mean = statistics.mean(bar.totals)
            sd = statistics.stdev(bar.totals) if len(bar.totals) > 1 else None
            x = position + offset
            ax.bar(x, mean, width=width * 0.9, color=color, edgecolor="#333333", linewidth=0.35, hatch=hatch, zorder=3)
            if sd is not None:
                below = min(sd, mean * 0.99)
                ax.errorbar(
                    x, mean, yerr=[[below], [sd]], fmt="none", ecolor="#222222",
                    elinewidth=0.7, capsize=1.8, capthick=0.7, zorder=4,
                )  # fmt: skip
                with_spread += 1
            plotted += 1
            lower = min(lower, (mean - (sd or 0)) / 1.3)
            upper = max(upper, (mean + (sd or 0)) * 1.3)
    ax.set_ylim(max(lower, 0.1), upper)
    decades = range(math.floor(math.log10(max(lower, 0.1))), math.ceil(math.log10(upper)) + 1)
    ax.set_yticks([10.0**d for d in decades if lower <= 10.0**d <= upper])

    handles = [
        Patch(facecolor=SERIES[isa][1], edgecolor="#333333", linewidth=0.35, hatch=SERIES[isa][2], label=SERIES[isa][0])
        for isa in isas
    ]
    fig.legend(
        handles=handles, loc="upper center", bbox_to_anchor=(0.54, 0.94),
        ncol=len(isas), frameon=False, fontsize=7, columnspacing=1,
    )  # fmt: skip

    memory = fig.add_axes((0.17, 0.07, 0.81, 0.23))
    memory.set_xlim(ax.get_xlim())
    memory.set_ylim(-0.5, 3.2)
    memory.axis("off")
    memory.text((len(sizes) - 1) / 2, 3, "Peak memory (GiB)", ha="center", va="center", fontsize=6)
    for index, isa in enumerate(isas):
        label, color, _ = SERIES[isa]
        y = 2 - index
        memory.text(-0.7, y, label, ha="right", va="center", fontsize=6, color=color)
        for position, k in enumerate(sizes):
            bar = bars.get((isa, k))
            text = f"{bar.peak_gib:.3g}" if bar is not None and bar.peak_gib is not None else "\N{EM DASH}"
            memory.text(position, y, text, ha="center", va="center", fontsize=6, color=color)

    runs = sorted({len(bar.totals) for bar in bars.values() if bar.totals})
    if with_spread == 0:
        note = "Variance unavailable: one run per configuration."
    elif with_spread == plotted:
        counted = " or ".join(str(n) for n in runs)
        note = f"Bars: mean of {counted} runs; error bars: ±1 sample standard deviation."
    else:
        note = "Error bars: ±1 SD where repeats exist; others: a single run."
    fig.text(0.54, 0.025, note, ha="center", fontsize=6)

    for suffix in (".pdf", ".png"):
        fig.savefig(output.with_suffix(suffix), dpi=240)
    plt.close(fig)
    print(f"Wrote {output.with_suffix('.pdf')} and .png: {plotted} bars, {with_spread} with error bars")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--results", type=Path, default=RESULTS)
    parser.add_argument("--output", type=Path, default=FIGURE, help="path without suffix")
    parser.add_argument("--isa", nargs="+", default=list(SERIES), choices=list(SERIES))
    parser.add_argument("--sizes", type=int, nargs="+", default=[128, 256, 512, 1024, 2048, 4096, 8192])
    args = parser.parse_args()
    draw(read_bars(args.results), args.isa, sorted(args.sizes), args.output)


if __name__ == "__main__":
    main()
