# Prototype diverging + muted palettes (Phase 2 design exploration) ------------
#
# Renders swatch grids to data-raw/refs/proto_*.png for visual review.
# Nothing here is baked into the package yet.

source("data-raw/colors_palettes.R")
library(ggplot2)

# Helpers ----------------------------------------------------------------------

# Perceptual (Lab) interpolation between anchor colors.
ramp_lab <- function(anchors, n) {
  grDevices::colorRampPalette(anchors, space = "Lab")(n)
}

# Darken / desaturate via HCL (colorspace) for principled tweaks.
darken <- function(x, amount) colorspace::darken(x, amount, method = "relative")
desat <- function(x, amount) colorspace::desaturate(x, amount)

# Render a labelled stack of palettes to a PNG.
render_swatches <- function(pals, file, title) {
  rows <- lapply(names(pals), function(nm) {
    cols <- pals[[nm]]
    data.frame(pal = nm, pos = seq_along(cols), hex = cols)
  })
  df <- do.call(rbind, rows)
  df$pal <- factor(df$pal, levels = rev(names(pals)))

  p <- ggplot(df, aes(pos, pal, fill = hex)) +
    geom_tile(width = 0.95, height = 0.85, color = "white", linewidth = 0.6) +
    geom_text(aes(label = hex), size = 2.1, angle = 90, color = "grey20") +
    scale_fill_identity() +
    labs(title = title) +
    theme_minimal(base_size = 11) +
    theme(
      axis.title = element_blank(),
      axis.text.x = element_blank(),
      panel.grid = element_blank(),
      axis.text.y = element_text(hjust = 1),
      plot.title = element_text(face = "bold")
    )
  ggsave(file, p, width = 10, height = 0.55 * length(pals) + 1.2, dpi = 150)
}

# Diverging candidates ---------------------------------------------------------
#
# Each arm anchored on brand family colors; shared near-neutral midpoint.
# Rendered at 9 steps via Lab interpolation.

mid <- "#F4F4F2" # warm near-white neutral

diverging <- list(
  # On-brand classic: red <-> turquesa
  vermelho_turquesa = ramp_lab(
    c(darken("#E50505", 0.35), "#E50505", mid, "#3ACC9F", "#1D7A5D"),
    9
  ),
  # Purple <-> green (high hue separation, equal weight)
  roxo_verde = ramp_lab(
    c("#40015B", "#730D9F", mid, "#78BE20", "#5E9428"),
    9
  ),
  # Orange <-> purple
  laranja_roxo = ramp_lab(
    c("#996017", "#F89D49", mid, "#9148B0", "#40015B"),
    9
  ),
  # Pink <-> green
  rosa_verde = ramp_lab(
    c("#CD2F9A", "#F47DCD", mid, "#92D053", "#5E9428"),
    9
  ),
  # Red <-> dark blue (azul) — strong, sober
  vermelho_azul = ramp_lab(
    c(darken("#E50505", 0.3), "#E50505", mid, "#2BA680", "#0E171D"),
    9
  )
)

render_swatches(
  diverging,
  "data-raw/refs/proto_diverging.png",
  "Diverging candidates (9-step, Lab-interpolated)"
)

# Muted candidates -------------------------------------------------------------
#
# Desaturated categorical set from the 6 hue bases + vermelho.
# Show base vs. three desaturation levels to pick a house style.

bases <- c(
  vermelho = "#E50505",
  turquesa = "#3ACC9F",
  verde = "#92D053",
  amarelo = "#FFCC00",
  laranja = "#F89D49",
  rosa = "#F47DCD",
  roxo = "#9148B0"
)

muted <- list(
  base = unname(bases),
  desat_25 = unname(desat(bases, 0.25)),
  desat_40 = unname(desat(bases, 0.40)),
  # desaturate + slight darken for print legibility
  desat40_dark = unname(darken(desat(bases, 0.40), 0.12))
)

render_swatches(
  muted,
  "data-raw/refs/proto_muted.png",
  "Muted categorical candidates (from hue bases)"
)

cat("Wrote data-raw/refs/proto_diverging.png and proto_muted.png\n")
