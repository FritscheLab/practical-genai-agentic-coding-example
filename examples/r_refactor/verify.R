#!/usr/bin/env Rscript
# Verify formatting changes without inspecting data: fixed constants, PNG bytes,
# stdout, stderr, and process status. The starter's chart layout is preserved.

read_bytes <- function(path) {
  if (!file.exists(path)) {
    stop('FAIL: expected output file was not created', call. = FALSE)
  }
  readBin(path, what = 'raw', n = file.info(path)$size)
}

check_equal <- function(actual, expected, label) {
  if (!identical(actual, expected)) {
    stop(paste('FAIL:', label), call. = FALSE)
  }
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 1L) {
    cat('Usage: Rscript examples/r_refactor/verify.R [candidate-script]\n',
        file = stderr())
    quit(save = 'no', status = 2L)
  }
  file_arg <- grep('^--file=', commandArgs(), value = TRUE)[1L]
  verifier <- gsub('~+~', ' ', sub('^--file=', '', file_arg), fixed = TRUE)
  directory <- dirname(normalizePath(verifier, mustWork = TRUE))
  original <- file.path(directory, 'starter.R')
  candidates <- if (length(args)) args else file.path(directory, c('starter.R', 'reference.R'))
  candidates <- normalizePath(candidates, mustWork = TRUE)
  scratch <- tempfile('R plot refactor checks ')
  dir.create(scratch)
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  rscript <- file.path(R.home('bin'), 'Rscript')

  run_script <- function(script, arguments) {
    out <- file.path(scratch, 'stdout.txt')
    err <- file.path(scratch, 'stderr.txt')
    status <- suppressWarnings(system2(
      rscript, c('--vanilla', shQuote(script), shQuote(arguments)),
      stdout = out, stderr = err, timeout = 30
    ))
    list(status = as.integer(status), stdout = read_bytes(out), stderr = read_bytes(err))
  }
  usage <- charToRaw('error: use --output PATH.png\n')
  help <- charToRaw('Usage: Rscript summary.R --output PATH.png\n')
  expected_labels <- c('Complete measurements', 'Missing height only',
                       'Missing weight only', 'Missing height and weight')
  baseline_png <- file.path(scratch, 'baseline.png')
  result <- run_script(original, c('--output', baseline_png))
  check_equal(result, list(status = 0L, stdout = raw(), stderr = raw()), 'original render')
  baseline <- read_bytes(baseline_png)
  check_equal(baseline[1:8], as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)), 'original PNG signature')

  for (candidate in candidates) {
    module <- new.env(parent = globalenv())
    sys.source(candidate, envir = module)
    check_equal(module$summary_categories, expected_labels, 'fixed category labels')
    check_equal(module$summary_groups, c('Group A', 'Group B'), 'fixed groups')
    expected_counts <- matrix(
      c(42, 31, 18, 9, 64, 18, 12, 6), nrow = 2, byrow = TRUE,
      dimnames = list(c('Group A', 'Group B'), expected_labels)
    )
    check_equal(module$summary_counts, expected_counts, 'fixed counts and assignments')
    check_equal(unname(rowSums(module$summary_counts)), c(100, 100), 'fixed group totals')

    spaced_script <- file.path(scratch, 'candidate script with spaces.R')
    stopifnot(file.copy(candidate, spaced_script, overwrite = TRUE))
    output <- file.path(tempfile('new output folder ', tmpdir = scratch), 'summary image.png')
    result <- run_script(spaced_script, c('--output', output))
    check_equal(result, list(status = 0L, stdout = raw(), stderr = raw()), 'render streams/status')
    check_equal(read_bytes(output), baseline, 'original-versus-candidate PNG contents')

    for (arguments in list(character(), '--output', c('--output', 'wrong.pdf'),
                           c('--output', 'extra.png', 'extra'))) {
      result <- run_script(candidate, arguments)
      check_equal(result, list(status = 2L, stdout = raw(), stderr = usage), 'invalid arguments')
    }
    blocker <- file.path(scratch, 'ordinary file')
    writeLines('Keep this file.', blocker)
    result <- run_script(candidate, c('--output', file.path(blocker, 'plot.png')))
    check_equal(result, list(status = 1L, stdout = raw(),
                            stderr = charToRaw('error: could not write PNG\n')), 'write failure')
    check_equal(readLines(blocker), 'Keep this file.', 'existing file preservation')
    check_equal(run_script(candidate, '--help'),
                list(status = 0L, stdout = help, stderr = raw()), 'help output')
    cat('PASS:', basename(candidate), '(constants, PNG contents, streams, and exit status)\n')
  }
  cat('Behavior preserved; inspect the code diff separately for formatting.\n')
}

main()
