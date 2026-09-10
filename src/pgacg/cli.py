from __future__ import annotations

import argparse
import sys
from math import isfinite
from pathlib import Path

from pgacg.cleaning import CleaningParams, clean_ehr_and_select_typical
from pgacg.io import DEMO_REQUIRED_COLUMNS, EHR_REQUIRED_COLUMNS, read_tsv, write_tsv
from pgacg.reporting import write_failure_summary, write_output_data_dictionary, write_run_summary
from pgacg.run_utils import (
    RunPaths,
    create_manifest,
    generate_run_id,
    setup_logging,
    sha256_file,
    validate_run_id,
    write_manifest,
)


def nonnegative_finite_float(value: str) -> float:
    try:
        number = float(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("must be a finite, nonnegative number") from exc
    if not isfinite(number) or number < 0:
        raise argparse.ArgumentTypeError("must be a finite, nonnegative number")
    return number


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="pgacg", description="Agentic coding demo pipeline")
    sub = parser.add_subparsers(dest="command", required=True)
    demo = sub.add_parser("demo", help="Run the synthetic teaching pipeline")
    demo.add_argument("--ehr", type=Path, required=True, help="Path to EHR BMI TSV")
    demo.add_argument("--demo", type=Path, required=True, help="Path to demographics TSV")
    demo.add_argument("--runs_dir", type=Path, default=Path("runs"), help="Base runs directory")
    demo.add_argument("--run_id", type=validate_run_id, default=None, help="Optional run id (default: auto)")
    demo.add_argument("--mismatch_threshold", type=nonnegative_finite_float, default=2.0, help="Finite, nonnegative absolute BMI mismatch threshold")
    demo.add_argument("--verbose", action="store_true", help="Include debug messages in console logs")
    return parser


def cmd_demo(args: argparse.Namespace, *, command: list[str], command_source: str) -> int:
    params = CleaningParams(mismatch_threshold=args.mismatch_threshold)
    run_id = args.run_id or generate_run_id()
    run_paths = RunPaths.create(args.runs_dir, run_id)
    logger = setup_logging(run_paths.logs_dir / "pipeline.log", verbose=args.verbose)
    logger.info("Starting pgacg demo run: %s", run_id)
    manifest = create_manifest(
        run_id=run_id, params=params, ehr_path=args.ehr, demo_path=args.demo,
        command=command, command_source=command_source,
    )
    try:
        write_manifest(run_paths, manifest)
        logger.debug("Parameters: %s", manifest["parameters"])
        for details in manifest["inputs"].values():
            details["sha256"] = sha256_file(Path(details["path"]))
        ehr_df = read_tsv(args.ehr, EHR_REQUIRED_COLUMNS, parse_dates=["measurement_date"])
        demo_df = read_tsv(args.demo, DEMO_REQUIRED_COLUMNS, parse_dates=["date_of_birth"])
        cleaned, flagged_rows, flagged_people, metrics = clean_ehr_and_select_typical(
            ehr_df, demo_df, params
        )
        write_tsv(cleaned, run_paths.outputs_dir / "cleaned_bmi_person.tsv")
        write_tsv(flagged_rows, run_paths.outputs_dir / "flagged_rows.tsv")
        write_tsv(flagged_people, run_paths.outputs_dir / "flagged_people.tsv")
        write_output_data_dictionary(run_paths.outputs_dir / "cleaned_bmi_person_data_dictionary.md")
        write_run_summary(
            run_paths.summary_path, run_id=run_id, params=params, metrics=metrics,
            cleaned=cleaned, ehr_path=args.ehr, demo_path=args.demo,
        )
        manifest["status"] = "success"
        manifest["metrics"] = metrics
        write_manifest(run_paths, manifest, finished=True)
    except Exception as exc:
        error = f"{type(exc).__name__}: {exc}"
        logger.error("Run failed: %s", error)
        logger.debug("Failure details", exc_info=True)
        manifest["status"] = "failed"
        manifest["error"] = error
        try:
            write_failure_summary(
                run_paths.summary_path, run_id=run_id, error=error, params=params,
                ehr_path=args.ehr, demo_path=args.demo,
            )
            write_manifest(run_paths, manifest, finished=True)
        except OSError as report_error:
            logger.error("Could not save failure artifacts: %s", report_error)
        return 1
    logger.info("Wrote outputs to: %s", run_paths.outputs_dir)
    logger.info("Wrote summary: %s", run_paths.summary_path)
    logger.info("Done.")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if argv is None:
        command = [sys.executable, *sys.orig_argv[1:]]
        command_source = "process"
    else:
        command = [sys.executable, "-m", "pgacg", *argv]
        command_source = "equivalent_module_invocation"
    try:
        return cmd_demo(args, command=command, command_source=command_source)
    except (OSError, ValueError) as exc:
        # Invalid arguments or an existing/unwritable run directory fail before running.
        parser.error(str(exc))
    return 2
