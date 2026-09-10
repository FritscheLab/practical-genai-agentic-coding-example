"""Compare the two baselines on synthetic fixtures; requires Python and R setup.

Native suites remain independent of the other language. This optional check
compares parsed data, not byte hashes or runtime-specific manifest metadata.
"""
from __future__ import annotations

import csv
import json
import math
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EHR_COLUMNS = ["person_id", "encounter_id", "bmi", "height_cm", "weight_kg", "measurement_date"]
DEMO_COLUMNS = [
    "person_id", "date_of_birth", "age", "age_bin", "deceased", "race_clean",
    "ethnicity_clean", "race_ethnicity", "race_ethnicity_harmonized", "sex_gender",
    "marital_status_name", "zip3",
]
NUMERIC = {"bmi", "height_cm", "weight_kg", "bmi_calc", "agedays_at_measurement"}
DATES = {"measurement_date", "date_of_birth"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def write_fixture(directory: Path, rows: list[tuple], people: list[str]) -> tuple[Path, Path]:
    directory.mkdir()
    ehr, demo = directory / "ehr.tsv", directory / "demo.tsv"
    with ehr.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t")
        writer.writerow(EHR_COLUMNS)
        writer.writerows(rows)
    with demo.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=DEMO_COLUMNS, delimiter="\t")
        writer.writeheader()
        for person in people:
            writer.writerow({"person_id": person, "date_of_birth": "1980-01-01",
                             "age": "40", "zip3": "012"})
    return ehr, demo


def normalized(column: str, value: str) -> object:
    if not value:
        return None
    if column in NUMERIC:
        return float(value)
    if column in DATES:
        return datetime.fromisoformat(value)
    if column == "bmi_imputed":
        require(value.lower() in {"true", "false"}, f"Invalid boolean: {value!r}")
        return value.lower() == "true"
    if column == "reasons":
        return frozenset(value.split(";"))
    return value


def compare_tsv(left: Path, right: Path) -> None:
    with left.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        columns = reader.fieldnames
        left_rows = list(reader)
    with right.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        require(set(columns or []) == set(reader.fieldnames or []), f"{left.name}: columns differ")
        right_rows = list(reader)
    # Output row order is not part of the shared data contract. Keep duplicate
    # rows visible through the length check, and compare with stable input IDs.
    key = lambda row: (row.get("person_id", ""), row.get("encounter_id", ""))  # noqa: E731
    left_rows.sort(key=key)
    right_rows.sort(key=key)
    require(len(left_rows) == len(right_rows), f"{left.name}: row counts differ")
    for index, (a, b) in enumerate(zip(left_rows, right_rows, strict=True)):
        for column in columns or []:
            av, bv = normalized(column, a[column]), normalized(column, b[column])
            equal = (math.isclose(av, bv, rel_tol=1e-12, abs_tol=1e-10)
                     if isinstance(av, float) and isinstance(bv, float) else av == bv)
            require(equal, f"{left.name}, row {index}, {column}: Python={av!r}, R={bv!r}")


def compare_case(name: str, inputs: tuple[Path, Path], runs: Path, rscript: str) -> None:
    for language, prefix in (
        ("python", [sys.executable, "-m", "pgacg", "demo"]),
        ("r", [rscript, str(ROOT / "scripts/r/demo.R")]),
    ):
        process = subprocess.run(
            [*prefix, "--ehr", str(inputs[0]), "--demo", str(inputs[1]),
             "--runs_dir", str(runs), "--run_id", f"{name}-{language}"],
            cwd=ROOT, text=True, capture_output=True, check=False, timeout=60,
        )
        require(process.returncode == 0, f"{name} ({language}): {process.stdout}\n{process.stderr}")
    left, right = runs / f"{name}-python", runs / f"{name}-r"
    a = json.loads((left / "manifest.json").read_text())
    b = json.loads((right / "manifest.json").read_text())
    require(a["status"] == b["status"] == "success", f"{name}: status differs")
    require(a["metrics"] == b["metrics"], f"{name}: metrics differ: {a['metrics']} / {b['metrics']}")
    require(a["parameters"] == b["parameters"], f"{name}: effective cleaning parameters differ")
    for filename in ("cleaned_bmi_person.tsv", "flagged_rows.tsv", "flagged_people.tsv"):
        compare_tsv(left / "outputs" / filename, right / "outputs" / filename)
    print(f"PASS: Python/R data and metrics agree for {name}")


def main() -> int:
    rscript = shutil.which("Rscript")
    if rscript is None:
        print("Rscript is required to compare languages; install both paths first.",
              file=sys.stderr)
        return 1
    # These examples exercise the teaching rules; native tests also assert
    # independently specified answers, since agreement alone proves no method.
    cases = {
        "ties": [
            ("p", "e2", 20, 200, 80, "2020-01-02"),
            ("p", "e10", 24, 200, 96, "2020-01-02"),
            ("p", "old", 20, 200, 80, "2020-01-01"),
            ("p", "older", 24, 200, 96, "2020-01-01"),
        ],
        "iqr": [("p", f"e{i}", bmi, 200, bmi * 4, f"2020-01-0{i + 1}")
                for i, bmi in enumerate([20, 20, 20, 20, 40])],
        "boundaries": [
            (f"p{i}", f"e{i}", bmi, 200, bmi * 4, "2020-01-01")
            for i, bmi in enumerate([10, 18.4, 18.5, 24.9, 25, 29.9, 30, 34.9, 35, 39.9, 40, 70])
        ] + [
            ("hmin", "hmin", 25, 100, 25, "2020-01-01"),
            ("hmax", "hmax", 48, 250, 300, "2020-01-01"),
            ("htie", "htie", 20, 150, 45, "2020-01-01"),
            ("wtie", "wtie", 20, 180, 64.8, "2020-01-01"),
            ("equal", "equal", 24, 200, 88, "2020-01-01"),
        ],
        "missing_and_flags": [
            ("p", "impute", "", 200, 80.2, "2020-01-01"),
            ("other", "good", 25, 200, 100, "2020-01-01"),
            ("q", "both", 20, 90, 400, "2020-01-01"),
            ("q", "missing", 20, "", 80, "2020-01-01"),
            ("q", "text", 20, 200, "text", "2020-01-01"),
            ("q", "date", 20, 200, 80, "invalid"),
            ("", "id", 20, 200, 80, "2020-01-01"),
        ],
        "all_excluded": [("p", "bad", 20, "", 80, "2020-01-01")],
        "timestamps": [
            ("p", "valid", 20, 200, 80, "2020-01-01 12:00:00.000000"),
            ("p", "fraction", 20, 200, 80, "2020-01-01 12:00:00.123000"),
            ("q", "small", 20, 200, 80, "2020-01-01 12:00:00.000001"),
            ("q", "rollover", 20, 200, 80, "2020-01-01 24:00:00.000000"),
            ("q", "badcalendar", 20, 200, 80, "2020-02-30 12:00:00.000000"),
        ],
        "unicode_ids": [
            ("pé", "é2", 20, 200, 80, "2020-01-01"),
            ("pé", "é1", 20, 200, 80, "2020-01-01"),
            ("人", "e3", 20, 200, 80, "2020-01-01"),
        ],
        "empty": [],
    }
    try:
        with tempfile.TemporaryDirectory(prefix="pgacg-language-parity-") as temporary:
            directory = Path(temporary)
            runs = directory / "runs"
            compare_case("example", (ROOT / "data/example/ehr_bmi_simulated_data.tsv",
                                     ROOT / "data/example/demographics_simulated_data.tsv"), runs, rscript)
            for name, rows in cases.items():
                # Include a demographics-only person and an EHR-only person.
                people = sorted({row[0] for row in rows if row[0] and row[0] != "other"} | {"absent"})
                compare_case(name, write_fixture(directory / name, rows, people), runs, rscript)
    except (AssertionError, OSError, ValueError, subprocess.TimeoutExpired) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    print(f"PASS: all {len(cases) + 1} language parity cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
