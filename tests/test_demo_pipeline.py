from __future__ import annotations

import hashlib
import json
import os
import platform
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import pandas as pd
import pytest

from pgacg import __version__
from pgacg.cli import main
from pgacg.io import DEMO_REQUIRED_COLUMNS


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def test_demo_pipeline_creates_expected_outputs(tmp_path: Path) -> None:
    root = repo_root()
    ehr = root / "data/example/ehr_bmi_simulated_data.tsv"
    demo = root / "data/example/demographics_simulated_data.tsv"

    runs_dir = tmp_path / "runs"
    run_id = "test_run"

    rc = main(
        [
            "demo",
            "--ehr",
            str(ehr),
            "--demo",
            str(demo),
            "--runs_dir",
            str(runs_dir),
            "--run_id",
            run_id,
        ]
    )
    assert rc == 0

    run_dir = runs_dir / run_id
    assert (run_dir / "summary.md").exists()

    outputs = run_dir / "outputs"
    cleaned_path = outputs / "cleaned_bmi_person.tsv"
    flagged_rows_path = outputs / "flagged_rows.tsv"
    flagged_people_path = outputs / "flagged_people.tsv"
    dict_path = outputs / "cleaned_bmi_person_data_dictionary.md"

    assert cleaned_path.exists()
    assert flagged_rows_path.exists()
    assert flagged_people_path.exists()
    assert dict_path.exists()

    cleaned = pd.read_csv(cleaned_path, sep="\t")
    assert cleaned["person_id"].is_unique
    assert len(cleaned) > 0

    # expected derived columns exist
    for col in ["bmi_category", "height_category", "weight_category", "bmi_calc", "bmi_imputed"]:
        assert col in cleaned.columns

    flagged = pd.read_csv(flagged_rows_path, sep="\t")
    assert "reasons" in flagged.columns


@pytest.fixture
def tiny_inputs(tmp_path: Path) -> tuple[Path, Path]:
    ehr = tmp_path / "ehr.tsv"
    ehr.write_text(
        "person_id\tencounter_id\tbmi\theight_cm\tweight_kg\tmeasurement_date\n"
        "p1\tfirst\t20\t200\t80\t2020-01-01\n"
        "p1\tselected\t24\t200\t96\t2020-01-02\n"
        "p2\tmissing\t20\t\t80\t2020-01-01\n", encoding="utf-8",
    )
    demo = tmp_path / "demo.tsv"
    frame = pd.DataFrame([
        {**dict.fromkeys(DEMO_REQUIRED_COLUMNS, ""), "person_id": person,
         "date_of_birth": "1980-01-01", "age": "40", "zip3": "012"}
        for person in ("p1", "p2", "p3")
    ])
    frame.to_csv(demo, sep="\t", index=False)
    return ehr, demo


def cli_arguments(inputs: tuple[Path, Path], runs: Path, run_id: str = "tiny") -> list[str]:
    return ["demo", "--ehr", str(inputs[0]), "--demo", str(inputs[1]),
            "--runs_dir", str(runs), "--run_id", run_id]


def test_manifest_records_provenance_and_verifiable_artifacts(
    tiny_inputs: tuple[Path, Path], tmp_path: Path,
) -> None:
    args = cli_arguments(tiny_inputs, tmp_path / "runs")
    assert main(args) == 0
    run = tmp_path / "runs/tiny"
    manifest = json.loads((run / "manifest.json").read_text())
    assert manifest["schema_version"] == 1
    assert manifest["status"] == "success"
    assert manifest["command"] == [sys.executable, "-m", "pgacg", *args]
    assert manifest["command_source"] == "equivalent_module_invocation"
    assert manifest["parameters"]["mismatch_threshold"] == 2.0
    assert manifest["code"]["version"] == __version__
    assert manifest["environment"]["python"] == platform.python_version()
    assert manifest["environment"]["dependencies"]["pandas"] == pd.__version__
    assert datetime.fromisoformat(manifest["finished_at"]) >= datetime.fromisoformat(manifest["started_at"])
    for name, path in zip(("ehr", "demographics"), tiny_inputs, strict=True):
        assert manifest["inputs"][name]["path"] == str(path.resolve())
        assert manifest["inputs"][name]["sha256"] == hashlib.sha256(path.read_bytes()).hexdigest()
    expected = {
        "summary.md", "outputs/cleaned_bmi_person.tsv", "outputs/flagged_rows.tsv",
        "outputs/flagged_people.tsv", "outputs/cleaned_bmi_person_data_dictionary.md",
    }
    assert set(manifest["artifacts"]) == expected
    for relative_path, metadata in manifest["artifacts"].items():
        content = (run / relative_path).read_bytes()
        assert metadata == {"sha256": hashlib.sha256(content).hexdigest(), "size_bytes": len(content)}
    cleaned = pd.read_csv(run / "outputs/cleaned_bmi_person.tsv", sep="\t", dtype=str)
    assert cleaned["encounter_id"].tolist() == ["selected"]
    assert cleaned["zip3"].tolist() == ["012"]
    assert manifest["metrics"]["n_people_no_valid_rows"] == 2
    summary = (run / "summary.md").read_text()
    assert "Category distributions" in summary
    assert "`mismatch_threshold`: 2.0" in summary


def test_multiple_invocations_have_separate_logs(tiny_inputs: tuple[Path, Path], tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    for run_id in ("first", "second"):
        assert main(cli_arguments(tiny_inputs, runs, run_id)) == 0
    for own, other in (("first", "second"), ("second", "first")):
        log = (runs / own / "logs/pipeline.log").read_text()
        assert f"Starting pgacg demo run: {own}" in log
        assert f"Starting pgacg demo run: {other}" not in log


@pytest.mark.parametrize("failure", ["missing_column", "duplicate_demographics", "missing_file"])
def test_failed_runs_keep_error_summary_log_and_manifest(
    tiny_inputs: tuple[Path, Path], tmp_path: Path, failure: str,
) -> None:
    ehr, demo = tiny_inputs
    if failure == "missing_column":
        ehr.write_text("person_id\nmissing\n", encoding="utf-8")
        expected_error = "Missing required columns"
    elif failure == "duplicate_demographics":
        frame = pd.read_csv(demo, sep="\t", dtype=str)
        pd.concat([frame, frame.iloc[:1]]).to_csv(demo, sep="\t", index=False)
        expected_error = "Demographics person_id must be unique"
    else:
        ehr.unlink()
        expected_error = "FileNotFoundError"
    assert main(cli_arguments(tiny_inputs, tmp_path / "runs")) == 1
    run = tmp_path / "runs/tiny"
    assert expected_error in (run / "summary.md").read_text()
    log = (run / "logs/pipeline.log").read_text()
    assert expected_error in log
    assert "Traceback" in log
    manifest = json.loads((run / "manifest.json").read_text())
    assert manifest["status"] == "failed"
    assert expected_error in manifest["error"]
    assert manifest["finished_at"] is not None
    assert set(manifest["artifacts"]) == {"summary.md"}


@pytest.mark.parametrize("threshold", ["-1", "nan", "inf", "-inf", "text"])
def test_invalid_threshold_fails_before_creating_run(
    tiny_inputs: tuple[Path, Path], tmp_path: Path, threshold: str,
) -> None:
    runs = tmp_path / "runs"
    with pytest.raises(SystemExit) as error:
        main([*cli_arguments(tiny_inputs, runs), f"--mismatch_threshold={threshold}"])
    assert error.value.code == 2
    assert not runs.exists()


@pytest.mark.parametrize("run_id", ["..", "../outside", "/absolute", "with space"])
def test_invalid_run_id_cannot_escape_run_directory(
    tiny_inputs: tuple[Path, Path], tmp_path: Path, run_id: str,
) -> None:
    runs = tmp_path / "runs"
    with pytest.raises(SystemExit) as error:
        main(cli_arguments(tiny_inputs, runs, run_id))
    assert error.value.code == 2
    assert not runs.exists()


def test_existing_run_is_not_overwritten(tiny_inputs: tuple[Path, Path], tmp_path: Path) -> None:
    args = cli_arguments(tiny_inputs, tmp_path / "runs")
    assert main(args) == 0
    manifest_path = tmp_path / "runs/tiny/manifest.json"
    original = manifest_path.read_bytes()
    with pytest.raises(SystemExit) as error:
        main(args)
    assert error.value.code == 2
    assert manifest_path.read_bytes() == original


def test_manifest_without_git_still_allows_run(
    tiny_inputs: tuple[Path, Path], tmp_path: Path, monkeypatch: pytest.MonkeyPatch,
) -> None:
    def unavailable(*args: object, **kwargs: object) -> None:
        raise FileNotFoundError("git unavailable")
    monkeypatch.setattr("pgacg.run_utils.subprocess.run", unavailable)
    assert main(cli_arguments(tiny_inputs, tmp_path / "runs")) == 0
    manifest = json.loads((tmp_path / "runs/tiny/manifest.json").read_text())
    assert manifest["code"]["git"] == {"revision": None, "dirty": None}


def test_python_module_cli_runs_in_new_process(tiny_inputs: tuple[Path, Path], tmp_path: Path) -> None:
    args = cli_arguments(tiny_inputs, tmp_path / "runs")
    process = subprocess.run(
        [sys.executable, "-m", "pgacg", *args], capture_output=True, text=True,
        env={**os.environ, "PYTHONPATH": str(repo_root() / "src")}, check=False,
    )
    assert process.returncode == 0, process.stderr
    manifest = json.loads((tmp_path / "runs/tiny/manifest.json").read_text())
    assert manifest["command_source"] == "process"
    assert manifest["command"] == [sys.executable, "-m", "pgacg", *args]
