# Data contract

Both paths follow this contract: `python -m pgacg demo` and `Rscript scripts/r/demo.R`. Use this page to understand what they read, how they choose a measurement for each person, and what their output files mean. These rules also give you an agreed reference when reviewing a code change.

The electronic health record (EHR) example uses synthetic data. Its fixed limits and category labels are simplified teaching choices applied to every record, including minors. They do not define a clinical cohort or implement the advanced adult BMI analysis described in Part 1.

## Inputs

Both inputs are UTF-8 tab-separated files (TSVs) with a header row. Identifiers and demographic fields are read as strings, preserving leading zeros such as ZIP prefix `012`. The reader removes surrounding whitespace and treats empty fields as missing. Extra columns are preserved; the generated dictionary covers the standard fields and derived columns described here.

### EHR BMI TSV

| Required column | Contract |
|---|---|
| `person_id` | Synthetic person identifier; repeated across encounters |
| `encounter_id` | Unique synthetic encounter identifier among nonempty values |
| `bmi` | Numeric BMI; may be missing |
| `height_cm` | Numeric height in centimeters; may be missing |
| `weight_kg` | Numeric weight in kilograms; may be missing |
| `measurement_date` | Consistently formatted, timezone-free ISO date (`YYYY-MM-DD`) or full timestamp (`YYYY-MM-DD HH:MM:SS`); generated data use the latter |

The run fails if a required column is absent or a nonempty encounter ID appears more than once. Individual rows with a missing person ID, encounter ID, or unparseable measurement date are excluded with the reason `missing_id_or_date`.

For inputs portable between languages, use one date format throughout each column, valid calendar dates, and ordinary clock fields (hours `00–23`, minutes and seconds `00–59`). Full timestamps may use `T` instead of a space and up to six fractional-second digits. The Python parser may accept additional date formats or normalize unusual clock values; those behaviors are outside the shared format contract. Normalize such inputs before comparing paths. The R path interprets timezone-free values in UTC internally to avoid local daylight-saving changes.

### Demographics TSV

| Required column | Contract |
|---|---|
| `person_id` | Unique, nonempty synthetic person identifier |
| `date_of_birth` | `YYYY-MM-DD`; missing or unparseable dates become missing |
| `age` | Age as supplied by the generator, in years; may be missing |
| `age_bin` | Age group as supplied by the generator; may be missing |
| `deceased` | Synthetic Yes/No value |
| `race_clean` | Synthetic race field; may be missing |
| `ethnicity_clean` | Synthetic ethnicity field; may be missing |
| `race_ethnicity` | Synthetic combined field; may be missing |
| `race_ethnicity_harmonized` | Synthetic grouped field; may be missing |
| `sex_gender` | Synthetic Male/Female value |
| `marital_status_name` | Synthetic marital status |
| `zip3` | Three-character synthetic ZIP prefix |

The demographics file must have one row per person. Missing columns, blank person IDs, and duplicate person IDs fail the run with `SchemaError`, which explains the problem. Other demographic values pass through unchanged: the pipeline does not validate their categories or recalculate `age` or `age_bin`. It computes `agedays_at_measurement` separately from the selected measurement date and birth date.

## Cleaning and record selection

The pipeline applies these steps in order:

1. Convert BMI, height, and weight to numbers. Values that cannot be converted become missing.
2. Flag missing height or weight as `missing_height` or `missing_weight`. Flag height outside **[100, 250] cm** and weight outside **[25, 300] kg** as `implausible_height` or `implausible_weight`; endpoints are included.
3. Compute `bmi_calc = weight_kg / (height_cm / 100)^2`, rounded to one decimal. Fill missing BMI from this value and mark `bmi_imputed`. This happens before exclusion, so flagged rows may also contain an imputed value.
4. Flag `bmi_mismatch` when the absolute difference between reported/imputed BMI and `bmi_calc` is **strictly greater than** `mismatch_threshold` (default **2.0**). Flag BMI outside **[10, 70]** as `implausible_bmi`.
5. Exclude rows with any of those reasons. For each person with **at least four remaining records**, calculate the interquartile range (IQR): the difference between the 75th percentile (Q3) and 25th percentile (Q1). Values below Q1 − 1.5 × IQR or above Q3 + 1.5 × IQR receive `per_person_iqr_outlier` and are excluded.
6. Select the remaining record nearest the person's median BMI. Break equal distances by the **latest measurement date**, then the **first encounter ID when sorted as text**. For example, `e10` sorts before `e2`. This selection is independent of input row order.
7. Add categories and join demographics, keeping one selected row per person. A selected EHR person absent from demographics is retained with missing demographic fields. A demographics person with no selected EHR record appears in `flagged_people.tsv`; this includes people with no EHR records at all.

The category labels use the boundaries below. In this notation, `[a,b)` includes `a` and excludes `b`.

| Measure | Categories |
|---|---|
| BMI | `<18.5` Underweight; `[18.5,25)` Normal; `[25,30)` Overweight; `[30,35)` Obesity I; `[35,40)` Obesity II; `>=40` Obesity III |
| Height (cm) | `<150` Short; `[150,180)` Average; `>=180` Tall |
| Weight (kg) | `<50` Light; `[50,80)` Medium; `[80,100)` Heavy; `>=100` Very Heavy |

An EHR file containing only the required header is valid, as is a file whose rows are all excluded. In either case, the cleaned file has a header but no data rows, and every demographics person appears in `flagged_people.tsv`. These inputs complete normally; an empty result is visible in the output counts.

## Outputs and counts

The starting summary includes counts and category distributions. In the [introductory exercise](../lessons/02-specify.md), you add a readable exclusion summary using the existing decisions.

Each run creates `runs/<run_id>/`. You can choose another parent directory with `--runs_dir`. An existing run directory causes an error, so earlier results remain available for comparison.

| Artifact | Contents |
|---|---|
| `outputs/cleaned_bmi_person.tsv` | At most one selected record per EHR person, derived categories, joined demographics, and age in days |
| `outputs/flagged_rows.tsv` | Excluded measurement rows after numeric conversion/imputation, with semicolon-separated `reasons` |
| `outputs/flagged_people.tsv` | Demographics person IDs with no selected record; reason `no_valid_rows_after_cleaning` |
| `outputs/cleaned_bmi_person_data_dictionary.md` | Standard cleaned-output fields and descriptions |
| `summary.md` | Status, parameters, counts, and category distributions, or an error explanation |
| `logs/pipeline.log` | Progress and diagnostic details for this invocation |
| `manifest.json` | Command, input/artifact hashes, parameters, code and environment metadata, status |

Every input measurement is either excluded or retained before representative selection:

`n_rows_input = n_rows_flagged_total + n_rows_kept_after_row_filters`

Reason counts can overlap. For example, `n_rows_bmi_mismatch` includes a row even if it also has an implausible height. Person counts need care too: `n_people_demo` counts the people listed in demographics, while `n_people_with_typical_record` counts people with a selected EHR record. These groups can differ when a person occurs in only one input file.

## CLI and failure behavior

`--ehr` and `--demo` are required paths. Optional flags are `--runs_dir`, `--run_id`, `--mismatch_threshold`, and `--verbose`. The mismatch threshold must be a finite number greater than or equal to zero. For direct function calls, Python's `CleaningParams` and R's `cleaning_params()` also check that limits are finite and nonnegative, each minimum is at most its maximum, and minimum height is greater than zero.

A run ID must start with an ASCII letter or digit and contain only ASCII letters, digits, `_`, `.`, or `-`. The default is a UTC timestamp plus a random suffix. Paths cannot be embedded in the ID.

The command's exit code tells a calling script whether it completed:

| Exit code | Meaning |
|---|---|
| **0** | Successful run |
| **1** | A schema, input, or pipeline error after the run started |
| **2** | Invalid command arguments or a problem creating the new run directory |

If a run has started, an error summary, log, and manifest are saved as long as the output directory remains writable. Read those files to diagnose the problem; any partial outputs belong to a failed run. Errors before a run starts, such as an existing run ID, cannot produce a new summary.

The reporting exercise keeps these exit codes unchanged. See [Logging and runs](https://ilarsf.github.io/practical-genai-agentic-coding-guide/docs/practices/logging_and_runs.html) for details of the manifest.

## Comparing languages

Both implementations use the same columns, reason tokens, category labels, effective cleaning parameters, and counts. TSV formatting can differ (for example, `True` versus `TRUE`, or a whole number written with a decimal suffix). Compare parsed values, not file hashes, across languages. The manifest records the actual interpreter and dependencies for the selected path; environment metadata and run timestamps will differ.

To compare both languages, run `python scripts/py/check_language_parity.py` after setting up both environments. It compares the included example and small synthetic edge cases. Each path also has its own tests with independently specified expected answers, because matching implementations can share a mistake.
