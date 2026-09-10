# Plotting contract

Both language paths create a PNG chart from the same invented aggregate counts. No individual-level inputs, filtering, or participant identifiers are involved.

## Fixed summary values

| Category, in order | Group A | Group B |
| --- | ---: | ---: |
| Complete measurements | 42 | 64 |
| Missing height only | 31 | 18 |
| Missing weight only | 18 | 12 |
| Missing height and weight | 9 | 6 |

Each group totals **100**. Keep all labels, counts, group assignments, and order unchanged. Constants are embedded in source code; the program does not accept a data-file path.

## Commands

Run from the example repository root:

```bash
python plotting/plot_summary.py --output runs/baseline/summary.png
```

```bash
Rscript plotting/plot_summary.R --output runs/baseline/summary.png
```

Use a different output path, such as `runs/with-fix/summary.png`, to preserve the baseline image. Both implementations expose a `plot_summary(output_path)` function. Python builds its layout in `make_summary_figure()`, called by that writer; R builds the layout inside `plot_summary()`. The Python path uses Matplotlib with a noninteractive backend; the R path uses base graphics and requires no extra packages.

## Starting problem and intended repair

The starter draws both groups at the same positions, so bars overlap, and leaves too little room for long category labels. It also falls short of the fictional journal's formatting rules. Image generation and ordinary behavior checks still work.

Repair the plotting function to produce side-by-side grouped bars and meet every requirement in [Journal specifications for figures](figure-specifications.md). The source of the layout is `make_summary_figure()` in Python and `plot_summary()` in R. Keep command behavior and invented values unchanged. The [task brief](../lessons/02-specify.md) explains the workflow.

## Verification

```bash
python -m unittest discover -s plotting/tests
```

```bash
Rscript plotting/tests/run_tests.R
```

These ordinary checks use independently specified categories, groups, and counts and exercise image generation and command behavior. A test pass does not prove that the chart is readable. Open the PNG, compare it with the baseline, and inspect the plotting-code diff separately. Python and R images need not match pixel for pixel.

The separate figure check renders the current implementation and checks journal requirements:

```bash
python plotting/check_figure.py --output runs/with-fix/summary.png
```

```bash
Rscript plotting/check_figure.R --output runs/with-fix/summary.png
```

The starter is expected to fail these acceptance checks. Use the resulting messages to inspect the plotting code, then review the saved PNG separately, including contrast, grayscale readability, and group identification without color. Write and review `runs/with-fix/summary.alt.txt` as required by the journal; this is a separate authoring deliverable, not a new plotting-program side effect. Do not edit the specification or checker to make an incorrect figure pass.
