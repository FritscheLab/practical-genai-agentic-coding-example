R path · [All steps](index.md) · [Change language](../python/index.md)

Lesson 5 of 6

# Check the diff

From the repository root:

```bash
git diff -- plotting/plot_summary.R
git status --short
```

Connect the changed settings to the improved chart. Did the counts, group assignments, CLI, and dependencies stay intact? Inspect any other changed or new source files too. The plotting command should still write only the PNG; the agent authors the alt text separately.

Want a second opinion? Ask a labmate or another agent:

```text
Review the R plotting diff against docs/reference/figure-specifications.md,
the checks, and the PNG and alt text in runs/with-fix/. Report concrete issues
and unperformed checks. Don't edit files.
```

The optional [plot-review skill](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/portable-context.html) packages that review. Check any findings before acting on them.

---

[← Previous: 4. Verify](04-verify.md) · [Next: 6. Hand off →](06-handoff.md)
