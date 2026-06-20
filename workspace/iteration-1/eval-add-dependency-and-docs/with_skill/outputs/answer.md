# Adding Dependencies, Documentation, and a Vignette with usethis

## 1. Adding Package Dependencies

To add **dplyr** and **stringr** as dependencies, use `use_package()`. By default this adds the package to the `Imports` field of `DESCRIPTION`, which is the recommended approach for packages whose functions you call in your own R code.

```r
library(usethis)

use_package("dplyr")
use_package("stringr")
```

`use_package()` has the following signature:

```r
use_package(package, type = "Imports", min_version = NULL)
```

- **`package`**: Name of the package to depend on (e.g., `"dplyr"`).
- **`type`**: One of `"Imports"`, `"Depends"`, `"Suggests"`, `"Enhances"`, or `"LinkingTo"`. Defaults to `"Imports"`, which is the best choice for packages whose functions you use internally.
- **`min_version`**: Optionally specify a minimum version. Set to `TRUE` to use the currently installed version, or pass a version string like `"1.1.0"`.

For example, if you need at least dplyr 1.1.0:

```r
use_package("dplyr", type = "Imports", min_version = "1.1.0")
```

## 2. Setting Up README.Rmd

Use `use_readme_rmd()` to create a skeleton `README.Rmd` file with stubs for a high-level description, installation instructions, and a basic example. The file is automatically added to `.Rbuildignore`. If the project is a Git repo, a pre-commit hook is configured to keep `README.Rmd` and `README.md` in sync.

```r
use_readme_rmd()
```

## 3. Adding pkgdown for a Website

Use `use_pkgdown()` to create a pkgdown configuration file (`_pkgdown.yml`) and add relevant entries to `.Rbuildignore` and `.gitignore`:

```r
use_pkgdown()
```

If your package is hosted on GitHub and you want automatic publishing to GitHub Pages, call `use_pkgdown_github_pages()` instead. This is a convenience wrapper that calls `use_pkgdown()`, `use_github_pages()`, `use_github_action("pkgdown")`, and adds the site URL to the pkgdown config and DESCRIPTION:

```r
use_pkgdown_github_pages()
```

## 4. Creating a Vignette Called "intro"

Use `use_vignette()` to create a new vignette in `vignettes/`. This also adds the necessary packages (e.g., knitr, rmarkdown) to `Suggests` in `DESCRIPTION` and updates `.gitignore`:

```r
use_vignette("intro", title = "Introduction to My Package")
```

`use_vignette()` has the signature:

```r
use_vignette(name, title = NULL)
```

- **`name`**: File name for the vignette (only numbers, letters, `_`, `-`; `.Rmd` or `.qmd` extension is optional and controls the format).
- **`title`**: The vignette title. If omitted, one is generated from `name`.

## 5. Complete Workflow

Here is the full sequence of `usethis` calls:

```r
library(usethis)

# Add dependencies
use_package("dplyr")
use_package("stringr")

# Set up documentation
use_readme_rmd()
use_pkgdown()              # or use_pkgdown_github_pages() for GitHub Pages
use_vignette("intro", title = "Introduction to My Package")
```

## 6. Properly Referencing dplyr Functions in Your R Code

When you add dplyr to `Imports` (via `use_package("dplyr")`), the recommended practice is to call dplyr functions with the explicit `package::function()` syntax in your R code. This avoids polluting the NAMESPACE and prevents name clashes. For example, in a file under `R/`:

```r
my_filter <- function(data, threshold) {
  dplyr::filter(data, value > threshold)
}

my_summarise <- function(data) {
  dplyr::summarise(data, mean_val = mean(value, na.rm = TRUE))
}
```

### Importing Specific Functions with `use_import_from()`

If you use a few dplyr functions very frequently and want to avoid repeating the `dplyr::` prefix, you can import specific functions into your NAMESPACE using `use_import_from()`. This adds the appropriate `@importFrom` roxygen tag to your package-level documentation:

```r
use_import_from("dplyr", c("filter", "select", "mutate", "summarise"))
```

After doing this, you can call those functions directly in your R code:

```r
my_filter <- function(data, threshold) {
  filter(data, value > threshold)
}
```

`use_import_from()` has the signature:

```r
use_import_from(package, fun, load = is_interactive())
```

- **`package`**: Package name (e.g., `"dplyr"`).
- **`fun`**: A character vector of function names to import (e.g., `c("filter", "select")`).
- **`load`**: Whether to re-load the package with `pkgload::load_all()` after updating the NAMESPACE.

### Summary of Recommended Practices

| Scenario | Approach |
|----------|----------|
| Use many functions from dplyr | `use_package("dplyr")` + call via `dplyr::fun()` in code |
| Use a few specific functions frequently | `use_package("dplyr")` + `use_import_from("dplyr", c("filter", "select"))` |
| Package needed only for tests/vignettes | `use_package("dplyr", type = "Suggests")` |

Using `dplyr::fun()` is the safest default. Reserve `use_import_from()` for cases where the repeated prefix harms readability and you are confident there is no name conflict.
