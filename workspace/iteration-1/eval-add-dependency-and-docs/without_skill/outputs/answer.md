# Setting Up Dependencies, Documentation, and a Vignette with usethis

## 1. usethis Functions to Call

Run these from the R console in your package project root:

```r
# Add dplyr and stringr as dependencies (added to Imports in DESCRIPTION)
usethis::use_package("dplyr")
usethis::use_package("stringr")

# Create a README.Rmd (also creates a README.md on knit,
# and adds a GitHub Actions workflow to build it)
usethis::use_readme_rmd()

# Set up a pkgdown website (creates _pkgdown.yml and a
# GitHub Actions workflow to build and deploy the site)
usethis::use_pkgdown()

# Create a vignette named "intro" (creates vignettes/intro.Rmd,
# adds knitr to Suggests, and updates the vignette engine in DESCRIPTION)
usethis::use_vignette("intro")
```

### What each function does

| Function | Effect |
|---|---|
| `use_package("dplyr")` | Adds `dplyr` to the `Imports` field of `DESCRIPTION`. This means dplyr will be installed when someone installs your package, and it will be available at runtime. |
| `use_package("stringr")` | Same as above, for stringr. |
| `use_readme_rmd()` | Creates `README.Rmd` (an R Markdown template) and adds a build step so that `README.md` is regenerated from it. This is preferred over a plain `README.md` because you can include live R code chunks. |
| `use_pkgdown()` | Creates the pkgdown configuration file (`_pkgdown.yml`) and a GitHub Actions workflow (`.github/workflows/pkgdown.yaml`) to automatically build and deploy your package website to GitHub Pages. |
| `use_vignette("intro")` | Creates `vignettes/intro.Rmd` with a standard template, adds `knitr` to `Suggests` in `DESCRIPTION`, and sets up the `VignetteEngine`. The vignette will be accessible via `vignette("intro", package = "splashr")` after installation. |

## 2. Referencing dplyr Functions in Your R Code

There are two main approaches. The **recommended** approach is to use explicit namespace prefixes (`dplyr::fun()`) in your code, which makes dependencies clear and avoids name collisions. Alternatively, you can use roxygen `@importFrom` tags.

### Option A: Explicit namespace qualification (recommended for most cases)

Use the `dplyr::function_name()` syntax directly in your R code:

```r
#' Filter and arrange splash palettes
#'
#' @param data A data frame of splash palettes.
#' @param min_colors Minimum number of colors in a palette.
#' @return A data frame filtered and arranged by number of colors.
#' @export
filter_palettes <- function(data, min_colors = 2) {
  data |>
    dplyr::filter(.data$n_colors >= min_colors) |>
    dplyr::arrange(.data$n_colors)
}
```

When you use `dplyr::filter()` explicitly, you do **not** need an `@importFrom` or `@import` roxygen tag for that function. The `dplyr::` prefix tells R exactly where to find the function, and since dplyr is listed in `Imports`, it will be available.

> **Tip:** Use `.data$` (from the rlang package, re-exported by dplyr) to refer to columns inside verbs like `filter()` and `mutate()`. This avoids R CMD check NOTEs about undefined global variables. You may want to add `usethis::use_package("rlang")` or use `@importFrom rlang .data` in your roxygen docs.

### Option B: Roxygen @importFrom (useful when you call a function many times)

If you call a dplyr function frequently and want to avoid repeating the `dplyr::` prefix, import specific functions with `@importFrom`:

```r
#' @importFrom dplyr filter arrange
#' @export
filter_palettes <- function(data, min_colors = 2) {
  data |>
    filter(n_colors >= min_colors) |>
    arrange(n_colors)
}
```

After running `devtools::document()` (or `roxygen2::roxygenise()`), roxygen will generate the appropriate `importFrom` lines in your `NAMESPACE` file:

```
importFrom(dplyr,filter)
importFrom(dplyr,arrange)
```

### Option C: @import the entire package (generally discouraged)

```r
#' @import dplyr
```

This imports **all** exported functions from dplyr into your package's namespace. This is generally discouraged because it:
- Pollutes your package's search path with hundreds of functions.
- Increases the risk of name collisions.
- Makes it harder for readers to know which functions come from which package.

Prefer `@importFrom` for specific functions, or just use the `dplyr::` prefix directly.

## 3. Putting It All Together

Here is the full sequence of steps for the `splashr` package:

```r
# In the R console, with the working directory set to your package root:

# 1. Add dependencies
usethis::use_package("dplyr")
usethis::use_package("stringr")

# 2. Set up documentation infrastructure
usethis::use_readme_rmd()
usethis::use_pkgdown()
usethis::use_vignette("intro")

# 3. Document the package (generates NAMESPACE and man/)
devtools::document()

# 4. Check that everything works
devtools::check()
```

### Resulting DESCRIPTION (relevant additions)

After running the above, your `DESCRIPTION` will include lines similar to:

```
Imports: 
    dplyr,
    stringr

Suggests: 
    knitr,
    rmarkdown,
    testthat (>= 3.0.0)

VignetteBuilder: 
    knitr
```

### Best Practices Summary

1. **Always list imported packages in `Imports`** (not `Depends`) via `usethis::use_package()`.
2. **Prefer `dplyr::fun()` syntax** in your code for clarity, or use `@importFrom` for functions you call very frequently.
3. **Use `.data$column`** to reference data frame columns inside dplyr verbs to avoid R CMD check NOTEs.
4. **Run `devtools::document()`** after adding `@importFrom` tags so that `NAMESPACE` is regenerated.
5. **Run `devtools::check()`** to verify that there are no missing dependencies or undefined functions.
