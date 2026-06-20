# 02-themes.R
# Showcase: the default vs cellpond themes, and custom theme registration.
devtools::load_all(".", quiet = TRUE)

cat("=== Available themes ===\n")
print(splash_themes())

cat("\n=== Same name, different hex across themes ===\n")
cat(sprintf('green (default):  %s\n', splash("green")))
cat(sprintf('green (cellpond): %s\n', splash("green", theme = "cellpond")))

cat("\n=== Same code, different hex across themes (cellpond skews bluer/greener) ===\n")
cat(sprintf('555 (default):  %s\n', splash("555")))
cat(sprintf('555 (cellpond): %s\n', splash("555", theme = "cellpond")))

cat("\n=== The eight named colors in each theme ===\n")
cat("--- default ---\n"); print(splash_named())
cat("--- cellpond ---\n"); print(splash_named("cellpond"))

cat("\n=== Define a custom theme and use it ===\n")
splash_theme(
  "warm",
  r = c(20, 50, 80, 110, 140, 170, 200, 220, 240, 255),
  g = c(10, 25, 40, 55, 70, 90, 115, 145, 190, 240),
  b = c( 5, 15, 25, 35, 50, 70,  95, 125, 170, 220),
  names = c(red = "900", ember = "940", gold = "990")
)
cat("themes now:", paste(splash_themes(), collapse = ", "), "\n")
cat(sprintf('warm red:   %s\n', splash("red", theme = "warm")))
cat(sprintf('warm ember: %s\n', splash("ember", theme = "warm")))
cat(sprintf('warm gold:  %s\n', splash("gold", theme = "warm")))
