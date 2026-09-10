# Transformations implement docs/reference/io_contract.md; no file I/O here.
cleaning_params <- function(mismatch_threshold = 2, min_height_cm = 100,
                            max_height_cm = 250, min_weight_kg = 25,
                            max_weight_kg = 300, min_bmi = 10, max_bmi = 70,
                            iqr_multiplier = 1.5) {
  params <- as.list(environment())
  for (name in names(params)) {
    value <- params[[name]]
    if (!is.numeric(value) || length(value) != 1L || !is.finite(value) || value < 0) {
      stop(sprintf("%s must be finite and nonnegative", name))
    }
  }
  for (quantity in c("height_cm", "weight_kg", "bmi")) {
    if (params[[paste0("min_", quantity)]] > params[[paste0("max_", quantity)]]) {
      stop(sprintf("min_%s must not exceed max_%s", quantity, quantity))
    }
  }
  if (min_height_cm == 0) stop("min_height_cm must be greater than zero")
  params
}

compute_bmi <- function(height_cm, weight_kg) weight_kg / (height_cm / 100)^2

clean_ehr_and_select_typical <- function(ehr, demo, params = cleaning_params()) {
  validate_ehr(ehr)
  validate_demographics(demo)
  df <- ehr
  rownames(df) <- NULL
  for (column in c("person_id", "encounter_id")) {
    df[[column]] <- trim_text(df[[column]])
    df[[column]][!is.na(df[[column]]) & df[[column]] == ""] <- NA_character_
  }
  for (column in c("bmi", "height_cm", "weight_kg")) {
    df[[column]] <- suppressWarnings(as.numeric(as.character(df[[column]])))
  }
  df$measurement_date <- parse_datetime(df$measurement_date)
  reasons <- rep("", nrow(df))
  add_reason <- function(mask, reason) {
    indices <- which(!is.na(mask) & mask)
    reasons[indices] <<- ifelse(reasons[indices] == "", reason,
                                paste(reasons[indices], reason, sep = ";"))
  }
  add_reason(is.na(df$person_id) | is.na(df$encounter_id) | is.na(df$measurement_date),
             "missing_id_or_date")
  add_reason(is.na(df$height_cm), "missing_height")
  add_reason(is.na(df$weight_kg), "missing_weight")
  add_reason(df$height_cm < params$min_height_cm | df$height_cm > params$max_height_cm,
             "implausible_height")
  add_reason(df$weight_kg < params$min_weight_kg | df$weight_kg > params$max_weight_kg,
             "implausible_weight")
  # Scale then round to nearest even, matching the Python path's NumPy rounding.
  df$bmi_calc <- round(compute_bmi(df$height_cm, df$weight_kg) * 10) / 10
  df$bmi_imputed <- is.na(df$bmi) & !is.na(df$bmi_calc)
  df$bmi[df$bmi_imputed] <- df$bmi_calc[df$bmi_imputed]
  mismatch <- !is.na(df$bmi) & !is.na(df$bmi_calc) &
    abs(df$bmi - df$bmi_calc) > params$mismatch_threshold
  mismatch[is.na(mismatch)] <- FALSE
  add_reason(mismatch, "bmi_mismatch")
  add_reason(df$bmi < params$min_bmi | df$bmi > params$max_bmi, "implausible_bmi")

  flagged_rows <- df[reasons != "", , drop = FALSE]
  flagged_rows$reasons <- reasons[reasons != ""]
  keep <- df[reasons == "", , drop = FALSE]
  outlier <- rep(FALSE, nrow(keep))
  for (indices in split(seq_len(nrow(keep)), keep$person_id)) {
    if (length(indices) < 4L) next
    quartiles <- quantile(keep$bmi[indices], c(0.25, 0.75), type = 7, na.rm = TRUE)
    spread <- diff(quartiles)
    outlier[indices] <- keep$bmi[indices] < quartiles[1] - params$iqr_multiplier * spread |
      keep$bmi[indices] > quartiles[2] + params$iqr_multiplier * spread
  }
  outlier[is.na(outlier)] <- FALSE
  outliers <- keep[outlier, , drop = FALSE]
  outliers$reasons <- rep("per_person_iqr_outlier", nrow(outliers))
  flagged_rows <- rbind(flagged_rows, outliers)
  keep2 <- keep[!outlier, , drop = FALSE]

  distance <- rep(NA_real_, nrow(keep2))
  for (indices in split(seq_len(nrow(keep2)), keep2$person_id)) {
    distance[indices] <- abs(keep2$bmi[indices] - median(keep2$bmi[indices], na.rm = TRUE))
  }
  # Radix text order does not depend on the host's locale (e10 sorts before e2).
  indices <- order(keep2$person_id, distance, -as.numeric(keep2$measurement_date),
                    keep2$encounter_id, method = "radix")
  typical <- keep2[indices, , drop = FALSE]
  typical <- typical[!duplicated(typical$person_id), , drop = FALSE]
  demo2 <- demo
  demo2$person_id <- trim_text(demo2$person_id)
  missing_people <- sort(setdiff(demo2$person_id, typical$person_id), method = "radix")
  flagged_people <- data.frame(
    person_id = missing_people,
    reason = rep("no_valid_rows_after_cleaning", length(missing_people)),
    stringsAsFactors = FALSE
  )
  typical$bmi_category <- as.character(cut(typical$bmi,
    c(-Inf, 18.5, 25, 30, 35, 40, Inf), right = FALSE,
    labels = c("Underweight", "Normal", "Overweight", "Obesity I", "Obesity II", "Obesity III")))
  typical$height_category <- as.character(cut(typical$height_cm,
    c(-Inf, 150, 180, Inf), right = FALSE, labels = c("Short", "Average", "Tall")))
  typical$weight_category <- as.character(cut(typical$weight_kg,
    c(-Inf, 50, 80, 100, Inf), right = FALSE,
    labels = c("Light", "Medium", "Heavy", "Very Heavy")))
  demo2$date_of_birth <- parse_datetime(demo2$date_of_birth)
  matched <- match(typical$person_id, demo2$person_id)
  merged <- typical
  for (column in setdiff(names(demo2), "person_id")) {
    destination <- if (column %in% names(typical)) paste0(column, "_demo") else column
    merged[[destination]] <- demo2[[column]][matched]
  }
  merged$agedays_at_measurement <- floor(as.numeric(difftime(
    merged$measurement_date, merged$date_of_birth, units = "days"
  )))
  rownames(merged) <- rownames(flagged_rows) <- NULL
  metrics <- list(
    n_rows_input = nrow(df), n_people_demo = length(unique(demo$person_id)),
    n_rows_flagged_total = nrow(flagged_rows), n_rows_kept_after_row_filters = nrow(keep2),
    n_people_with_typical_record = nrow(merged), n_people_no_valid_rows = nrow(flagged_people),
    n_rows_outliers = nrow(outliers), n_rows_bmi_mismatch = sum(mismatch)
  )
  list(cleaned = merged, flagged_rows = flagged_rows,
        flagged_people = flagged_people, metrics = metrics)
}
