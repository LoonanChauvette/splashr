#' Convert Splash colors to hex strings
#'
#' `splash()` is the main entry point of the package. It converts Splash
#' color codes to `#RRGGBB` hex strings that can be used directly in plots
#' and graphics.
#'
#' A Splash color is a 3-digit number `RGB` where each digit is a channel
#' from 0 to 9 (red, green, blue in that order). `000` is black, `999` is
#' white, `900` is red, `090` is green, `009` is blue.
#'
#' @section Input grammar:
#'
#' `splash()` accepts a vector of mixed inputs, each resolved independently:
#'
#' \itemize{
#'   \item **Numeric** -- an integer code, zero-padded to 3 digits.
#'         `splash(900)` == `splash("900")`. Codes outside 0-999 are an error.
#'   \item **3-digit code string** -- a string of exactly three digits.
#'         `splash("407")`.
#'   \item **Wildcard string** -- a 3-character string containing exactly one
#'         `_`, e.g. `"9_9"`. Expands to the 10 native Splash colors along the
#'         wildcard axis (the digit varies 0 to 9), so `"9_9"` yields 10 hex
#'         strings: `"909"`, `"919"`, ..., `"999"`.
#'   \item **Theme color name** -- a string matching a named color in the
#'         active theme, e.g. `"green"`. Names are theme-aware: `"green"`
#'         resolves to `"090"` in the default theme but `"093"` in cellpond.
#' }
#'
#' Mixing is fine: `splash(c("green", "9_9", 900))` returns 1 + 10 + 1 = 12
#' hex strings.
#'
#' @param color A numeric or character vector of Splash colors. See *Input
#'   grammar* above.
#' @param theme Theme name (a single string). Defaults to `"default"`. Use
#'   [splash_themes()] to list available themes and [splash_theme()] to
#'   define your own.
#'
#' @return A character vector of `#RRGGBB` hex strings (lowercase). Length
#'   equals the number of resolved colors: 1 per full code or name, 10 per
#'   wildcard.
#'
#' @examples
#' splash("900")
#' splash(c("900", "090", "009"))
#' splash(900)
#'
#' # By name (theme-aware)
#' splash("green")
#' splash("green", theme = "cellpond")
#'
#' # A 10-step ramp along one channel ("_" is a wildcard)
#' splash("9_9")
#'
#' @export
splash <- function(color, theme = "default") {
  th <- get_theme(theme)
  # Normalize everything to character first so we can branch on string shape.
  color <- as_splash_input(color)
  unlist(lapply(color, resolve_one, theme = th), use.names = FALSE)
}

# Internal: coerce input to a character vector, handling numeric codes.
# Numeric codes are zero-padded to 3 digits; characters pass through.
as_splash_input <- function(color) {
  if (is.numeric(color)) {
    if (anyNA(color)) stop("`color` contains NA values.")
    if (any(color < 0) || any(color > 999) || any(color != floor(color))) {
      stop("Numeric `color` values must be integers in 0-999.")
    }
    return(sprintf("%03d", as.integer(color)))
  }
  if (!is.character(color)) {
    stop("`color` must be a numeric or character vector.")
  }
  if (anyNA(color)) stop("`color` contains NA values.")
  color
}

# Internal: resolve a single character element to one or more hex strings,
# using the given theme. Returns a character vector (length 1 for a full
# code or name, length 10 for a wildcard).
resolve_one <- function(code, theme) {
  # Branch 1: wildcard -- exactly one "_" plus two other chars that are digits.
  if (nchar(code) == 3L && grepl("^[0-9]_[0-9]$|^[0-9]{2}_$|^_[0-9]{2}$", code)) {
    codes <- expand_wildcard(code)
    return(vapply(codes, code_to_hex, character(1), theme = theme))
  }
  # Branch 2: full 3-digit code.
  if (grepl("^[0-9]{3}$", code)) {
    return(code_to_hex(code, theme))
  }
  # Branch 3: theme color name.
  if (code %in% names(theme$names)) {
    return(code_to_hex(theme$names[[code]], theme))
  }
  # Branch 4: nothing matched -- error with a helpful message.
  valid <- paste(names(theme$names), collapse = ", ")
  stop(sprintf(
    "Unknown Splash color `%s`. Use a 3-digit code (e.g. \"900\"), a wildcard (e.g. \"9_9\"), or a theme color name. Valid names for theme `%s`: %s",
    code, theme_name_or_unknown(theme), if (nzchar(valid)) valid else "(none)"
  ))
}

# Internal: expand a wildcard code (3 chars, one "_") to the 10 full codes.
expand_wildcard <- function(code) {
  pos <- which(strsplit(code, "")[[1]] == "_")
  vapply(0:9, function(d) {
    chars <- strsplit(code, "")[[1]]
    chars[pos] <- as.character(d)
    paste(chars, collapse = "")
  }, character(1))
}

# Internal: convert a 3-digit code string to a #RRGGBB hex string, given a
# theme. Looks up each digit in the theme's per-channel LUT.
code_to_hex <- function(code, theme) {
  digits <- as.integer(strsplit(code, "")[[1]])
  sprintf("#%02x%02x%02x",
    theme$r[digits[1] + 1L],
    theme$g[digits[2] + 1L],
    theme$b[digits[3] + 1L]
  )
}

# Internal: best-effort recovery of a theme's name for error messages. Themes
# are stored without their name attached, so we scan the registry. Returns
# "?" if not found (e.g. a freshly built but unregistered theme in tests).
theme_name_or_unknown <- function(theme) {
  for (nm in ls(.splash_themes)) {
    if (identical(get(nm, envir = .splash_themes), theme)) return(nm)
  }
  "?"
}
