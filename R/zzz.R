#' Package load/unload hooks
#'
#' Registers the bundled themes (`default`, `cellpond`) once all `R/*.R`
#' files have been sourced, so source order does not matter.
#'
#' @name splashr-zzz
#' @keywords internal
NULL

.onLoad <- function(libname, pkgname) {
  register_theme("default", default_theme())
  register_theme("cellpond", cellpond_theme())
}
