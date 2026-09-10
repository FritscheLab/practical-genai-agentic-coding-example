---
name: lab-r-refactor
description: Refactor an existing R script into the lab format with metadata, emoji section headings, readable code, and explanatory comments while preserving its behavior. Use for requests to organize or format R scripts.
---

# Refactor an R script into the lab format

Before editing, read the [lab R template](references/lab-r-template.md). Use its examples to organize the script.

Work from source code and invented examples. Do not inspect data tables or participant records, and do not diagnose individual data points. If a check needs study data, report it as not run.

## Procedure

1. Read the requested script and applicable repository instructions. Identify its arguments, dependencies, calculations, validation, outputs, and existing checks. Save an unchanged copy in permitted scratch space for comparison.
2. Add or tidy the metadata header. Preserve existing authorship, creation dates, and other recorded history. Use `Not recorded` for unknown values; do not infer authorship from the repository owner or use today's date as a creation date. Describe only what the script actually does.
3. Organize the code using only applicable sections from the local template. Add one relevant emoji to each section-heading comment, such as `⚙️ Constants`, `📊 Plotting function`, or `▶️ Command-line arguments`. Keep the words so headings remain clear without the symbol. Use emojis only in comments, never in strings, object names, chart text, or console output. Keep execution order and scope intact. Use two-space indentation, consistent spacing, readable line breaks, and descriptive names where safe. Add short comments explaining intent or a non-obvious decision; avoid narrating each expression.
4. Preserve the script's behavior: argument interface, dependencies, calculations, validation, output contents and formatting, stdout, stderr, and exit status. Do not redirect data from `cat()` or `write.table()` to `message()`. Do not add packages, dependency installation, `optparse`, flags, logging, timestamps, `sessionInfo()`, new validation, or other functional features unless the user requests them. If you notice a defect, report it separately rather than silently changing the calculation during formatting.
5. Run the available automated checks on the original and candidate with the same invented examples and arguments. Let the verifier compare image contents, stdout, stderr, and exit status; use its pass/fail results. For this repository's optional exercise, run `Rscript examples/r_refactor/verify.R <candidate-script>` from the repository root. Inspect the code diff separately to confirm that organization improved. Passing behavior checks alone does not show that refactoring occurred.
6. For repository work, edit the requested file and report the organization changes, commands actually run, outcomes, and any untested behavior. If the user asks for returned code instead, provide the complete refactored script in an R code block; do not replace that deliverable with file edits. Never imply checks ran when they did not.
