Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 3 of 6

# Ask the agent to add the report

Copy this prompt into your [coding client](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/index.html) with the repository open and editing enabled:

```text
Add a readable exclusion section to summary.md in the Python pipeline.
Read AGENTS.md, REPO_MAP.md, src/pgacg/cli.py, and src/pgacg/reporting.py first.

Use the existing flagged rows to show how many input measurements were excluded
and how many had each observed reason. Explain that one measurement can have
several reasons, so the reason counts can exceed the excluded total.

For data/example/exclusion_report/ehr.tsv, show 3 of 6 excluded, with missing
height on 2 and missing weight on 2. For ehr_complete.tsv in the same folder,
show 0 of 6 excluded with a clear no-exclusion message. Both use demographics.tsv
from that folder.

Keep the existing cleaning rules, data outputs, command behavior, and dependencies.
Work in the Python implementation.
Run python -m pytest and show me the changed files and results.
```

Watch the agent read the code, edit it, and run the tests. If a command fails, read the error and let it investigate. If it starts changing cleaning rules or adding packages, bring it back to the report.

When it finishes, [run the example and read the new summary](04-verify.md).

## Optional: practice testing

Ask the agent to add a small report test for the overlapping reasons or the no-exclusion example. Read its expected answer alongside the six rows; the input should explain the answer.

---

[← Previous: 2. Specify](02-specify.md) · [Next: 4. Verify →](04-verify.md)
