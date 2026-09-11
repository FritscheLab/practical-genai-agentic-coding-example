Python path · [Change language](../r/index.md)

# Fix a plot in Python

Overlapping bars. Clipped labels. A very particular fictional journal. **Use VS Code and GitHub Copilot to turn this chart into a readable figure.** You will ask questions in Chat, inspect images in Explorer, and review code changes in Source Control.

The source contains invented aggregate counts for two groups, with no participant records or data-file inputs. Keep study data outside this workspace. [Data guidance](../../reference/lab-data-policy.md).

## Set up in VS Code

1. Follow the [VS Code + GitHub Copilot setup](../../setup/vscode-copilot.md), including cloning the example through Source Control. You need VS Code, Git, Copilot access, and Python 3.10–3.12 and Matplotlib in a workspace `.venv`.
2. Complete the [Python environment and baseline steps](../../setup/vscode-copilot.md#python). In Chat, use the **Local** session target and **Agent** role to prepare the environment, run the existing behavior tests, and save the starting chart. Read the expanded command output before continuing.
3. In **Explorer**, expand `runs`, then `baseline`, and open `summary.png`. Find the overlapping bars and clipped category labels. Keep this image for comparison.
4. Open **Source Control**. Setup should leave **Changes** and **Staged Changes** empty: the generated chart and local environment are ignored by Git. If tracked files changed, review them and ask Copilot to explain before beginning the repair.

**Passing tests does not guarantee a readable chart.** The starter passes behavior checks and fails the separate journal figure checker. The repair should eventually pass both.

Already prepared the environment but missing the chart? Select **Agent** and paste:

```text
Use the existing Python environment for this repository. Run the existing
Python plotting behavior tests and render plotting/plot_summary.py to
runs/baseline/summary.png. Preserve any baseline already there; if it exists,
report its path instead of overwriting it. Do not edit tracked source files,
tests, specifications, or dependencies. Report the actual commands, results,
and output path. Keep the deliberately overlapping and clipped chart.
```

Prefer the Claude Code extension in VS Code? Use the [Claude setup and mode translation](../../setup/vscode-copilot.md#prefer-claude-code), then follow these same lessons and Source Control steps.

For environment or Chat-control problems, use [setup troubleshooting](../../setup/vscode-copilot.md#troubleshooting). If you prefer typing commands, follow the [complete Python CLI appendix](../../appendix/command-line.md#python).

## Follow the six lessons

| Step | Surface and action |
| --- | --- |
| [1. Orient](01-orient.md) | **Ask**: locate the plotting function and compare code with the baseline. |
| [2. Specify](02-specify.md) | **Plan**: propose a repair against the journal specification. |
| [3. Implement](03-implement.md) | **Agent**: carry out the reviewed plan. |
| [4. Verify](04-verify.md) | **Agent**: rerun checks; you inspect the chart and alternative text. |
| [5. Review](05-review.md) | **Source Control**: inspect changed files and color-coded diffs. |
| [6. Hand off](06-handoff.md) | **Source Control**: stage reviewed source, commit locally, and record results. |

---

[Next: 1. Orient →](01-orient.md)
