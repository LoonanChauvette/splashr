# 04-round-trip.R
# Showcase: as_splash() inverse and the 1000-code round-trip property.
devtools::load_all(".", quiet = TRUE)

cat("=== Hex -> Splash code ===\n")
print(as_splash("#ff0000"))
print(as_splash("00ff00"))     # no leading '#'
print(as_splash("#f00"))       # shorthand #RGB
print(as_splash(c("#ff0000", "#00ff00", "#0000ff")))

cat("\n=== Round-trip: code -> hex -> code ===\n")
for (code in c("000", "555", "999", "407", "940")) {
  rt <- as_splash(splash(code))
  cat(sprintf("%s -> %s -> %s  %s\n", code, splash(code), rt,
              if (rt == code) "OK" else "MISMATCH"))
}

cat("\n=== Theme-aware: cellpond '000' maps to #171d28 ===\n")
cat(sprintf("cellpond 000 hex: %s\n", splash("000", theme = "cellpond")))
cat(sprintf("#171d28 -> code (cellpond): %s\n", as_splash("#171d28", theme = "cellpond")))

cat("\n=== Marquee: round-trip ALL 1000 codes, both themes ===\n")
codes <- sprintf("%03d", 0:999)
ok_default  <- identical(as_splash(splash(codes)), codes)
ok_cellpond <- identical(as_splash(splash(codes, theme = "cellpond"), theme = "cellpond"), codes)
cat(sprintf("default  1000-code round-trip: %s\n", ok_default))
cat(sprintf("cellpond 1000-code round-trip: %s\n", ok_cellpond))
