# Insper color quick-reference table -------------------------------------------
#
# Builds a flat, "one row per swatch" lookup table of every official Insper
# brand color (hierarquia | familia | nome | amostra | pantone | RGB | hex).
#
# Source of truth: `data-raw/colors_palettes.R` (hex/Pantone/RGB values,
# already transcribed and corrected against `data-raw/refs/insper-guia-de-marca.pdf`)
# plus the neutral gray ramp + Azul (Educação Executiva), which appear in the
# guide's segment pages rather than the main "2.1 Cores" section but are kept
# here for completeness under hierarquia = "Neutros".
#
# Outputs:
#   - data/insper_color_reference.rda   (exported package dataset)
#   - data-raw/insper_color_reference.rds  (intermediate artifact, same table)
#   - data-raw/insper_color_reference.xlsx (human-readable copy, "amostra"
#     column cell-filled with the actual color)

library(tibble)
library(openxlsx)

# Table ---------------------------------------------------------------------
# fmt: skip
insper_color_reference <- tribble(
  ~hierarquia, ~familia, ~nome, ~pantone, ~rgb, ~hex,

  # Principais --------------------------------------------------------------
  "Principais", "Vermelho", "vermelho", "2034 C", "229, 5, 5", "#E50505",
  "Principais", "Branco", "branco", "-", "255, 255, 255", "#FFFFFF",
  "Principais", "Preto", "preto", "-", "0, 0, 0", "#000000",

  # Secundários — Verde -------------------------------------------------------
  "Secund\u00e1rios", "Verde", "verde 0", "7487 C", "146, 208, 83", "#92D053",
  "Secund\u00e1rios", "Verde", "verde 1", "7485 C", "196, 230, 163", "#C4E6A3",
  "Secund\u00e1rios", "Verde", "verde 2", "7486 C", "171, 219, 123", "#ABDB7B",
  "Secund\u00e1rios", "Verde", "verde 3", "368 C", "120, 190, 32", "#78BE20",
  "Secund\u00e1rios", "Verde", "verde 4", "7737 C", "94, 148, 40", "#5E9428",

  # Secundários — Amarelo ------------------------------------------------------
  "Secund\u00e1rios", "Amarelo", "amarelo 0", "Yellow C", "255, 204, 0", "#FFCC00",
  "Secund\u00e1rios", "Amarelo", "amarelo 1", "2001 C", "255, 224, 102", "#FFE066",
  "Secund\u00e1rios", "Amarelo", "amarelo 2", "128 C", "243, 213, 78", "#F3D54E",
  "Secund\u00e1rios", "Amarelo", "amarelo 3", "103 C", "204, 163, 0", "#CCA300",
  "Secund\u00e1rios", "Amarelo", "amarelo 4", "111 C", "161, 128, 0", "#A18000",

  # Secundários — Laranja -------------------------------------------------------
  "Secund\u00e1rios", "Laranja", "laranja 0", "7411 C", "248, 157, 73", "#F89D49",
  "Secund\u00e1rios", "Laranja", "laranja 1", "2015 C", "255, 207, 162", "#FFCFA2",
  "Secund\u00e1rios", "Laranja", "laranja 2", "713 C", "253, 190, 135", "#FDBE87",
  "Secund\u00e1rios", "Laranja", "laranja 3", "1385 C", "213, 120, 0", "#D57800",
  "Secund\u00e1rios", "Laranja", "laranja 4", "1395 C", "153, 96, 23", "#996017",

  # Secundários — Rosa ----------------------------------------------------------
  "Secund\u00e1rios", "Rosa", "rosa 0", "218 C", "244, 125, 205", "#F47DCD",
  "Secund\u00e1rios", "Rosa", "rosa 1", "677 C", "253, 199, 235", "#FDC7EB",
  "Secund\u00e1rios", "Rosa", "rosa 2", "230 C", "244, 166, 215", "#F4A6D7",
  "Secund\u00e1rios", "Rosa", "rosa 3", "238 C", "240, 76, 186", "#F04CBA",
  "Secund\u00e1rios", "Rosa", "rosa 4", "241 C", "205, 47, 154", "#CD2F9A",

  # Secundários — Roxo -----------------------------------------------------------
  "Secund\u00e1rios", "Roxo", "roxo 0", "2593 C", "115, 13, 159", "#730D9F",
  "Secund\u00e1rios", "Roxo", "roxo 1", "2072 C", "203, 132, 233", "#CB84E9",
  "Secund\u00e1rios", "Roxo", "roxo 2", "2081 C", "145, 72, 176", "#9148B0",
  "Secund\u00e1rios", "Roxo", "roxo 3", "2597 C", "96, 0, 138", "#60008A",
  "Secund\u00e1rios", "Roxo", "roxo 4", "2617 C", "64, 1, 91", "#40015B",

  # Secundários — Turquesa --------------------------------------------------------
  "Secund\u00e1rios", "Turquesa", "turquesa 0", "3258 C", "58, 204, 159", "#3ACC9F",
  "Secund\u00e1rios", "Turquesa", "turquesa 1", "324 C", "138, 225, 198", "#8AE1C6",
  "Secund\u00e1rios", "Turquesa", "turquesa 2", "3533 C", "97, 214, 178", "#61D6B2",
  "Secund\u00e1rios", "Turquesa", "turquesa 3", "7723 C", "43, 166, 128", "#2BA680",
  "Secund\u00e1rios", "Turquesa", "turquesa 4", "625 C", "29, 122, 93", "#1D7A5D",

  # Neutros — Cinza + Azul (ramp used in Pós-Graduação / Educação Executiva) ---
  "Neutros", "Cinza", "cinza 0", "Cool Gray 1 C", "220, 220, 220", "#DCDCDC",
  "Neutros", "Cinza", "cinza 1", "Cool Gray 6 C", "171, 171, 171", "#ABABAB",
  "Neutros", "Cinza", "cinza 2", "Cool Gray 8 C", "128, 128, 128", "#808080",
  "Neutros", "Cinza", "cinza 3", "Cool Gray 8 C", "91, 91, 91", "#5B5B5B",
  "Neutros", "Cinza", "cinza 4", "Black 7 C", "63, 63, 63", "#3F3F3F",
  "Neutros", "Azul", "azul escuro", "5395 C", "14, 23, 29", "#0E171D",

  # Cidades — Insper Cidades sub-brand ------------------------------------------
  # From `refs/Manual de Aplicação - Insper Cidades.pdf` (June 2026), p.12. The
  # manual specifies CMYK only, so `pantone` is "-" for all four. It has no
  # accessibility page, so `acessibilidade` stays NA (see below).
  "Cidades", "Folhagem", "folhagem", "-", "1, 152, 129", "#019881",
  "Cidades", "Solar", "solar", "-", "255, 167, 1", "#FFA701",
  "Cidades", "Asfalto", "asfalto", "-", "127, 21, 130", "#7F1582",
  "Cidades", "Tijolo", "tijolo", "-", "255, 75, 1", "#FF4B01"
) |>
  tibble::add_column(amostra = NA_character_, .after = "nome") |>
  dplyr::mutate(amostra = hex) # swatch column mirrors the hex (no image payload)

# Acessibilidade -------------------------------------------------------------
#
# Permitted text/logo color on each background, per the brand guide's
# accessibility and logo-background pages (`refs/brand-guide-accessibility-
# contrast.png`, `refs/brand-guide-logo-backgrounds.png`). The guide only
# rules on the family base colors and neutrals; tints/shades are NA. The
# Insper Cidades manual has no accessibility page, so its four colors are NA
# too — this column records what a guide *rules*, not what the package
# computes. Derived contrast guidance lives in `vignettes/brand-kit.Rmd`.
#   "branco" — only white text/logo
#   "preto"  — only black text/logo
#   "ambos"  — both pass
acessibilidade_guide <- c(
  "vermelho" = "branco",
  "branco" = "preto",
  "preto" = "branco",
  "verde 0" = "preto",
  "amarelo 0" = "preto",
  "laranja 0" = "preto",
  "rosa 0" = "ambos",
  "roxo 0" = "branco",
  "turquesa 0" = "ambos",
  "cinza 0" = "preto",
  "cinza 1" = "preto",
  "cinza 2" = "branco",
  "cinza 3" = "branco",
  "cinza 4" = "branco",
  "azul escuro" = "branco"
)

insper_color_reference <- insper_color_reference |>
  dplyr::mutate(
    acessibilidade = unname(acessibilidade_guide[nome])
  )

stopifnot(
  nrow(insper_color_reference) == 43,
  all(grepl("^#[0-9A-F]{6}$", insper_color_reference$hex)),
  sum(!is.na(insper_color_reference$acessibilidade)) ==
    length(acessibilidade_guide)
)

# Save package dataset --------------------------------------------------------

usethis::use_data(insper_color_reference, overwrite = TRUE)

# Save intermediate .rds artifact ----------------------------------------------

readr::write_rds(
  insper_color_reference,
  "data-raw/insper_color_reference.rds"
)

# Save human-readable .xlsx with color-filled "amostra" cells -------------------

# Minimal luminance-based contrast picker (mirrors R/utils.R::get_contrast_text_color
# but kept local/self-contained for this data-raw script).
get_contrast_text_color <- function(hex) {
  rgb <- grDevices::col2rgb(hex) / 255
  lum <- 0.2126 *
    rgb["red", ] +
    0.7152 * rgb["green", ] +
    0.0722 * rgb["blue", ]
  ifelse(lum > 0.5, "#000000", "#FFFFFF")
}

build_color_reference_xlsx <- function(df, path) {
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "cores")
  openxlsx::writeData(
    wb,
    "cores",
    df,
    headerStyle = openxlsx::createStyle(
      textDecoration = "bold",
      fgFill = "#0E171D",
      fontColour = "#FFFFFF"
    )
  )

  amostra_col <- which(names(df) == "amostra")
  acess_col <- which(names(df) == "acessibilidade")
  for (i in seq_len(nrow(df))) {
    text_color <- get_contrast_text_color(df$hex[i])
    style <- openxlsx::createStyle(
      fgFill = df$hex[i],
      fontColour = text_color,
      halign = "center"
    )
    openxlsx::addStyle(wb, "cores", style, rows = i + 1, cols = amostra_col)

    # Acessibilidade cell: "Insper" set on the row's color, in the permitted
    # text color ("Ambos" rendered in black — both pass on those backgrounds).
    acess <- df$acessibilidade[i]
    if (!is.na(acess)) {
      label <- if (acess == "ambos") "Ambos" else "Insper"
      font <- if (acess == "branco") "#FFFFFF" else "#000000"
      openxlsx::writeData(
        wb,
        "cores",
        label,
        startRow = i + 1,
        startCol = acess_col
      )
      acess_style <- openxlsx::createStyle(
        fgFill = df$hex[i],
        fontColour = font,
        halign = "center"
      )
      openxlsx::addStyle(
        wb,
        "cores",
        acess_style,
        rows = i + 1,
        cols = acess_col
      )
    }
  }

  openxlsx::setColWidths(wb, "cores", cols = seq_len(ncol(df)), widths = "auto")
  openxlsx::freezePane(wb, "cores", firstRow = TRUE)
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
}

build_color_reference_xlsx(
  insper_color_reference,
  "data-raw/insper_color_reference.xlsx"
)
