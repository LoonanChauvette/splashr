# 06-plot-with-ggplot2.R
# Showcase: using splash colors and palettes in real ggplot2 plots.
# ggplot2 is NOT a package dependency -- it's only used here for demonstration.
devtools::load_all(".", quiet = TRUE)
suppressPackageStartupMessages(library(ggplot2))
# Note: ggplot2 also exports get_theme(); splashr's internal one is unaffected
# because we qualify splashr calls via the loaded namespace below.

outdir <- file.path(dirname(normalizePath(
  sub("--file=", "", grep("--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]),
  mustWork = FALSE
)), "output")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# ---- 1. Discrete scale from a Splash palette (default theme) -----------------
p1 <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point(size = 3, alpha = 0.8) +
  scale_color_manual(values = unname(splash_palette(3))) +
  labs(title = "iris -- splash_palette(3), default theme") +
  theme_minimal(base_size = 13)

# ---- 2. Same plot, cellpond theme (pastel) ----------------------------------
p2 <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point(size = 3, alpha = 0.8) +
  scale_color_manual(values = unname(splash_palette(3, theme = "cellpond"))) +
  labs(title = "iris -- splash_palette(3), cellpond theme") +
  theme_minimal(base_size = 13)

# ---- 3. Filled bars from named colors ---------------------------------------
p3 <- ggplot(mtcars, aes(factor(cyl), fill = factor(cyl))) +
  geom_bar() +
  scale_fill_manual(
    values = unname(splash(c("900", "940", "990"))),  # red, orange, yellow
    labels = c("4 cyl", "6 cyl", "8 cyl")
  ) +
  labs(title = "mtcars -- splash(c('900','940','990'))", x = NULL, fill = NULL) +
  theme_minimal(base_size = 13)

# ---- 4. A 10-step ramp used as a manual sequential fill ---------------------
ramp <- unname(splash("9_9"))  # red=9, blue=9, green varies 0..9
df <- data.frame(x = seq_along(ramp), y = 1, fill = ramp)
p4 <- ggplot(df, aes(x, y, fill = factor(x))) +
  geom_col(width = 1) +
  scale_fill_manual(values = ramp, guide = "none") +
  labs(title = "splash('9_9') -- a 10-step ramp used as a fill") +
  scale_x_continuous(breaks = df$x) +
  theme_void(base_size = 13)

# ---- 5. Cellpond ramp on a continuous-looking discrete scale -----------------
ramp2 <- unname(splash("5_5", theme = "cellpond"))
df2 <- data.frame(x = seq_along(ramp2), y = 1, fill = ramp2)
p5 <- ggplot(df2, aes(x, y, fill = factor(x))) +
  geom_col(width = 1) +
  scale_fill_manual(values = ramp2, guide = "none") +
  labs(title = "splash('5_5', cellpond) -- pastel lightness ramp") +
  scale_x_continuous(breaks = df2$x) +
  theme_void(base_size = 13)

save <- function(name, plot, w = 7, h = 4.5) {
  path <- file.path(outdir, paste0(name, ".png"))
  ggsave(path, plot, width = w, height = h, dpi = 150, bg = "white")
  cat("wrote", path, "\n")
}

save("ggplot-iris-default",  p1)
save("ggplot-iris-cellpond", p2)
save("ggplot-mtcars-bars",   p3, h = 4)
save("ggplot-ramp-9_9",      p4, h = 2.5)
save("ggplot-ramp-cellpond", p5, h = 2.5)

cat("\nDone. View the PNGs in", normalizePath(outdir), "\n")
