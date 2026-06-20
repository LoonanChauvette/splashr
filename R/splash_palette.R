#' Generate an n-color Splash palette
#'
#' `splash_palette()` returns `n` hex colors sampled from the theme's named
#' color backbone. It is the quickest way to get a ready-to-use categorical
#' palette for plotting.
#'
#' Selection is evenly spaced across the backbone in its authored order,
#' always preserving that order. For `n` less than the backbone size, every
#' `floor(size / n)`-th color is taken (with the first and last always
#' included). For `n` equal to the backbone size, the full backbone is
#' returned in order.
#'
#' Because the v0.1 palette is restricted to the theme's named backbone, `n`
#' is capped at the backbone size (8 for the bundled themes). Requesting more
#' returns the full backbone with a warning. Interpolated palettes for larger
#' `n` are planned for a future release.
#'
#' @param n Integer. Number of colors requested. Defaults to `8`. Values
#'   larger than the theme's backbone are capped (with a warning); values
#'   less than 1 are an error.
#' @param theme Theme name (a single string). Defaults to `"default"`.
#'
#' @return A character vector of `#RRGGBB` hex strings, length `min(n,
#'   backbone_size)`.
#'
#' @examples
#' splash_palette()          # the full default backbone (8 colors)
#' splash_palette(4)         # 4 evenly-spaced colors
#' splash_palette(3, theme = "cellpond")
#'
#' @export
splash_palette <- function(n = 8L, theme = "default") {
  th <- get_theme(theme)
  backbone <- splash_named(theme)
  size <- length(backbone)
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1L || n != floor(n)) {
    stop("`n` must be a single positive integer.")
  }
  n <- as.integer(n)
  if (n > size) {
    warning(sprintf(
      "`n` (%d) is larger than the theme's named backbone (%d); returning the full backbone. Interpolated palettes for larger n are planned for a future release.",
      n, size
    ))
    return(backbone)
  }
  if (n == size) {
    return(backbone)
  }
  # Evenly-spaced indices across 1..size, always including first and last.
  # seq() guarantees length n with endpoints included.
  idx <- round(seq(1L, size, length.out = n))
  backbone[idx]
}
