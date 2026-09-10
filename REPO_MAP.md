# Repository map

Start with `README.md`, then stay on your chosen language path. The [online guide](https://ilarsf.github.io/practical-genai-agentic-coding-guide/) provides the same walkthroughs plus client setup and further explanations.

## Exercise instructions

| Path | Purpose |
| --- | --- |
| `docs/paths/python/`, `docs/paths/r/` | Setup and six lessons from the starting run through a short handoff. |
| `docs/lessons/02-specify.md` | Six measurements and the expected reporting change. |
| `docs/reference/io_contract.md` | Input schemas, existing behavior, and output meanings. |
| `docs/reference/synthetic-data.md` | Small fixtures and larger simulated example. |
| `docs/reference/lab-data-policy.md` | Synthetic-data boundaries and study adaptation. |
| `data/example/exclusion_report/` | Six-row missing-data and complete-data fixtures. |
| `docs/templates/` | Optional task brief, data contract, and handoff templates. |

## Pipeline

| File | Responsibility |
| --- | --- |
| `src/pgacg/__main__.py`, `src/pgacg/cli.py` | `python -m pgacg demo`, argument handling, and run lifecycle. |
| `src/pgacg/io.py` | TSV reading and schema validation. |
| `src/pgacg/cleaning.py` | Filtering, representative selection, categories, and metrics. |
| `src/pgacg/reporting.py`, `src/pgacg/run_utils.py` | Summary, dictionary, logging, and provenance. |
| `R/io.R`, `R/cleaning.R` | R schema validation, filtering, selection, categories, and metrics. |
| `R/cli.R`, `R/reporting.R`, `R/run_utils.R` | R CLI, reports, logging, and provenance. |
| `scripts/r/demo.R` | R command-line entrypoint. |
| `scripts/r/install_dependencies.R` | Explicit installation of R dependencies (`jsonlite`, `digest`). |
| `tests/test_*.py`, `tests/r/run_tests.R` | Independent synthetic cases and complete CLI checks. |
| `scripts/py/check_language_parity.py` | Optional comparison of parsed outputs and counts across both languages. |
| `scripts/r/simulate_ehr_data.R`, `scripts/py/check_example_data.py` | Optional larger-fixture generation and checksum verification. |

## Agent instructions

- `AGENTS.md`: task scope, synthetic-data rules, verification, and handoff.
- `.agents/skills/pipeline-review/SKILL.md`: optional review procedure.
- `.codex/config.toml`: shared Codex settings; effective permissions also depend on your client configuration.
- `.codex/agents/pipeline-reviewer.toml`: optional reviewer definition.
- `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`: pointers to the shared instructions.

## Checks from the repository root

After completing setup, run the checks for your chosen language. Python:

```bash
python -m pytest
python -m ruff check .
```

R:

```bash
Rscript tests/r/run_tests.R
```

Then follow Lesson 4 in your language path to run both six-row fixtures, read the reports, and compare the data with your saved baseline.

`runs/`, `tmp/`, `.venv/`, `data/raw/`, `data/derived/`, and caches are generated. Keep them out of commits.
