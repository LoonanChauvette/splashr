# 05-swatch.R
# Showcase: splash_show() rendering single colors, ramps, and palettes.
# Writes PNGs to examples/output/ so you can view the results.
devtools::load_all(".", quiet = TRUE)

# Resolve this script's directory so output goes next to it.
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("--file=", "", grep("--file=", args, value = TRUE)[1])
script_dir <- if (nzchar(file_arg)) dirname(normalizePath(file_arg)) else "."
outdir <- file.path(script_dir, "output")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

draw <- function(name, expr) {
  path <- file.path(outdir, paste0(name, ".png"))
  png(path, width = 900, height = 120)
  on.exit(dev.off(), add = TRUE)
  eval(expr)
  cat("wrote", path, "\n")
}

cat("=== A single color ===\n")
draw("single-900", splash_show("900"))

cat("\n=== A named palette ===\n")
draw("palette-named", splash_show(c("red", "green", "blue", "yellow")))

cat("\n=== A 10-step wildcard ramp (green varies) ===\n")
draw("ramp-9_9", splash_show("9_9"))

cat("\n=== splash_palette(8), default theme ===\n")
draw("palette-8-default", splash_show(splash_palette(8)))

cat("\n=== splash_palette(4), cellpond theme ===\n")
draw("palette-4-cellpond", splash_show(splash_palette(4, theme = "cellpond")))

cat("\n=== Wildcard ramp in the cellpond theme ===\n")
draw("ramp-9_9-cellpond", splash_show("9_9", theme = "cellpond"))

cat("\nDone. View the PNGs in", normalizePath(outdir), "\n")
