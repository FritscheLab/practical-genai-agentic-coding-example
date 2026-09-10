parameter_lines <- function(params) {
  sprintf("- `%s`: %s", names(params), vapply(params, as.character, character(1)))
}

render_markdown_table <- function(values, header_left = "value", header_right = "count") {
  counts <- sort(table(values, useNA = "ifany"), decreasing = TRUE)
  c(sprintf("| %s | %s |", header_left, header_right), "|---|---:|",
     sprintf("| %s | %d |", names(counts), as.integer(counts)))
}

write_run_summary <- function(path, run_id, params, metrics, cleaned, ehr_path, demo_path) {
  lines <- c(
    sprintf("# Run summary: `%s`", run_id), "", paste("- **Timestamp:**", utc_now()),
    "- **Status:** success",
    "- **Provenance:** `manifest.json` (input and artifact checksums, command, code and environment)",
    sprintf("- **EHR input:** `%s`", ehr_path), sprintf("- **Demographics input:** `%s`", demo_path), "",
    paste("These are simplified teaching rules applied to synthetic data, including minors.",
          "Categories are demonstration labels, not clinical assessments or a validated cohort definition."), "",
    "## Parameters", parameter_lines(params), "", "## Key counts", parameter_lines(metrics), "",
    "## Category distributions (cleaned person-level output)", ""
  )
  for (measure in c("bmi", "height", "weight")) {
    title <- switch(measure, bmi = "BMI", height = "Height", weight = "Weight")
    column <- paste0(measure, "_category")
    lines <- c(lines, paste("###", title, "category"),
                render_markdown_table(cleaned[[column]], column, "n_people"), "")
  }
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

write_failure_summary <- function(path, run_id, error, params, ehr_path, demo_path) {
  lines <- c(
    sprintf("# Run summary: `%s`", run_id), "", "- **Status:** failed",
    sprintf("- **EHR input:** `%s`", ehr_path), sprintf("- **Demographics input:** `%s`", demo_path), "",
    "## Error", "", error, "",
    paste("See `logs/pipeline.log` for diagnostic details and `manifest.json` for provenance.",
          "Any artifacts retained in this run folder are incomplete and must not be treated as a successful run."),
    "", "## Parameters", "", parameter_lines(params), ""
  )
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}

write_output_data_dictionary <- function(path) {
  columns <- c(EHR_REQUIRED_COLUMNS, "bmi_calc", "bmi_imputed", "bmi_category",
                "height_category", "weight_category", setdiff(DEMO_REQUIRED_COLUMNS, "person_id"),
                "agedays_at_measurement")
  types <- c("string", "string", "float", "float", "float", "datetime", "float", "bool",
              rep("string", 3), "datetime", "int", rep("string", 9), "int")
  descriptions <- c(
    "synthetic person identifier", "encounter id for the selected typical record",
    "BMI used for selection (reported or imputed from height/weight)",
    "height (cm) for the selected record", "weight (kg) for the selected record",
    "measurement timestamp for the selected record", "BMI calculated from height/weight",
    "whether BMI was missing and filled from height/weight",
    "Underweight / Normal / Overweight / Obesity I/II/III", "Short / Average / Tall",
    "Light / Medium / Heavy / Very Heavy", "DOB (from demographics)",
    "age in years (from demographics; may be missing)", "age bin (from demographics)",
    "Yes/No", "race (may be missing)", "ethnicity (may be missing)",
    "combined race/ethnicity (may be missing)", "harmonized race/ethnicity (may be missing)",
    "sex/gender", "marital status", "3-digit ZIP prefix",
    "(measurement_date - date_of_birth) in whole days (may be missing if DOB missing)"
  )
  lines <- c("# Data dictionary: cleaned_bmi_person.tsv", "",
    "This dictionary describes the **person-level** output of the synthetic teaching pipeline.",
    "Categories use simplified fixed thresholds; they are not clinical assessments.", "",
    "| column | type | description |", "|---|---|---|",
    sprintf("| %s | %s | %s |", columns, types, descriptions))
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
}
