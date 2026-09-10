"""Check the rendered figure against the fictional JUSF requirements.

Behavior tests remain separate. This checker intentionally fails on the starter.
"""

import argparse
import importlib.util
from itertools import combinations
from pathlib import Path

from matplotlib.colors import to_hex, to_rgba
from matplotlib.container import BarContainer
from matplotlib.text import Text
from PIL import Image

CATEGORIES = (
    "Complete measurements", "Missing height only",
    "Missing weight only", "Missing height and weight",
)
GROUPS = ("Group A", "Group B")
COUNTS = ((42, 31, 18, 9), (64, 18, 12, 6))
COLORS = ("#440154", "#b8de29")


def check_figure(output_path, source_path=None):
    """Render the real writer and inspect its saved PNG and actual artists."""
    source = Path(source_path) if source_path else Path(__file__).with_name("plot_summary.py")
    spec = importlib.util.spec_from_file_location("checked_plot", source)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    captured = []
    build = module.make_summary_figure

    def capture():
        figure = build()
        captured.append((figure, figure.clear))
        # Retain the writer's actual artists until inspection is complete.
        figure.clear = lambda: None
        return figure

    module.make_summary_figure = capture
    errors = []

    def require(condition, message):
        if not condition:
            errors.append(message)

    try:
        module.plot_summary(output_path)
        require(len(captured) == 1, "The writer must build one summary figure.")
        if not captured:
            return errors
        figure = captured[0][0]
        with Image.open(output_path) as png:
            require(png.format == "PNG" and png.size == (1800, 1200),
                    "PNG must be exactly 1800 x 1200 pixels.")
            require(all(abs(value - 300) < 0.1 for value in png.info.get("dpi", (0, 0))),
                    "PNG resolution metadata must be 300 dpi.")
        require(to_rgba(figure.get_facecolor()) == to_rgba("white"),
                "Figure background must be white.")
        require(len(figure.axes) == 1, "Use one shared count axis.")
        if len(figure.axes) != 1:
            return errors
        axes = figure.axes[0]
        require(to_rgba(axes.get_facecolor()) == to_rgba("white"),
                "Axes background must be white.")
        require(tuple(axes.get_xlim()) == (0, 80), "Count axis must run from 0 to 80.")
        require(tuple(axes.get_xticks()) == (0, 20, 40, 60, 80),
                "Count ticks must be 0, 20, 40, 60, 80.")
        require(axes.get_title() == "Measurement completeness", "Use the exact journal title.")
        require(axes.get_xlabel() == "Number of measurements", "Use the exact count-axis label.")
        ticks = axes.get_yticklabels()
        require(tuple(t.get_text() for t in ticks) == CATEGORIES and axes.yaxis_inverted(),
                "Keep the four category labels in the specified top-to-bottom order.")
        containers = [item for item in axes.containers if isinstance(item, BarContainer)]
        require(len(containers) == 2, "Draw two labelled groups of four horizontal bars.")
        bars_by_group = {item.get_label(): item for item in containers}
        for index, group in enumerate(GROUPS):
            bars = bars_by_group.get(group, [])
            require(len(bars) == 4, f"{group} must have four bars.")
            if len(bars) != 4:
                continue
            require(tuple(bar.get_width() for bar in bars) == COUNTS[index],
                    f"Preserve all four {group} counts and their category order.")
            require(all(bar.get_x() == 0 for bar in bars), "Grouped bars must start at zero.")
            require(all(to_hex(bar.get_facecolor()) == COLORS[index] and
                        bar.get_facecolor()[3] == 1 for bar in bars),
                    f"Use the required fill for {group}.")
            require(all(to_hex(bar.get_edgecolor()) == "#000000" and
                        bar.get_edgecolor()[3] == 1 and 0 < bar.get_linewidth() <= 1
                        for bar in bars), "Give every bar a thin black border (at most 1 pt).")
        if all(len(bars_by_group.get(group, [])) == 4 for group in GROUPS):
            bars_a, bars_b = (bars_by_group[group] for group in GROUPS)
            centers = []
            for index, (bar_a, bar_b) in enumerate(zip(bars_a, bars_b, strict=True)):
                a_y, b_y = (bar.get_y() + bar.get_height() / 2 for bar in (bar_a, bar_b))
                require(a_y < b_y, "Place Group A above Group B in every category.")
                require(bar_a.get_y() + bar_a.get_height() <= bar_b.get_y(),
                        "Bars within each category must not overlap.")
                centers.append((a_y + b_y) / 2)
                require(index < len(axes.get_yticks()) and
                        abs(centers[-1] - axes.get_yticks()[index]) < 0.05,
                        "Center each category label on its pair of bars.")
            all_bars = list(bars_a) + list(bars_b)
            for first, second in combinations(all_bars, 2):
                require(min(first.get_y() + first.get_height(),
                            second.get_y() + second.get_height()) -
                        max(first.get_y(), second.get_y()) <= 1e-9,
                        "Bars must not overlap.")
            for index in range(3):
                lower_edge = max(bar.get_y() + bar.get_height()
                                 for bar in (bars_a[index], bars_b[index]))
                next_upper_edge = min(bar.get_y()
                                      for bar in (bars_a[index + 1], bars_b[index + 1]))
                require(lower_edge < next_upper_edge, "Leave space between categories.")
        legend = axes.get_legend()
        require(legend is not None, "Add a legend.")
        if legend is not None:
            require(tuple(t.get_text() for t in legend.get_texts()) == GROUPS,
                    "Legend must list Group A then Group B.")
            require(not legend.get_frame_on(), "Remove the legend frame.")
            handles = getattr(legend, "legend_handles", getattr(legend, "legendHandles", []))
            require(tuple(to_hex(h.get_facecolor()) for h in handles) == COLORS and
                    all(h.get_facecolor()[3] == 1 for h in handles),
                    "Legend fills must match the required group colors.")
        figure.canvas.draw()
        renderer = figure.canvas.get_renderer()
        texts = [item for item in figure.findobj(Text)
                 if item.get_visible() and item.get_text().strip()]
        for item in texts:
            title = item is axes.title
            require(abs(item.get_fontsize() - (11 if title else 9)) < 0.01,
                    "Use 9 pt text and an 11 pt title.")
            widths = [renderer.get_text_width_height_descent(
                character * 4, item.get_fontproperties(), False)[0]
                for character in ("i", "W", "0", " ")]
            require(max(widths) - min(widths) < 0.1,
                    "Use a resolved monospace font throughout.")
            require(to_rgba(item.get_color()) == to_rgba("black"),
                    "Use black text on the white background.")
            if title:
                require(item.get_fontweight() in ("bold", 700), "Make the title bold.")
            box = item.get_window_extent(renderer)
            require(figure.bbox.contains(box.x0, box.y0) and
                    figure.bbox.contains(box.x1, box.y1), "Keep every text label inside the image.")
        count_labels = [item for item in axes.texts if item.get_text().isdigit()]
        require(sorted(item.get_text() for item in count_labels) ==
                sorted(str(value) for counts in COUNTS for value in counts),
                "Label all eight counts as integers.")
        for group in GROUPS:
            for bar in bars_by_group.get(group, []):
                end = axes.transData.transform(
                    (bar.get_width(), bar.get_y() + bar.get_height() / 2))
                matching = [item for item in count_labels
                            if item.get_text() == str(int(bar.get_width()))]
                require(any(0 <= item.get_window_extent(renderer).x0 - end[0] <= 80 and
                            abs((item.get_window_extent(renderer).y0 +
                                 item.get_window_extent(renderer).y1) / 2 - end[1]) <= 20
                            for item in matching), "Put each integer beside its own bar end.")
        boxes = [(item, item.get_window_extent(renderer)) for item in texts]
        for (_, first), (_, second) in combinations(boxes, 2):
            require(not first.overlaps(second), "Text labels must not overlap.")
        if legend is not None:
            box = legend.get_window_extent(renderer)
            require(all(not box.overlaps(bar.get_window_extent(renderer))
                        for item in containers for bar in item),
                    "Keep the legend clear of the bars.")
    finally:
        for figure, clear in captured:
            figure.clear = clear
            clear()
    return list(dict.fromkeys(errors))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args(argv)
    if args.output.suffix.lower() != ".png":
        parser.error("output path must end in .png")
    try:
        errors = check_figure(args.output)
    except Exception as error:
        print(f"FAIL: could not inspect the rendered figure: {error}")
        return 1
    for error in errors:
        print(f"FAIL: {error}")
    if not errors:
        print("PASS: automated JUSF figure requirements.")
    print("VISUAL REVIEW: inspect the PNG at 6 x 4 inches, grayscale readability, "
          "remaining collisions, and the separately authored alt text.")
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
