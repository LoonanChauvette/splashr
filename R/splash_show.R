#' Display Splash colors as a swatch plot
#'
#' `splash_show()` draws a quick horizontal swatch strip of one or more Splash
#' colors, labeling each with its code. It uses base R graphics only (no
#' ggplot2), so it works anywhere R runs. It's handy for exploring colors and
#' palettes, and for the package README.
#'
#' The function accepts anything [splash()] accepts: a 3-digit code, a
#' wildcard ramp (e.g. `"9_9"`), a theme color name, a numeric code, or a
#' vector mixing any of these. Labels show the resolved code for each swatch;
#' for theme names the name is shown in parentheses.
#'
#' @param color A Splash color specification passed to [splash()]. A single
#'   value or a vector.
#' @param theme Theme name (a single string). Defaults to `"default"`.
#' @param labels Logical. Whether to draw text labels (codes) on the swatches.
#'   Defaults to `TRUE`.
#' @param ... Additional arguments passed to [graphics::par()] (e.g. `mar`).
#'
#' @return Invisibly, a character vector of the hex colors drawn (the same
#'   value [splash()] would return for `color`).
#'
#' @examples
#' \donttest{
#' splash_show("900")
#' splash_show(c("red", "green", "blue"))
#' splash_show("9_9")                 # a 10-step ramp
#' splash_show(splash_palette(4))
#' splash_show("9_9", theme = "cellpond")
#' }
#'
#' @export
splash_show <- function(color, theme = "default", labels = TRUE, ...) {
  # Accept either Splash specs (codes/names/wildcards) or pre-resolved hex
  # strings (e.g. the output of splash_palette()). Hex is passed through
  # unchanged so users can show any palette of colors.
  if (is_hex_vec(color)) {
    hex <- color
    labs <- rep_len("", length(hex))
  } else {
    hex <- splash(color, theme = theme)
    labs <- label_for(color, theme = theme, n = length(hex))
  }
  draw_swatch(hex, labs, labels = labels, ...)
  invisible(hex)
}

# Internal: detect a character vector of #RRGGBB hex strings (so splash_show
# can pass them through without re-resolving as Splash codes).
is_hex_vec <- function(color) {
  is.character(color) && length(color) > 0L &&
    all(grepl("^#[0-9a-fA-F]{6}$", color))
}

# Internal: build a label for each swatch. For a single full code/name we show
# the code (and the name in parens if a name was given). For a wildcard we
# show the 10 expanded codes. For a vector we resolve each element in turn.
label_for <- function(color, theme, n) {
  th <- get_theme(theme)
  # Normalize to character so we can branch on string shape, mirroring splash().
  color <- as_splash_input(color)
  out <- character(0)
  for (code in color) {
    if (nchar(code) == 3L && grepl("^[0-9]_[0-9]$|^[0-9]{2}_$|^_[0-9]{2}$", code)) {
      # Wildcard: label with the 10 expanded codes.
      out <- c(out, expand_wildcard(code))
    } else if (grepl("^[0-9]{3}$", code)) {
      out <- c(out, code)
    } else if (code %in% names(th$names)) {
      out <- c(out, sprintf("%s (%s)", th$names[[code]], code))
    } else {
      # Should not happen: splash() would have errored first. Fall back to raw.
      out <- c(out, code)
    }
  }
  out
}

# Internal: draw a horizontal swatch strip with optional labels.
draw_swatch <- function(hex, labs, labels = TRUE, ...) {
  n <- length(hex)
  if (n == 0L) {
    stop("Nothing to display: `color` resolved to zero colors.")
  }
  op <- graphics::par(mar = c(2, 1, 2, 1), ...)
  on.exit(graphics::par(op), add = TRUE)
  # Set up an empty plot region; each swatch is a vertical slice.
  graphics::plot.new()
  graphics::plot.window(xlim = c(0, n), ylim = c(0, 1))
  for (i in seq_len(n)) {
    graphics::rect(i - 1, 0, i, 1, col = hex[i], border = NA)
  }
  if (labels) {
    # Place the label in the middle of each swatch, choosing text color for
    # contrast against the swatch background.
    for (i in seq_len(n)) {
      txt_col <- if (is_light(hex[i])) "#000000" else "#ffffff"
      graphics::text(i - 0.5, 0.5, labs[i], col = txt_col, cex = 0.7)
    }
  }
  # A thin outer box for definition.
  graphics::rect(0, 0, n, 1, border = "#808080")
}

# Internal: decide whether a hex color is light enough to need dark text.
# Uses relative luminance (Rec. 709) and a 0.5 threshold.
is_light <- function(hex) {
  rgb <- parse_hex(hex)
  # luminance = 0.2126 R + 0.7152 G + 0.0722 B, normalized to 0-1.
  lum <- (0.2126 * rgb[, "r"] + 0.7152 * rgb[, "g"] + 0.0722 * rgb[, "b"]) / 255
  lum > 0.5
}
