#' Named Splash colors for a theme
#'
#' Returns the theme's named colors as a named character vector of hex
#' strings. Useful on its own (e.g. `splash_named()["green"]`) or as the
#' backbone for [splash_palette()].
#'
#' Names are part of the theme: the same name maps to different hex values in
#' different themes. For example, `"green"` is `#00ff00` in the default theme
#' but `#17ff80` in cellpond.
#'
#' @param theme Theme name (a single string). Defaults to `"default"`.
#'
#' @return A named character vector of `#RRGGBB` hex strings, in the theme's
#'   authored order. Length equals the number of named colors in the theme
#'   (8 for the bundled themes).
#'
#' @examples
#' splash_named()
#' splash_named("cellpond")
#'
#' # Pick one by name
#' splash_named()["green"]
#'
#' @export
splash_named <- function(theme = "default") {
  th <- get_theme(theme)
  if (length(th$names) == 0L) {
    out <- character(0)
    return(out)
  }
  hex <- vapply(th$names, code_to_hex, character(1), theme = th)
  names(hex) <- names(th$names)
  hex
}
