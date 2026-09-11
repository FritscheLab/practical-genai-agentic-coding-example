R path · [All steps](index.md) · [Change language](../python/index.md)

Lesson 3 of 6

# Have Agent make the repair

Keep the reviewed plan in the Chat conversation. Select **Agent**, leaving the session target on **Local**, and paste:

```text
Implement the plan we just reviewed. Fix plot_summary() in
plotting/plot_summary.R to follow docs/reference/figure-specifications.md.
Preserve counts, category order, group assignments, command behavior, and
dependencies. Keep runs/baseline/summary.png. Save the repaired PNG to
runs/with-fix/summary.png and author runs/with-fix/summary.alt.txt separately.
Run the R behavior tests and figure checker. Summarize changed files,
actual commands and results, and anything you could not verify. Do not
change the specification or checker, stage files, commit, or publish.
Use a direct, readable repair in the existing plotting function. Avoid
unrequested frameworks, configuration, and unrelated refactors. If the
reviewed scope is insufficient, propose the smallest necessary expansion
and a simpler alternative, then wait for my decision before broader changes.
```

If you opened a new conversation, include the reviewed plan before this request. The local journal specification carries the detailed layout, accessibility, and output rules; `AGENTS.md` carries the repository boundaries.

Watch Copilot read the relevant files, edit the plotting code, and request command execution when the current permissions require it. Expand each request to check its purpose, working directory, affected files or destinations, and approval scope. If you cannot explain its consequences, choose **Skip** and ask for clarification; use the [permissions guide](../../reference/agent-control.md) for examples. Check completed command output as well as the final Chat summary.

Open the edited plotting file and the new PNG from Explorer. If Copilot heads off course, stop the action and give a focused correction such as “Keep the counts unchanged.” If a run fails, have it explain the reported error before changing the environment or task.

**Ready for the next step:** the workspace contains a proposed repair, a new PNG, and separate alt text. [Verify the current files](04-verify.md), even when Chat reports success.

---

[← Previous: 2. Specify](02-specify.md) · [Next: 4. Verify →](04-verify.md)
