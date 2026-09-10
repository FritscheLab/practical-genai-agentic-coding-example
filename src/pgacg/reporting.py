from __future__ import annotations

from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd

from pgacg.cleaning import CleaningParams


def render_markdown_table(counts: pd.Series, header_left: str = "value", header_right: str = "count") -> str:
    df = counts.reset_index()
    df.columns = [header_left, header_right]
    lines = ["| " + " | ".join(df.columns) + " |", "|---|---:|"]
    for _, row in df.iterrows():
        left = row.iloc[0]
        right = int(row.iloc[1])
        lines.append(f"| {left} | {right} |")
    return "\n".join(lines)


def write_run_summary(
    path: Path,
    *,
    run_id: str,
    params: CleaningParams,
    metrics: dict[str, int],
    cleaned: pd.DataFrame,
    ehr_path: Path,
    demo_path: Path,
) -> None:
    """Write a human-readable Markdown summary for the run."""
    now = datetime.now(timezone.utc).isoformat()

    # Category breakdowns
    bmi_counts = cleaned["bmi_category"].value_counts(dropna=False)
    height_counts = cleaned["height_category"].value_counts(dropna=False)
    weight_counts = cleaned["weight_category"].value_counts(dropna=False)

    lines: list[str] = []
    lines.append(f"# Run summary: `{run_id}`")
    lines.append("")
    lines.append(f"- **Timestamp:** {now}")
    lines.append("- **Status:** success")
    lines.append("- **Provenance:** `manifest.json` (input and artifact checksums, command, code and environment)")
    lines.append(f"- **EHR input:** `{ehr_path}`")
    lines.append(f"- **Demographics input:** `{demo_path}`")
    lines.append("")
    lines.append("These are simplified teaching rules applied to synthetic data, including minors. "
                 "Categories are demonstration labels, not clinical assessments or a validated cohort definition.")
    lines.append("")
    lines.append("## Parameters")
    for k, v in asdict(params).items():
        lines.append(f"- `{k}`: {v}")
    lines.append("")
    lines.append("## Key counts")
    for k, v in metrics.items():
        lines.append(f"- `{k}`: {v}")
    lines.append("")
    lines.append("## Category distributions (cleaned person-level output)")
    lines.append("")
    lines.append("### BMI category")
    lines.append(render_markdown_table(bmi_counts, "bmi_category", "n_people"))
    lines.append("")
    lines.append("### Height category")
    lines.append(render_markdown_table(height_counts, "height_category", "n_people"))
    lines.append("")
    lines.append("### Weight category")
    lines.append(render_markdown_table(weight_counts, "weight_category", "n_people"))
    lines.append("")

    path.write_text("\n".join(lines), encoding="utf-8")


def write_failure_summary(
    path: Path, *, run_id: str, error: str, params: CleaningParams,
    ehr_path: Path, demo_path: Path,
) -> None:
    lines = [
        f"# Run summary: `{run_id}`", "", "- **Status:** failed",
        f"- **EHR input:** `{ehr_path}`", f"- **Demographics input:** `{demo_path}`", "",
        "## Error", "", error, "",
        "See `logs/pipeline.log` for the traceback and `manifest.json` for provenance. "
        "Any artifacts retained in this run folder are incomplete and must not be treated as a successful run.",
        "", "## Parameters", "",
        *(f"- `{key}`: {value}" for key, value in asdict(params).items()), "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def write_output_data_dictionary(path: Path) -> None:
    """Write a lightweight data dictionary for the cleaned person-level output."""
    content = """# Data dictionary: cleaned_bmi_person.tsv

This dictionary describes the **person-level** output of the synthetic teaching pipeline.
Categories use simplified fixed thresholds; they are not clinical assessments.

| column | type | description |
|---|---|---|
| person_id | string | synthetic person identifier |
| encounter_id | string | encounter id for the selected ‘typical’ record |
| bmi | float | BMI used for selection (reported or imputed from height/weight) |
| height_cm | float | height (cm) for the selected record |
| weight_kg | float | weight (kg) for the selected record |
| measurement_date | datetime | measurement timestamp for the selected record |
| bmi_calc | float | BMI calculated from height/weight |
| bmi_imputed | bool | whether BMI was missing and filled from height/weight |
| bmi_category | string | Underweight / Normal / Overweight / Obesity I/II/III |
| height_category | string | Short / Average / Tall |
| weight_category | string | Light / Medium / Heavy / Very Heavy |
| date_of_birth | datetime | DOB (from demographics) |
| age | int | age in years (from demographics; may be missing) |
| age_bin | string | age bin (from demographics) |
| deceased | string | Yes/No |
| race_clean | string | race (may be missing) |
| ethnicity_clean | string | ethnicity (may be missing) |
| race_ethnicity | string | combined race/ethnicity (may be missing) |
| race_ethnicity_harmonized | string | harmonized race/ethnicity (may be missing) |
| sex_gender | string | sex/gender |
| marital_status_name | string | marital status |
| zip3 | string | 3-digit ZIP prefix |
| agedays_at_measurement | int | (measurement_date - date_of_birth) in days (may be missing if DOB missing) |
"""
    path.write_text(content, encoding="utf-8")
