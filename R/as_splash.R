#' Convert hex colors to Splash codes
#'
#' `as_splash()` is the inverse of [splash()]: it takes `#RRGGBB` hex strings
#' and returns the nearest Splash code for the given theme. "Nearest" means
#' each channel is independently matched to the closest value in the theme's
#' 0-9 lookup table.
#'
#' Because the mapping is theme-specific, round-trips are stable within a
#' theme: `as_splash(splash(code, theme), theme)` returns `code` for every
#' valid Splash code.
#'
#' @param hex A character vector of hex colors. A leading `#` is optional;
#'   shorthand `#RGB` (e.g. `"#fff"`) is expanded to `#RRGGBB`. Case is
#'   ignored.
#' @param theme Theme name (a single string). Defaults to `"default"`.
#'
#' @return A character vector of 3-digit Splash code strings (e.g. `"900"`),
#'   the same length as `hex`.
#'
#' @examples
#' as_splash("#ff0000")
#' as_splash("00ff00")
#' as_splash(c("#ff0000", "#00ff00", "#0000ff"))
#'
#' # Round-trips are stable within a theme
#' code <- "407"
#' as_splash(splash(code), theme = "default")
#'
#' # Theme-aware: the same hex may map to different codes
#' as_splash("#171d28", theme = "cellpond")
#'
#' @export
as_splash <- function(hex, theme = "default") {
  th <- get_theme(theme)
  rgb <- parse_hex(hex)
  apply_nearest(rgb, th)
}

# Internal: parse a hex color string to an integer matrix with 3 columns
# (R, G, B), values in 0-255. Accepts #RRGGBB, RRGGBB, #RGB, and RGB (case
# insensitive). Returns a matrix with length(hex) rows.
parse_hex <- function(hex) {
  if (!is.character(hex)) {
    stop("`hex` must be a character vector.")
  }
  if (anyNA(hex)) stop("`hex` contains NA values.")
  # Strip a leading '#'.
  stripped <- sub("^#", "", hex)
  # Normalize shorthand #RGB -> #RRGGBB by doubling each char.
  is_short <- nchar(stripped) == 3L
  is_long  <- nchar(stripped) == 6L
  if (!all(is_short | is_long)) {
    stop("Each hex color must be 3 or 6 hex digits (optionally prefixed with '#').")
  }
  expanded <- vapply(seq_along(stripped), function(i) {
    s <- stripped[i]
    if (nchar(s) == 3L) {
      chars <- strsplit(s, "")[[1]]
      paste(rep(chars, each = 2L), collapse = "")
    } else {
      s
    }
  }, character(1))
  # Validate hex digits and convert.
  if (!all(grepl("^[0-9a-fA-F]{6}$", expanded))) {
    stop("Hex colors must contain only 0-9 and a-f (case insensitive).")
  }
  r <- strtoi(substr(expanded, 1L, 2L), 16L)
  g <- strtoi(substr(expanded, 3L, 4L), 16L)
  b <- strtoi(substr(expanded, 5L, 6L), 16L)
  m <- cbind(r = r, g = g, b = b)
  rownames(m) <- NULL
  m
}

# Internal: for each row in an RGB matrix, find the nearest LUT index (0-9)
# in the theme for each channel, and return the 3-digit code strings.
apply_nearest <- function(rgb, theme) {
  digits <- cbind(
    nearest_index(rgb[, "r"], theme$r),
    nearest_index(rgb[, "g"], theme$g),
    nearest_index(rgb[, "b"], theme$b)
  )
  apply(digits, 1L, function(d) {
    sprintf("%d%d%d", d[1L], d[2L], d[3L])
  })
}

# Internal: for each value, return the index (0-9) of the nearest entry in
# the lookup table `lut`. Ties resolve to the lower index (i.e. the first
# minimum), which is deterministic and keeps round-trips stable.
nearest_index <- function(value, lut) {
  idx <- integer(length(value))
  for (i in seq_along(value)) {
    idx[i] <- which.min(abs(lut - value[i])) - 1L
  }
  idx
}
