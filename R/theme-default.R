#' The default Splash theme
#'
#' Linear mapping: each 0-9 digit maps to `floor(d/9 * 255)`, i.e.
#' `0, 28, 56, 85, 113, 141, 170, 198, 226, 255`. Named colors are the eight
#' "popular" colors from TodePond's Splash post.
#'
#' @keywords internal
#' @name theme-default
NULL

# Linear 0-9 -> 0-255 channel mapping (floor(d/9 * 255)). Defined here, built
# and registered in .onLoad (R/zzz.R) so file source order does not matter.
.default_channel <- as.integer(floor(seq(0, 9) / 9 * 255))

.default_names <- c(
  green  = "090",
  cyan   = "099",
  blue   = "009",
  purple = "409",
  pink   = "909",
  red    = "900",
  orange = "940",
  yellow = "990"
)

# Internal: build the default theme list.
default_theme <- function() {
  make_theme(
    r = .default_channel,
    g = .default_channel,
    b = .default_channel,
    names = .default_names
  )
}
