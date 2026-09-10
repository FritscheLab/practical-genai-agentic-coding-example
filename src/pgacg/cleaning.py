from __future__ import annotations

from dataclasses import asdict, dataclass
from math import isfinite

import numpy as np
import pandas as pd

from pgacg.io import validate_demographics, validate_ehr


@dataclass(frozen=True)
class CleaningParams:
    mismatch_threshold: float = 2.0
    min_height_cm: float = 100.0
    max_height_cm: float = 250.0
    min_weight_kg: float = 25.0
    max_weight_kg: float = 300.0
    min_bmi: float = 10.0
    max_bmi: float = 70.0
    iqr_multiplier: float = 1.5

    def __post_init__(self) -> None:
        for name, value in asdict(self).items():
            if not isfinite(value) or value < 0:
                raise ValueError(f"{name} must be finite and nonnegative")
        for quantity in ("height_cm", "weight_kg", "bmi"):
            if getattr(self, f"min_{quantity}") > getattr(self, f"max_{quantity}"):
                raise ValueError(f"min_{quantity} must not exceed max_{quantity}")
        if self.min_height_cm == 0:
            raise ValueError("min_height_cm must be greater than zero")


def compute_bmi(height_cm: pd.Series, weight_kg: pd.Series) -> pd.Series:
    height_m = height_cm / 100.0
    with np.errstate(divide="ignore", invalid="ignore"):
        bmi = weight_kg / (height_m**2)
    return bmi


def _add_reason(reasons: pd.Series, mask: pd.Series, reason: str) -> pd.Series:
    # reasons is a Series of lists
    reasons = reasons.copy()
    idx = mask.fillna(False)
    reasons.loc[idx] = reasons.loc[idx].apply(lambda lst: lst + [reason])
    return reasons


def _finalize_reasons(reasons: pd.Series) -> pd.Series:
    return reasons.apply(lambda lst: ";".join(lst) if lst else "")


def clean_ehr_and_select_typical(
    ehr: pd.DataFrame,
    demo: pd.DataFrame,
    params: CleaningParams,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, dict[str, int]]:
    """Clean EHR BMI rows and select a representative row per person.

    Returns:
      cleaned_person_df: 1 row/person
      flagged_rows_df: excluded rows with reasons
      flagged_people_df: people with no valid rows
      metrics: counts for run summary
    """
    validate_ehr(ehr)
    validate_demographics(demo)
    df = ehr.copy().reset_index(drop=True)
    for col in ("person_id", "encounter_id"):
        df[col] = df[col].astype("string").str.strip().replace({"": pd.NA})

    # Parse numeric columns
    for col in ["bmi", "height_cm", "weight_kg"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    # Ensure measurement_date is datetime
    if not np.issubdtype(df["measurement_date"].dtype, np.datetime64):
        df["measurement_date"] = pd.to_datetime(df["measurement_date"], errors="coerce")

    reasons = pd.Series([[] for _ in range(len(df))], index=df.index, dtype=object)

    # Missing identifiers / dates
    missing_id_or_date = df["person_id"].isna() | df["encounter_id"].isna() | df["measurement_date"].isna()
    reasons = _add_reason(reasons, missing_id_or_date, "missing_id_or_date")

    # Missing height/weight
    reasons = _add_reason(reasons, df["height_cm"].isna(), "missing_height")
    reasons = _add_reason(reasons, df["weight_kg"].isna(), "missing_weight")

    # Implausible height/weight
    reasons = _add_reason(
        reasons,
        df["height_cm"].notna() & ((df["height_cm"] < params.min_height_cm) | (df["height_cm"] > params.max_height_cm)),
        "implausible_height",
    )
    reasons = _add_reason(
        reasons,
        df["weight_kg"].notna() & ((df["weight_kg"] < params.min_weight_kg) | (df["weight_kg"] > params.max_weight_kg)),
        "implausible_weight",
    )

    # BMI calculation and mismatch
    df["bmi_calc"] = compute_bmi(df["height_cm"], df["weight_kg"]).round(1)

    df["bmi_imputed"] = df["bmi"].isna() & df["bmi_calc"].notna()
    df.loc[df["bmi_imputed"], "bmi"] = df.loc[df["bmi_imputed"], "bmi_calc"]

    mismatch = (
        df["bmi"].notna()
        & df["bmi_calc"].notna()
        & ((df["bmi"] - df["bmi_calc"]).abs() > params.mismatch_threshold)
    )
    reasons = _add_reason(reasons, mismatch, "bmi_mismatch")

    # Plausible BMI range (after imputation)
    reasons = _add_reason(
        reasons,
        df["bmi"].notna() & ((df["bmi"] < params.min_bmi) | (df["bmi"] > params.max_bmi)),
        "implausible_bmi",
    )

    # Flagged rows so far
    any_reasons = reasons.apply(bool)
    flagged_rows = df.loc[any_reasons].copy()
    flagged_rows["reasons"] = _finalize_reasons(reasons.loc[any_reasons])

    keep = df.loc[~any_reasons].copy()

    # Per-person BMI outliers (IQR rule) using transforms (no groupby.apply)
    grp = keep.groupby("person_id")["bmi"]
    size = grp.transform("size")
    q1 = grp.transform(lambda s: s.quantile(0.25))
    q3 = grp.transform(lambda s: s.quantile(0.75))
    iqr = q3 - q1
    low = q1 - params.iqr_multiplier * iqr
    high = q3 + params.iqr_multiplier * iqr

    outlier_mask = (size >= 4) & ((keep["bmi"] < low) | (keep["bmi"] > high))
    outliers = keep.loc[outlier_mask.fillna(False)].copy()
    outliers["reasons"] = "per_person_iqr_outlier"

    keep2 = keep.loc[~outlier_mask.fillna(False)].copy()

    flagged_rows = pd.concat([flagged_rows, outliers], ignore_index=True)

    # Representative record selection (no groupby.apply)
    grp2 = keep2.groupby("person_id")["bmi"]
    med = grp2.transform("median")
    keep2 = keep2.copy()
    keep2["dist_from_median_bmi"] = (keep2["bmi"] - med).abs()

    typical = (
        keep2.sort_values(
            ["person_id", "dist_from_median_bmi", "measurement_date", "encounter_id"],
            ascending=[True, True, False, True],
        )
        .groupby("person_id", as_index=False)
        .head(1)
        .drop(columns=["dist_from_median_bmi"])
        .reset_index(drop=True)
    )

    # People with zero valid rows
    demo2 = demo.copy()
    demo2["person_id"] = demo2["person_id"].astype("string").str.strip()
    all_people = pd.Index(demo2["person_id"].dropna().unique())
    kept_people = pd.Index(typical["person_id"].dropna().unique())
    missing_people = all_people.difference(kept_people)
    flagged_people = pd.DataFrame({"person_id": missing_people, "reason": "no_valid_rows_after_cleaning"})

    # Categorization
    typical = typical.copy()

    def bmi_category(bmi: float) -> str:
        if pd.isna(bmi):
            return ""
        if bmi < 18.5:
            return "Underweight"
        if bmi < 25:
            return "Normal"
        if bmi < 30:
            return "Overweight"
        if bmi < 35:
            return "Obesity I"
        if bmi < 40:
            return "Obesity II"
        return "Obesity III"

    def height_category(h: float) -> str:
        if pd.isna(h):
            return ""
        if h < 150:
            return "Short"
        if h < 180:
            return "Average"
        return "Tall"

    def weight_category(w: float) -> str:
        if pd.isna(w):
            return ""
        if w < 50:
            return "Light"
        if w < 80:
            return "Medium"
        if w < 100:
            return "Heavy"
        return "Very Heavy"

    typical["bmi_category"] = typical["bmi"].apply(bmi_category)
    typical["height_category"] = typical["height_cm"].apply(height_category)
    typical["weight_category"] = typical["weight_kg"].apply(weight_category)

    # Join demographics (left join; keep all typical people)
    demo2["date_of_birth"] = pd.to_datetime(demo2["date_of_birth"], errors="coerce")

    merged = typical.merge(
        demo2, on="person_id", how="left", suffixes=("", "_demo"), validate="one_to_one"
    )

    # Agedays at measurement (optional helper column)
    merged["agedays_at_measurement"] = (merged["measurement_date"] - merged["date_of_birth"]).dt.days

    # Metrics for summary
    metrics: dict[str, int] = {
        "n_rows_input": int(len(df)),
        "n_people_demo": int(demo["person_id"].nunique()),
        "n_rows_flagged_total": int(len(flagged_rows)),
        "n_rows_kept_after_row_filters": int(len(keep2)),
        "n_people_with_typical_record": int(merged["person_id"].nunique()),
        "n_people_no_valid_rows": int(len(flagged_people)),
        "n_rows_outliers": int(len(outliers)),
        "n_rows_bmi_mismatch": int(mismatch.sum()),
    }

    return merged, flagged_rows, flagged_people, metrics
