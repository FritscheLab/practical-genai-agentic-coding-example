# Six-measurement reporting example

These hand-written synthetic fixtures introduce the exclusion-report exercise.
They contain no patient records and are independent of the larger seeded simulation.

- `ehr.tsv`: six people, one measurement each. Measurements a, b, c are usable;
  d lacks height, e lacks weight, and f lacks both. Expected: 3 excluded of 6,
  missing height on 2 measurements and missing weight on 2 measurements.
- `ehr_complete.tsv`: the same six measurements with d/e/f filled to height
  170 cm and weight 70 kg. Expected: 0 excluded of 6.
- `demographics.tsv`: six synthetic people; blank optional fields are intentional.

All measurement dates are 2020-01-01. The three complete examples use heights
170/175/180 cm and weights 70/70/81 kg; the reported BMI agrees with the existing
pipeline's one-decimal calculation. No mismatch or IQR exclusion is expected.

The overlapping reason counts describe three excluded measurements, not four.
The exercise changes reporting only; both baseline pipelines already produce
the expected row-level decisions.

See [the exercise](../../../docs/lessons/02-specify.md) for the visible table and
plain-language acceptance criteria. The original simulator and its provenance
still describe the larger files one directory above, not these hand-written examples.
