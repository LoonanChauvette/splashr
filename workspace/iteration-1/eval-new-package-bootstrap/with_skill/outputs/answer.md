# Creating the `datacleanr` Package: usethis Workflow

Below is the step-by-step usethis workflow to bootstrap the `datacleanr` package from scratch — package creation, Git setup, MIT license, first R file, and testthat.

## Prerequisites

```r
library(usethis)
```

(You can also `library(devtools)`, which loads usethis and gives you access to `load_all()`, `check()`, `document()`, etc.)

---

## Step 1: Create the package

```r
create_package("~/path/to/datacleanr")
```

This creates the package directory structure:

- `R/` — where your R source code lives
- `DESCRIPTION` — package metadata
- `NAMESPACE` — exports/imports (managed by roxygen2)
- `.Rbuildignore` and `.gitignore`
- `datacleanr.Rproj` — RStudio project file (if RStudio is available)

> Replace `"~/path/to/datacleanr"` with the actual path where you want the package to live.

After `create_package()`, the new project is activated automatically (in interactive sessions). All subsequent `usethis::` calls operate within this project.

---

## Step 2: Initialize Git

```r
use_git()
```

This:

- Initializes a Git repository in the package directory
- Adds standard R/Git ignore patterns (e.g. ignores `.Rproj.user`, `*.so`, etc.)
- Makes an initial commit with the message `"Initial commit"`

> `use_git()` has an optional `message` argument: `use_git(message = "Initial commit")`.

---

## Step 3: Add an MIT license

```r
use_mit_license("Your Name")
```

This:

- Sets the `License` field in `DESCRIPTION` to `MIT + file LICENSE`
- Creates a `LICENSE` file containing the MIT license text with your name as copyright holder
- Creates `LICENSE.md` (a full copy of the license) and adds it to `.Rbuildignore` (CRAN doesn't want copies of standard licenses bundled)

> Replace `"Your Name"` with your actual name. If you omit the argument, it defaults to `"{package name} authors"`.

---

## Step 4: (Optional but recommended) Enable roxygen2 markdown

```r
use_roxygen_md()
```

This enables roxygen2 markdown support, letting you write `@description` and inline documentation in Markdown. It updates the `Roxygen` field in `DESCRIPTION` to include `list(markdown = TRUE)`.

---

## Step 5: Create your first R file for `clean_names()`

```r
use_r("clean_names")
```

This creates (and opens) `R/clean_names.R`. Now write your function with roxygen documentation:

```r
#' Clean column names of a data frame
#'
#' Standardizes column names by converting to snake_case and removing
#' problematic characters.
#'
#' @param data A data frame or tibble.
#'
#' @return A data frame with cleaned column names.
#' @export
#'
#' @examples
#' df <- data.frame(Bad Name = 1, `Col 2!` = 2, check.names = FALSE)
#' clean_names(df)
clean_names <- function(data) {
  names(data) <- tolower(gsub("[^[:alnum:]]+", "_", names(data)))
  names(data) <- gsub("^_|_$", "", names(data))
  data
}
```

Then generate documentation and update `NAMESPACE`:

```r
devtools::document()
```

---

## Step 6: Set up testthat

```r
use_testthat()
```

This:

- Creates the `tests/testthat/` directory
- Creates `tests/testthat.R` (the test runner file)
- Adds `testthat` to the `Suggests` field in `DESCRIPTION`
- Uses the latest testthat edition by default (edition 3)

> You can specify an edition explicitly: `use_testthat(edition = 3)`.

---

## Step 7: Create the paired test file

```r
use_test("clean_names")
```

This creates `tests/testthat/test-clean_names.R` (paired with `R/clean_names.R`). Now write your test:

```r
test_that("clean_names() standardizes column names", {
  df <- data.frame(Bad Name = 1, `Col 2!` = 2, check.names = FALSE)
  result <- clean_names(df)
  expect_equal(names(result), c("bad_name", "col_2"))
})

test_that("clean_names() handles already-clean names", {
  df <- data.frame(a = 1, b = 2)
  result <- clean_names(df)
  expect_equal(names(result), c("a", "b"))
})
```

Run your tests:

```r
devtools::test()
```

---

## Summary: Exact usethis calls in order

```r
library(usethis)

create_package("~/path/to/datacleanr")
use_git()
use_mit_license("Your Name")
use_roxygen_md()
use_r("clean_names")
use_testthat()
use_test("clean_names")
```

## What each step produces

| Step | Function | Files created / modified |
|------|----------|--------------------------|
| 1 | `create_package()` | `R/`, `DESCRIPTION`, `NAMESPACE`, `.gitignore`, `.Rbuildignore`, `.Rproj` |
| 2 | `use_git()` | Git repo initialized, initial commit |
| 3 | `use_mit_license()` | `LICENSE`, `LICENSE.md`, `DESCRIPTION` License field |
| 4 | `use_roxygen_md()` | `DESCRIPTION` Roxygen field (markdown enabled) |
| 5 | `use_r("clean_names")` | `R/clean_names.R` |
| 6 | `use_testthat()` | `tests/testthat/`, `tests/testthat.R`, DESCRIPTION Suggests |
| 7 | `use_test("clean_names")` | `tests/testthat/test-clean_names.R` |

## Next steps (optional)

After the core setup, you may also want to:

```r
# Add package dependencies
use_package("dplyr", type = "Imports")

# Create a README
use_readme_rmd()

# Push to GitHub
use_github()

# Add CI
use_github_action("check-standard")
```

> **Tip**: Commit after each step. The `use_git()` call makes an initial commit, but after adding the license, R files, and tests, run `gert::git_commit_all("Add license, clean_names function, and tests")` or commit via your IDE.
