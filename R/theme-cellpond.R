#' The Cellpond Splash theme
#'
#' TodePond's personal pastel channel mapping, taken from the `CHANNEL_VALUES`
#' table in the Splash blog post (https://www.todepond.com/lab/splash/).
#' Named colors are his personal eight. Compared to the default theme, colors
#' skew slightly bluer/greener and more pastel, and `000` is a touch off-black
#' so it remains visible on a black background.
#'
#' @keywords internal
#' @name theme-cellpond
NULL

# Per-channel 0-9 -> hex, from the blog post's CHANNEL_VALUES:
#   R: ['17', '37', '46', '62', '80', '9f', 'ae', 'cc', 'f2', 'ff']
#   G: ['1d', '43', '62', '80', '9f', 'ae', 'cc', 'de', 'f5', 'ff']
#   B: ['28', '46', '62', '80', '9f', 'ae', 'cc', 'de', 'f7', 'ff']
# Converted to decimal integers. Built and registered in .onLoad (R/zzz.R).
.cellpond_r <- c(0x17L, 0x37L, 0x46L, 0x62L, 0x80L, 0x9fL, 0xaeL, 0xccL, 0xf2L, 0xffL)
.cellpond_g <- c(0x1dL, 0x43L, 0x62L, 0x80L, 0x9fL, 0xaeL, 0xccL, 0xdeL, 0xf5L, 0xffL)
.cellpond_b <- c(0x28L, 0x46L, 0x62L, 0x80L, 0x9fL, 0xaeL, 0xccL, 0xdeL, 0xf7L, 0xffL)

# TodePond's personal eight, from the blog post.
.cellpond_names <- c(
  green  = "093",
  cyan   = "289",
  blue   = "059",
  purple = "529",
  pink   = "947",
  red    = "922",
  orange = "942",
  yellow = "991"
)

# Internal: build the cellpond theme list.
cellpond_theme <- function() {
  make_theme(
    r = .cellpond_r,
    g = .cellpond_g,
    b = .cellpond_b,
    names = .cellpond_names
  )
}
