# Practical GenAI Agentic Coding Example

**Fix a plotting function and see the improvement.** Start with a chart whose groups overlap and long labels are clipped. Use VS Code + GitHub Copilot to discuss the repair in Chat, inspect charts in Explorer, and review color-coded code changes in Source Control.

This is the runnable exercise for [Part 2 of the Fritsche Lab Practical GenAI series](https://fritschelab.org/practical-genai-agentic-coding-guide/), by [Lars G. Fritsche](https://medschool.umich.edu/profile/4980/lars-fritsche) and the [Fritsche Lab](https://fritschelab.org/) at the University of Michigan. [Part 1](https://fritschelab.org/practical-genai-coding-guide/) introduces planning, context, and checking an assistant's work. Accessibility belongs in the brief and review: consider contrast, legibility, and alternative text whenever creating something others will use.

**Practising what we teach:** this guide and exercise were developed with substantial AI assistance in writing, coding, testing, and review. They are provided **as is, without warranty**, to the extent permitted by applicable law. Review the code, agent instructions, permissions, and results before use. Read the [AI-assistance disclosure, use guidance, and warranty notice](docs/reference/agent-control.md#about-ai-assistance-in-this-guide).

## Choose your path

Start with the [detailed VS Code + GitHub Copilot setup](docs/setup/vscode-copilot.md). It covers Windows, macOS, Git installation, Copilot access, cloning, and the **Ask / Plan / Agent** controls. VS Code includes Git controls and uses a separately installed Git program.

| Path | Requirements | Follow online | Follow here |
| --- | --- | --- | --- |
| Python | Python 3.10–3.12, Git, and Matplotlib | [Python walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/python/) | [Python setup and six lessons](docs/paths/python/index.md) |
| R | R 4.1 or later and Git; no extra R packages | [R walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/r/) | [R setup and six lessons](docs/paths/r/index.md) |

Install only your chosen language. Have Copilot prepare it and run the starting code, then inspect the result yourself. Both paths follow six stages: **Ask** to orient, **Plan** the repair, **Agent** to implement and verify, then **Source Control** to review diffs, stage source files, and commit locally.

Prefer a terminal? The [CLI appendix](docs/appendix/command-line.md) keeps complete Python and R setup, rendering, checking, and Git commands, plus optional Copilot CLI guidance.

Read [permissions and independent work](docs/reference/agent-control.md) before approving agent actions. Keep repairs small enough to understand and practise without AI too: working output does not establish that you can maintain the code if access becomes unavailable or prohibited.

## What the agent works with

**Code, tests, and a chart of invented aggregate counts.** No participant records or data-file inputs are involved. Use an approved client and keep study data outside its workspace. [Lab data guidance](docs/reference/lab-data-policy.md).

## Find what you need

- [Plot repair brief](docs/lessons/02-specify.md): the visible problem and acceptance criteria.
- [Plotting contract](docs/reference/io_contract.md): fixed counts, command interface, and output expectations.
- [Journal specifications for figures](docs/reference/figure-specifications.md): the fictional journal's precise layout, styling, accessibility, and alternative-text requirements.
- [Repository map](REPO_MAP.md): source files, tests, outputs, and instructions.
- [AGENTS.md](AGENTS.md): focused instructions for your coding agent.
- [Invented summary counts](docs/reference/synthetic-data.md): what the chart represents.
- [Templates](docs/templates/index.md): optional briefs, contracts, and handoffs.
- [Optional R refactoring skill](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/r-refactoring.html): reuse a local lab template and named agent to organize R code.

Images go under `runs/`; scratch work goes under `tmp/`. Both stay out of commits. The guide and templates build on Part 1. See [CITATION.cff](CITATION.cff) and [LICENSE](LICENSE).
