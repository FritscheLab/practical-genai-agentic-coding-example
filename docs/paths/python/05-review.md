Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 5 of 6

# Look through the change

Use your editor's changed-file view, or run:

```bash
git diff
```

Find where the existing reasons reach the summary. Can you connect that code to the report you just read? Look for one excluded total and separate reason counts. Open any new files in your editor too.

Make sure the change explains exclusions without changing which rows are kept. If you spot a mistake, have it fixed and rerun the tests. Then [leave a short handoff](06-handoff.md).

## Optional: get a second reading

Ask a labmate or a fresh agent session:

```text
Review the Python exclusion-report change. Check it against the six rows in
data/example/exclusion_report/ehr.tsv and the no-exclusion example in
ehr_complete.tsv. Look for counting mistakes or changes to the original data
outputs. Explain any problem with a concrete example. Do not edit files.
```

The included [review skill](https://ilarsf.github.io/practical-genai-agentic-coding-guide/docs/platforms/portable-context.html) is another option for a larger review. You do not need a reviewer agent to finish this demo.

---

[← Previous: 4. Verify](04-verify.md) · [Next: 6. Hand off →](06-handoff.md)
