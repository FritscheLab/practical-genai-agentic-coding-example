# CLI appendix

Prefer a terminal? Use the complete section for [Python](#python) or [R](#r). The default [VS Code + GitHub Copilot setup](../setup/vscode-copilot.md) covers the graphical route. Both routes use the same [repair brief](../lessons/02-specify.md), [journal specification](../reference/figure-specifications.md), and six lessons.

Run shell commands in a terminal from the **example repository root**, the folder containing `README.md` and `plotting/`. You can use VS Code's integrated terminal or RStudio's **Terminal** tab; these commands do not belong in a Python prompt or the R console. Paste `text` prompts into your coding assistant. You can use [Copilot CLI](#copilot-cli) or another approved client.

Install Git and only your chosen language. Keep study data outside this workspace; the example contains invented aggregate constants. [Lab data guidance](../reference/lab-data-policy.md).

Read [permissions, sandboxing, and independent work](../reference/agent-control.md) before granting execution access. These commands also let you run and review the exercise without an AI service. Keep practising that independent workflow; broad auto-approval or bypass flags are unnecessary for this exercise.

## Python

You need **Python 3.10–3.12**, Git, and Matplotlib. Use a shell on macOS/Linux or PowerShell on Windows.

### 1. Clone and prepare the environment

If you do not already have the example, run:

```bash
git clone https://github.com/FritscheLab/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

If it is already cloned, open a terminal in that folder instead. Confirm the interpreter version before creating the environment:

```bash
python --version
```

If your system calls the supported interpreter `python3`, use `python3` here and when creating the environment below. If it reports a version outside 3.10–3.12, select an installed supported interpreter before continuing.

If this exercise already has a working `.venv`, keep it and continue to activation. Otherwise create it with the supported interpreter:

```bash
python -m venv .venv
```

Activate the environment on macOS/Linux:

```bash
source .venv/bin/activate
```

Or in Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, use `.venv\Scripts\python.exe` in place of `python` in every subsequent Python command; no activation-policy change is required. On macOS/Linux the equivalent direct executable is `.venv/bin/python`.

Install the existing dependency and check the selected interpreter:

```bash
python -m pip install -r requirements-plotting.txt
python -c "import sys; print(sys.executable)"
python -m unittest discover -s plotting/tests
```

The executable path should point into this repository's `.venv`. The behavior tests should finish with `OK`. If installation fails, read the first error and resolve the interpreter, package-index, or network problem before changing dependencies.

### 2. Save the baseline

Before running the next command, check whether `runs/baseline/summary.png` already exists. Keep an existing baseline; use a different output path if you need another starting image.

```bash
python plotting/plot_summary.py --output runs/baseline/summary.png
git status --short
```

Open `runs/baseline/summary.png` in an image viewer. It should show overlapping groups and clipped category labels. Keep it for comparison. The plotting command creates the parent directory and normally produces no console output. Setup should leave Git's status empty because the environment, caches, and `runs/` are ignored.

You can confirm the intentionally unfinished figure fails the separate journal checker:

```bash
python plotting/check_figure.py --output runs/baseline/figure-check.png
```

Expect `FAIL:` messages and a nonzero exit status. This is the teaching baseline; do not change tests or the specification to remove the failures.

### 3. Orient, plan, and implement

Use the prompts in [1. Orient](../paths/python/01-orient.md), [2. Specify](../paths/python/02-specify.md), and [3. Implement](../paths/python/03-implement.md) in your coding assistant. Their VS Code selector instructions apply only to the IDE; choose your CLI client's corresponding planning and execution controls. [Copilot CLI guidance](#copilot-cli) appears below.

First understand `make_summary_figure()` in `plotting/plot_summary.py`. Review a short plan against `docs/reference/figure-specifications.md`, then request the repair. Preserve all eight counts, group assignments, category order, command behavior, and dependencies. Have the assistant save the repaired PNG and separately author `runs/with-fix/summary.alt.txt`; the plotting program still writes only the PNG.

### 4. Verify the current repair

Run both checks after the final edit, even if the first one fails:

```bash
python -m unittest discover -s plotting/tests
python plotting/check_figure.py --output runs/with-fix/summary.png
```

The first should end with `OK`; the second should report `PASS: automated JUSF figure requirements.` Both should exit successfully. The figure checker renders the current source, replacing the repaired image at that output path. To render without running acceptance checks:

```bash
python plotting/plot_summary.py --output runs/with-fix/summary.png
```

Follow [4. Verify](../paths/python/04-verify.md) to compare baseline and repaired PNGs, inspect the figure at 6 × 4 inches and in grayscale, and read the alt text. Check every count and the at-most-150-word requirement. Automated passes do not establish accessibility or accuracy of the description. After another repair, rerun both checks and inspect the new image.

### 5. Review and commit source

```bash
git status --short
git diff -- plotting/plot_summary.py
git diff --stat
git diff
```

Read every changed source file and any untracked files listed by status; `git diff` does not show untracked file contents. If files are already staged, inspect `git diff --cached` too. Confirm the change preserves counts and behavior. The PNG and alt text remain ignored under `runs/` and need a separate visual review.

Stage only source files you have reviewed; add other specific file paths if the repair legitimately changed them:

```bash
git add -- plotting/plot_summary.py
git diff --cached
git status --short
git commit -m "Repair Python grouped figure layout for journal specifications"
git log -1 --oneline
git status --short
```

If Git requests an author identity, follow [repository-local Git identity](#git-identity), then retry the commit. Check the staged diff before committing; staging selects the saved content for the commit, so newer edits require another review and staging step. The local commit requires no write access to the upstream GitHub repository.

### 6. Hand off

Follow [6. Hand off](../paths/python/06-handoff.md#write-the-handoff): describe the change, actual commands and results, visual checks, and unfinished work. Name `runs/with-fix/summary.png` and `runs/with-fix/summary.alt.txt`. Share the image and reviewed description together, and attach the description through the document or slide's alternative-text feature. Pushing or publishing is outside the exercise.

[Back to the Python path](../paths/python/index.md)

## R

You need **R 4.1 or later** and Git. The exercise uses base R and needs no additional R packages. Use a shell on macOS/Linux or PowerShell on Windows, including RStudio's **Terminal** tab if you prefer.

### 1. Clone and confirm the runtime

If you do not already have the example, run:

```bash
git clone https://github.com/FritscheLab/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

If it is already cloned, open a terminal in that folder instead. From the example repository root:

```bash
Rscript --version
Rscript plotting/tests/run_tests.R
```

Confirm R 4.1 or later. A passing test run ends with `All plotting behavior checks passed; review image readability separately.` The suite intentionally tests invalid arguments and unwritable outputs; an actual suite failure exits unsuccessfully. Read the final result, not an isolated error message.

If the terminal cannot find `Rscript`, use [R runtime troubleshooting](../setup/vscode-copilot.md#troubleshooting) to locate the executable. On Windows, a full path containing spaces needs PowerShell's call operator. For example, replace the bracketed path with the actual installed executable:

```powershell
& "[FULL PATH TO Rscript.exe]" --version
& "[FULL PATH TO Rscript.exe]" plotting/tests/run_tests.R
```

Use that same full-path form for each remaining R command. Restarting the terminal after installing R can resolve a stale search path.

### 2. Save the baseline

Before running the next command, check whether `runs/baseline/summary.png` already exists. Keep an existing baseline; use a different output path if you need another starting image.

```bash
Rscript plotting/plot_summary.R --output runs/baseline/summary.png
git status --short
```

Open `runs/baseline/summary.png` in an image viewer. It should show overlapping groups and clipped category labels. Keep it for comparison. The plotting command creates the parent directory and normally produces no console output. Setup should leave Git's status empty because `runs/` is ignored.

You can confirm the intentionally unfinished figure fails the separate journal checker:

```bash
Rscript plotting/check_figure.R --output runs/baseline/figure-check.png
```

Expect `FAIL:` messages and a nonzero exit status. Do not change the specification or checker to obtain a pass.

### 3. Orient, plan, and implement

Use the prompts in [1. Orient](../paths/r/01-orient.md), [2. Specify](../paths/r/02-specify.md), and [3. Implement](../paths/r/03-implement.md) in your coding assistant. Their VS Code selector instructions apply only to the IDE; choose your CLI client's corresponding planning and execution controls. [Copilot CLI guidance](#copilot-cli) appears below.

First understand `plot_summary()` in `plotting/plot_summary.R`. Review a short plan against `docs/reference/figure-specifications.md`, then request the repair. Preserve all eight counts, group assignments, category order, command behavior, and base-R dependencies. Have the assistant save the repaired PNG and separately author `runs/with-fix/summary.alt.txt`; the plotting program still writes only the PNG.

### 4. Verify the current repair

Run both checks after the final edit, even if the first one fails:

```bash
Rscript plotting/tests/run_tests.R
Rscript plotting/check_figure.R --output runs/with-fix/summary.png
```

The first should end with the behavior-pass message; the second should report `PASS: automated JUSF figure requirements.` Both should exit successfully. The figure checker renders the current source, replacing the repaired image at that output path. To render without running acceptance checks:

```bash
Rscript plotting/plot_summary.R --output runs/with-fix/summary.png
```

Follow [4. Verify](../paths/r/04-verify.md) to compare baseline and repaired PNGs, inspect the figure at 6 × 4 inches and in grayscale, and read the alt text. Check every count and the at-most-150-word requirement. Automated passes do not establish accessibility or accuracy of the description. After another repair, rerun both checks and inspect the new image.

### 5. Review and commit source

```bash
git status --short
git diff -- plotting/plot_summary.R
git diff --stat
git diff
```

Read every changed source file and any untracked files listed by status; `git diff` does not show untracked file contents. If files are already staged, inspect `git diff --cached` too. Confirm counts, group assignments, category order, command behavior, and dependencies stayed intact. The PNG and alt text remain ignored under `runs/` and need a separate visual review.

Stage only source files you have reviewed; add other specific file paths if the repair legitimately changed them:

```bash
git add -- plotting/plot_summary.R
git diff --cached
git status --short
git commit -m "Repair R grouped figure layout for journal specifications"
git log -1 --oneline
git status --short
```

If Git requests an author identity, follow [repository-local Git identity](#git-identity), then retry the commit. Check the staged diff before committing; staging selects the saved content for the commit, so newer edits require another review and staging step. The local commit requires no write access to the upstream GitHub repository.

### 6. Hand off

Follow [6. Hand off](../paths/r/06-handoff.md#write-the-handoff): describe the change, actual commands and results, visual checks, and unfinished work. Name `runs/with-fix/summary.png` and `runs/with-fix/summary.alt.txt`. Share the image and reviewed description together, and attach the description through the document or slide's alternative-text feature. Pushing or publishing is outside the exercise.

[Back to the R path](../paths/r/index.md)

## Git identity

Git's author name and email label a commit; signing in to Copilot does not necessarily configure them. From the example repository root, replace both bracketed placeholders with your chosen commit identity and run:

```bash
git config --local user.name "[YOUR COMMIT NAME]"
git config --local user.email "[YOUR COMMIT EMAIL]"
git config --local --get user.name
git config --local --get user.email
```

These settings apply only to this repository. You can use the no-reply address shown in your GitHub email settings. Inspect the output, then retry the local commit.

## Copilot CLI

This optional terminal client can use the same repository instructions and lesson prompts. It is separate from Copilot Chat in VS Code. Follow GitHub's [current CLI quickstart](https://docs.github.com/en/copilot/get-started/cli-quickstart) for platform installers and account access; organization policy can also control availability.

If you already use npm with **Node.js 22 or later**, install with:

```bash
npm install -g @github/copilot
```

Otherwise use the operating-system installer documented in that quickstart; Node.js is a requirement of the npm route, not the Python/R exercise. From the example repository root, start:

```bash
copilot
```

Inside the Copilot prompt, enter `/login` and follow the GitHub authentication flow. Confirm the working folder is this invented-data exercise. Use `/help` for the installed client's commands. [CLI installation and sign-in](https://docs.github.com/en/copilot/get-started/cli-quickstart)

For orientation, request explanation without edits. Before planning, use `/permissions default`; then enter `/plan` followed by the planning prompt from your language's Lesson 2. Review the plan before beginning implementation with the Lesson 3 prompt. Plan mode restricts recognized project writes, but tools and uncertain shell actions can still have effects; inspect action requests. If your account offers manual model choice, `/model` changes the model for the session. Model choice is optional. [CLI command and permission reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference)

After implementation, use the exact native checks and Git review commands in your language section above. Record results yourself, including anything the CLI cannot inspect visually. If your allowance is exhausted, you can still run the local checks and review files; wait for renewed access or continue with another approved client.

Client documentation reviewed September 11, 2026. Local authenticated CLI behavior and account-specific availability require a live session to verify.
