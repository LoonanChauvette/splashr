#' Internal theme registry for splashr
#'
#' Themes are stored in an environment inside the package namespace so that
#' \code{splash_theme()} can register user-defined themes at runtime and
#' \code{get_theme()} can retrieve them quickly. A theme is a list with:
#' \itemize{
#'   \item \code{r}, \code{g}, \code{b} -- integer vectors of length 10, the
#'         per-channel lookup table mapping a 0-9 digit to a 0-255 value.
#'   \item \code{names} -- an optional named character vector of 3-digit
#'         Splash codes, e.g. \code{c(green = "090", ...)}. Names are part of
#'         the theme because the same color name maps to different codes in
#'         different themes.
#' }
#'
#' @keywords internal
#' @name splashr-themes
NULL

# The registry environment. Using an environment gives us mutable state
# without touching the global env or options(), and it survives for the
# lifetime of the loaded package. Bundled themes are registered in .onLoad.
.splash_themes <- new.env(parent = emptyenv())

# Internal: validate a single channel lookup table.
.validate_channel <- function(x, name) {
  if (!is.numeric(x) || length(x) != 10L) {
    stop(sprintf("theme channel `%s` must be a numeric vector of length 10.", name))
  }
  x <- as.integer(x)
  if (anyNA(x) || any(x < 0L) || any(x > 255L)) {
    stop(sprintf("theme channel `%s` values must be integers in 0-255.", name))
  }
  x
}

# Internal: validate the `names` component of a theme.
.validate_names <- function(names, label = "names") {
  if (is.null(names)) {
    out <- character(0)
    names(out) <- character(0)
    return(out)
  }
  if (!is.character(names)) {
    stop(sprintf("theme `%s` must be a character vector (or NULL).", label))
  }
  if (anyNA(names) || any(!nzchar(names))) {
    stop(sprintf("theme `%s` entries must be non-empty and non-NA.", label))
  }
  if (is.null(names(names))) {
    stop(sprintf("theme `%s` must be a named vector (name -> code).", label))
  }
  if (anyDuplicated(names(names))) {
    stop(sprintf("theme `%s` has duplicate color names.", label))
  }
  # Codes must be 1-3 digits. Zero-pad to 3 chars for a canonical form.
  nm <- names(names)
  codes <- vapply(names, function(code) {
    if (!grepl("^[0-9]{1,3}$", code)) {
      stop(sprintf("theme `%s` code `%s` must be 1-3 digits.", label, code))
    }
    sprintf("%03d", as.integer(code))
  }, character(1))
  names(codes) <- nm
  codes
}

# Internal: build and validate a full theme list.
make_theme <- function(r, g, b, names = NULL) {
  list(
    r = .validate_channel(r, "r"),
    g = .validate_channel(g, "g"),
    b = .validate_channel(b, "b"),
    names = .validate_names(names)
  )
}

# Internal: retrieve a theme by name. Errors clearly if missing.
get_theme <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)) {
    stop("`theme` must be a single non-empty character string.")
  }
  if (!exists(name, envir = .splash_themes)) {
    avail <- paste(sort(ls(.splash_themes)), collapse = ", ")
    stop(sprintf(
      "Unknown theme `%s`. Available themes: %s",
      name, if (nzchar(avail)) avail else "(none)"
    ))
  }
  get(name, envir = .splash_themes)
}

# Internal: register a theme by name (overwrites silently).
register_theme <- function(name, theme) {
  assign(name, theme, envir = .splash_themes)
}

# Internal: remove a theme by name (no-op if absent). Used by tests for cleanup.
register_theme_reset <- function(name) {
  if (exists(name, envir = .splash_themes)) {
    rm(list = name, envir = .splash_themes)
  }
  invisible(NULL)
}

#' Define a custom Splash theme
#'
#' A Splash theme maps each 0-9 digit to a 0-255 value for each of the three
#' channels (red, green, blue), and optionally attaches named colors. Themes
#' are registered for the lifetime of the loaded package.
#'
#' @param name Theme name (a single non-empty string).
#' @param r,g,b Numeric vectors of length 10. Values are coerced to integer
#'   and must lie in 0-255.
#' @param names Optional named character vector of 3-digit Splash codes, e.g.
#'   `c(green = "090", red = "900")`. Names are part of the theme: the same
#'   color name can map to different codes in different themes.
#'
#' @return Invisibly, the registered theme (a list with `r`, `g`, `b`,
#'   `names`).
#'
#' @examples
#' splash_theme(
#'   "high-contrast",
#'   r = seq(0, 255, length.out = 10),
#'   g = seq(0, 255, length.out = 10),
#'   b = seq(0, 255, length.out = 10)
#' )
#' splash_themes()
#'
#' @export
splash_theme <- function(name, r, g, b, names = NULL) {
  if (!is.character(name) || length(name) != 1L || is.na(name) || !nzchar(name)) {
    stop("`name` must be a single non-empty character string.")
  }
  theme <- make_theme(r, g, b, names)
  register_theme(name, theme)
  invisible(theme)
}

#' List available Splash themes
#'
#' @return A character vector of registered theme names, sorted alphabetically.
#'
#' @examples
#' splash_themes()
#'
#' @export
splash_themes <- function() {
  sort(ls(.splash_themes))
}
