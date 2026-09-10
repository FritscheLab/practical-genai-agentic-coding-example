R path · [All steps](index.md) · [Change language](../python/index.md)

Lesson 4 of 6

# Does it work—and can you read it?

From the example repository root:

```bash
Rscript plotting/tests/run_tests.R
Rscript plotting/check_figure.R --output runs/with-fix/summary.png
```

The first command checks behavior; the second renders and checks the journal rules. **The starter passes the first and fails the second.** A repair should pass both.

## Look at the result

Open `runs/baseline/summary.png` beside `runs/with-fix/summary.png`, with the [journal rules](../../reference/figure-specifications.md) handy:

- Two bars per category, Group A above B; all eight values unchanged?
- Complete labels, correct legend, and no clipping or overlap?
- Required colors, fonts, dimensions, and axes?
- Legible text and outlines at 6 × 4 inches? Groups identifiable without color?

Check a grayscale view too. If your viewer cannot provide one, record that check as unfinished.

## Read the description

Open `runs/with-fix/summary.alt.txt`. Does it explain the comparison, all values, and the invented nature of the counts in at most 150 words? It must stand on its own without color names.

**The checker cannot approve accessibility or alt-text accuracy for you.** Fix any problem, rerun both commands, and inspect the new image. If the agent cannot view PNGs, you do that step.

---

[← Previous: 3. Implement](03-implement.md) · [Next: 5. Review →](05-review.md)
