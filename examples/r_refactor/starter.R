summary_categories <- c("Complete measurements", "Missing height only", "Missing weight only",
"Missing height and weight")
summary_groups <- c("Group A", "Group B")
summary_counts <- matrix(c(42, 31, 18, 9, 64, 18, 12, 6), nrow = 2, byrow = TRUE, dimnames = list(summary_groups,
summary_categories))
plot_summary <- function(output_path) {
if (length(output_path) != 1L || is.na(output_path) || !nzchar(output_path) || !endsWith(tolower(output_path),
".png")) {
stop("output path must end in .png", call. = FALSE)
}
output_dir <- dirname(output_path)
if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)) {
stop("could not create output directory", call. = FALSE)
}
png(filename = output_path, width = 768, height = 456, res = 120, type = if (capabilities("cairo"))
"cairo"
else getOption("bitmapType"))
on.exit(dev.off(), add = TRUE)
par(mar = c(4, 5, 3, 1))
for (group in seq_along(summary_groups)) {
counts <- rev(summary_counts[group, ])
positions <- barplot(counts, names.arg = rev(summary_categories), horiz = TRUE, las = 1,
col = "#0f766e", border = NA, xlim = c(0, 80), xlab = "Invented measurement count",
main = "Measurement completeness (invented totals)", add = group > 1)
text(counts, positions, labels = counts, pos = 4)
}
invisible(output_path)
}
main <- function(args = commandArgs(trailingOnly = TRUE)) {
if (identical(args, "--help")) {
cat("Usage: Rscript summary.R --output PATH.png\n")
return(0L)
}
if (length(args) != 2L || args[[1L]] != "--output" || !nzchar(args[[2L]]) || startsWith(args[[2L]],
"--") || !endsWith(tolower(args[[2L]]), ".png")) {
cat("error: use --output PATH.png\n", file = stderr())
return(2L)
}
tryCatch({
plot_summary(args[[2L]])
0L
}, error = function(error) {
cat("error: could not write PNG\n", file = stderr())
1L
})
}
if (sys.nframe() == 0L) {
quit(status = main())
}
