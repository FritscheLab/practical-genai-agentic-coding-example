from __future__ import annotations

import hashlib
import json
import logging
import platform
import random
import re
import string
import subprocess
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from importlib.metadata import version
from pathlib import Path

from pgacg import __version__
from pgacg.cleaning import CleaningParams


def generate_run_id(prefix: str = "", dt: datetime | None = None) -> str:
    """Generate YYYYMMDD_HHMMSS_<rand4>, with an optional prefix."""
    dt = dt or datetime.now(timezone.utc)
    stamp = dt.strftime("%Y%m%d_%H%M%S")
    rand = "".join(random.choices(string.ascii_lowercase + string.digits, k=4))
    return f"{prefix}{stamp}_{rand}"


def validate_run_id(run_id: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", run_id):
        raise ValueError("run_id must start with a letter or digit and contain only letters, digits, _, ., or -")
    return run_id


@dataclass(frozen=True)
class RunPaths:
    run_dir: Path
    logs_dir: Path
    outputs_dir: Path
    summary_path: Path

    @staticmethod
    def create(base_dir: Path, run_id: str) -> RunPaths:
        run_dir = Path(base_dir) / validate_run_id(run_id)
        # Reserve the whole directory so an existing partial run is never overwritten.
        run_dir.mkdir(parents=True, exist_ok=False)
        logs_dir = run_dir / "logs"
        outputs_dir = run_dir / "outputs"
        logs_dir.mkdir()
        outputs_dir.mkdir()
        return RunPaths(run_dir, logs_dir, outputs_dir, run_dir / "summary.md")


def setup_logging(log_file: Path | None = None, verbose: bool = False) -> logging.Logger:
    """Configure independent console and file handlers for each invocation."""
    logger = logging.getLogger("pgacg")
    logger.setLevel(logging.DEBUG)
    logger.propagate = False
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)
        handler.close()

    fmt = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG if verbose else logging.INFO)
    console.setFormatter(fmt)
    logger.addHandler(console)

    if log_file is not None:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        handler = logging.FileHandler(log_file, encoding="utf-8")
        handler.setLevel(logging.DEBUG)
        handler.setFormatter(fmt)
        logger.addHandler(handler)
    return logger


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _git_state() -> dict[str, str | bool | None]:
    source_root = Path(__file__).resolve().parents[2]
    state: dict[str, str | bool | None] = {"revision": None, "dirty": None}
    # A wheel installed inside another repository must not inherit that repository's revision.
    if (source_root / "src/pgacg/run_utils.py").resolve() != Path(__file__).resolve():
        return state
    for name, args in (
        ("revision", ["rev-parse", "HEAD"]),
        ("dirty", ["status", "--porcelain", "--untracked-files=normal"]),
    ):
        try:
            result = subprocess.run(
                ["git", "-C", str(source_root), *args],
                capture_output=True, text=True, timeout=5, check=False,
            )
        except (OSError, subprocess.TimeoutExpired):
            continue
        if result.returncode == 0:
            state[name] = bool(result.stdout.strip()) if name == "dirty" else result.stdout.strip()
    return state


def create_manifest(
    *, run_id: str, params: CleaningParams, ehr_path: Path, demo_path: Path,
    command: list[str], command_source: str,
) -> dict:
    """Describe a run before I/O; unavailable Git metadata is recorded as null."""
    return {
        "schema_version": 1,
        "run_id": run_id,
        "status": "running",
        "started_at": datetime.now(timezone.utc).isoformat(),
        "finished_at": None,
        "command": command,
        "command_source": command_source,
        "working_directory": str(Path.cwd()),
        "parameters": asdict(params),
        "inputs": {
            "ehr": {"path": str(ehr_path.resolve()), "sha256": None},
            "demographics": {"path": str(demo_path.resolve()), "sha256": None},
        },
        "code": {"version": __version__, "git": _git_state()},
        "environment": {
            "python": platform.python_version(),
            "implementation": platform.python_implementation(),
            "platform": platform.platform(),
            "dependencies": {name: version(name) for name in ("pandas", "numpy")},
        },
        "artifacts": {},
        "error": None,
    }


def write_manifest(run_paths: RunPaths, manifest: dict, *, finished: bool = False) -> None:
    if finished:
        manifest["finished_at"] = datetime.now(timezone.utc).isoformat()
        paths = [run_paths.summary_path, *sorted(run_paths.outputs_dir.glob("*"))]
        manifest["artifacts"] = {
            str(path.relative_to(run_paths.run_dir)): {
                "sha256": sha256_file(path), "size_bytes": path.stat().st_size,
            }
            for path in paths if path.is_file()
        }
    path = run_paths.run_dir / "manifest.json"
    temporary = path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(manifest, indent=2, allow_nan=False) + "\n", encoding="utf-8")
    temporary.replace(path)
