Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 6 of 6

# Leave a three-sentence handoff

Tell a labmate what changed, how you checked it, and what remains. For example:

> Added an exclusion section so a labmate can see why measurements are missing. `python -m pytest` passed, the small example reported 3 of 6 excluded with reason counts of 2 and 2, and the complete example reported no exclusions. The cleaned and flagged rows matched the baseline, and I have no remaining issues to report.

Use your actual results and mention anything unfinished. Save the note somewhere you can find it; no template or submission is required. The [handoff template](../../templates/handoff.md) is available when you need more structure.

## Optional: keep the change in Git

If you want to keep the change in Git, stage the specific source and test files, inspect the staged diff, and commit. Leave generated run folders and credentials out of the commit.

---

[← Previous: 5. Review](05-review.md) · [Back to all steps](index.md)
