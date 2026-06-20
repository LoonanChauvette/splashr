test_that("both bundled themes are registered on load", {
  avail <- splash_themes()
  expect_contains(avail, c("default", "cellpond"))
})

test_that("get_theme() retrieves a registered theme", {
  th <- get_theme("default")
  expect_type(th, "list")
  expect_named(th, c("r", "g", "b", "names"))
})

test_that("get_theme() errors clearly on unknown theme", {
  expect_error(get_theme("nope"), class = "simpleError")
  expect_snapshot(error = TRUE, get_theme("nope"))
})

test_that("get_theme() rejects bad name input", {
  expect_error(get_theme(c("a", "b")))
  expect_error(get_theme(NA_character_))
  expect_error(get_theme(""))
})

test_that("bundled themes have well-formed channel LUTs", {
  for (name in c("default", "cellpond")) {
    th <- get_theme(name)
    for (chan in c("r", "g", "b")) {
      expect_type(th[[chan]], "integer")
      expect_length(th[[chan]], 10L)
      expect_true(all(th[[chan]] >= 0L & th[[chan]] <= 255L))
    }
  }
})

test_that("default theme uses the linear floor(d/9 * 255) mapping", {
  th <- get_theme("default")
  expected <- as.integer(floor(seq(0, 9) / 9 * 255))
  expect_equal(th$r, expected)
  expect_equal(th$g, expected)
  expect_equal(th$b, expected)
})

test_that("default theme has the eight popular named colors", {
  th <- get_theme("default")
  expect_named(th$names)
  expect_setequal(names(th$names), c("green","cyan","blue","purple","pink","red","orange","yellow"))
  expect_equal(th$names[["red"]], "900")
  expect_equal(th$names[["green"]], "090")
  expect_equal(th$names[["blue"]], "009")
})

test_that("cellpond theme uses TodePond's channel LUTs from the blog post", {
  th <- get_theme("cellpond")
  expect_equal(th$r, c(0x17L,0x37L,0x46L,0x62L,0x80L,0x9fL,0xaeL,0xccL,0xf2L,0xffL))
  expect_equal(th$g, c(0x1dL,0x43L,0x62L,0x80L,0x9fL,0xaeL,0xccL,0xdeL,0xf5L,0xffL))
  expect_equal(th$b, c(0x28L,0x46L,0x62L,0x80L,0x9fL,0xaeL,0xccL,0xdeL,0xf7L,0xffL))
})

test_that("cellpond theme has TodePond's personal eight names", {
  th <- get_theme("cellpond")
  expect_setequal(names(th$names), c("green","cyan","blue","purple","pink","red","orange","yellow"))
  expect_equal(th$names[["green"]], "093")
  expect_equal(th$names[["red"]], "922")
})

test_that("splash_theme() registers a custom theme", {
  splash_theme("custom-test", r = 0:9 * 25, g = 0:9 * 25, b = 0:9 * 25)
  withr::defer(splashr:::register_theme_reset("custom-test"))
  expect_in("custom-test", splash_themes())
  th <- get_theme("custom-test")
  expect_equal(th$r, as.integer(0:9 * 25))
})

test_that("splash_theme() accepts named colors and zero-pads codes", {
  splash_theme(
    "custom-named",
    r = rep(0L, 10), g = rep(0L, 10), b = rep(0L, 10),
    names = c(red = "9", green = "90")
  )
  withr::defer(splashr:::register_theme_reset("custom-named"))
  th <- get_theme("custom-named")
  expect_equal(th$names[["red"]], "009")
  expect_equal(th$names[["green"]], "090")
})

test_that("splash_theme() returns the theme invisibly", {
  th <- splash_theme("custom-invisible", 0:9, 0:9, 0:9)
  withr::defer(splashr:::register_theme_reset("custom-invisible"))
  expect_type(th, "list")
  expect_named(th, c("r", "g", "b", "names"))
})

test_that("splash_theme() validates channel length and range", {
  expect_error(splash_theme("bad", r = 1:9, g = 0:9, b = 0:9), "length 10")
  expect_error(splash_theme("bad", r = 0:9, g = 0:9, b = c(-1, 0:8)), "0-255")
  expect_error(splash_theme("bad", r = 0:9, g = 0:9, b = c(256, 0:8)), "0-255")
})

test_that("splash_theme() validates names", {
  expect_error(
    splash_theme("bad", 0:9, 0:9, 0:9, names = c(red = "900", red = "900")),
    "duplicate"
  )
  expect_error(
    splash_theme("bad", 0:9, 0:9, 0:9, names = c(red = "xyz")),
    "digits"
  )
  expect_error(
    splash_theme("bad", 0:9, 0:9, 0:9, names = c("900", "090")),
    "named vector"
  )
})

test_that("splash_theme() validates the name argument", {
  expect_error(splash_theme(c("a","b"), 0:9, 0:9, 0:9))
  expect_error(splash_theme("", 0:9, 0:9, 0:9))
})
