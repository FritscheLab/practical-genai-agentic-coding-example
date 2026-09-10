#!/usr/bin/env Rscript
# Resolve modules from the script, so input/output paths remain relative to the caller.
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_arg) != 1L) stop("Run this entrypoint with Rscript scripts/r/demo.R")
script_path <- normalizePath(gsub("~+~", " ", sub("^--file=", "", script_arg), fixed = TRUE),
                              mustWork = TRUE)
repo_root <- normalizePath(file.path(dirname(script_path), "..", ".."), mustWork = TRUE)
source(file.path(repo_root, "R", "cli.R"))
quit(status = main(), save = "no")
