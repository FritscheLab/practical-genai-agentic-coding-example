Python path · [Change language](../r/index.md)

# Start the Python demo

A labmate runs the pipeline with six measurements and finds only three in the cleaned output. **Add a short report that explains why.** Follow along during the presentation or work through it at home.

The example keeps **a, b, c**. It excludes **d** for missing height, **e** for missing weight, and **f** for both. Your report will show **3 of 6 excluded**, with **2 missing height** and **2 missing weight**. The pipeline already records these reasons.

Use the included synthetic files and an approved coding client. See the [lab data guidance](../../reference/lab-data-policy.md) before adapting this to study data.

## Set up

You need Git and a terminal. If you already have the exercise repository, open a terminal in its root. Otherwise, clone it first:

```bash
git clone https://github.com/ilarsf/practical-genai-agentic-coding-example.git
cd practical-genai-agentic-coding-example
```

You need Python 3.10–3.12. Create an environment:

```bash
python -m venv .venv
```

If your system uses `python3`, use that for the command above. Activate the environment on macOS/Linux:

```bash
source .venv/bin/activate
```

Or in Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, use `.venv\Scripts\python.exe` in place of `python` below. Install the packages:

```bash
python -m pip install -r requirements-dev.txt
python -m pytest
```

The package installs in editable mode, so code changes take effect without reinstalling.

## Run the six-row example

```bash
python -m pgacg demo --ehr data/example/exclusion_report/ehr.tsv --demo data/example/exclusion_report/demographics.tsv --run_id baseline
```

Open `runs/baseline/summary.md`, then these files under `runs/baseline/outputs/`:

| File | What you will see |
| --- | --- |
| `cleaned_bmi_person.tsv` | Measurements a, b, c. |
| `flagged_rows.tsv` | Measurements d, e, f and their reasons. |

The summary has overall counts but lacks a readable reason breakdown. Keep this run folder so you can look back at it after the change. If `baseline` already exists, choose another `--run_id`.

## Follow the demo

Follow one change from understanding the repository through implementation, verification, review, and a short handoff.

| Step | What to do |
| --- | --- |
| [1. Orient](01-orient.md) | Find the existing reasons and open your agent. |
| [2. Specify](02-specify.md) | See all six rows and the report you want. |
| [3. Implement](03-implement.md) | Copy the prompt and ask for the report. |
| [4. Verify](04-verify.md) | Run the existing tests and read the result. |
| [5. Review](05-review.md) | Look through the changed code. |
| [6. Hand off](06-handoff.md) | Leave a three-sentence handoff. |

You can make the same edit manually without an assistant. For setup problems, use the [checklist below](#setup-troubleshooting).

## Setup troubleshooting

- **Python version:** Run `python --version` and check that it reports Python 3.10–3.12, the supported range for this walkthrough's packages.
- **Active environment:** Run `python -c "import sys; print(sys.executable)"`. The path should point inside this repository's `.venv`. If it does not, activate the environment as shown above, or use its Python executable directly.
- **Working directory:** Run the setup and demo commands from the repository root, the folder containing `README.md` and `requirements-dev.txt`.
- **Package installation:** Read the first pip error. Connection, DNS, timeout, or package-index access errors mean pip could not fetch packages; check your environment's approved network and package-index access. If pip reaches the index but reports incompatible Python or package versions, check the interpreter above and save the full error for troubleshooting. Do not change dependency versions to work around a network failure.

See [pipeline troubleshooting](https://ilarsf.github.io/practical-genai-agentic-coding-guide/docs/runbooks/demo_pipeline.html#troubleshooting) for help with input or run errors.

---

[Next: 1. Orient →](01-orient.md)
