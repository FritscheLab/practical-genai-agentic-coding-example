# Source this file to call main(args) without starting a process.
.pgacg_root <- normalizePath(file.path(dirname(sys.frame(1)$ofile), ".."),
                              winslash = "/", mustWork = TRUE)
for (.pgacg_module in c("io.R", "cleaning.R", "run_utils.R", "reporting.R")) {
  source(file.path(.pgacg_root, "R", .pgacg_module), local = TRUE)
}
rm(.pgacg_module)

cli_usage <- function() {
  paste(
    "Usage: Rscript scripts/r/demo.R --ehr PATH --demo PATH [options]",
    "Run the synthetic BMI teaching pipeline in R.", "",
    "  --ehr PATH                  EHR BMI TSV (required)",
    "  --demo PATH                 Demographics TSV (required)",
    "  --runs_dir PATH             Parent output directory (default: runs)",
    "  --run_id ID                 Optional run ID (default: generated)",
    "  --mismatch_threshold N      Finite, nonnegative threshold (default: 2)",
    "  --verbose                  Include diagnostic console messages",
    "  --help                     Show this help", sep = "\n"
  )
}

parse_cli_args <- function(args) {
  parsed <- list(ehr = NULL, demo = NULL, runs_dir = "runs", run_id = NULL,
                  mismatch_threshold = 2, verbose = FALSE, help = FALSE)
  value_flags <- c("ehr", "demo", "runs_dir", "run_id", "mismatch_threshold")
  i <- 1L
  while (i <= length(args)) {
    argument <- args[[i]]
    if (argument %in% c("--help", "-h")) {
      parsed$help <- TRUE
      return(parsed)
    }
    if (argument == "--verbose") {
      parsed$verbose <- TRUE
      i <- i + 1L
      next
    }
    if (!startsWith(argument, "--")) stop(sprintf("Unexpected argument: %s", argument))
    flag <- sub("=.*$", "", substring(argument, 3))
    if (!flag %in% value_flags) stop(sprintf("Unknown option: --%s", flag))
    if (grepl("=", argument, fixed = TRUE)) {
      value <- sub("^[^=]*=", "", argument)
    } else {
      i <- i + 1L
      if (i > length(args) || startsWith(args[[i]], "--")) {
        stop(sprintf("Option --%s requires a value", flag))
      }
      value <- args[[i]]
    }
    if (!nzchar(value)) stop(sprintf("Option --%s requires a nonempty value", flag))
    parsed[[flag]] <- value
    i <- i + 1L
  }
  if (is.null(parsed$ehr) || is.null(parsed$demo)) stop("--ehr and --demo are required")
  threshold <- suppressWarnings(as.numeric(parsed$mismatch_threshold))
  if (length(threshold) != 1L || !is.finite(threshold) || threshold < 0) {
    stop("--mismatch_threshold must be a finite, nonnegative number")
  }
  parsed$mismatch_threshold <- threshold
  if (!is.null(parsed$run_id)) validate_run_id(parsed$run_id)
  parsed
}

cmd_demo <- function(args, command, command_source) {
  params <- cleaning_params(mismatch_threshold = args$mismatch_threshold)
  run_id <- if (is.null(args$run_id)) generate_run_id() else args$run_id
  run_paths <- create_run_paths(args$runs_dir, run_id)
  logger <- setup_logging(file.path(run_paths$logs_dir, "pipeline.log"), args$verbose)
  logger("INFO", sprintf("Starting pgacg R demo run: %s", run_id))
  manifest <- create_manifest(run_id, params, args$ehr, args$demo, command, command_source)
  error_calls <- character()
  outcome <- tryCatch(withCallingHandlers({
    write_manifest(run_paths, manifest)
    logger("DEBUG", paste(parameter_lines(params), collapse = "; "))
    for (name in names(manifest$inputs)) {
      manifest$inputs[[name]]$sha256 <- sha256_file(manifest$inputs[[name]]$path)
    }
    ehr <- read_tsv(args$ehr, EHR_REQUIRED_COLUMNS, "measurement_date")
    demo <- read_tsv(args$demo, DEMO_REQUIRED_COLUMNS, "date_of_birth")
    result <- clean_ehr_and_select_typical(ehr, demo, params)
    write_tsv(result$cleaned, file.path(run_paths$outputs_dir, "cleaned_bmi_person.tsv"))
    write_tsv(result$flagged_rows, file.path(run_paths$outputs_dir, "flagged_rows.tsv"))
    write_tsv(result$flagged_people, file.path(run_paths$outputs_dir, "flagged_people.tsv"))
    write_output_data_dictionary(file.path(run_paths$outputs_dir, "cleaned_bmi_person_data_dictionary.md"))
    write_run_summary(run_paths$summary_path, run_id, params, result$metrics,
                       result$cleaned, args$ehr, args$demo)
    manifest$status <- "success"
    manifest$metrics <- result$metrics
    write_manifest(run_paths, manifest, finished = TRUE)
    0L
  }, error = function(error) {
    error_calls <<- vapply(sys.calls(), function(call) paste(deparse(call), collapse = " "), character(1))
  }), error = function(error) {
    error_text <- sprintf("%s: %s", class(error)[1], conditionMessage(error))
    logger("ERROR", paste("Run failed:", error_text))
    logger("DEBUG", paste("Call stack:", paste(error_calls, collapse = "\n"), sep = "\n"))
    manifest$status <- "failed"
    manifest$error <- error_text
    tryCatch({
      write_failure_summary(run_paths$summary_path, run_id, error_text, params, args$ehr, args$demo)
      write_manifest(run_paths, manifest, finished = TRUE)
    }, error = function(report_error) {
      logger("ERROR", paste("Could not save failure artifacts:", conditionMessage(report_error)))
    })
    1L
  })
  if (outcome == 0L) {
    logger("INFO", paste("Wrote outputs to:", run_paths$outputs_dir))
    logger("INFO", paste("Wrote summary:", run_paths$summary_path))
    logger("INFO", "Done.")
  }
  outcome
}

main <- function(args = commandArgs(trailingOnly = TRUE)) {
  process_invocation <- missing(args)
  tryCatch({
    parsed <- parse_cli_args(args)
    if (parsed$help) {
      cat(cli_usage(), "\n", sep = "")
      return(0L)
    }
    require_dependencies()
    command <- if (process_invocation) commandArgs() else
      c(file.path(R.home("bin"), "Rscript"), file.path(.pgacg_root, "scripts", "r", "demo.R"), args)
    file_argument <- startsWith(command, "--file=")
    command[file_argument] <- gsub("~+~", " ", command[file_argument], fixed = TRUE)
    command_source <- if (process_invocation) "process" else "equivalent_script_invocation"
    cmd_demo(parsed, command, command_source)
  }, error = function(error) {
    cat("pgacg R: ", conditionMessage(error), "\n", file = stderr(), sep = "")
    2L
  })
}
