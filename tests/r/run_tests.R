#!/usr/bin/env Rscript
# Independent, hand-calculated cases; run without Python or a test framework.
script <- gsub("~+~", " ", sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]),
                fixed = TRUE)
root <- normalizePath(file.path(dirname(script), "..", ".."), mustWork = TRUE)
source(file.path(root, "R", "cli.R"))
require_dependencies()
scratch <- tempfile("pgacg R tests ")
dir.create(scratch)

checks <- 0L
check <- function(label, code) {
  tryCatch(force(code), error = function(error) {
    stop(sprintf("FAIL: %s\n%s", label, conditionMessage(error)), call. = FALSE)
  })
  checks <<- checks + 1L
  cat(sprintf("ok %d - %s\n", checks, label))
}
expect_error <- function(code, pattern) {
  error <- tryCatch({force(code); NULL}, error = identity)
  stopifnot(inherits(error, "error"), grepl(pattern, conditionMessage(error)))
}
demographics <- function(people) {
  frame <- as.data.frame(setNames(rep(list(rep("", length(people))),
                                      length(DEMO_REQUIRED_COLUMNS)), DEMO_REQUIRED_COLUMNS),
                          stringsAsFactors = FALSE)
  frame$person_id <- people
  frame$date_of_birth <- rep("1980-01-01", length(people))
  frame$age <- rep("40", length(people))
  frame$zip3 <- rep("012", length(people))
  frame
}
ehr_rows <- function(...) {
  rows <- list(...)
  if (!length(rows)) return(as.data.frame(setNames(rep(list(character()), 6), EHR_REQUIRED_COLUMNS)))
  frame <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(frame) <- EHR_REQUIRED_COLUMNS
  frame
}
clean <- function(ehr, people, params = cleaning_params()) {
  clean_ehr_and_select_typical(ehr, demographics(people), params)
}

check("known selected encounters, imputation, overlapping reasons, and counts", {
  result <- clean(ehr_rows(
    c("p1", "a", 20, 200, 80, "2020-01-01"),
    c("p1", "b", 22, 200, 88, "2020-01-02"),
    c("p1", "c", 24, 200, 96, "2020-01-03"),
    c("p2", "d", NA, 200, 100, "2020-01-01"),
    c("p3", "bad", 24, 50, 60, "2020-01-01")), c("p1", "p2", "p3", "p4"))
  stopifnot(identical(result$cleaned$encounter_id, c("b", "d")),
    identical(result$cleaned$bmi, c(22, 25)),
    identical(result$cleaned$bmi_imputed, c(FALSE, TRUE)),
    identical(result$cleaned$bmi_category, c("Normal", "Overweight")),
    identical(result$cleaned$zip3, c("012", "012")),
    identical(result$flagged_rows$reasons, "implausible_height;bmi_mismatch"),
    identical(result$flagged_people$person_id, c("p3", "p4")),
    result$metrics$n_rows_input == 5, result$metrics$n_rows_kept_after_row_filters == 4,
    result$metrics$n_rows_flagged_total == 1)
})

check("mismatch excludes strictly above the threshold", {
  ehr <- ehr_rows(c("p", "a", 24, 200, 88, "2020-01-01"))
  stopifnot(nrow(clean(ehr, "p", cleaning_params(mismatch_threshold = 2))$cleaned) == 1,
    nrow(clean(ehr, "p", cleaning_params(mismatch_threshold = 1.9))$cleaned) == 0,
    nrow(clean(ehr, "p", cleaning_params(mismatch_threshold = 0))$cleaned) == 0)
})

check("IQR removes outliers before choosing the latest median record", {
  ehr <- ehr_rows(c("p", "a", 20, 200, 80, "2020-01-01"),
                  c("p", "b", 20, 200, 80, "2020-01-02"),
                  c("p", "c", 20, 200, 80, "2020-01-03"),
                  c("p", "d", 20, 200, 80, "2020-01-04"),
                  c("p", "high", 40, 200, 160, "2020-01-05"))
  result <- clean(ehr, "p")
  stopifnot(result$cleaned$encounter_id == "d", result$flagged_rows$encounter_id == "high",
    result$flagged_rows$reasons == "per_person_iqr_outlier", result$metrics$n_rows_outliers == 1)
  # With three observations the rule does not apply, even when IQR multiplier is zero.
  stopifnot(clean(ehr[c(1, 2, 5), ], "p", cleaning_params(iqr_multiplier = 0))$metrics$n_rows_outliers == 0)
})

check("IQR uses linear quartiles and keeps equality at the fence", {
  # Q1=21.5, Q3=24.5, IQR=3; with multiplier 0.5 the fences are 20 and 26.
  ehr <- ehr_rows(c("p", "a", 20, 200, 80, "2020-01-01"),
                  c("p", "b", 22, 200, 88, "2020-01-02"),
                  c("p", "c", 24, 200, 96, "2020-01-03"),
                  c("p", "d", 26, 200, 104, "2020-01-04"))
  result <- clean(ehr, "p", cleaning_params(iqr_multiplier = 0.5))
  stopifnot(result$metrics$n_rows_outliers == 0, result$cleaned$encounter_id == "c")
})

check("selection uses latest timestamp and text encounter order regardless of row order", {
  ehr <- ehr_rows(c("p", "old", 20, 200, 80, "2020-01-01 13:00:00"),
                  c("p", "e2", 20, 200, 80, "2020-01-02 13:00:00"),
                  c("p", "e10", 24, 200, 96, "2020-01-02 13:00:00"),
                  c("p", "older", 24, 200, 96, "2020-01-01 13:00:00"))
  for (seed in 1:5) {
    set.seed(seed)
    result <- clean(ehr[sample(4), ], "p")
    stopifnot(result$cleaned$encounter_id == "e10", result$cleaned$bmi == 24)
  }
})

check("BMI category boundaries", {
  bmi <- c(18.4, 18.5, 24.9, 25, 29.9, 30, 34.9, 35, 39.9, 40)
  people <- sprintf("p%02d", seq_along(bmi))
  ehr <- data.frame(person_id = people, encounter_id = people, bmi = bmi,
                    height_cm = 200, weight_kg = bmi * 4, measurement_date = "2020-01-01")
  stopifnot(identical(clean(ehr, people)$cleaned$bmi_category,
    c("Underweight", "Normal", "Normal", "Overweight", "Overweight", "Obesity I",
      "Obesity I", "Obesity II", "Obesity II", "Obesity III")))
})

check("height and weight category boundaries", {
  height <- c(149.9, 150, 179.9, 180)
  people <- paste0("p", seq_along(height))
  ehr <- data.frame(person_id = people, encounter_id = people, bmi = 20,
                    height_cm = height, weight_kg = 20 * (height / 100)^2,
                    measurement_date = "2020-01-01")
  stopifnot(identical(clean(ehr, people)$cleaned$height_category,
                      c("Short", "Average", "Average", "Tall")))
  weight <- c(49.9, 50, 79.9, 80, 99.9, 100)
  people <- paste0("p", seq_along(weight))
  ehr <- data.frame(person_id = people, encounter_id = people, bmi = weight / 2.25,
                    height_cm = 150, weight_kg = weight, measurement_date = "2020-01-01")
  stopifnot(identical(clean(ehr, people)$cleaned$weight_category,
                      c("Light", "Medium", "Medium", "Heavy", "Heavy", "Very Heavy")))
})

check("plausibility endpoints are included", {
  ehr <- ehr_rows(c("a", "a", 25, 100, 25, "2020-01-01"),
                  c("b", "b", 48, 250, 300, "2020-01-01"),
                  c("c", "c", 10, 200, 40, "2020-01-01"),
                  c("d", "d", 70, 200, 280, "2020-01-01"))
  stopifnot(nrow(clean(ehr, letters[1:4])$cleaned) == 4)
})

check("scaled nearest-even rounding matches the shared contract", {
  ehr <- ehr_rows(c("a", "a", NA, 200, 80.2, "2020-01-01"),
                  c("b", "b", NA, 200, 80.6, "2020-01-01"))
  stopifnot(identical(clean(ehr, c("a", "b"))$cleaned$bmi, c(20, 20.2)))
})

check("missing identifiers, dates, and nonnumeric measurements are excluded", {
  ehr <- ehr_rows(c("", "a", 20, 200, 80, "2020-01-01"),
                  c("p", NA, 20, 200, 80, "2020-01-01"),
                  c("p", "b", 20, 200, 80, "bad-date"),
                  c("p", "c", 20, "text", NA, "2020-01-01"))
  result <- clean(ehr, "p")
  stopifnot(nrow(result$cleaned) == 0,
    identical(result$flagged_rows$reasons,
      c(rep("missing_id_or_date", 3), "missing_height;missing_weight")))
})

check("empty and all-excluded EHR retain output columns and flag demographics", {
  for (ehr in list(ehr_rows(), ehr_rows(c("p", "bad", 20, NA, 80, "2020-01-01")))) {
    result <- clean(ehr, "p")
    stopifnot(nrow(result$cleaned) == 0, result$flagged_people$person_id == "p",
      all(c("person_id", "bmi_category", "agedays_at_measurement") %in% names(result$cleaned)))
  }
})

check("left join retains EHR-only people, extra fields, and demographic suffixes", {
  ehr <- ehr_rows(c("outside", "a", 20, 200, 80, "2020-01-01"),
                  c("p", "b", 20, 200, 80, "2020-01-01"))
  ehr$note <- c("ehr outside", "ehr p")
  demo <- demographics(c("p", "no-ehr"))
  demo$note <- c("demo p", "demo no-ehr")
  demo$extra <- c("kept", "unused")
  result <- clean_ehr_and_select_typical(ehr, demo)
  stopifnot(identical(result$cleaned$person_id, c("outside", "p")),
    is.na(result$cleaned$zip3[1]), result$cleaned$note[2] == "ehr p",
    result$cleaned$note_demo[2] == "demo p", result$cleaned$extra[2] == "kept",
    result$flagged_people$person_id == "no-ehr")
})

check("age in days uses elapsed full days including negative differences", {
  ehr <- ehr_rows(c("a", "a", 20, 200, 80, "1980-01-02 23:59:59"),
                  c("b", "b", 20, 200, 80, "1979-12-31 23:59:59"),
                  c("c", "c", 20, 200, 80, "2020-01-01 12:00:00"))
  demo <- demographics(c("a", "b", "c"))
  demo$date_of_birth[3] <- "invalid"
  result <- clean_ehr_and_select_typical(ehr, demo)
  stopifnot(identical(result$cleaned$agedays_at_measurement, c(1, -1, NA_real_)))
})

check("invalid clock times and dates are missing, with no rollover to the next day", {
  values <- c("2020-01-01 24:00:00", "2020-01-01 23:59:60", "2020-02-30", "2020-13-01")
  stopifnot(all(is.na(parse_datetime(values))),
    !is.na(parse_datetime("2020-02-29 23:59:59")))
})

check("decimal timestamp fractions survive output formatting", {
  values <- paste0("2020-01-01 00:00:00", c(".1", ".123", ".000001", ".999999"))
  stopifnot(identical(format_datetime(parse_datetime(values)), values))
})

check("schema rejects missing columns and duplicate nonempty encounter IDs", {
  expect_error(clean(ehr_rows()[, -5], "p"), "Missing required columns.*weight_kg")
  ehr <- ehr_rows(c("p", "same", 20, 200, 80, "2020-01-01"),
                  c("p", " same ", 20, 200, 80, "2020-01-02"))
  expect_error(clean(ehr, "p"), "encounter_id must be unique")
})

check("schema rejects missing, blank, and duplicate demographic keys", {
  for (key in c(NA, "", "  ")) {
    expect_error(clean_ehr_and_select_typical(ehr_rows(), demographics(key)), "must not be missing or blank")
  }
  expect_error(clean(ehr_rows(), c("p", " p ")), "person_id must be unique")
})

check("public cleaning parameters reject invalid values and reversed bounds", {
  for (value in list(-1, NaN, Inf, "2", numeric())) {
    expect_error(cleaning_params(mismatch_threshold = value), "finite and nonnegative")
  }
  expect_error(cleaning_params(min_height_cm = 0), "greater than zero")
  expect_error(cleaning_params(min_bmi = 71), "must not exceed")
})

check("TSV preserves literal NA, leading zero IDs, whitespace normalization and quoted tabs", {
  path <- file.path(scratch, "string fields.tsv")
  writeLines(c("person_id\tencounter_id\tbmi\theight_cm\tweight_kg\tmeasurement_date\tnote",
    ' 001 \tNA\t20\t200\t80\t2020-01-01\t"a\tb"'), path)
  data <- read_tsv(path, EHR_REQUIRED_COLUMNS, "measurement_date")
  stopifnot(data$person_id == "001", data$encounter_id == "NA", data$note == "a\tb")
  write_tsv(data, path)
  stopifnot(identical(read_tsv(path, EHR_REQUIRED_COLUMNS)$note, "a\tb"))
  # Nonbreaking spaces also count as surrounding whitespace; keep UTF-8 identifiers sortable.
  ehr <- ehr_rows(c("\u00a0p\u00a0", "\u00e9", 20, 200, 80, "2020-01-01"))
  demo <- demographics("\u00a0p\u00a0")
  write_tsv(ehr, path)
  ehr <- read_tsv(path, EHR_REQUIRED_COLUMNS, "measurement_date")
  result <- clean_ehr_and_select_typical(ehr, demo)
  stopifnot(result$cleaned$person_id == "p", result$cleaned$encounter_id == "\u00e9")
})

ehr_path <- file.path(scratch, "ehr input.tsv")
demo_path <- file.path(scratch, "demo input.tsv")
write_tsv(ehr_rows(c("p1", "first", 20, 200, 80, "2020-01-01"),
                   c("p1", "selected", 24, 200, 96, "2020-01-02"),
                   c("p2", "missing", 20, NA, 80, "2020-01-01")), ehr_path)
write_tsv(demographics(c("p1", "p2", "p3")), demo_path)
runs <- file.path(scratch, "runs")
cli_args <- function(id, ehr = ehr_path, demo = demo_path, runs_dir = runs) {
  c("--ehr", ehr, "--demo", demo, "--runs_dir", runs_dir, "--run_id", id)
}
read_manifest <- function(id) jsonlite::read_json(file.path(runs, id, "manifest.json"), simplifyVector = TRUE)

check("CLI writes known outputs, verifiable hashes, environment, command, and summary", {
  args <- cli_args("tiny")
  stopifnot(main(args) == 0L)
  manifest <- read_manifest("tiny")
  stopifnot(manifest$schema_version == 1L, manifest$status == "success",
    identical(tail(manifest$command, length(args)), args),
    manifest$command_source == "equivalent_script_invocation",
    manifest$parameters$mismatch_threshold == 2,
    manifest$code$version == PGACG_R_VERSION,
    manifest$environment$R == as.character(getRversion()),
    manifest$environment$dependencies$jsonlite == as.character(packageVersion("jsonlite")),
    manifest$environment$dependencies$digest == as.character(packageVersion("digest")),
    manifest$finished_at >= manifest$started_at,
    manifest$metrics$n_people_no_valid_rows == 2)
  for (name in c("ehr", "demographics")) {
    path <- if (name == "ehr") ehr_path else demo_path
    stopifnot(manifest$inputs[[name]]$path == normalizePath(path, winslash = "/"),
      manifest$inputs[[name]]$sha256 == digest::digest(file = path, algo = "sha256", serialize = FALSE))
  }
  expected <- c("summary.md", "outputs/cleaned_bmi_person.tsv", "outputs/flagged_rows.tsv",
                 "outputs/flagged_people.tsv", "outputs/cleaned_bmi_person_data_dictionary.md")
  stopifnot(setequal(names(manifest$artifacts), expected))
  for (relative in names(manifest$artifacts)) {
    path <- file.path(runs, "tiny", relative)
    stopifnot(manifest$artifacts[[relative]]$sha256 == digest::digest(file = path, algo = "sha256", serialize = FALSE),
      manifest$artifacts[[relative]]$size_bytes == file.info(path)$size)
  }
  cleaned <- read_tsv(file.path(runs, "tiny", "outputs", "cleaned_bmi_person.tsv"), EHR_REQUIRED_COLUMNS)
  stopifnot(cleaned$encounter_id == "selected", cleaned$zip3 == "012")
  summary <- paste(readLines(file.path(runs, "tiny", "summary.md")), collapse = "\n")
  stopifnot(grepl("Category distributions", summary), grepl("`mismatch_threshold`: 2", summary, fixed = TRUE))
})

check("existing run is never overwritten", {
  path <- file.path(runs, "tiny", "manifest.json")
  original <- readBin(path, "raw", n = file.info(path)$size)
  stopifnot(main(cli_args("tiny")) == 2L,
    identical(original, readBin(path, "raw", n = file.info(path)$size)))
})

check("separate invocations keep separate logs", {
  stopifnot(main(cli_args("second")) == 0L)
  first <- paste(readLines(file.path(runs, "tiny", "logs", "pipeline.log")), collapse = "\n")
  second <- paste(readLines(file.path(runs, "second", "logs", "pipeline.log")), collapse = "\n")
  stopifnot(grepl("demo run: tiny", first), !grepl("demo run: second", first),
    grepl("demo run: second", second), !grepl("demo run: tiny", second))
})

check("invalid CLI thresholds, run IDs, missing arguments and unknown flags create no run", {
  absent <- file.path(scratch, "must not exist")
  for (value in c("-1", "NaN", "Inf", "-Inf", "text")) {
    stopifnot(main(c(cli_args("invalid", runs_dir = absent), paste0("--mismatch_threshold=", value))) == 2L)
  }
  for (id in c("..", "../outside", "/absolute", "with space")) {
    stopifnot(main(cli_args(id, runs_dir = absent)) == 2L)
  }
  stopifnot(main(character()) == 2L,
    main(c(cli_args("invalid", runs_dir = absent), "--unknown")) == 2L, !dir.exists(absent))
})

check("runtime failures retain error summary, call stack, and completed failure manifest", {
  bad_ehr <- file.path(scratch, "bad ehr.tsv")
  writeLines(c("person_id", "missing"), bad_ehr)
  bad_demo <- file.path(scratch, "duplicate demo.tsv")
  write_tsv(demographics(c("p1", "p1")), bad_demo)
  cases <- list(
    list("schema", bad_ehr, demo_path, "Missing required columns"),
    list("duplicate", ehr_path, bad_demo, "person_id must be unique"),
    list("missing_file", file.path(scratch, "absent.tsv"), demo_path, "Input file not found")
  )
  for (case in cases) {
    stopifnot(main(cli_args(case[[1]], case[[2]], case[[3]])) == 1L)
    manifest <- read_manifest(case[[1]])
    stopifnot(manifest$status == "failed", grepl(case[[4]], manifest$error),
      !is.null(manifest$finished_at), identical(names(manifest$artifacts), "summary.md"))
    log <- paste(readLines(file.path(runs, case[[1]], "logs", "pipeline.log")), collapse = "\n")
    summary <- paste(readLines(file.path(runs, case[[1]], "summary.md")), collapse = "\n")
    stopifnot(grepl(case[[4]], log), grepl("Call stack:", log), grepl(case[[4]], summary))
  }
})

check("empty EHR completes with header-only cleaned output", {
  empty <- file.path(scratch, "empty.tsv")
  write_tsv(ehr_rows(), empty)
  stopifnot(main(cli_args("empty", ehr = empty)) == 0L)
  manifest <- read_manifest("empty")
  stopifnot(manifest$metrics$n_rows_input == 0, manifest$metrics$n_people_no_valid_rows == 3,
    nrow(read_tsv(file.path(runs, "empty", "outputs", "cleaned_bmi_person.tsv"), EHR_REQUIRED_COLUMNS)) == 0)
})

check("SHA256 helper matches the known abc digest and Git metadata may be unavailable", {
  path <- file.path(scratch, "abc")
  writeBin(charToRaw("abc"), path)
  stopifnot(sha256_file(path) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
    identical(git_state(file.path(scratch, "no checkout")), list(revision = NULL, dirty = NULL)))
})

check("Rscript entrypoint works from another directory with paths containing spaces", {
  process <- local({
    previous <- setwd(scratch)
    on.exit(setwd(previous))
    suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
      shQuote(c(file.path(root, "scripts", "r", "demo.R"), cli_args("process"))),
      stdout = TRUE, stderr = TRUE))
  })
  stopifnot(is.null(attr(process, "status")), read_manifest("process")$command_source == "process")
  stopifnot(!any(grepl("~+~", read_manifest("process")$command, fixed = TRUE)))
})

check("included synthetic fixture matches its documented baseline counts", {
  stopifnot(main(cli_args("fixture",
    file.path(root, "data", "example", "ehr_bmi_simulated_data.tsv"),
    file.path(root, "data", "example", "demographics_simulated_data.tsv"))) == 0L)
  counts <- read_manifest("fixture")$metrics
  stopifnot(counts$n_rows_input == 1074, counts$n_rows_flagged_total == 218,
    counts$n_rows_kept_after_row_filters == 856, counts$n_people_with_typical_record == 12,
    counts$n_rows_outliers == 11, counts$n_rows_bmi_mismatch == 51)
})

unlink(scratch, recursive = TRUE)
cat(sprintf("All %d R checks passed.\n", checks))
