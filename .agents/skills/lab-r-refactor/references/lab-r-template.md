# Lab R formatting template

Use these header and section examples to organize an R script. This template is inspired by Part 1's R refactoring example. Keep the script's behavior unchanged.

## Header

Use the actual filename and preserve recorded authorship and dates. Write `Not recorded` when that information is unknown. This example describes the plotting exercise:

```r
# ==============================================================================
# Script: plot_summary.R
# Description: Draw a chart from invented aggregate measurement counts.
# Author: Not recorded
# Date: Not recorded
# Input: Fixed category labels and counts defined in the source code.
# Output: A PNG chart at the requested output path.
# ==============================================================================
```

## Sections and formatting

Give each useful section a small visual marker: `⚙️ Constants`, `📊 Plotting function`, or `▶️ Command-line arguments`. Keep the descriptive words and omit empty sections. Put emojis in comments only; preserve strings, object names, chart text, and console output. Save the script as UTF-8 and keep execution order unchanged.

```r
# --- ⚙️ Constants -------------------------------------------------------------
# Keep the supplied category order so before/after charts remain comparable.
counts <- rbind(
  "Group A" = c(42, 31, 18, 9),
  "Group B" = c(64, 18, 12, 6)
)

# --- 📊 Plotting function -----------------------------------------------------
# Keep the existing plotting calls here, with readable spacing and line breaks.

# --- ▶️ Command-line arguments ------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
```

These snippets show organization, not a replacement implementation. Keep the requested script's own values, plotting calls, validation, messages, and output handling. Do not add logging, packages, or session information just to fill a section.
