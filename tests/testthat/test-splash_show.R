test_that("splash_show() draws a single color without error", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(splash_show("900"))
})

test_that("splash_show() draws a palette without error", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(splash_show(splash_palette(4)))
})

test_that("splash_show() draws a wildcard ramp without error", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  out <- splash_show("9_9")
  expect_length(out, 10L)
})

test_that("splash_show() draws named colors without error", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(splash_show(c("red", "green", "blue")))
})

test_that("splash_show() is theme-aware", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(splash_show("9_9", theme = "cellpond"))
})

test_that("splash_show() respects labels = FALSE", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_invisible(splash_show("900", labels = FALSE))
})

test_that("splash_show() returns the hex colors invisibly", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  out <- splash_show(c("900", "090", "009"))
  expect_equal(out, splash(c("900", "090", "009")))
})

test_that("splash_show() errors on empty input", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_error(splashr:::draw_swatch(character(0), character(0)), "zero colors")
})

test_that("label_for() labels a full code", {
  th <- get_theme("default")
  expect_equal(splashr:::label_for("900", "default", 1L), "900")
})

test_that("label_for() labels a theme name with the code and name", {
  expect_equal(splashr:::label_for("green", "default", 1L), "090 (green)")
})

test_that("label_for() expands a wildcard to 10 labels", {
  labs <- splashr:::label_for("9_9", "default", 10L)
  expect_length(labs, 10L)
  expect_equal(labs[1], "909")
  expect_equal(labs[10], "999")
})

test_that("label_for() handles a mixed vector", {
  labs <- splashr:::label_for(c("green", "9_9", 900), "default", 12L)
  expect_length(labs, 1L + 10L + 1L)
  expect_equal(labs[1], "090 (green)")
  expect_equal(labs[2], "909")
  expect_equal(labs[12], "900")
})

test_that("is_light() identifies light vs dark colors", {
  expect_true(splashr:::is_light("#ffffff"))   # white is light
  expect_false(splashr:::is_light("#000000"))  # black is dark
  expect_true(splashr:::is_light("#00ff00"))   # bright green is light
  expect_false(splashr:::is_light("#0000ff"))  # pure blue is dark
})

test_that("splash_show() errors on bad theme", {
  f <- withr::local_tempfile(fileext = ".pdf")
  pdf(f)
  on.exit(dev.off(), add = TRUE)
  expect_error(splash_show("900", theme = "nope"))
})
