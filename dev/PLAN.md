# splashr — Implementation Plan

Status: design locked, implementation not started.
Source of truth for the Splash spec: <https://www.todepond.com/lab/splash/>

---

## Locked design decisions

- **`splash(color, theme = "default")`** — vectorized Splash → hex (`"#RRGGBB"`). Plain character output, no S3 class.
- **One input grammar** for `splash()`, all vectorized and composable:
  1. Numeric → integer code, zero-padded to 3 (`splash(900)`, `splash(c(900, 90))`).
  2. Character 3-char code with digits and at most one `_` wildcard → full color, or 10-color ramp along the wildcard axis (`splash("9_9")` → 10 hex).
  3. Character matching a theme color name → that name's code in the active theme (`splash("green")`).
  4. Else → error listing valid names for the active theme.
- **Themes are first-class and respected everywhere**, including `as_splash()` rounding (so round-trips are stable within a theme).
- A **theme** = `list(r = <10 ints 0–255>, g = <10 ints 0–255>, b = <10 ints 0–255>, names = c(green = "090", ...))`. Names are part of the theme (codes differ per theme: default green = `090`, cellpond green = `093`).
- **Wildcard character:** `_`. Ramp output is always exactly 10 colors (native Splash resolution). No interpolation in v0.1.
- **`splash_palette(n = 8, theme = "default")`** — n ≤ 8: evenly-spaced selection from the theme's named sequence (order preserved). **n > 8: capped at 8 with a warning** (interpolation is a future feature). Default `n = 8`.
- **No S3 classes** in v0.1. `scale_*` (future) will accept raw code vectors directly.
- **No hard dependencies.** Core is base R only. `ggplot2`/`scales` will be `Suggests` when added.
- **Bundled themes:** `"default"` (linear mapping `floor(d/9 * 255)` + the 8 popular names) and `"cellpond"` (TodePond's pastel channel LUTs from the blog post + his personal 8 names).

## v0.1 scope (core)

| Function | Purpose |
|----------|---------|
| `splash(color, theme = "default")` | Vectorized → hex. Numeric / 3-digit code / `_` wildcard / theme name. |
| `as_splash(hex, theme = "default")` | Inverse: hex → nearest code string (theme-respecting). |
| `splash_named(theme = "default")` | Theme's named colors as a named hex vector. |
| `splash_palette(n = 8, theme = "default")` | Automatic n-color palette from the named backbone (cap 8). |
| `splash_theme(name, r, g, b, names = NULL)` | Define/register a custom theme. |
| `splash_themes()` | List available theme names. |
| `splash_show(color, theme = "default")` | Base-R swatch plot via `image()` (no ggplot2). |

---

## Implementation phases

Each phase: implement → write tests → run `devtools::test()` → document with roxygen → `devtools::document()`. Move to the next phase only when the current one is green.

### Phase 0 — Scaffold cleanup
- [ ] Remove placeholder `strsplit1()` + its `man/strsplit1.Rd` and the `export(strsplit1)` line in `NAMESPACE`.
- [ ] Rewrite `README.Rmd`/`README.md` intro to describe splashr's actual purpose.
- [ ] Add `^dev$` to `.Rbuildignore`.
- [ ] Confirm `Rscript`/R available in dev env (currently not on PATH in this shell — resolve before coding).

### Phase 1 — Theme infrastructure
- [ ] `R/themes.R`: internal theme registry (an environment in the package namespace), `splash_theme()`, `splash_themes()`, `get_theme(name)` internal accessor.
- [ ] `R/theme-default.R`: define + register `"default"` (linear LUTs + 8 popular names: green `090`, cyan `099`, blue `009`, purple `409`, pink `909`, red `900`, orange `940`, yellow `990`).
- [ ] `R/theme-cellpond.R`: define + register `"cellpond"` using the channel LUTs from the blog post's `CHANNEL_VALUES` + TodePond's personal 8 names (green `093`, cyan `289`, blue `059`, purple `529`, pink `947`, red `922`, orange `942`, yellow `991`).
- [ ] Tests: registry stores/retrieves themes; invalid theme name errors clearly; bundled themes present and well-formed (length-10 LUTs, 8 names).

### Phase 2 — Core `splash()` conversion  ✅
- [x] `R/splash.R`: `splash(color, theme = "default")` with the 4-branch input resolution above.
- [x] Internals: `code_to_hex(code, theme)` (digits → LUT lookup → `sprintf("#%02x%02x%02x")`), `expand_wildcard(code)` → 10 codes.
- [x] Name resolution via the active theme's `names` map.
- [x] Tests: numeric/char/wildcard/name inputs; vectorized combos; error on bad codes/names; both bundled themes; round-trip with `as_splash` (phase 3).

### Phase 3 — Inverse `as_splash()`  ✅
- [x] `R/as_splash.R`: `as_splash(hex, theme = "default")` — parse hex → 0–255 RGB → for each channel find the LUT index whose value is nearest → 3-digit string.
- [x] Tests: known hexes map to expected codes per theme; round-trip `as_splash(splash(x)) == x` for all 1000 codes within a theme (property test over `0:999`).

### Phase 4 — Named + palette helpers  ✅
- [x] `R/splash_named.R`: `splash_named(theme = "default")` → `setNames(splash(names_vec), names(names_vec))`.
- [x] `R/splash_palette.R`: `splash_palette(n = 8, theme = "default")` → evenly-spaced selection from `splash_named()`; cap + warn when `n > 8`.
- [x] Tests: `splash_named()` returns 8 named hex; `splash_palette(1)`, `(4)`, `(8)` return correct subsets; `n > 8` warns and returns 8; `n = 0`/negative handled gracefully.

### Phase 5 — `splash_show()`  ✅
- [x] `R/splash_show.R`: base-R swatch via `graphics::image()` (or `rect()`), works for a single color, a palette, and a wildcard ramp. No ggplot2.
- [x] Tests: runs without error; snapshot the printed/swatch output if feasible.

### Phase 6 — Docs & polish
- [ ] Full roxygen2 docs for all exported functions with `@examples`.
- [ ] `devtools::document()`; regenerate `NAMESPACE` and `man/`.
- [ ] Rewrite `README.Rmd` with a real worked example (splash codes, names, a palette, a swatch) and re-render.
- [ ] `devtools::check()` → 0 errors/warnings/notes.
- [ ] Tag v0.1.0.

---

## Future features (parking lot — not v0.1)

Ordered roughly by value/effort. Re-rank before picking one up.

### ggplot2 integration (Suggests: ggplot2, scales)
- `scale_color_splash(palette, ...)` / `scale_fill_splash(...)` — discrete scale from a code vector or `splash_palette()`.
- `scale_color_splash_continuous(from, to, ...)` / `scale_fill_*` — continuous scale.
- A `splash_pal()` discrete palette function (scales-style) so it composes with `scales::manual_pal`.
- Vignette: "Using splashr with ggplot2".

### Interpolation & ramps (the v0.1 cap removal)
- `splash_ramp(n, from, to, theme = "default")` — n colors between two codes.
- Decide interpolation space: RGB (simple, can be muddy) vs HSL (nicer gradients). Offer `space = "rgb"` / `"hsl"`.
- Round interpolated values to nearest valid Splash code so output stays in-system.
- Let `splash_palette(n)` use interpolation for `n > 8` once ramps exist (removes the cap).

### Common palettes expressed in Splash
Map well-known categorical palettes to nearest Splash codes per theme, so users get familiar semantics with the Splash aesthetic:
- Okabe-Ito (8 colorblind-safe) — natural fit since we also cap at 8.
- Paul Tol's qualitative palettes.
- ColorBrewer qualitative (Set2/Set3) subsets.
- A "splash-optimized" qualitative palette chosen for max perceptual distance within the 1000-color cube.
- Implementation: a `data-raw/` script + shipped lookup (codes per theme), exposed as `splash_palette("okabe-ito")` etc. Keep names as the default backbone; these are alternatives.

### Sequentials & dividers
- `splash_sequential(n, hue)` and `splash_diverging(n, neg, pos)` built from wildcard ramps (e.g. `"0_9"` lightness sweeps) per hue.

### Theme management
- `splash_theme_remove(name)`, `splash_theme_default(name)` (set session default).
- Import/export themes as JSON or CSV (`splash_theme_read()` / `splash_theme_write()`).
- Validate user-supplied themes (length-10, 0–255, names length 8 or NULL).

### Inspection & ergonomics
- `splash_show()` for the full 1000-color grid; `splash_show(theme)` to compare themes side by side.
- `splash_named()` with `all = TRUE` to list names across all themes.
- A `splash_guess(palette)` to suggest a Splash palette nearest to an arbitrary set of hex colors (uses `as_splash`).

### Distribution
- pkgdown site + "Getting started" vignette.
- GitHub Actions: R CMD check + testthat + pkgdown build.
- CRAN submission (after ggplot2 integration lands; v0.2).

---

## Open questions (resolve as we hit them)

- Should `splash_palette(n)` selection order follow the theme's named-vector order as authored, or a fixed canonical order (e.g. spectrum: red→orange→yellow→green→cyan→blue→purple→pink)? Affects which colors you get for `n < 8`.
- For `as_splash`, should ties (a channel value exactly between two LUT entries) round up or down? Decide + test.
- Wildcard: allow multiple `_` (e.g. `"___"` = all 1000)? Out of scope for v0.1, but decide if the grammar should reserve that possibility.
