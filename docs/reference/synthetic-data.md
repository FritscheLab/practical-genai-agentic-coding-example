# Invented summary counts

The plotting exercise compares two invented groups. These aggregate counts were written directly for teaching, not calculated from participant records:

| Category, in order | Group A | Group B |
| --- | ---: | ---: |
| Complete measurements | 42 | 64 |
| Missing height only | 31 | 18 |
| Missing weight only | 18 | 12 |
| Missing height and weight | 9 | 6 |
| **Total** | **100** | **100** |

The constants live in `plotting/plot_summary.py` and `plotting/plot_summary.R`. There are no input data files or participant identifiers. The health-related labels supply familiar context; these numbers are not findings or clinical guidance.

The learner repairs the grouped chart and follows the fictional [journal figure specifications](figure-specifications.md), keeping all eight counts and group assignments unchanged. The [plotting contract](io_contract.md) describes program behavior.

For actual results, check what the selected service may receive before sharing a chart, summary, code, or logs. Aggregation alone does not establish that information may be disclosed; see [lab data guidance](lab-data-policy.md).
