from __future__ import annotations

from collections.abc import Iterable
from pathlib import Path

import pandas as pd

EHR_REQUIRED_COLUMNS = [
    "person_id",
    "encounter_id",
    "bmi",
    "height_cm",
    "weight_kg",
    "measurement_date",
]

DEMO_REQUIRED_COLUMNS = [
    "person_id",
    "date_of_birth",
    "age",
    "age_bin",
    "deceased",
    "race_clean",
    "ethnicity_clean",
    "race_ethnicity",
    "race_ethnicity_harmonized",
    "sex_gender",
    "marital_status_name",
    "zip3",
]


class SchemaError(ValueError):
    pass


def _missing_columns(df: pd.DataFrame, required: Iterable[str]) -> list[str]:
    required_set = set(required)
    present = set(df.columns)
    missing = sorted(required_set - present)
    return missing


def validate_columns(df: pd.DataFrame, required: Iterable[str], *, label: str) -> None:
    missing = _missing_columns(df, required)
    if missing:
        raise SchemaError(f"Missing required columns in {label}: {missing}")


def validate_demographics(df: pd.DataFrame) -> None:
    """Require one nonempty demographics key per person before joining."""
    validate_columns(df, DEMO_REQUIRED_COLUMNS, label="demographics")
    keys = df["person_id"].astype("string").str.strip()
    if (keys.isna() | keys.eq("")).any():
        raise SchemaError("Demographics person_id must not be missing or blank")
    if keys.duplicated().any():
        raise SchemaError("Demographics person_id must be unique; duplicate keys found")


def validate_ehr(df: pd.DataFrame) -> None:
    validate_columns(df, EHR_REQUIRED_COLUMNS, label="EHR")
    keys = df["encounter_id"].astype("string").str.strip()
    nonempty = keys.dropna().loc[lambda values: values.ne("")]
    if nonempty.duplicated().any():
        raise SchemaError("EHR encounter_id must be unique; duplicate keys found")


def _normalize_empty_strings(df: pd.DataFrame) -> pd.DataFrame:
    """Convert empty/whitespace-only strings to NA in object/string columns."""
    df = df.copy()
    for col in df.columns:
        if pd.api.types.is_object_dtype(df[col].dtype) or pd.api.types.is_string_dtype(df[col].dtype):
            df[col] = (
                df[col]
                .astype("string")
                .str.strip()
                .replace({"": pd.NA})
            )
    return df


def read_tsv(
    path: Path,
    required_columns: Iterable[str],
    *,
    parse_dates: list[str] | None = None,
) -> pd.DataFrame:
    """Read a TSV and validate that required columns exist."""
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Input file not found: {path}")

    df = pd.read_csv(path, sep="\t", dtype=str, keep_default_na=False, na_values=[""])
    df = _normalize_empty_strings(df)

    validate_columns(df, required_columns, label=path.name)

    if parse_dates:
        for col in parse_dates:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors="coerce")

    return df


def write_tsv(df: pd.DataFrame, path: Path) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path, sep="\t", index=False, na_rep="")
