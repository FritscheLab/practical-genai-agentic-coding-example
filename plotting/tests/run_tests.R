# Behavior checks; inspect the rendered image separately for readability.

script_arg <- grep("^--file=", commandArgs(), value = TRUE)
test_path <- normalizePath(gsub(
  "~+~", " ", sub("^--file=", "", script_arg[[1L]]), fixed = TRUE
))
script_path <- file.path(dirname(dirname(test_path)), "plot_summary.R")
scratch <- tempfile("plot checks ")
dir.create(scratch)

check <- function(condition, label) {
  if (!isTRUE(condition)) stop(paste("FAIL:", label), call. = FALSE)
  cat("PASS:", label, "\n")
}

check_png <- function(path) {
  signature <- readBin(path, what = "raw", n = 8L)
  identical(signature, as.raw(c(137, 80, 78, 71, 13, 10, 26, 10))) &&
    file.info(path)$size > 1000
}

run_cli <- function(arguments) {
  stdout_path <- file.path(scratch, "stdout.txt")
  stderr_path <- file.path(scratch, "stderr.txt")
  status <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    args = vapply(c(script_path, arguments), shQuote, character(1L)),
    stdout = stdout_path, stderr = stderr_path
  ))
  list(
    status = status,
    stdout = readLines(stdout_path, warn = FALSE),
    stderr = readLines(stderr_path, warn = FALSE)
  )
}

run_checks <- function() {
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  module <- new.env(parent = globalenv())
  source(script_path, local = module)
  expected_categories <- c(
    "Complete measurements", "Missing height only",
    "Missing weight only", "Missing height and weight"
  )
  check(
    identical(module$summary_categories, expected_categories) &&
      identical(module$summary_groups, c("Group A", "Group B")) &&
      identical(unname(module$summary_counts),
                matrix(c(42, 31, 18, 9, 64, 18, 12, 6), nrow = 2, byrow = TRUE)) &&
      identical(unname(rowSums(module$summary_counts)), c(100, 100)),
    "invented categories, groups, counts, and totals"
  )

  source(file.path(dirname(script_path), "check_figure.R"), local = TRUE)
  output <- file.path(scratch, "function result", "summary chart.png")
  previous_device <- dev.cur()
  probe <- plot_probe(script_path, output)
  drawn <- probe$observed
  check(
    identical(probe$result, output) && check_png(output) &&
      identical(dev.cur(), previous_device),
    "sourceable function writes PNG and closes its device"
  )
  # A repair may use one matrix barplot call or one call per group.
  if (length(drawn$bars) == 1L && is.matrix(drawn$bars[[1L]]$height)) {
    actual <- drawn$bars[[1L]]$height
    check(
      identical(colnames(actual), rev(expected_categories)) &&
        setequal(rownames(actual), c("Group A", "Group B")) &&
        identical(unname(actual[c("Group A", "Group B"), ]),
                  matrix(c(9, 18, 31, 42, 6, 12, 18, 64), nrow = 2, byrow = TRUE)),
      "drawn categories, groups, and counts keep their assignments"
    )
  } else {
    check(
      length(drawn$bars) == 2L &&
        identical(unname(drawn$bars[[1L]]$height), c(9, 18, 31, 42)) &&
        identical(unname(drawn$bars[[2L]]$height), c(6, 12, 18, 64)) &&
        all(vapply(drawn$bars, function(bar) {
          identical(bar$names, rev(expected_categories))
        }, logical(1L))),
      "drawn categories, groups, and counts keep their assignments"
    )
  }
  all_labels <- unlist(lapply(drawn$texts, function(item) as.character(item$labels)))
  count_labels <- as.numeric(all_labels[grepl("^[0-9]+$", all_labels)])
  check(
    all(vapply(drawn$bars, function(bar) isTRUE(bar$horizontal), logical(1L))) &&
      identical(sort(count_labels), sort(c(42, 31, 18, 9, 64, 18, 12, 6))),
    "all eight counts are drawn and labelled horizontally"
  )

  cli_output <- file.path(scratch, "new folder", "summary chart.png")
  result <- run_cli(c("--output", cli_output))
  check(
    result$status == 0L && length(result$stdout) == 0L &&
      length(result$stderr) == 0L && check_png(cli_output),
    "CLI writes a PNG to a nested path with spaces without console output"
  )

  invalid_arguments <- list(
    character(), "--output", "--unknown", c("--output", "chart.pdf"),
    c("--output", ""), c("--output", "chart.png", "extra")
  )
  for (arguments in invalid_arguments) {
    result <- run_cli(arguments)
    check(
      result$status == 2L && length(result$stdout) == 0L &&
        identical(result$stderr, "error: use --output PATH.png"),
      "incorrect arguments fail with status 2 and a stable diagnostic"
    )
  }

  blocker <- file.path(scratch, "ordinary file")
  writeLines("Keep this file.", blocker)
  result <- run_cli(c("--output", file.path(blocker, "summary.png")))
  check(
    result$status == 1L && length(result$stdout) == 0L &&
      identical(result$stderr, "error: could not write PNG") &&
      identical(readLines(blocker), "Keep this file."),
    "unwritable output fails with status 1 and preserves the existing file"
  )

  result <- run_cli("--help")
  check(
    result$status == 0L && length(result$stderr) == 0L &&
      any(grepl("--output", result$stdout, fixed = TRUE)),
    "CLI help succeeds"
  )
  cat("All plotting behavior checks passed; review image readability separately.\n")
}

run_checks()
