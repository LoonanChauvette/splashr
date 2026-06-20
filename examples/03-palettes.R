# 03-palettes.R
# Showcase: splash_named() and splash_palette(n) for different n and themes.
devtools::load_all(".", quiet = TRUE)

cat("=== splash_named() -- the full backbone ===\n")
print(splash_named())

cat("\n=== splash_palette(n) -- evenly-spaced subsets (order preserved) ===\n")
for (n in c(1, 2, 3, 4, 6, 8)) {
  cat(sprintf("\n--- n = %d ---\n", n))
  print(splash_palette(n))
}

cat("\n=== Same n, different theme ===\n")
cat("--- default, n = 4 ---\n"); print(splash_palette(4))
cat("--- cellpond, n = 4 ---\n"); print(splash_palette(4, theme = "cellpond"))

cat("\n=== n larger than the backbone caps at 8 with a warning ===\n")
out <- tryCatch(splash_palette(12), warning = function(w) {
  cat("warning:", conditionMessage(w), "\n")
  suppressWarnings(splash_palette(12))
})
cat("returned length:", length(out), "\n")
print(out)
