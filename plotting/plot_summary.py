"""Plot fixed, invented aggregate counts for the layout-repair exercise."""

import argparse
from pathlib import Path

from matplotlib.backends.backend_agg import FigureCanvasAgg
from matplotlib.figure import Figure

CATEGORIES = (
    "Complete measurements",
    "Missing height only",
    "Missing weight only",
    "Missing height and weight",
)
GROUPS = ("Group A", "Group B")
COUNTS = ((42, 31, 18, 9), (64, 18, 12, 6))


def make_summary_figure() -> Figure:
    """Build the chart from invented totals, without reading any data files."""
    figure = Figure(figsize=(6.4, 3.8), dpi=120)
    FigureCanvasAgg(figure)
    axes = figure.subplots()
    # Both groups currently share positions, hiding parts of the first group.
    for group, counts in zip(GROUPS, COUNTS, strict=True):
        bars = axes.barh(CATEGORIES, counts, color="#0f766e", label=group)
        axes.bar_label(bars, padding=5)
    axes.invert_yaxis()
    axes.set_xlim(0, 80)
    axes.set_xlabel("Invented measurement count")
    axes.set_title("Measurement completeness (invented totals)")
    axes.spines[["top", "right"]].set_visible(False)
    # The starting layout leaves too little room for the category labels.
    figure.subplots_adjust(left=0.17, right=0.95, bottom=0.18, top=0.86)
    return figure


def plot_summary(output_path: str | Path) -> Path:
    """Write a headless PNG; create its parent directory when needed."""
    output = Path(output_path)
    if output.suffix.lower() != ".png":
        raise ValueError("output path must end in .png")
    output.parent.mkdir(parents=True, exist_ok=True)
    figure = make_summary_figure()
    try:
        figure.savefig(output, format="png")
    finally:
        figure.clear()
    return output


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path, help="destination PNG path")
    args = parser.parse_args(argv)
    if args.output.suffix.lower() != ".png":
        parser.error("output path must end in .png")
    try:
        plot_summary(args.output)
    except OSError:
        parser.exit(1, "error: could not write PNG\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
