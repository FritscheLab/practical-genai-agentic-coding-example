# Fix the figure, keep the results

Two groups overlap. Long labels disappear. Your job is to turn that chart into a readable grouped figure that meets the journal rules.

| Choose your path | Change this function |
| --- | --- |
| [Python](../paths/python/02-specify.md) | `make_summary_figure()` in `plotting/plot_summary.py` |
| [R](../paths/r/02-specify.md) | `plot_summary()` in `plotting/plot_summary.R` |

## The brief lives in a file

Read [Journal specifications for figures](../reference/figure-specifications.md). Our fictional **Journal of Unnecessarily Specific Figures** demands purple-and-lime bars, typewriter text, precise export settings, and accessible presentation. The file supplies the complete rules and all eight invented counts.

Keep the counts, category order, group assignments, CLI, and dependencies unchanged. Work from source, tests, and the invented chart; there are no participant records or input data files.

## Done looks like this

- Two readable bars per category, with every journal rule met.
- Behavior tests **and** the figure checker pass.
- You have reviewed the image, contrast, and grayscale readability yourself.
- `runs/with-fix/summary.png` has an accurate, separately authored `summary.alt.txt` of at most 150 words.

The starter passes behavior tests and fails the figure checker. Automated checks do not establish accessibility or alt-text accuracy. Keep the baseline for comparison and report anything unverified.

Use the short [Python repair prompt](../paths/python/03-implement.md) or [R repair prompt](../paths/r/03-implement.md). You can point the agent to the specification instead of pasting all its rules.

Finished? Try a stacked chart in a separate copy with its own layout brief. Keep the completed grouped figure.
