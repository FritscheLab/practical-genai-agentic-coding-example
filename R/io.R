# Input and output functions for the synthetic teaching pipeline.
EHR_REQUIRED_COLUMNS <- c(
  "person_id", "encounter_id", "bmi", "height_cm", "weight_kg", "measurement_date"
)
DEMO_REQUIRED_COLUMNS <- c(
  "person_id", "date_of_birth", "age", "age_bin", "deceased", "race_clean",
  "ethnicity_clean", "race_ethnicity", "race_ethnicity_harmonized", "sex_gender",
  "marital_status_name", "zip3"
)

schema_error <- function(message) {
  stop(structure(list(message = message, call = NULL),
                 class = c("SchemaError", "error", "condition")))
}

trim_text <- function(values) trimws(enc2utf8(as.character(values)), whitespace = "[\\h\\v]")

validate_columns <- function(df, required, label) {
  missing <- sort(setdiff(required, names(df)))
  if (length(missing)) {
    schema_error(sprintf("Missing required columns in %s: %s", label,
                         paste(missing, collapse = ", ")))
  }
}

validate_demographics <- function(df) {
  validate_columns(df, DEMO_REQUIRED_COLUMNS, "demographics")
  keys <- trim_text(df$person_id)
  if (any(is.na(keys) | keys == "")) {
    schema_error("Demographics person_id must not be missing or blank")
  }
  if (anyDuplicated(keys)) {
    schema_error("Demographics person_id must be unique; duplicate keys found")
  }
}

validate_ehr <- function(df) {
  validate_columns(df, EHR_REQUIRED_COLUMNS, "EHR")
  keys <- trim_text(df$encounter_id)
  if (anyDuplicated(keys[!is.na(keys) & keys != ""])) {
    schema_error("EHR encounter_id must be unique; duplicate keys found")
  }
}

# Interpret the contract's timezone-free ISO dates in UTC, avoiding local DST.
parse_datetime <- function(values) {
  if (inherits(values, "POSIXt")) return(as.POSIXct(values, tz = "UTC"))
  if (inherits(values, "Date")) return(as.POSIXct(values, tz = "UTC"))
  values <- as.character(values)
  result <- as.POSIXct(rep(NA_real_, length(values)), origin = "1970-01-01", tz = "UTC")
  date_only <- !is.na(values) & grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", values)
  timestamp <- !is.na(values) & grepl(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\\.[0-9]+)?$", values
  )
  result[date_only] <- as.POSIXct(strptime(values[date_only], "%Y-%m-%d", tz = "UTC"))
  result[timestamp] <- as.POSIXct(strptime(gsub("T", " ", values[timestamp], fixed = TRUE),
                                         "%Y-%m-%d %H:%M:%OS", tz = "UTC"))
  result
}

read_tsv <- function(path, required_columns, parse_dates = character()) {
  if (!file.exists(path)) stop(sprintf("Input file not found: %s", path))
  df <- read.delim(path, header = TRUE, sep = "\t", colClasses = "character",
                   na.strings = "", check.names = FALSE, stringsAsFactors = FALSE,
                   quote = '"', comment.char = "", fileEncoding = "UTF-8")
  for (column in names(df)) {
    df[[column]] <- trim_text(df[[column]])
    df[[column]][!is.na(df[[column]]) & df[[column]] == ""] <- NA_character_
  }
  validate_columns(df, required_columns, basename(path))
  for (column in intersect(parse_dates, names(df))) {
    df[[column]] <- parse_datetime(df[[column]])
  }
  df
}

format_datetime <- function(values) {
  seconds <- as.numeric(values)
  whole <- floor(seconds)
  # strftime's %OS truncates binary fractions (0.1 can print as .099999).
  # Round to microseconds explicitly to retain supplied decimal timestamps.
  microseconds <- round((seconds - whole) * 1e6)
  carry <- !is.na(microseconds) & microseconds >= 1e6
  whole[carry] <- whole[carry] + 1
  microseconds[carry] <- 0
  output <- format(as.POSIXct(whole, origin = "1970-01-01", tz = "UTC"),
                    "%Y-%m-%d %H:%M:%S", tz = "UTC")
  fractional <- which(!is.na(microseconds) & microseconds != 0)
  suffix <- sub("0+$", "", sprintf(".%06d", as.integer(microseconds[fractional])))
  output[fractional] <- paste0(output[fractional], suffix)
  output
}

write_tsv <- function(df, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  for (column in names(df)) {
    if (inherits(df[[column]], "POSIXt")) {
      df[[column]] <- format_datetime(df[[column]])
      if (column == "date_of_birth") df[[column]] <- sub(" 00:00:00$", "", df[[column]])
    } else if (is.logical(df[[column]])) {
      df[[column]] <- ifelse(is.na(df[[column]]), NA_character_,
                             ifelse(df[[column]], "True", "False"))
    }
  }
  write.table(df, path, sep = "\t", quote = TRUE, row.names = FALSE,
              na = "", qmethod = "double", fileEncoding = "UTF-8")
}
