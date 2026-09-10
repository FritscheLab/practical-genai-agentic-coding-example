# Synthetic teaching data

`data/example/` contains the small generated input files used by the quickstart. The generation command, versions, checksums, and expected baseline counts are documented in [Synthetic data](../docs/reference/synthetic-data.md); `data/example/provenance.json` records the file identities.

- Track only these small synthetic examples and their dictionaries/provenance.
- Generate optional larger examples under `data/raw/`.
- Keep pipeline runs under ignored `runs/` or another explicitly chosen approved directory.
- Never commit real records or treat `.gitignore` as an access control.

The examples include missing and implausible values by design. They are generated independently of real individuals and support software exercises, not clinical conclusions.
