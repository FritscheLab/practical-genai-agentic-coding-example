# Run directories, checksums, and provenance; no Python runtime is needed.
PGACG_R_VERSION <- "0.1.0"

utc_now <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")

require_dependencies <- function() {
  missing <- c("jsonlite", "digest")[!vapply(c("jsonlite", "digest"), requireNamespace,
                                            logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop(sprintf("Missing R packages: %s. Run Rscript scripts/r/install_dependencies.R",
                  paste(missing, collapse = ", ")))
  }
}

generate_run_id <- function() {
  paste0(format(Sys.time(), "%Y%m%d_%H%M%S", tz = "UTC"), "_",
          paste(sample(c(letters, 0:9), 4, replace = TRUE), collapse = ""))
}

validate_run_id <- function(run_id) {
  if (length(run_id) != 1L || is.na(run_id) ||
      !grepl("^[A-Za-z0-9][A-Za-z0-9_.-]*$", run_id)) {
    stop("run_id must start with a letter or digit and contain only letters, digits, _, ., or -")
  }
  run_id
}

create_run_paths <- function(base_dir, run_id) {
  run_dir <- file.path(base_dir, validate_run_id(run_id))
  dir.create(base_dir, recursive = TRUE, showWarnings = FALSE)
  # A single mkdir reserves the directory; never reuse an existing partial run.
  if (!dir.create(run_dir, showWarnings = FALSE)) {
    stop(sprintf("Cannot create run directory (it may already exist): %s", run_dir))
  }
  paths <- list(run_dir = run_dir, logs_dir = file.path(run_dir, "logs"),
                 outputs_dir = file.path(run_dir, "outputs"),
                 summary_path = file.path(run_dir, "summary.md"))
  if (!dir.create(paths$logs_dir) || !dir.create(paths$outputs_dir)) {
    stop(sprintf("Cannot create subdirectories in: %s", run_dir))
  }
  paths
}

setup_logging <- function(log_file, verbose = FALSE) {
  force(log_file)
  force(verbose)
  function(level, message) {
    line <- sprintf("%s | %s | %s", utc_now(), level, message)
    cat(line, "\n", file = log_file, append = TRUE, sep = "")
    if (level != "DEBUG" || verbose) cat(line, "\n", file = stderr(), sep = "")
  }
}

sha256_file <- function(path) {
  if (!file.exists(path)) stop(sprintf("Input file not found: %s", path))
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

absolute_path <- function(path) {
  path <- path.expand(path)
  if (!grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", path)) path <- file.path(getwd(), path)
  normalizePath(path, winslash = "/", mustWork = FALSE)
}

git_state <- function(source_root) {
  state <- list(revision = NULL, dirty = NULL)
  git <- Sys.which("git")
  if (!nzchar(git) || !file.exists(file.path(source_root, "R", "run_utils.R"))) return(state)
  for (name in c("revision", "dirty")) {
    args <- if (name == "revision") c("rev-parse", "HEAD") else
      c("status", "--porcelain", "--untracked-files=normal")
    result <- tryCatch(suppressWarnings(system2(git, c("-C", shQuote(source_root), args),
      stdout = TRUE, stderr = FALSE, timeout = 5)), error = function(e) NULL)
    if (!is.null(result) && is.null(attr(result, "status"))) {
      state[name] <- list(if (name == "dirty") any(nzchar(result)) else paste(result, collapse = "\n"))
    }
  }
  state
}

create_manifest <- function(run_id, params, ehr_path, demo_path, command, command_source) {
  list(
    schema_version = 1L, run_id = run_id, status = "running",
    started_at = utc_now(), finished_at = NULL, command = I(command),
    command_source = command_source, working_directory = getwd(), parameters = params,
    inputs = list(ehr = list(path = absolute_path(ehr_path), sha256 = NULL),
                   demographics = list(path = absolute_path(demo_path), sha256 = NULL)),
    code = list(version = PGACG_R_VERSION, git = git_state(.pgacg_root)),
    environment = list(R = as.character(getRversion()), implementation = "R",
      platform = R.version$platform,
      dependencies = list(jsonlite = as.character(utils::packageVersion("jsonlite")),
                          digest = as.character(utils::packageVersion("digest")))),
    artifacts = setNames(list(), character()), error = NULL
  )
}

write_manifest <- function(run_paths, manifest, finished = FALSE) {
  if (finished) {
    manifest$finished_at <- utc_now()
    files <- c("summary.md", file.path("outputs", sort(list.files(run_paths$outputs_dir))))
    paths <- file.path(run_paths$run_dir, files)
    files <- files[file.exists(paths) & !dir.exists(paths)]
    manifest$artifacts <- setNames(lapply(files, function(relative) {
      path <- file.path(run_paths$run_dir, relative)
      list(sha256 = sha256_file(path), size_bytes = unname(file.info(path)$size))
    }), gsub("\\\\", "/", files))
  }
  path <- file.path(run_paths$run_dir, "manifest.json")
  temporary <- paste0(path, ".tmp")
  jsonlite::write_json(manifest, temporary, auto_unbox = TRUE, pretty = TRUE, null = "null",
                       na = "null", digits = NA)
  if (!file.rename(temporary, path)) stop(sprintf("Cannot save manifest: %s", path))
  invisible(manifest)
}
