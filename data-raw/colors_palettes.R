# Insper brand colors — 2026 brand kit -----------------------------------------
#
# Authoritative source of truth for the new Insper visual identity.
# Hexcodes transcribed from `data-raw/refs/insper-guia-de-marca.pdf` and the
# accompanying screenshots. Pantone references kept as comments for traceability.
#
# Structure:
#   primary           — Vermelho / Branco / Preto
#   secondary_<hue>    — 6 hue families, each a 5-step ramp (base + 4 variants)
#   neutral            — cinza ramp + Azul (dark)
#
# Derived palettes (qualitative / sequential / diverging / muted) are NOT built
# here yet — see Phase 2. This file only defines the raw tokens.

# Primary ----------------------------------------------------------------------

primary <- c(
  vermelho = "#E50505", # PANTONE 2034 C   R229 G5   B5
  branco = "#FFFFFF", #                  R255 G255 B255
  preto = "#000000" #                  R0   G0   B0
)

# Secondary — hue families -----------------------------------------------------
#
# Within each family: `_0` is the brand base; `_1`/`_2` are tints (lighter),
# `_3`/`_4` are shades (darker). Luminance ordering for sequential ramps is a
# Phase 2 concern; here we preserve the kit's semantic labels.

secondary_turquesa <- c(
  turquesa_0 = "#3ACC9F", # PANTONE 3258 C  R58  G204 B159  (base)
  turquesa_1 = "#8AE1C6", # PANTONE 324 C   R138 G225 B198  (was #BAE1C6 — fixed)
  turquesa_2 = "#61D6B2", # PANTONE 3533 C  R97  G214 B178
  turquesa_3 = "#2BA680", # PANTONE 7723 C  R43  G166 B128
  turquesa_4 = "#1D7A5D" # PANTONE 625 C   R29  G122 B93
)

secondary_verde <- c(
  verde_0 = "#92D053", # PANTONE 7487 C  R146 G208 B83  (base)
  verde_1 = "#C4E6A3", # PANTONE 7485 C  R196 G230 B163
  verde_2 = "#ABDB7B", # PANTONE 7486 C  R171 G219 B123
  verde_3 = "#78BE20", # PANTONE 368 C   R120 G190 B32
  verde_4 = "#5E9428" # PANTONE 7737 C  R94  G148 B40
)

secondary_amarelo <- c(
  amarelo_0 = "#FFCC00", # PANTONE YELLOW C R255 G204 B0  (base)
  amarelo_1 = "#FFE066", # PANTONE 2001 C   R255 G224 B102
  amarelo_2 = "#F3D54E", # PANTONE 128 C    R243 G213 B78
  amarelo_3 = "#CCA300", # PANTONE 103 C    R204 G163 B0
  amarelo_4 = "#A18000" # PANTONE 111 C    R161 G128 B0
)

secondary_laranja <- c(
  laranja_0 = "#F89D49", # PANTONE 7411 C  R248 G157 B73  (base)
  laranja_1 = "#FFCFA2", # PANTONE 2015 C  R255 G207 B162
  laranja_2 = "#FDBE87", # PANTONE 713 C   R253 G190 B135
  laranja_3 = "#D57800", # PANTONE 1385 C  R213 G120 B0
  laranja_4 = "#996017" # PANTONE 1395 C  R153 G96  B23
)

secondary_rosa <- c(
  rosa_0 = "#F47DCD", # PANTONE 218 C  R244 G125 B205  (base)
  rosa_1 = "#FDC7EB", # PANTONE 677 C  R253 G199 B235
  rosa_2 = "#F4A6D7", # PANTONE 230 C  R244 G166 B215
  rosa_3 = "#F04CBA", # PANTONE 238 C  R240 G76  B186
  rosa_4 = "#CD2F9A" # PANTONE 241 C  R205 G47  B154
)

secondary_roxo <- c(
  roxo_0 = "#730D9F", # PANTONE 2593 C  R115 G13 B159  (base; was #790D9F — fixed)
  roxo_1 = "#CB84E9", # PANTONE 2072 C  R203 G132 B233
  roxo_2 = "#9148B0", # PANTONE 2081 C  R145 G72  B176
  roxo_3 = "#60008A", # PANTONE 2597 C  R96  G0   B138
  roxo_4 = "#40015B" # PANTONE 2617 C  R64  G1   B91
)

# Neutral — cinza ramp + Azul ---------------------------------------------------

neutral <- c(
  cinza_0 = "#DCDCDC", # PANTONE COOL GRAY 1 C  R220 G220 B220
  cinza_1 = "#ABABAB", # PANTONE COOL GRAY 6 C  R171 G171 B171
  cinza_2 = "#808080", # PANTONE COOL GRAY 8 C  R128 G128 B128
  cinza_3 = "#5B5B5B", # PANTONE COOL GRAY 8 C  R91  G91  B91
  cinza_4 = "#3F3F3F", # PANTONE BLACK 7 C      R63  G63  B63
  azul_escuro = "#0E171D", # PANTONE 5395 C         R14  G23  B29  (Azul)
  preto = "#000000" #                        R0   G0   B0
)

# Open questions (do not bake in until confirmed with brand team):
#   - roxo_0: guide prints hex #730D9F but RGB "R155" (=#9B0D9F); using the hex.
#   - vivid orange #FF6B06 appears in the accessibility chart but not the color
#     pages — unclear if it is an official token. Excluded for now.

# Convenience bundle -----------------------------------------------------------

insper_brand_colors <- c(
  primary,
  secondary_turquesa,
  secondary_verde,
  secondary_amarelo,
  secondary_laranja,
  secondary_rosa,
  secondary_roxo,
  neutral[setdiff(names(neutral), "preto")] # avoid duplicate `preto`
)

# Derivation helpers -----------------------------------------------------------

# Order a set of colors light -> dark by perceptual lightness (CIELAB L*).
order_by_lightness <- function(x) {
  L <- farver::convert_colour(t(grDevices::col2rgb(x)), "rgb", "lab")[, "l"]
  unname(x[order(L, decreasing = TRUE)])
}

# Perceptual (Lab) interpolation between anchor colors.
ramp_lab <- function(anchors, n) {
  grDevices::colorRampPalette(anchors, space = "Lab")(n)
}

# Neutral midpoint shared by all diverging palettes (warm near-white).
diverging_mid <- "#F4F4F2"

# Individual named colors ------------------------------------------------------
#
# Building blocks exposed via get_insper_colors(). Brand tokens plus a few
# English aliases for the primaries.

insper_individual_colors <- c(
  red = unname(primary["vermelho"]),
  white = unname(primary["branco"]),
  black = unname(primary["preto"]),
  insper_brand_colors
)

# Derived palettes -------------------------------------------------------------

insper_palettes <- list(
  # -- Qualitative ----
  # Brand hue bases (+ vermelho), interleaved for adjacent contrast.
  main = unname(c(
    primary["vermelho"],
    secondary_turquesa["turquesa_0"],
    secondary_amarelo["amarelo_0"],
    secondary_roxo["roxo_0"],
    secondary_verde["verde_0"],
    secondary_laranja["laranja_0"],
    secondary_rosa["rosa_0"]
  )),
  # Softer categorical set: `main` desaturated 25% (house default "muted").
  muted = unname(colorspace::desaturate(
    c(
      primary["vermelho"],
      secondary_turquesa["turquesa_0"],
      secondary_amarelo["amarelo_0"],
      secondary_roxo["roxo_0"],
      secondary_verde["verde_0"],
      secondary_laranja["laranja_0"],
      secondary_rosa["rosa_0"]
    ),
    amount = 0.25
  )),

  # -- Sequential (light -> dark, 5 steps) ----
  # Six brand families come straight from the kit; `vermelho` and `azul` are
  # perceptually interpolated since the kit ships no tints/shades for them.
  vermelho = ramp_lab(
    c(
      colorspace::lighten("#E50505", 0.75),
      "#E50505",
      colorspace::darken("#E50505", 0.45)
    ),
    5
  ),
  turquesa = order_by_lightness(secondary_turquesa),
  verde = order_by_lightness(secondary_verde),
  amarelo = order_by_lightness(secondary_amarelo),
  laranja = order_by_lightness(secondary_laranja),
  rosa = order_by_lightness(secondary_rosa),
  roxo = order_by_lightness(secondary_roxo),
  cinza = unname(c(
    neutral["cinza_0"],
    neutral["cinza_1"],
    neutral["cinza_2"],
    neutral["cinza_3"],
    neutral["cinza_4"]
  )),
  # Azul (#0E171D) is the segment color for Educação Executiva / Pós; the kit
  # ships only the single dark token, so the ramp is derived from it. The
  # light anchor keeps the token's blue hue at higher chroma so the ramp is
  # distinguishable from `cinza`; the dark end is pinned to the exact brand
  # token (Lab interpolation rounds endpoints by 1 bit).
  azul = c(ramp_lab(c("#C5D3E0", "#0E171D"), 5)[1:4], "#0E171D"),

  # -- Diverging (5 anchors: darkA, A, neutral, B, darkB) ----
  # Stored as anchors; continuous scales Lab-interpolate to any length.
  vermelho_turquesa = c(
    colorspace::darken("#E50505", 0.35),
    "#E50505",
    diverging_mid,
    "#3ACC9F",
    "#1D7A5D"
  ),
  roxo_verde = c("#40015B", "#730D9F", diverging_mid, "#78BE20", "#5E9428"),
  laranja_roxo = c("#996017", "#F89D49", diverging_mid, "#9148B0", "#40015B"),
  rosa_verde = c("#CD2F9A", "#F47DCD", diverging_mid, "#92D053", "#5E9428"),

  # -- Colorblind-safe reference sets (brand-independent) ----
  categorical_ito = unname(grDevices::palette.colors(palette = "Okabe-Ito")[
    -1
  ]),
  categorical_tab = unname(grDevices::palette.colors(palette = "Tableau 10")),
  categorical_set = unname(grDevices::palette.colors(palette = "Set1"))
)

# Save internal data -----------------------------------------------------------

usethis::use_data(
  insper_individual_colors,
  insper_palettes,
  internal = TRUE,
  overwrite = TRUE
)
