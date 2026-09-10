Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 1 of 6

# Find the reasons already in the output

Open `runs/baseline/outputs/flagged_rows.tsv` from [Python setup](index.md). Find **d, e, and f** in the `encounter_id` column and read their `reasons`.

A **measurement** is one input row. A **person** may have several measurements, but this example has one per person. Row f is one excluded measurement with two reasons.

Find `src/pgacg/cli.py` and `src/pgacg/reporting.py`. The first runs the pipeline; the second writes the summary. Your change will bring the existing flags into that report.

Open the repository in your coding client. Follow the [client setup page](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/index.html) if needed, and check that it can read `AGENTS.md`, edit this workspace, and run commands.

## Ask the agent to explain the starting code

```text
I am following the Python demo. Read AGENTS.md and REPO_MAP.md.
Find where the pipeline records exclusion reasons and writes summary.md.
Use row f in data/example/exclusion_report/ehr.tsv to explain why one
measurement can have two reasons. Point to the files you read; do not edit yet.
```

Compare its explanation with the flagged file, then continue to [the six-row example](02-specify.md). The [folder map](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/portable-context.html) explains client instructions, settings, and skills if you want to explore those next.

---

[← Previous: Setup](index.md) · [Next: 2. Specify →](02-specify.md)
