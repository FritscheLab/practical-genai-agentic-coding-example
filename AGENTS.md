# AGENTS.md

Help the learner make and verify one reporting change in the synthetic BMI pipeline.

## Start with the learner's path

Read `README.md` and `REPO_MAP.md`, then follow `docs/paths/python/` or `docs/paths/r/` for the language the learner selected. Read relevant files before editing and use `rg` to locate code. When asked for an explanation without edits, inspect and explain before proceeding.

## Keep the exercise focused

- Work in the selected language: `src/pgacg/` for Python, or `R/` and `scripts/r/` for R.
- Use the existing flagged rows to build the exclusion report. Preserve cleaning rules, selected records, data tables, CLI behavior, and dependencies.
- Treat each input row as one measurement. A flagged measurement can have several reasons; count it once in the excluded total and once under each applicable reason.
- Keep functions small and testable, with I/O in CLI/reporting layers. Use type hints and `pathlib.Path` in Python; keep R functions sourceable and use `file.path()`.
- Preserve unrelated work. If another agent is working in parallel, agree on separate file ownership.
- Ask when the request leaves a scientific method, public schema, CLI behavior, or access decision unresolved. Explain a plan when the approach is unclear or the work is substantial.

## Use synthetic data

Use only the included synthetic fixtures or small synthetic cases. Never add real patient or participant records, PHI, PII, or credentials to files or agent context. These simplified pipeline rules are teaching specifications, not clinical recommendations.

Outputs, logs, paths, and screenshots can disclose information. This pipeline does not de-identify data or redact saved paths and errors. See `docs/reference/lab-data-policy.md` before adapting the workflow to study data.

`runs/`, `tmp/`, `data/raw/`, `data/derived/`, `.venv/`, and caches are generated. Keep them out of commits. Ignore rules and instruction files do not grant access; follow the client's effective permissions. Keep credentials and personal client settings out of the repository.

## Verify the change

Run the selected language's checks. Python:

```bash
python -m pytest
python -m ruff check .
```

R:

```bash
Rscript tests/r/run_tests.R
```

Use Lesson 4's commands for both six-row fixtures. Compare the summaries with `docs/lessons/02-specify.md`: 3 of 6 excluded with missing height on 2 and missing weight on 2, an overlap explanation, and 0 of 6 excluded for complete data. Compare the cleaned and flagged outputs with the saved baseline. The larger demo, extra report tests, and documentation updates are optional follow-ups.

Review the actual diff and open new files too. For a requested pipeline review, use `.agents/skills/pipeline-review/SKILL.md`; it is optional for the learner's own review. The data contract is `docs/reference/io_contract.md`.

Finish with a short handoff: what changed, commands actually run and their results, and anything unfinished or untested. Passing tests or agreement between agents does not establish scientific validity. Do not publish, deploy, or modify external services without authorization.
