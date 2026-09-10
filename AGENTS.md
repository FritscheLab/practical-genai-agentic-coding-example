# AGENTS.md

Help the learner repair a plotting function using code, tests, and a chart made from invented summary counts.

## Start with the chosen language

Read `README.md`, `REPO_MAP.md`, and the relevant page in `docs/paths/python/` or `docs/paths/r/`. The plotting contract is `docs/reference/io_contract.md`. Python uses `plotting/plot_summary.py`; R uses `plotting/plot_summary.R`.

The starting chart deliberately overlaps two groups and clips long labels. Preserve that unfinished exercise during maintenance unless the user asks to solve it. For a learner's repair, change the plotting function to make the grouped chart follow `docs/reference/figure-specifications.md` while preserving categories, counts, group assignments, and order.

## Explore code and the chart

Explain source files, function calls, and tests. Do not open individual-level data, inspect participant records, or diagnose why a data point failed. This exercise has no participant records or data-file inputs. Its fixed aggregate counts are invented and embedded in source code.

Use the supplied chart to discuss labels, spacing, axes, and readability. Run the synthetic checks when requested and use their pass/fail evidence. Tests do not establish visual quality; inspect the rendered image separately. Do not change expected values to make a test pass.

When reusing this workflow, work in a separate workspace with code permitted for the selected service and invented examples. Keep study data, exports, logs, credentials, and sensitive code literals outside the agent's access. A local terminal, read-only mode, or `.gitignore` is not a data-sharing permission. See `docs/reference/lab-data-policy.md`.

## Verify and hand off

From the repository root, run the chosen language's checks:

```bash
python -m unittest discover -s plotting/tests
```

```bash
Rscript plotting/tests/run_tests.R
```

Render a new image, compare it with the saved baseline, and inspect the code diff. Follow the journal's accessibility requirements: review contrast, legibility, and group identification without color, and write accurate alternative text in `runs/with-fix/summary.alt.txt`. Attach that text when placing the image in a document or slide. Consider accessibility whenever creating an artifact for others to use. Keep `runs/` and `tmp/` ignored. Use `.agents/skills/plot-review/SKILL.md` for a requested independent review. The optional `lab-r-refactor` skill applies the local R template without changing behavior.

Preserve unrelated work and agree on file ownership with other agents. Finish with what changed, actual commands and outcomes, visual observations, and anything untested. Do not publish or modify external services without authorization.
