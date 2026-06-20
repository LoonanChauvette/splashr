# Shared expected named colors for the default theme.
.default_named_hex <- c(
  green  = "#00ff00",
  cyan   = "#00ffff",
  blue   = "#0000ff",
  purple = "#7100ff",
  pink   = "#ff00ff",
  red    = "#ff0000",
  orange = "#ff7100",
  yellow = "#ffff00"
)

test_that("splash_named() returns the theme's named colors as named hex", {
  out <- splash_named()
  expect_type(out, "character")
  expect_named(out, names(.default_named_hex))
  expect_equal(out, .default_named_hex)
})

test_that("splash_named() is theme-aware", {
  cell <- splash_named("cellpond")
  expect_named(cell, names(.default_named_hex))
  # Same names, different hex (cellpond skews bluer/greener).
  expect_false(identical(cell, .default_named_hex))
  # Spot-check: cellpond green = "093" -> #17ff80.
  expect_equal(cell[["green"]], splash("093", theme = "cellpond"))
})

test_that("splash_named() respects theme order", {
  th <- get_theme("default")
  out <- splash_named()
  expect_equal(names(out), names(th$names))
})

test_that("splash_named() errors on bad theme", {
  expect_error(splash_named("nope"))
})

test_that("splash_palette() default returns the full backbone", {
  out <- splash_palette()
  expect_equal(out, splash_named())
  expect_length(out, 8L)
})

test_that("splash_palette(n) returns evenly-spaced subsets in order", {
  full <- splash_named()
  # n = 1: just the first color.
  expect_equal(splash_palette(1L), full[1])
  # n = 2: first and last.
  expect_equal(splash_palette(2L), full[c(1, 8)])
  # n = 4: evenly spaced, order preserved, includes endpoints.
  out4 <- splash_palette(4L)
  expect_length(out4, 4L)
  expect_equal(out4[1], full[1])
  expect_equal(out4[4], full[8])
  expect_equal(names(out4), names(out4)) # stable
  # n = 8: full backbone.
  expect_equal(splash_palette(8L), full)
})

test_that("splash_palette() preserves the backbone's order", {
  full <- splash_named()
  for (n in 1:8) {
    out <- splash_palette(n)
    # Selected indices must be strictly increasing in the backbone.
    pos <- match(names(out), names(full))
    expect_equal(pos, sort(pos), info = paste("n =", n))
  }
})

test_that("splash_palette() is theme-aware", {
  expect_equal(splash_palette(8L, theme = "cellpond"), splash_named("cellpond"))
  expect_equal(splash_palette(4L, theme = "cellpond")[1], splash_named("cellpond")[1])
})

test_that("splash_palette() caps n > backbone with a warning", {
  expect_warning(out <- splash_palette(12L), "larger than the theme's named backbone")
  expect_equal(out, splash_named())
  expect_length(out, 8L)
})

test_that("splash_palette() errors on bad n", {
  expect_error(splash_palette(0L))
  expect_error(splash_palette(-1L))
  expect_error(splash_palette(1.5))
  expect_error(splash_palette(c(1, 2)))
  expect_error(splash_palette(NA_integer_))
})

test_that("splash_palette() errors on bad theme", {
  expect_error(splash_palette(4L, theme = "nope"))
})
