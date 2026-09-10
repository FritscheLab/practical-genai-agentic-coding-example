# Describe the data the code should expect

A *data contract* is an agreement about the data: what each column means, which values are allowed, and what the program should do when something is missing or invalid. Writing this down helps prevent two people—or a person and an agent—from making different assumptions about the same file. See the [pipeline contract](../reference/io_contract.md) for a worked example.

Use synthetic fixtures in this repository. When adapting the template for a study elsewhere, record the data classification, permitted services and storage, and relevant study agreements in that project's approved documentation. The [lab data guidance](../reference/lab-data-policy.md) explains what to check.

```markdown
## Where the data comes from
Purpose: [question the dataset can answer]
Source/version: [synthetic source and version for this exercise]
Synthetic fixture: [path and generation recipe]

## Columns
| Column | Type | Units | Can be missing? | Meaning |
| --- | --- | --- | --- | --- |
| [name] | [type] | [unit] | [yes/no] | [definition] |

## Relationships and validation
Primary key: [which column(s) uniquely identify a row]
Join: [which columns link files, how many matches to expect, and what to do if none]
Invalid values: [reject, flag, or preserve with a reason]
Empty input: [schema and status]

## Calculated values
[Formula, thresholds, reference dates, precision, tie breaking, and source.]

## Running the program
Command: [command to run from the repo root]
Input and output files: [paths]
Existing output files: [whether to replace them or stop]
Success and failure: [exit status and where to find an explanation]

## Examples we can check by hand
[Hand-worked input/output cases, including boundaries.]
```
