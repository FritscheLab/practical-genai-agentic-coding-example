Python path · [Change language](../r/index.md)

# Fix a plot in Python

Overlapping bars. Clipped labels. A very particular fictional journal. **Use an agent to turn this chart into a readable figure.**

The source contains invented aggregate counts for two groups—no participant records or data-file inputs. Use an approved coding client and keep study data outside this workspace. [Data guidance](../../reference/lab-data-policy.md).

## Set up

You need Git and a terminal. If you already have the exercise repository, open a terminal in its root. Otherwise, clone it:

```bash
git clone https://github.com/FritscheLab/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

You need Python 3.10–3.12. Create an environment:

```bash
python -m venv .venv
```

If your system uses `python3`, use it for that command. Activate the environment on macOS/Linux:

```bash
source .venv/bin/activate
```

Or in Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, use `.venv\Scripts\python.exe` in place of `python` below. Install the plotting dependency and run the checks:

```bash
python -m pip install -r requirements-plotting.txt
python -m unittest discover -s plotting/tests
```

## Save the starting chart

From the example repository root, run:

```bash
python plotting/plot_summary.py --output runs/baseline/summary.png
```

Open `runs/baseline/summary.png` in your editor or file browser. Spot the overlapping bars and clipped labels. Keep this image for comparison; choose another output path if you already have a baseline to preserve.

**Passing tests ≠ a readable chart.** Behavior checks pass on this starter; the journal checker introduced in Lesson 4 should fail until you repair it.

## Follow the demo

| Step | What to do |
| --- | --- |
| [1. Orient](01-orient.md) | Ask the agent to locate the plotting function and its layout settings. |
| [2. Specify](02-specify.md) | Read the figure specifications and preserve both groups' values. |
| [3. Implement](03-implement.md) | Ask the agent to repair the plot. |
| [4. Verify](04-verify.md) | Check the image, accessibility, and accompanying alt text. |
| [5. Review](05-review.md) | Inspect the code changes. |
| [6. Hand off](06-handoff.md) | Record what changed, the checks, and any remaining issues. |


## Setup troubleshooting

- **Python version:** `python --version` should report Python 3.10–3.12.
- **Environment:** `python -c "import sys; print(sys.executable)"` should point inside this repository's `.venv`. Activate it or use its executable directly.
- **Package installation:** Read the first installation error. A connection or package-index error is an environment problem; check approved network access before changing dependencies.
- **Working directory:** Run commands from the example repository root, the folder containing `README.md` and `plotting/`.
- **Opening the chart:** The output is a PNG image. Open it from your file browser or editor; no browser server is needed.

---

[Next: 1. Orient →](01-orient.md)
