# splashr 0.1.0

2026-06-20

* Initial release.
* `splash()` converts Splash color codes (numeric, 3-digit strings, `_`
  wildcard ramps, or theme color names) to `#RRGGBB` hex strings, with full
  vectorization and mixed-input support.
* `as_splash()` is the theme-respecting inverse: hex to the nearest Splash
  code. Round-trips are stable for all 1000 codes within a theme.
* `splash_named()` returns a theme's named colors as a named hex vector.
* `splash_palette(n = 8)` returns an evenly-spaced categorical palette from
  the theme's named backbone (capped at the backbone size, with a warning).
* `splash_theme()` / `splash_themes()` register and list custom themes. Two
  themes ship with the package: `"default"` (linear mapping) and `"cellpond"`
  (TodePond's personal pastel palette from the Splash blog post).
* `splash_show()` draws a base-R swatch strip of any Splash colors or
  pre-resolved hex palette, with auto-contrast labels.
