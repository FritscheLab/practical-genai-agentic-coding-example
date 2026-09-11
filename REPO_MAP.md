# Repository map

Start with [VS Code + GitHub Copilot setup](docs/setup/vscode-copilot.md), then follow [Python](docs/paths/python/index.md) or [R](docs/paths/r/index.md). Use Explorer for source files and charts, Copilot Chat for Ask/Plan/Agent, and Source Control for changed files, diffs, staging, and local commits.

## Plotting exercise

| File | Purpose |
| --- | --- |
| `plotting/plot_summary.py` | Python's fixed invented counts, plotting function, and output CLI. |
| `plotting/plot_summary.R` | The equivalent base-R plotting function and CLI. |
| `plotting/tests/` | Independent behavioral checks for both languages. |
| `requirements-plotting.txt` | Python plotting dependency. |
| `docs/setup/vscode-copilot.md` | VS Code, Git, Copilot, language environments, and the baseline. |
| `docs/appendix/command-line.md` | Complete optional Python/R terminal workflows and Copilot CLI guidance. |
| `docs/lessons/02-specify.md` | Plot repair brief and visual acceptance criteria. |
| `plotting/check_figure.py`, `plotting/check_figure.R` | Separate journal figure acceptance checks; the starter intentionally fails them. |
| `docs/reference/figure-specifications.md` | Fictional journal rules for dimensions, fonts, colors, and grouped layout. |
| `docs/reference/io_contract.md` | Categories, counts, commands, and output expectations. |
| `docs/reference/synthetic-data.md` | Why the aggregate counts are safe teaching examples. |
| `docs/reference/lab-data-policy.md` | Boundaries when taking the workflow to study code. |
| `docs/reference/agent-control.md` | Approval fatigue, permissions, sandbox limits, and maintaining independent coding skills. |
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

## Checks and generated files

Use the [Python verification lesson](docs/paths/python/04-verify.md) or [R verification lesson](docs/paths/r/04-verify.md). Its Agent prompt runs behavior tests and the separate figure checker against the current workspace. The [CLI appendix](docs/appendix/command-line.md) supplies exact terminal commands.

| Path | Where to inspect it |
| --- | --- |
| `runs/baseline/summary.png` | Explorer: preserve the starting chart for comparison. |
| `runs/with-fix/summary.png` | Explorer: inspect the repaired chart after the latest checks. |
| `runs/with-fix/summary.alt.txt` | Explorer: read the separately authored description and check every value. |
| Modified or new source files | Source Control: inspect each diff before staging and committing. |

The starter passes behavior tests and fails the figure checker. Inspect readability and accessibility yourself even after both pass. `runs/`, `tmp/`, environments, and caches are ignored by Git, so generated figures and alt text appear in Explorer but stay out of Source Control and source commits.
