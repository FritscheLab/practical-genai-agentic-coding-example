"""Verify generated teaching inputs against the recorded fixture identity."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, default=root / "data/example")
    args = parser.parse_args()
    provenance = json.loads((root / "data/example/provenance.json").read_text())
    failures = []
    for name, expected in provenance["files"].items():
        path = args.directory / name
        if not path.is_file():
            failures.append(f"Missing: {path}")
        elif hashlib.sha256(path.read_bytes()).hexdigest() != expected["sha256"]:
            failures.append(f"Checksum differs: {path}")
    generator = root / provenance["generator"]
    if hashlib.sha256(generator.read_bytes()).hexdigest() != provenance["generator_sha256"]:
        failures.append("Generator changed: review the fixture recipe and provenance together.")
    if failures:
        print("\n".join(failures))
        return 1
    print(f"Verified {len(provenance['files'])} synthetic input files and simulator identity.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
