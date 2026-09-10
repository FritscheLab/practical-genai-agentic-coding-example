# Practical GenAI Agentic Coding Example

**Fix a plotting function and see the improvement.** Start with a chart whose groups overlap and long labels are clipped. Use a short request, a local journal brief, and checks you can inspect.

This is the runnable exercise for [Part 2 of the Fritsche Lab Practical GenAI series](https://fritschelab.org/practical-genai-agentic-coding-guide/), by [Lars G. Fritsche](https://medschool.umich.edu/profile/4980/lars-fritsche) and the [Fritsche Lab](https://fritschelab.org/) at the University of Michigan. [Part 1](https://fritschelab.org/practical-genai-coding-guide/) introduces planning, context, and checking an assistant's work. Accessibility belongs in the brief and review: consider contrast, legibility, and alternative text whenever creating something others will use.

## Choose your path

| Path | Requirements | Follow online | Follow here |
| --- | --- | --- | --- |
| Python | Python 3.10–3.12, Git, and Matplotlib | [Python walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/python/) | [Python setup and six lessons](docs/paths/python/index.md) |
| R | R 4.1 or later and Git; no extra R packages | [R walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/r/) | [R setup and six lessons](docs/paths/r/index.md) |

Install only your chosen language. Its setup page gives the commands to create the starting chart. Both paths follow the same six stages: orient, specify, implement, verify, review, and hand off.

## What the agent works with

**Code, tests, and a chart of invented aggregate counts.** No participant records or data-file inputs are involved. Use an approved client and keep study data outside its workspace. [Lab data guidance](docs/reference/lab-data-policy.md).

## Find what you need

- [Plot repair brief](docs/lessons/02-specify.md): the visible problem and acceptance criteria.
- [Plotting contract](docs/reference/io_contract.md): fixed counts, command interface, and output expectations.
- [Journal specifications for figures](docs/reference/figure-specifications.md): the fictional journal's precise layout, styling, accessibility, and alternative-text requirements.
- [Repository map](REPO_MAP.md): files, tests, and commands.
- [AGENTS.md](AGENTS.md): focused instructions for your coding agent.
- [Invented summary counts](docs/reference/synthetic-data.md): what the chart represents.
- [Templates](docs/templates/index.md): optional briefs, contracts, and handoffs.
- [Optional R refactoring skill](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/platforms/r-refactoring.html): reuse a local lab template and named agent to organize R code.

Images go under `runs/`; scratch work goes under `tmp/`. Both stay out of commits. The guide and templates build on Part 1. See [CITATION.cff](CITATION.cff) and [LICENSE](LICENSE).
