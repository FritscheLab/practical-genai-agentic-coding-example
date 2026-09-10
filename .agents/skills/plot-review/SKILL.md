---
name: plot-review
description: Review a plotting repair against its code contract, tests, and rendered chart. Use when asked to check plotting changes; do not inspect participant records or diagnose data points.
---

Read `AGENTS.md`, `docs/reference/io_contract.md`, `docs/reference/figure-specifications.md`, the requested source diff, and the selected language's test code. Review `plotting/plot_summary.py` or `plotting/plot_summary.R`.

Check that the repair keeps the four category labels and group assignments unchanged: Group A counts are 42, 31, 18, 9; Group B counts are 64, 18, 12, 6. Preserve category order and show Group A above Group B within each category. Trace plotting options, function calls, and output handling. Do not open data tables, participant records, or study logs, and do not explain why an individual value failed.

When tools permit, run `python -m unittest discover -s plotting/tests` or `Rscript plotting/tests/run_tests.R` and use the pass/fail evidence. Run the selected language's `plotting/check_figure.py` or `plotting/check_figure.R` with `--output` and an ignored PNG path when execution is permitted. The starter intentionally fails this stricter acceptance check. Inspect the rendered chart against every fictional journal requirement, including grouping, legend, and full readable labels. Record image inspection as untested when image tools are unavailable. A passing test suite alone does not establish visual quality.

Review accessibility explicitly: black text on white, visible bar outlines, readable labels at the intended size, and group identification that survives grayscale. Read `runs/with-fix/summary.alt.txt` and compare its group names, values, and summary with the invented constants and chart. Check that the description will be attached when the image is used; a sidecar file alone does not provide screen-reader access. Record visual or assistive-technology checks that were unavailable.

Return concrete findings with source locations, expected behavior, and observed behavior. Separate code/test findings from visual and accessibility observations. Do not modify files during a review unless asked. Report commands actually run and any checks left unrun.
