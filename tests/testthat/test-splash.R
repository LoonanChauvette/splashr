# Default theme channel LUT (linear floor(d/9 * 255)), for expected values.
.lin <- as.integer(floor(seq(0, 9) / 9 * 255))
.hex <- function(r, g, b) sprintf("#%02x%02x%02x", .lin[r + 1], .lin[g + 1], .lin[b + 1])

test_that("splash() converts a 3-digit code string to hex", {
  expect_equal(splash("000"), "#000000")
  expect_equal(splash("999"), "#ffffff")
  expect_equal(splash("900"), .hex(9, 0, 0))
  expect_equal(splash("090"), .hex(0, 9, 0))
  expect_equal(splash("009"), .hex(0, 0, 9))
  expect_equal(splash("407"), .hex(4, 0, 7))
})

test_that("splash() accepts numeric codes, zero-padded", {
  expect_equal(splash(900), splash("900"))
  expect_equal(splash(0), splash("000"))
  expect_equal(splash(9), splash("009"))
  expect_equal(splash(90), splash("090"))
  expect_equal(splash(c(900, 90, 9)), c(splash("900"), splash("090"), splash("009")))
})

test_that("splash() is vectorized over codes and names", {
  expect_equal(
    splash(c("900", "090", "009")),
    c(.hex(9,0,0), .hex(0,9,0), .hex(0,0,9))
  )
  expect_equal(
    splash(c("red", "green", "blue")),
    c(splash("900"), splash("090"), splash("009"))
  )
})

test_that("splash() resolves theme color names", {
  expect_equal(splash("red"), splash("900"))
  expect_equal(splash("green"), splash("090"))
  expect_equal(splash("yellow"), splash("990"))
  # All eight default names resolve.
  for (nm in c("green","cyan","blue","purple","pink","red","orange","yellow")) {
    expect_true(splash(nm) %in% splash(paste0(
      c("090","099","009","409","909","900","940","990")
    )))
  }
})

test_that("splash() name resolution is theme-aware", {
  # default green = "090", cellpond green = "093" -> different hex.
  expect_equal(splash("green"), splash("090"))
  expect_equal(splash("green", theme = "cellpond"), splash("093", theme = "cellpond"))
  expect_false(splash("green") == splash("green", theme = "cellpond"))
})

test_that("splash() expands a wildcard to 10 colors along the axis", {
  r <- splash("9_9")
  expect_length(r, 10L)
  # Green varies 0..9, red=9, blue=9.
  expect_equal(r, vapply(0:9, function(d) .hex(9, d, 9), character(1)))

  expect_equal(splash("_09"), vapply(0:9, function(d) .hex(d, 0, 9), character(1)))
  expect_equal(splash("90_"), vapply(0:9, function(d) .hex(9, 0, d), character(1)))
})

test_that("splash() mixes input types in a single call", {
  out <- splash(c("green", "9_9", 900))
  expect_length(out, 1L + 10L + 1L)
  expect_equal(out[1], splash("green"))
  expect_equal(out[2:11], splash("9_9"))
  expect_equal(out[12], splash("900"))
})

test_that("splash() respects the theme for code conversion", {
  # Same code, different theme -> different hex (cellpond skews bluer/greener).
  expect_false(splash("555") == splash("555", theme = "cellpond"))
  # cellpond "000" is slightly off-black (b channel min = 0x28 = 40).
  expect_equal(splash("000", theme = "cellpond"), "#171d28")
})

test_that("splash() errors on unknown names with a helpful message", {
  expect_snapshot(error = TRUE, splash("chartreuse"))
})

test_that("splash() errors on malformed codes", {
  expect_snapshot(error = TRUE, splash("99"))     # too short
  expect_snapshot(error = TRUE, splash("9999"))   # too long
  expect_snapshot(error = TRUE, splash("9x9"))    # non-digit, non-wildcard
  expect_snapshot(error = TRUE, splash("9__"))    # two wildcards
})

test_that("splash() errors on out-of-range or non-integer numeric", {
  expect_error(splash(-1))
  expect_error(splash(1000))
  expect_error(splash(90.5))
})

test_that("splash() errors on NA input", {
  expect_error(splash(NA_character_))
  expect_error(splash(NA_integer_))
})

test_that("splash() errors on bad theme", {
  expect_error(splash("900", theme = "nope"))
})

test_that("splash() returns lowercase hex of length-7 (#RRGGBB)", {
  out <- splash(c("000","555","999","407"))
  expect_true(all(grepl("^#[0-9a-f]{6}$", out)))
})
