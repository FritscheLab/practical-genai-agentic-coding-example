# Help a labmate understand missing measurements

A labmate runs the pipeline on six measurements and finds only three in the cleaned output. The excluded records are saved in another file, but the summary does not explain the reasons. They ask: **“Which measurements did we exclude, and why?”**

Your task is to add a short exclusion report to `summary.md`. The pipeline already decides which measurements to exclude. You will make those decisions easier to see.

Follow [Python Lesson 2](../paths/python/02-specify.md) or [R Lesson 2](../paths/r/02-specify.md) for your path's brief and next step. Both paths use the six-row example below.

## Start with six rows you can inspect

The synthetic files are in `data/example/exclusion_report/`. Each person has one measurement. Dates are valid; empty TSV cells mean missing data.

| Measurement | Person | BMI | Height (cm) | Weight (kg) | What the existing pipeline does |
| --- | --- | ---: | ---: | ---: | --- |
| a | p1 | 24.2 | 170 | 70 | Keeps it |
| b | p2 | 22.9 | 175 | 70 | Keeps it |
| c | p3 | 25.0 | 180 | 81 | Keeps it |
| d | p4 | 24.2 | Missing | 70 | Excludes it: missing height |
| e | p5 | 24.2 | 170 | Missing | Excludes it: missing weight |
| f | p6 | 24.2 | Missing | Missing | Excludes it: both values missing |

Open `ehr.tsv` and the baseline run's `outputs/flagged_rows.tsv`. Find measurements **d, e, and f** yourself.

## Describe the improvement

The baseline summary exposes technical counts:

```text
n_rows_input: 6
n_rows_flagged_total: 3
```

An improved summary could show:

```text
Measurement exclusions

3 of 6 input measurements were excluded.

Reason             Measurements
Missing height                2
Missing weight                2

A measurement can have more than one reason.
These reason counts overlap; they are not four different measurements.
See outputs/flagged_rows.tsv for the individual records.
```

Measurement **f** appears in both reason counts. It is still only one of the three excluded measurements. The report should summarize every reason present in the flagged records when run on other inputs too.

## What to look for

1. With `ehr.tsv`, the report says **3 of 6 measurements were excluded** and gives the two reason counts: **2 missing height, 2 missing weight**.
2. It explains that reason counts overlap, so a reader will not add them to get the number of excluded measurements.
3. With `ehr_complete.tsv`, which fills in the three rows' missing values, it clearly reports **no exclusions out of 6 measurements**.
4. The selected and excluded records are the same as before the change, and the existing pipeline tests still pass.

Headings, wording, table layout, and function names may differ. Check the meaning and counts.

## Write the request

Use the [Python Lesson 3 prompt](../paths/python/03-implement.md) or [R Lesson 3 prompt](../paths/r/03-implement.md) to ask the agent to inspect the code, make the reporting change, and run the existing tests. Keep the existing cleaning rules, command options, data tables, and run status.

The Lesson 1 explanation is enough to proceed once you understand why f counts as one excluded measurement with two reasons. If the counting approach is still unclear, ask the agent to explain its plan before editing. A [task brief](../templates/task-brief.md) and documentation updates are optional follow-ups to this short exercise.

## Optional next checks

Try the larger simulated dataset after the small example works. Summarize all reasons present in `flagged_rows.tsv`. A usable measurement not chosen as a person's representative is not an exclusion.

For an empty input, the report should say there were no input measurements.
