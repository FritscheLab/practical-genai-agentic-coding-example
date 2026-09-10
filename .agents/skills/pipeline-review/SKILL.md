---
name: pipeline-review
description: Review changes to this synthetic BMI pipeline against its documented data contract and independent test cases. Use for a requested pipeline review, not general prose edits or unrelated repositories.
---

Resolve all repository-relative paths below from the project root containing `AGENTS.md`.

Read the applicable repository instructions, `docs/reference/io_contract.md`, the requested diff, and the relevant tests. The method is a teaching specification; do not invent a clinical interpretation or replace the agreed thresholds.

Trace changed behavior from inputs to selected encounters, flags, run status, and recorded artifacts. Useful failure cases include repeated demographics keys, tied measurements, missing values, equality at thresholds, and a run that fails after initialization. Use only the cases relevant to the requested change.

For the workshop exclusion report, read `docs/lessons/02-specify.md` and compare the report with the six-row example. There are three excluded measurements, with missing height on two and missing weight on two. Check that the report explains the overlap and summarizes all actual reasons. Usable measurements not chosen as a person's representative are not exclusions. Preserve existing cleaning and CLI behavior.

Identify the selected language from the task and changed files: Python uses `src/pgacg/`, and R uses `R/` with `scripts/r/demo.R`. When execution is available and within scope, run relevant tests (`python -m pytest` or `Rscript tests/r/run_tests.R`) and inspect the small-example reports. Review the meaning and counts rather than prescribing function names or report wording. If tools are restricted to reading, inspect supplied evidence and identify checks as unrun. Never claim agreement with another agent or the other language's implementation establishes scientific validity.

Return concrete findings with a file location, a small synthetic reproducing case, expected behavior, actual behavior, and impact. Separate observed defects from uncertainties and optional improvements. Do not edit files as part of a review unless the user requests fixes.
