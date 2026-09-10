R path · [Change language](../python/index.md)

# Fix a plot in R

Overlapping bars. Clipped labels. A very particular fictional journal. **Use an agent to turn this chart into a readable figure.**

The source contains invented aggregate counts for two groups—no participant records or data-file inputs. Use an approved coding client and keep study data outside this workspace. [Data guidance](../../reference/lab-data-policy.md).

## Set up

You need Git and a terminal. If you already have the exercise repository, open a terminal in its root. Otherwise, clone it:

```bash
git clone https://github.com/FritscheLab/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

You need R 4.1 or later. The example uses base R; no package installation is needed. Run the checks from your terminal, including RStudio's Terminal tab if you use it:

```bash
Rscript plotting/tests/run_tests.R
```

## Save the starting chart

From the example repository root, run:

```bash
Rscript plotting/plot_summary.R --output runs/baseline/summary.png
```

Open `runs/baseline/summary.png` in your editor or file browser. Spot the overlapping bars and clipped labels. Keep this image for comparison; choose another output path if you already have a baseline to preserve.

**Passing tests ≠ a readable chart.** Behavior checks pass on this starter; the journal checker introduced in Lesson 4 should fail until you repair it.

## Follow the demo

| Step | What to do |
| --- | --- |
| [1. Orient](01-orient.md) | Ask the agent to locate the plotting function and its layout settings. |
| [2. Specify](02-specify.md) | Read the figure specifications and preserve both groups' values. |
| [3. Implement](03-implement.md) | Ask the agent to repair the plot. |
| [4. Verify](04-verify.md) | Check the image, accessibility, and accompanying alt text. |
| [5. Review](05-review.md) | Inspect the code changes. |
| [6. Hand off](06-handoff.md) | Record what changed, the checks, and any remaining issues. |


## Setup troubleshooting

- **R command:** If the terminal cannot find `Rscript`, check your R installation and terminal environment.
- **Working directory:** Run commands from the example repository root, the folder containing `README.md` and `plotting/`.
- **Opening the chart:** The output is a PNG image. Open it from your file browser or editor; no browser server is needed.

---

[Next: 1. Orient →](01-orient.md)
