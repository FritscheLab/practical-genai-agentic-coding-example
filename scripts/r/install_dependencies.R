#!/usr/bin/env Rscript
# Uses R's normal library configuration, including R_LIBS_USER when set.
packages <- c("jsonlite", "digest")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  library_path <- .libPaths()[1]
  if (file.access(library_path, 2) != 0) {
    library_path <- path.expand(Sys.getenv("R_LIBS_USER"))
    library_path <- strsplit(library_path, .Platform$path.sep, fixed = TRUE)[[1]][1]
    if (!nzchar(library_path)) stop("Set R_LIBS_USER to a writable library directory")
    dir.create(library_path, recursive = TRUE, showWarnings = FALSE)
    .libPaths(c(library_path, .libPaths()))
  }
  install.packages(missing, repos = "https://cloud.r-project.org", lib = library_path)
}
unavailable <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(unavailable)) stop(paste("Could not install:", paste(unavailable, collapse = ", ")))
cat("R demo dependencies ready:\n")
for (package in packages) cat(sprintf("  %s %s\n", package, as.character(packageVersion(package))))
