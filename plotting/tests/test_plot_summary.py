"""Behavior checks; inspect the rendered image separately for readability."""

import importlib.util
import struct
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "plot_summary.py"
SPEC = importlib.util.spec_from_file_location("plot_summary", SCRIPT)
SUMMARY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SUMMARY)

EXPECTED_CATEGORIES = (
    "Complete measurements",
    "Missing height only",
    "Missing weight only",
    "Missing height and weight",
)
EXPECTED_GROUPS = ("Group A", "Group B")
EXPECTED_COUNTS = ((42, 31, 18, 9), (64, 18, 12, 6))


class PlotSummaryTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="plot checks ")
        self.addCleanup(self.scratch.cleanup)
        self.directory = Path(self.scratch.name)

    def run_cli(self, *arguments):
        return subprocess.run(
            [sys.executable, str(SCRIPT), *map(str, arguments)],
            cwd=self.directory, capture_output=True, text=True, check=False,
        )

    def assert_png(self, path):
        content = path.read_bytes()
        self.assertEqual(content[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(content[12:16], b"IHDR")
        width, height = struct.unpack(">II", content[16:24])
        self.assertGreater(width, 0)
        self.assertGreater(height, 0)
        self.assertGreater(len(content), 1000)

    def test_invented_constants(self):
        self.assertEqual(SUMMARY.CATEGORIES, EXPECTED_CATEGORIES)
        self.assertEqual(SUMMARY.GROUPS, EXPECTED_GROUPS)
        self.assertEqual(SUMMARY.COUNTS, EXPECTED_COUNTS)
        self.assertEqual(tuple(map(sum, SUMMARY.COUNTS)), (100, 100))

    def test_drawn_categories_counts_and_order(self):
        figure = SUMMARY.make_summary_figure()
        self.addCleanup(figure.clear)
        axes = figure.axes[0]
        self.assertEqual(
            tuple(label.get_text() for label in axes.get_yticklabels()),
            EXPECTED_CATEGORIES,
        )
        containers = [item for item in axes.containers if hasattr(item, "patches")]
        self.assertEqual(len(containers), 2)
        for group, expected, bars in zip(EXPECTED_GROUPS, EXPECTED_COUNTS, containers, strict=True):
            self.assertEqual(bars.get_label(), group)
            self.assertEqual(tuple(bar.get_width() for bar in bars), expected)
        self.assertTrue(axes.yaxis_inverted())
        self.assertCountEqual(
            tuple(text.get_text() for text in axes.texts),
            ("42", "31", "18", "9", "64", "18", "12", "6"),
        )

    def test_importable_function_writes_png(self):
        output = self.directory / "function result" / "summary.png"
        self.assertEqual(SUMMARY.plot_summary(output), output)
        self.assert_png(output)

    def test_cli_nested_path_with_spaces(self):
        output = self.directory / "new folder" / "summary chart.png"
        result = self.run_cli("--output", output)
        self.assertEqual((result.returncode, result.stdout, result.stderr), (0, "", ""))
        self.assert_png(output)

    def test_cli_invalid_arguments(self):
        for arguments in [(), ("--output",), ("--unknown",),
                          ("--output", "chart.pdf"), ("--output", ""),
                          ("--output", "chart.png", "extra")]:
            with self.subTest(arguments=arguments):
                result = self.run_cli(*arguments)
                self.assertEqual(result.returncode, 2)
                self.assertEqual(result.stdout, "")
                self.assertIn("error:", result.stderr)
        self.assertEqual(list(self.directory.iterdir()), [])

    def test_cli_unwritable_output(self):
        blocker = self.directory / "ordinary file"
        blocker.write_text("Keep this file.\n", encoding="utf-8")
        result = self.run_cli("--output", blocker / "summary.png")
        self.assertEqual(
            (result.returncode, result.stdout, result.stderr),
            (1, "", "error: could not write PNG\n"),
        )
        self.assertEqual(blocker.read_text(encoding="utf-8"), "Keep this file.\n")

    def test_cli_help(self):
        result = self.run_cli("--help")
        self.assertEqual(result.returncode, 0)
        self.assertIn("--output", result.stdout)
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
