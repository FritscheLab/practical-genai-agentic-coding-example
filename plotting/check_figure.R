# Check the current figure against the fictional JUSF requirements.
# The starter should fail; ordinary behavior tests remain separate.

plot_probe <- function(script_path, output_path) {
  module <- new.env(parent = globalenv())
  source(script_path, local = module)
  observed <- new.env(parent = emptyenv())
  kinds <- c("devices", "bars", "texts", "legends", "axes", "titles")
  for (kind in kinds) observed[[kind]] <- list()
  record <- function(kind, values) {
    values$settings <- graphics::par(c(
      "ps", "cex", "cex.axis", "cex.lab", "cex.main",
      "font.main", "family", "bg", "usr", "lwd",
      "col", "col.axis", "col.lab", "col.main"
    ))
    effective_family <- values$settings$family
    if (!is.null(values$dots$family)) effective_family <- values$dots$family
    widths <- graphics::strwidth(
      c("iiiiii", "WWWWWW", "000000"), units = "inches", family = effective_family
    )
    values$monospaced <- max(widths) - min(widths) < 0.001
    observed[[kind]][[length(observed[[kind]]) + 1L]] <- values
  }
  traced <- list()
  install <- function(name, package, expression, entry = FALSE) {
    locations <- list(asNamespace(package), as.environment(paste0("package:", package)))
    for (namespace in locations) {
      if (entry) {
        suppressMessages(trace(name, where = namespace, tracer = expression, print = FALSE))
      } else {
        suppressMessages(trace(name, where = namespace, exit = expression, print = FALSE))
      }
      traced[[length(traced) + 1L]] <<- list(name = name, namespace = namespace)
    }
  }
  on.exit({
    for (item in rev(traced)) {
      suppressMessages(untrace(item$name, where = item$namespace))
    }
  }, add = TRUE)
  install("png", "grDevices", bquote(.(record)("devices", list())))
  pick <- function(args, name, fallback) {
    if (is.null(args[[name]])) fallback else args[[name]]
  }
  record_bars <- function(height, args, positions) {
    record("bars", list(
      height = height, names = pick(args, "names.arg", colnames(height)),
      horizontal = pick(args, "horiz", FALSE), beside = pick(args, "beside", FALSE),
      positions = positions, col = args$col,
      border = pick(args, "border", graphics::par("fg")),
      cex.names = pick(args, "cex.names", graphics::par("cex.axis")), dots = args
    ))
  }
  record_text <- function(x, args) {
    y <- args$y
    if (is.null(y) && length(args) && (is.null(names(args)) || names(args)[1L] == "")) {
      y <- args[[1L]]
    }
    coords <- grDevices::xy.coords(x, y, recycle = TRUE)
    # Check the drawn text's left edge, not just its anchor: pos = 2 puts
    # a label to the left of the bar end, inside the colored bar.
    text_cex <- pick(args, "cex", 1)
    text_family <- pick(args, "family", graphics::par("family"))
    text_width <- graphics::strwidth(
      as.character(args$labels), cex = text_cex,
      font = pick(args, "font", graphics::par("font")), family = text_family
    )
    alignment <- pick(args, "adj", graphics::par("adj"))[[1L]]
    left <- coords$x - alignment * text_width
    if (!is.null(args$pos)) {
      position <- rep_len(args$pos, length(coords$x))
      offset <- pick(args, "offset", 0.5) * graphics::par("cxy")[[1L]]
      left <- ifelse(position == 4, coords$x + offset,
                     ifelse(position == 2, coords$x - offset - text_width,
                            coords$x - text_width / 2))
    }
    record("texts", list(
      x = coords$x, y = coords$y, left = left, labels = args$labels,
      cex = text_cex, pos = args$pos, dots = args
    ))
  }
  install("barplot", "graphics", bquote(.(record_bars)(height, list(...), returnValue())))
  install("text", "graphics", bquote(.(record_text)(x, list(...))))
  install("legend", "graphics", bquote(.(record)("legends", list(
    labels = legend, fill = fill, bty = bty, cex = cex, dots = list()
  ))), entry = TRUE)
  install("axis", "graphics", bquote(.(record)("axes", list(
    side = side, at = returnValue(), labels = labels, dots = list(...)
  ))))
  install("title", "graphics", bquote(.(record)("titles", list(
    main = main, xlab = xlab, dots = list(...)
  ))))
  result <- module$plot_summary(output_path)
  list(module = module, observed = as.list(observed), result = result)
}

png_metadata <- function(path) {
  connection <- file(path, "rb")
  on.exit(close(connection))
  signature <- readBin(connection, "raw", 8L)
  if (!identical(signature, as.raw(c(137, 80, 78, 71, 13, 10, 26, 10)))) {
    stop("Output is not PNG.", call. = FALSE)
  }
  result <- list(width = NA_integer_, height = NA_integer_, dpi = c(NA, NA))
  repeat {
    size <- readBin(connection, integer(), 1L, size = 4L, endian = "big")
    if (length(size) == 0L) break
    kind <- rawToChar(readBin(connection, "raw", 4L))
    payload <- readBin(connection, "raw", size)
    readBin(connection, "raw", 4L)
    if (kind == "IHDR") {
      result$width <- readBin(payload[1:4], integer(), 1L, size = 4L, endian = "big")
      result$height <- readBin(payload[5:8], integer(), 1L, size = 4L, endian = "big")
    }
    if (kind == "pHYs" && payload[[9L]] == as.raw(1)) {
      result$dpi <- c(
        readBin(payload[1:4], integer(), 1L, size = 4L, endian = "big"),
        readBin(payload[5:8], integer(), 1L, size = 4L, endian = "big")
      ) * 0.0254
    }
    if (kind == "IEND") break
  }
  result
}

check_figure <- function(script_path, output_path) {
  probe <- plot_probe(script_path, output_path)
  observed <- probe$observed
  errors <- character()
  require <- function(condition, message) {
    if (!isTRUE(condition)) errors <<- c(errors, message)
  }
  value <- function(values, name, fallback) {
    if (is.null(values[[name]])) fallback else values[[name]]
  }
  color <- function(values) {
    if (length(values) == 0L) return(character())
    apply(grDevices::col2rgb(values, alpha = TRUE), 2L, function(rgba) {
      if (rgba[[4L]] != 255) return("transparent")
      sprintf("#%02x%02x%02x", rgba[[1L]], rgba[[2L]], rgba[[3L]])
    })
  }
  categories <- c(
    "Complete measurements", "Missing height only",
    "Missing weight only", "Missing height and weight"
  )
  groups <- c("Group A", "Group B")
  expected <- matrix(c(42, 31, 18, 9, 64, 18, 12, 6), nrow = 2, byrow = TRUE)
  palette <- c("#440154", "#b8de29")
  metadata <- png_metadata(output_path)
  require(
    identical(c(metadata$width, metadata$height), c(1800L, 1200L)),
    "PNG must be exactly 1800 x 1200 pixels."
  )
  require(all(abs(metadata$dpi - 300) < 0.1), "PNG resolution metadata must be 300 dpi.")
  require(length(observed$devices) == 1L, "Render one PNG device.")
  for (device in observed$devices) {
    require(identical(unname(color(device$settings$bg)), "#ffffff"),
            "Background must be white.")
  }
  bars <- observed$bars
  require(length(bars) > 0L, "Use base barplot() so drawn bar assignments can be checked.")
  drawn <- list()
  for (index in seq_along(bars)) {
    bar <- bars[[index]]
    require(isTRUE(bar$horizontal), "Draw horizontal bars.")
    require(all(value(bar$dots, "offset", 0) == 0), "Grouped bars must start at zero.")
    require(identical(as.numeric(bar$settings$usr[1:2]), c(0, 80)),
            "Use a count axis from 0 to 80 without automatic expansion.")
    require(bar$monospaced, "Use a resolved monospace font throughout.")
    require(abs(bar$settings$ps * bar$settings$cex * bar$cex.names - 9) < 0.01,
            "Category labels must be 9 pt.")
    height <- bar$height
    if (is.matrix(height)) {
      require(isTRUE(bar$beside), "Use side-by-side grouped bars, not stacked bars.")
      if (!isTRUE(bar$beside) || !is.matrix(bar$positions)) next
      group_names <- rownames(height)
      category_names <- colnames(height)
      require(identical(bar$names, rev(categories)), "Keep the specified category order.")
      for (column in seq_len(ncol(height))) {
        for (row in seq_len(nrow(height))) {
          drawn[[length(drawn) + 1L]] <- list(
            group = group_names[row], category = category_names[column],
            count = height[row, column], y = bar$positions[row, column],
            fill = rep_len(color(bar$col), nrow(height))[row],
            border = rep_len(color(bar$border), nrow(height))[row],
            thickness = rep_len(value(bar$dots, "width", 1), nrow(height))[row],
            lwd = value(bar$dots, "lwd", bar$settings$lwd)
          )
        }
      }
    } else {
      require(length(bars) == 2L, "Draw both groups.")
      for (column in seq_along(height)) {
        drawn[[length(drawn) + 1L]] <- list(
          group = groups[index], category = bar$names[column],
          count = height[column], y = bar$positions[column],
          fill = rep_len(color(bar$col), length(height))[column],
          border = rep_len(color(bar$border), length(height))[column],
          thickness = rep_len(value(bar$dots, "width", 1), length(height))[column],
          lwd = value(bar$dots, "lwd", bar$settings$lwd)
        )
      }
    }
  }
  require(length(drawn) == 8L, "Draw all eight bars.")
  positions <- matrix(NA_real_, 2, 4)
  for (group in seq_along(groups)) {
    for (category in seq_along(categories)) {
      matches <- Filter(function(bar) {
        identical(bar$group, groups[group]) && identical(bar$category, categories[category])
      }, drawn)
      require(length(matches) == 1L, "Keep each count assigned to its category and group.")
      if (length(matches) != 1L) next
      bar <- matches[[1L]]
      positions[group, category] <- bar$y
      require(unname(bar$count) == expected[group, category], "Preserve all eight counts.")
      require(identical(unname(bar$fill), palette[group]), "Use the required group fills.")
      # Base graphics uses approximately 1/96 inch per lwd unit.
      require(identical(unname(bar$border), "#000000") &&
                all(bar$lwd > 0 & bar$lwd * 72 / 96 <= 1),
              "Give every bar a thin black border (at most 1 pt).")
      matching_labels <- unlist(lapply(observed$texts, function(item) {
        as.character(item$labels) == as.character(expected[group, category]) &
          abs(item$y - bar$y) < 0.01 & item$left >= bar$count & item$left <= bar$count + 5
      }))
      require(any(matching_labels), "Put each integer beside its corresponding bar end.")
    }
  }
  require(all(positions[1, ] > positions[2, ]), "Place Group A above Group B.")
  require(all(diff(colMeans(positions)) < 0), "Keep categories in top-to-bottom order.")
  require(length(unique(as.vector(positions))) == 8L,
          "Give all eight bars separate positions.")
  if (length(drawn) == 8L) {
    for (first in seq_len(7L)) {
      for (second in seq.int(first + 1L, 8L)) {
        a <- drawn[[first]]
        b <- drawn[[second]]
        require(abs(a$y - b$y) + 1e-9 >= (a$thickness + b$thickness) / 2,
                "Bars must not overlap.")
      }
    }
    for (category in seq_len(3L)) {
      upper <- Filter(function(bar) identical(bar$category, categories[category]), drawn)
      lower <- Filter(function(bar) identical(bar$category, categories[category + 1L]), drawn)
      if (length(upper) == 2L && length(lower) == 2L) {
        require(min(vapply(upper, function(bar) bar$y - bar$thickness / 2, numeric(1))) >
                  max(vapply(lower, function(bar) bar$y + bar$thickness / 2, numeric(1))),
                "Leave space between categories.")
      }
    }
  }
  legend <- observed$legends
  require(length(legend) == 1L, "Add one legend.")
  if (length(legend) == 1L) {
    require(identical(legend[[1L]]$labels, groups), "Legend must list Group A then Group B.")
    require(identical(unname(color(legend[[1L]]$fill)), palette), "Legend fills must match groups.")
    require(legend[[1L]]$bty == "n", "Remove the legend frame.")
    require(abs(legend[[1L]]$settings$ps * legend[[1L]]$settings$cex *
                legend[[1L]]$cex - 9) < 0.01, "Legend text must be 9 pt.")
  }
  axes <- Filter(function(item) item$side == 1, observed$axes)
  require(length(axes) > 0L && all(vapply(axes, function(item) {
    identical(as.numeric(item$at), c(0, 20, 40, 60, 80)) &&
      abs(item$settings$ps * item$settings$cex *
            value(item$dots, "cex.axis", item$settings$cex.axis) - 9) < 0.01
  }, logical(1L))), "Count ticks must be 0, 20, 40, 60, 80 in 9 pt.")
  titles <- Filter(function(item) length(item$main) > 0L, observed$titles)
  require(length(titles) == 1L && identical(titles[[1L]]$main, "Measurement completeness"),
          "Use the exact journal title.")
  if (length(titles) == 1L) {
    item <- titles[[1L]]
    require(abs(item$settings$ps * item$settings$cex *
                  value(item$dots, "cex.main", item$settings$cex.main) - 11) < 0.01 &&
              value(item$dots, "font.main", item$settings$font.main) == 2,
            "Title must be 11 pt and bold.")
  }
  labels <- Filter(function(item) length(item$xlab) > 0L, observed$titles)
  require(length(labels) == 1L && identical(labels[[1L]]$xlab, "Number of measurements"),
          "Use the exact count-axis label.")
  if (length(labels) == 1L) {
    item <- labels[[1L]]
    require(abs(item$settings$ps * item$settings$cex *
                  value(item$dots, "cex.lab", item$settings$cex.lab) - 9) < 0.01,
            "Count-axis label must be 9 pt.")
  }
  for (item in c(observed$texts, observed$legends, observed$axes, observed$titles)) {
    require(item$monospaced, "Use a resolved monospace font throughout.")
  }
  for (item in observed$texts) {
    require(all(abs(item$settings$ps * item$settings$cex * item$cex - 9) < 0.01),
            "Count and legend text must be 9 pt.")
    require(all(color(value(item$dots, "col", item$settings$col)) == "#000000"),
            "Use black text on the white background.")
  }
  for (item in observed$axes) {
    require(all(color(value(item$dots, "col.axis", item$settings$col.axis)) == "#000000"),
            "Use black tick labels.")
  }
  for (item in observed$titles) {
    require(all(color(value(item$dots, "col.main", item$settings$col.main)) == "#000000") &&
              all(color(value(item$dots, "col.lab", item$settings$col.lab)) == "#000000"),
            "Use black title and axis-label text.")
  }
  unique(errors)
}

figure_check_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (length(args) != 2L || args[[1L]] != "--output" ||
      !endsWith(tolower(args[[2L]]), ".png")) {
    cat("error: use --output PATH.png\n", file = stderr())
    return(2L)
  }
  file_arg <- grep("^--file=", commandArgs(), value = TRUE)[[1L]]
  own_path <- normalizePath(gsub("~+~", " ", sub("^--file=", "", file_arg), fixed = TRUE))
  errors <- tryCatch(
    check_figure(file.path(dirname(own_path), "plot_summary.R"), args[[2L]]),
    error = function(error) paste("Could not inspect the rendered figure:", conditionMessage(error))
  )
  if (length(errors)) {
    cat(paste0("FAIL: ", errors), sep = "\n")
    cat("\n")
  } else {
    cat("PASS: automated JUSF figure requirements.\n")
  }
  cat("VISUAL REVIEW: inspect text bounds, bar edges, legend placement, grayscale readability,\n")
  cat("and the separately authored alt text. View the figure at 6 x 4 inches.\n")
  as.integer(length(errors) > 0L)
}

if (sys.nframe() == 0L) quit(status = figure_check_main())
