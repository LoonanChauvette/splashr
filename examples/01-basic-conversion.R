# 01-basic-conversion.R
# Showcase: the core splash() function with every input type.
devtools::load_all(".", quiet = TRUE)

cat("=== A single 3-digit code ===\n")
print(splash("900"))

cat("\n=== Several codes at once (vectorized) ===\n")
print(splash(c("900", "090", "009")))

cat("\n=== Numeric codes are zero-padded to 3 digits ===\n")
print(splash(c(900, 90, 9)))   # 900, 090, 009

cat("\n=== By theme color name ===\n")
print(splash(c("red", "green", "blue", "yellow")))

cat("\n=== Wildcard ramp: '9_9' -> green varies 0..9 (10 colors) ===\n")
print(splash("9_9"))

cat("\n=== Mixed input in a single call (1 + 10 + 1 = 12 colors) ===\n")
out <- splash(c("green", "9_9", 900))
cat("length:", length(out), "\n")
print(out)
