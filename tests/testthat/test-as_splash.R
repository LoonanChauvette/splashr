test_that("as_splash() converts full hex to a 3-digit code", {
  expect_equal(as_splash("#ff0000"), "900")
  expect_equal(as_splash("#00ff00"), "090")
  expect_equal(as_splash("#0000ff"), "009")
  expect_equal(as_splash("#000000"), "000")
  expect_equal(as_splash("#ffffff"), "999")
})

test_that("as_splash() works without the leading '#'", {
  expect_equal(as_splash("ff0000"), as_splash("#ff0000"))
  expect_equal(as_splash("00ff00"), as_splash("#00ff00"))
})

test_that("as_splash() accepts shorthand #RGB and expands it", {
  expect_equal(as_splash("#f00"), as_splash("#ff0000"))
  expect_equal(as_splash("#0f0"), as_splash("#00ff00"))
  expect_equal(as_splash("f00"), as_splash("#ff0000"))
})

test_that("as_splash() is case insensitive", {
  expect_equal(as_splash("#FF0000"), as_splash("#ff0000"))
  expect_equal(as_splash("#FfFfFf"), as_splash("#ffffff"))
})

test_that("as_splash() is vectorized", {
  expect_equal(
    as_splash(c("#ff0000", "#00ff00", "#0000ff")),
    c("900", "090", "009")
  )
})

test_that("as_splash() returns 3-character digit strings", {
  out <- as_splash(c("#000000", "#ffffff", "#171d28"))
  expect_true(all(grepl("^[0-9]{3}$", out)))
})

test_that("as_splash() is theme-aware", {
  # cellpond "000" maps to #171d28; round-trips within cellpond.
  expect_equal(as_splash("#171d28", theme = "cellpond"), "000")
  # The same hex may map to different codes across themes.
  # #ff0000 -> "900" in default, but cellpond's red LUT differs.
  expect_equal(as_splash("#ff0000"), "900")
})

test_that("as_splash() round-trips every code in 0:999 (default theme)", {
  codes <- sprintf("%03d", 0:999)
  rt <- as_splash(splash(codes, theme = "default"), theme = "default")
  expect_equal(rt, codes)
})

test_that("as_splash() round-trips every code in 0:999 (cellpond theme)", {
  codes <- sprintf("%03d", 0:999)
  rt <- as_splash(splash(codes, theme = "cellpond"), theme = "cellpond")
  expect_equal(rt, codes)
})

test_that("as_splash() round-trips theme color names via splash()", {
  for (nm in c("green","cyan","blue","purple","pink","red","orange","yellow")) {
    code <- get_theme("default")$names[[nm]]
    expect_equal(as_splash(splash(nm)), code)
  }
})

test_that("as_splash() errors on malformed hex", {
  expect_snapshot(error = TRUE, as_splash("#ff000"))   # 5 digits -> bad
  expect_snapshot(error = TRUE, as_splash("ff"))       # 2 digits -> bad
  expect_snapshot(error = TRUE, as_splash("#gggggg"))  # non-hex chars
})

test_that("as_splash() errors on NA and non-character input", {
  expect_error(as_splash(NA_character_))
  expect_error(as_splash(123))
})

test_that("as_splash() errors on bad theme", {
  expect_error(as_splash("#ff0000", theme = "nope"))
})

test_that("nearest_index ties resolve to the lower index (deterministic)", {
  # In the default theme, the LUT is 0,28,56,...,255. The midpoint between
  # 0 and 28 is 14; values <= 14 round down to index 0, >= 15 to index 1.
  th <- get_theme("default")
  expect_equal(splashr:::nearest_index(14, th$r), 0L)
  expect_equal(splashr:::nearest_index(15, th$r), 1L)
})
