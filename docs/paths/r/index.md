R path · [Change language](../python/index.md)

# Start the R demo

A labmate runs the pipeline with six measurements and finds only three in the cleaned output. **Add a short report that explains why.** Follow along during the presentation or work through it at home.

The example keeps **a, b, c**. It excludes **d** for missing height, **e** for missing weight, and **f** for both. Your report will show **3 of 6 excluded**, with **2 missing height** and **2 missing weight**. The pipeline already records these reasons.

Use the included synthetic files and an approved coding client. See the [lab data guidance](../../reference/lab-data-policy.md) before adapting this to study data.

## Set up

You need Git and a terminal. If you already have the exercise repository, open a terminal in its root. Otherwise, clone it first:

```bash
git clone https://github.com/FritscheLab/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

You need R 4.1 or later. Install the two packages used by the pipeline:

```bash
Rscript scripts/r/install_dependencies.R
Rscript tests/r/run_tests.R
```

This adds missing `jsonlite` and `digest` packages. You can use RStudio's terminal for these commands.

Some tests deliberately use invalid inputs and print error messages. Look for the final `All ... R checks passed.` summary and a successful exit (status `0`); an earlier error message alone does not mean the tests failed.

## Run the six-row example

```bash
Rscript scripts/r/demo.R --ehr data/example/exclusion_report/ehr.tsv --demo data/example/exclusion_report/demographics.tsv --run_id baseline
```

Open `runs/baseline/summary.md`, then these files under `runs/baseline/outputs/`:

| File | What you will see |
| --- | --- |
| `cleaned_bmi_person.tsv` | Measurements a, b, c. |
| `flagged_rows.tsv` | Measurements d, e, f and their reasons. |

The summary has overall counts but lacks a readable reason breakdown. Keep this run folder so you can look back at it after the change. If `baseline` already exists, choose another `--run_id`.

## Follow the demo

Follow one change from understanding the repository through implementation, verification, review, and a short handoff.

| Step | What to do |
| --- | --- |
| [1. Orient](01-orient.md) | Find the existing reasons and open your agent. |
| [2. Specify](02-specify.md) | See all six rows and the report you want. |
| [3. Implement](03-implement.md) | Copy the prompt and ask for the report. |
| [4. Verify](04-verify.md) | Run the existing tests and read the result. |
| [5. Review](05-review.md) | Look through the changed code. |
| [6. Hand off](06-handoff.md) | Leave a three-sentence handoff. |

You can make the same edit manually without an assistant. For setup problems, check your working directory and language environment, then see [pipeline troubleshooting](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/runbooks/demo_pipeline.html#troubleshooting).

---

**Next:** [1. Orient](01-orient.md)
