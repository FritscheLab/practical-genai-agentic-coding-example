from __future__ import annotations

import pandas as pd
import pytest

from pgacg.cleaning import CleaningParams, clean_ehr_and_select_typical
from pgacg.io import DEMO_REQUIRED_COLUMNS, EHR_REQUIRED_COLUMNS, SchemaError


def demographics(*people: str) -> pd.DataFrame:
    return pd.DataFrame(
        [{**dict.fromkeys(DEMO_REQUIRED_COLUMNS, ""), "person_id": person,
          "date_of_birth": "1980-01-01", "age": "40", "zip3": "012"}
         for person in people], columns=DEMO_REQUIRED_COLUMNS,
    )


def ehr_rows(*rows: tuple) -> pd.DataFrame:
    """Rows specify person, encounter, BMI, height, weight, and date explicitly."""
    return pd.DataFrame(rows, columns=EHR_REQUIRED_COLUMNS)


def test_known_records_imputation_and_exclusions() -> None:
    ehr = ehr_rows(
        ("p1", "a", 20, 200, 80, "2020-01-01"),
        ("p1", "b", 22, 200, 88, "2020-01-02"),
        ("p1", "c", 24, 200, 96, "2020-01-03"),
        ("p2", "d", None, 200, 100, "2020-01-01"),
        ("p3", "bad", 24, 50, 60, "2020-01-01"),
    )
    cleaned, flagged, people, metrics = clean_ehr_and_select_typical(
        ehr, demographics("p1", "p2", "p3", "p4"), CleaningParams()
    )
    assert cleaned["encounter_id"].tolist() == ["b", "d"]
    assert cleaned["bmi"].tolist() == [22, 25]
    assert cleaned["bmi_imputed"].tolist() == [False, True]
    assert cleaned["bmi_category"].tolist() == ["Normal", "Overweight"]
    assert cleaned["zip3"].tolist() == ["012", "012"]
    assert flagged["encounter_id"].tolist() == ["bad"]
    assert set(flagged.iloc[0]["reasons"].split(";")) == {"implausible_height", "bmi_mismatch"}
    assert people["person_id"].tolist() == ["p3", "p4"]
    assert metrics["n_rows_input"] == 5
    assert metrics["n_rows_kept_after_row_filters"] == 4
    assert metrics["n_rows_flagged_total"] == 1


@pytest.mark.parametrize("threshold,expected_people", [(2.0, 1), (1.9, 0), (0.0, 0)])
def test_mismatch_boundary_is_strictly_greater(threshold: float, expected_people: int) -> None:
    # Reported BMI 24 minus calculated BMI 88 / 2**2 = 22 gives exactly 2.
    ehr = ehr_rows(("p", "a", 24, 200, 88, "2020-01-01"))
    cleaned, flagged, _, _ = clean_ehr_and_select_typical(
        ehr, demographics("p"), CleaningParams(mismatch_threshold=threshold)
    )
    assert len(cleaned) == expected_people
    assert len(flagged) == 1 - expected_people


def test_iqr_outlier_removed_before_selection() -> None:
    ehr = ehr_rows(
        ("p", "a", 20, 200, 80, "2020-01-01"),
        ("p", "b", 20, 200, 80, "2020-01-02"),
        ("p", "c", 20, 200, 80, "2020-01-03"),
        ("p", "d", 20, 200, 80, "2020-01-04"),
        ("p", "high", 40, 200, 160, "2020-01-05"),
    )
    cleaned, flagged, _, metrics = clean_ehr_and_select_typical(ehr, demographics("p"), CleaningParams())
    assert cleaned["encounter_id"].tolist() == ["d"]
    assert flagged[["encounter_id", "reasons"]].values.tolist() == [["high", "per_person_iqr_outlier"]]
    assert metrics["n_rows_outliers"] == 1


def test_selection_uses_latest_date_then_encounter_id_independent_of_input_order() -> None:
    ehr = ehr_rows(
        ("p", "older", 20, 200, 80, "2020-01-01"),
        ("p", "z", 20, 200, 80, "2020-01-02"),
        ("p", "a", 24, 200, 96, "2020-01-02"),
        ("p", "older2", 24, 200, 96, "2020-01-01"),
    )
    for seed in range(5):
        cleaned, _, _, _ = clean_ehr_and_select_typical(
            ehr.sample(frac=1, random_state=seed), demographics("p"), CleaningParams()
        )
        assert cleaned["encounter_id"].tolist() == ["a"]
        assert cleaned["bmi"].tolist() == [24]


@pytest.mark.parametrize("empty", [True, False])
def test_empty_or_all_excluded_input_preserves_output_schema(empty: bool) -> None:
    ehr = ehr_rows() if empty else ehr_rows(("p", "bad", 20, None, 80, "2020-01-01"))
    cleaned, flagged, people, metrics = clean_ehr_and_select_typical(ehr, demographics("p"), CleaningParams())
    assert cleaned.empty
    assert {"person_id", "bmi_category", "agedays_at_measurement"} <= set(cleaned.columns)
    assert len(flagged) == (0 if empty else 1)
    assert people["person_id"].tolist() == ["p"]
    assert metrics["n_people_no_valid_rows"] == 1


@pytest.mark.parametrize("key", [None, "", "   "])
def test_missing_demographics_key_rejected(key: str | None) -> None:
    demo = demographics("p")
    demo.loc[0, "person_id"] = key
    with pytest.raises(SchemaError, match="must not be missing or blank"):
        clean_ehr_and_select_typical(ehr_rows(), demo, CleaningParams())


def test_duplicate_demographics_rejected_instead_of_multiplying_rows() -> None:
    ehr = ehr_rows(("p", "a", 20, 200, 80, "2020-01-01"))
    with pytest.raises(SchemaError, match="Demographics person_id must be unique"):
        clean_ehr_and_select_typical(ehr, demographics("p", "p"), CleaningParams())


def test_duplicate_encounter_key_rejected() -> None:
    ehr = ehr_rows(
        ("p", "a", 20, 200, 80, "2020-01-01"),
        ("p", "a", 24, 200, 96, "2020-01-01"),
    )
    with pytest.raises(SchemaError, match="EHR encounter_id must be unique"):
        clean_ehr_and_select_typical(ehr, demographics("p"), CleaningParams())


def test_missing_input_column_rejected() -> None:
    with pytest.raises(SchemaError, match="Missing required columns in EHR.*weight_kg"):
        clean_ehr_and_select_typical(ehr_rows().drop(columns="weight_kg"), demographics("p"), CleaningParams())


@pytest.mark.parametrize("value", [-1, float("nan"), float("inf")])
def test_public_parameters_reject_invalid_threshold(value: float) -> None:
    with pytest.raises(ValueError, match="mismatch_threshold must be finite and nonnegative"):
        CleaningParams(mismatch_threshold=value)
