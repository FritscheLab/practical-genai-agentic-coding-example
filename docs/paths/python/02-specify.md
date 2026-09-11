Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 2 of 6

# Plan against the journal brief

The fictional **Journal of Unnecessarily Specific Figures** wants purple-and-lime grouped bars, typewriter text, exact dimensions, and accessible presentation.

Open [Journal specifications for figures](../../reference/figure-specifications.md). This file contains all eight counts, formatting rules, and the required alternative text. It is the repair brief.

In the same **Local** Chat session, switch from **Ask** to **Plan** and paste:

```text
Read docs/reference/figure-specifications.md and the Python plotting code.
Plan a small repair to make_summary_figure() in plotting/plot_summary.py.
Name the layout changes, files to edit, behavior tests, figure checker,
and visual and alt-text checks. Preserve counts, category order, group
assignments, command behavior, and dependencies. Keep the baseline image.
Prefer a direct repair in the existing function. Do not propose a new
framework, configuration system, or unrelated refactor. Explain why any
new helper is needed and identify a simpler alternative if scope grows.
Do not implement the repair or change project files yet.
```

Read the proposed plan before handing it to Agent. It should connect the journal rules to the plotting function and name both kinds of automated check. Request a revision if it proposes changing the constants, test expectations, checker, or specification to obtain a pass.

Your repair is done when:

- The repair stays understandable: new code and abstractions serve this task, and you can explain the changed function.
- The grouped chart meets every journal rule and preserves the program's behavior.
- Behavior tests and the figure checker pass against the latest code, and you have inspected the image yourself.
- The separately written `runs/with-fix/summary.alt.txt` accurately describes the comparison in at most 150 words.

**Ready for the next step:** you have reviewed a specific plan. The repository instructions provide standing rules; the journal file provides the details.

---

[← Previous: 1. Orient](01-orient.md) · [Next: 3. Implement →](03-implement.md)
