# Creating the `datacleanr` R Package with usethis

Below is the complete `usethis` workflow in order, with exact function calls and explanation.

## Step 1: Create the package scaffold

```r
library(usethis)
create_package("datacleanr")
```

This creates the directory `datacleanr/` with the standard R package structure: `DESCRIPTION`, `NAMESPACE`, `R/`, `data/`, `data-raw/`, `tests/`, `vignettes/`, `.Rbuildignore`, and `datacleanr.Rproj`. It also opens the project in a new RStudio session (or changes working directory in the current session).

## Step 2: Initialize Git

```r
use_git()
```

This initializes a Git repository inside `datacleanr/`, creates a `.gitignore` file appropriate for R packages (ignoring `.Rproj.user/`, `.Rhistory`, `.RData`, etc.), and makes the initial commit with all current files.

## Step 3: Add an MIT license

```r
use_mit_license(copyright_holder = "Your Name")
```

This adds `LICENSE` and `LICENSE.md` files to the package root. The `LICENSE` file contains the full MIT license text with the year and copyright holder filled in. `LICENSE.md` is added to `.Rbuildignore` so it is not included in the built tarball. The `DESCRIPTION` file is updated to include `License: MIT + file LICENSE`.

## Step 4: Create your first R file for `clean_names()`

```r
use_r("clean_names")
```

This creates and opens `R/clean_names.R`. You would then write your function there, for example:

```r
clean_names <- function(x) {
  nm <- names(x)
  nm <- tolower(nm)
  nm <- gsub("[^a-z0-9]+", "_", nm)
  nm <- gsub("^_|_$", "", nm)
  names(x) <- nm
  x
}
```

Every time you call `use_r("foo")`, usethis also sets up (or ensures) a corresponding test file when testthat is active, but testthat itself is set up in the next step.

## Step 5: Set up testthat

```r
use_testthat()
```

This creates the `tests/` directory structure:
- `tests/testthat.R` — the test runner script that runs `test_check("datacleanr")` on `R CMD check`.
- `tests/testthat/` — the directory where individual test files live.

It also adds `testthat` to `Suggests` in `DESCRIPTION` and adds a testthat edition (typically edition 3) via the `Config/testthat/edition` field.

After this, to create your first test file matching `clean_names`, run:

```r
use_test("clean_names")
```

This creates and opens `tests/testthat/test-clean_names.R` with a stub:

```r
test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
```

which you would replace with your actual tests, e.g.:

```r
test_that("clean_names lowercases and sanitizes", {
  df <- data.frame(MESSY.NAME = 1, `weird col!` = 2, check.names = FALSE)
  out <- clean_names(df)
  expect_equal(names(out), c("messy_name", "weird_col"))
})
```

---

## Summary of exact calls in order

```r
library(usethis)

# 1. Create the package
create_package("datacleanr")

# 2. Set up Git
use_git()

# 3. Add MIT license
use_mit_license(copyright_holder = "Your Name")

# 4. Create the first R source file
use_r("clean_names")

# 5. Set up testthat
use_testthat()

# 6. Create the matching test file
use_test("clean_names")
```

After writing your function in `R/clean_names.R` and your tests in `tests/testthat/test-clean_names.R`, run `devtools::load_all()` followed by `devtools::test()` to verify everything works. When ready for your first real commit of the function and tests, use `use_git()` again (or commit via your usual Git workflow) to commit the new files.
