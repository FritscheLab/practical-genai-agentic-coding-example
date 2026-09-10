# Repository map

Start with `README.md`, then follow your chosen language through `docs/paths/python/` or `docs/paths/r/`.

## Plotting exercise

| File | Purpose |
| --- | --- |
| `plotting/plot_summary.py` | Python's fixed invented counts, plotting function, and output CLI. |
| `plotting/plot_summary.R` | The equivalent base-R plotting function and CLI. |
| `plotting/tests/` | Independent behavioral checks for both languages. |
| `requirements-plotting.txt` | Python plotting dependency. |
| `docs/lessons/02-specify.md` | Plot repair brief and visual acceptance criteria. |
| `plotting/check_figure.py`, `plotting/check_figure.R` | Separate journal figure acceptance checks; the starter intentionally fails them. |
| `docs/reference/figure-specifications.md` | Fictional journal rules for dimensions, fonts, colors, and grouped layout. |
| `docs/reference/io_contract.md` | Categories, counts, commands, and output expectations. |
| `docs/reference/synthetic-data.md` | Why the aggregate counts are safe teaching examples. |
| `docs/reference/lab-data-policy.md` | Boundaries when taking the workflow to study code. |
| `examples/r_refactor/` | Optional compact R starter, formatted reference, and behavior verifier. |

## Reusable instructions

- `AGENTS.md`: code, chart, test, and data boundaries.
- `.agents/skills/plot-review/SKILL.md`: review plotting code and test evidence.
- `.codex/agents/plot-reviewer.toml`: optional named reviewer.
- `.agents/skills/lab-r-refactor/SKILL.md`: R formatting procedure.
- `.agents/skills/lab-r-refactor/references/lab-r-template.md`: local R header and section examples.
- `.codex/agents/r-refactorer.toml`: optional R refactoring role; model and permissions inherit.
- `.codex/config.toml`: shared Codex defaults; actual access depends on the session.
- `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`: client pointers to the common instructions.

## Checks from this repository root

```bash
python -m unittest discover -s plotting/tests
```

```bash
Rscript plotting/tests/run_tests.R
```

Use your language path to render baseline and repaired images. Passing checks confirms tested behavior; inspect the image separately for readable labels and layout. Keep `runs/`, `tmp/`, environments, and caches out of Git.
