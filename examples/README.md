# examples/

Standalone scripts that showcase the `splashr` v0.1.0 API. Each script is
self-contained — run it with:

```bash
Rscript examples/<script>.R
```

from the package root (the scripts use `devtools::load_all(".")` so you don't
need to install the package first).

These scripts are **not** part of the package build (see `.Rbuildignore`) and
have **no dependency on ggplot2 for the package itself** — ggplot2 is only
loaded where a script plots with it.

## Scripts

| Script | Shows |
|--------|-------|
| `01-basic-conversion.R` | `splash()` with numeric, string, name, and wildcard inputs |
| `02-themes.R` | Default vs cellpond themes, custom theme registration |
| `03-palettes.R` | `splash_named()` and `splash_palette(n)` for different `n` |
| `04-round-trip.R` | `as_splash()` inverse and the 1000-code round-trip property |
| `05-swatch.R` | `splash_show()` rendering single colors, ramps, and palettes |
| `06-plot-with-ggplot2.R` | Using splash colors/palettes in real ggplot2 plots |

## Output

The plotting scripts (`05`, `06`) write PNGs next to themselves
(e.g. `examples/output/...png`) so you can view the results without running
them interactively.
