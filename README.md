# Practical GenAI Agentic Coding Example

**Make and verify one reporting change in a synthetic BMI pipeline.** Choose Python or R, run six measurements, ask your coding agent to explain the exclusions, check the result, and leave a short handoff.

This is the runnable exercise for [Part 2 of the Fritsche Lab Practical GenAI series](https://fritschelab.org/practical-genai-agentic-coding-guide/), by [Lars G. Fritsche](https://medschool.umich.edu/profile/4980/lars-fritsche) and the [Fritsche Lab](https://fritschelab.org/) at the University of Michigan. [Part 1](https://fritschelab.org/practical-genai-coding-guide/) introduces planning, context, and checking an assistant's work.

## Choose your path

You should be comfortable running a script and using a terminal. Install only your chosen language. Both paths use the same synthetic files and reporting task.

| Path | Requirements | Follow online | Follow in this repository |
| --- | --- | --- | --- |
| Python | Python 3.10–3.12 and Git | [Python walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/python/) | [Python setup and six lessons](docs/paths/python/index.md) |
| R | R 4.1 or later and Git | [R walkthrough](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/paths/r/) | [R setup and six lessons](docs/paths/r/index.md) |

The setup page gives the clone command, installs the required packages, and runs the starting example. You only need this exercise repository to run the code. The online and local walkthroughs have the same steps; choose whichever is easier to follow. The [online guide](https://fritschelab.org/practical-genai-agentic-coding-guide/) also has client setup, explanations, and workshop material.

Use an institution-approved coding assistant for the agent exercise; the pipeline itself needs no model API or credentials. You can also make the change manually. Keep files, prompts, logs, and screenshots synthetic. Read the [lab data guidance](docs/reference/lab-data-policy.md) before adapting this workflow to study data.

## Find what you need

- [Exercise specification](docs/lessons/02-specify.md): all six measurements and the four observable results.
- [Data contract](docs/reference/io_contract.md): inputs, cleaning rules, and output meanings.
- [Repository map](REPO_MAP.md): code, tests, and commands.
- [AGENTS.md](AGENTS.md): focused instructions for your coding agent.
- [Templates](docs/templates/index.md): optional task briefs, data contracts, and handoffs.
- [Synthetic data](docs/reference/synthetic-data.md): fixture details and the optional larger example.

Runs are saved under `runs/`; environments, caches, and run outputs stay out of commits. The pipeline's rules are teaching specifications, not clinical recommendations.

The simulator and templates build on Part 1. See [CITATION.cff](CITATION.cff) for citation and [LICENSE](LICENSE) for the GNU General Public License v3.0.
