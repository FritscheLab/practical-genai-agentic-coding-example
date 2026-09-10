R path · [All steps](index.md) · [Change language](../python/index.md)

Lesson 2 of 6

# Show the report you want

Here are all six measurements in `data/example/exclusion_report/ehr.tsv`. The IDs are synthetic. “Missing” is an empty TSV field; every measurement date is `2020-01-01`.

| Measurement | Person | BMI | Height (cm) | Weight (kg) | Existing result |
| --- | --- | ---: | ---: | ---: | --- |
| a | p1 | 24.2 | 170 | 70 | Kept |
| b | p2 | 22.9 | 175 | 70 | Kept |
| c | p3 | 25.0 | 180 | 81 | Kept |
| d | p4 | 24.2 | missing | 70 | Missing height |
| e | p5 | 24.2 | 170 | missing | Missing weight |
| f | p6 | 24.2 | missing | missing | Missing height and weight |

The current summary gives overall counts. Add something like this:

> 3 of 6 input measurements were excluded. Missing height: 2. Missing weight: 2. A measurement can have more than one reason, so the reason counts can add up to more than the excluded total.

Row **f** appears under both reasons. That is why four reason counts describe three excluded measurements. Use the existing flags so the report can also describe other exclusion reasons in other inputs.

## What to look for

- `ehr.tsv`: **3 of 6 excluded**, with **2 missing height** and **2 missing weight**.
- A short explanation that the reason counts overlap.
- `ehr_complete.tsv`: **0 of 6 excluded**, with a clear no-exclusion message. This file fills d, e, and f with height 170 and weight 70.
- The cleaned and flagged data stay the same; this change makes the summary easier to read.

Choose any clear wording or layout. Continue to [the implementation prompt](03-implement.md). The [shared example](../../lessons/02-specify.md) has more detail.

## Optional: practice writing a brief or plan

For a larger task, a [short brief](../../templates/task-brief.md) can help you keep the request clear. Try asking the agent to explain its proposed changes before allowing edits. Check that its plan uses the existing flags and treats f as one measurement with two reasons.

---

**Previous:** [1. Orient](01-orient.md) · **Next:** [3. Implement](03-implement.md)
