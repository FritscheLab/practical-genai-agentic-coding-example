Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 4 of 6

# Run the tests and read the report

Run the existing tests and the same six rows with a fresh run ID:

```bash
python -m pytest
python -m ruff check .
python -m pgacg demo --ehr data/example/exclusion_report/ehr.tsv --demo data/example/exclusion_report/demographics.tsv --run_id with-report
```

Ruff checks code style and common coding mistakes.

Open `runs/with-report/summary.md`. Look for **3 of 6 excluded**, **missing height: 2**, and **missing weight: 2**. Does the explanation make it clear why those reason counts add up to four?

Now try the file with all six heights and weights filled in:

```bash
python -m pgacg demo --ehr data/example/exclusion_report/ehr_complete.tsv --demo data/example/exclusion_report/demographics.tsv --run_id complete-with-report
```

Open `runs/complete-with-report/summary.md`. It should clearly say **0 of 6 excluded**. Use another run ID if either folder already exists.

## Look back at the data

Open the cleaned and flagged TSVs in `runs/with-report/outputs/` beside the copies in `runs/baseline/outputs/`. You should still see a, b, c cleaned and d, e, f flagged with the same values and reasons. The new information belongs in the summary.

Check the actual test result. If a test or report differs from what you expected, show the agent the input and result, then ask it to explain and fix the discrepancy. Continue to [review the change](05-review.md).

## Optional: try more data

Run the original 1,074-row example to see more reasons:

```bash
python -m pgacg demo --ehr data/example/ehr_bmi_simulated_data.tsv --demo data/example/demographics_simulated_data.tsv --run_id larger-report
```

Compare the report with its flagged rows. An empty input is another optional reporting example.

---

[← Previous: 3. Implement](03-implement.md) · [Next: 5. Review →](05-review.md)
