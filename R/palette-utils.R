# Palette metadata ----

#' Palette catalogue backing show_insper_palettes()
#'
#' Four parallel vectors, maintained by hand. A new palette needs a new entry
#' in all four, in the same position, and the row order here sets the display
#' order in [show_insper_palettes()]. `n_colors` must match the actual length
#' of the palette in `insper_palettes` (R/sysdata.rda), which is regenerated
#' by `data-raw/colors_palettes.R`.
#'
#' The integrity tests in `test-colors.R` compare this table against
#' `insper_palettes` on every run, so a missing entry, a duplicate name, or a
#' wrong `n_colors` fails the suite rather than drifting quietly. Row order is
#' not tested, since the tests compare name sets.
#'
#' @return Data frame with columns name, type, n_colors, recommended_use.
#' @keywords internal
#' @noRd
palette_metadata <- function() {
  data.frame(
    name = c(
      # qualitative
      "main",
      "muted",
      "colorblind",
      "cidades",
      # sequential
      "vermelho",
      "turquesa",
      "verde",
      "amarelo",
      "laranja",
      "rosa",
      "roxo",
      "cinza",
      "azul",
      "cidades_folhagem",
      "cidades_solar",
      "cidades_asfalto",
      "cidades_tijolo",
      # diverging
      "vermelho_turquesa",
      "roxo_verde",
      "laranja_roxo",
      "rosa_verde",
      "cidades_folhagem_asfalto",
      "cidades_folhagem_tijolo"
    ),
    type = c(
      rep("qualitative", 4),
      rep("sequential", 13),
      rep("diverging", 6)
    ),
    n_colors = c(
      7,
      7,
      8,
      4,
      5,
      5,
      5,
      5,
      5,
      5,
      5,
      5,
      5,
      7,
      7,
      7,
      7,
      5,
      5,
      5,
      5,
      5,
      5
    ),
    recommended_use = c(
      "Primary brand hues for categorical data",
      "Softer (desaturated) categorical data",
      "Colorblind-safe fallback (Okabe-Ito, not a brand palette)",
      "Insper Cidades sub-brand; do not mix with main",
      "Intensity scales (light to dark red)",
      "Intensity scales (light to dark turquesa)",
      "Intensity scales (light to dark verde)",
      "Intensity scales (light to dark amarelo)",
      "Intensity scales (light to dark laranja)",
      "Intensity scales (light to dark rosa)",
      "Intensity scales (light to dark roxo)",
      "Intensity scales (light to dark cinza)",
      "Intensity scales (light to dark azul)",
      "Insper Cidades: intensity scale (light to dark folhagem)",
      "Insper Cidades: intensity scale (light to dark solar)",
      "Insper Cidades: intensity scale (light to dark asfalto)",
      "Insper Cidades: intensity scale (light to dark tijolo)",
      "Diverging data (vermelho/turquesa, default)",
      "Diverging data (roxo/verde)",
      "Diverging data (laranja/roxo)",
      "Diverging data (rosa/verde)",
      "Insper Cidades diverging (preferred)",
      "Insper Cidades diverging (weak under red-green CVD)"
    ),
    stringsAsFactors = FALSE
  )
}


# Individual colors (internal) ----

#' Look up individual brand colors by name
#'
#' Called with no arguments, returns the whole `insper_individual_colors`
#' vector. Otherwise returns the requested tokens, named, in the order asked
#' for. Retired names resolve through [deprecate_color_name()], which warns
#' against the caller's frame so the message points at user code rather than
#' at the package internals.
#'
#' @param ... Character color token names, e.g. "vermelho", "turquesa_3".
#' @return Named character vector of hex codes.
#' @keywords internal
#' @noRd
get_insper_colors <- function(...) {
  if (length(list(...)) == 0) {
    return(insper_individual_colors)
  }
  requested <- c(...)
  user_env <- rlang::caller_env()
  resolved <- vapply(
    requested,
    deprecate_color_name,
    character(1),
    user_env = user_env
  )
  missing <- setdiff(resolved, names(insper_individual_colors))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "x" = "Colors not found: {.val {missing}}",
      "i" = "Available colors: {.val {names(insper_individual_colors)}}"
    ))
  }
  insper_individual_colors[resolved]
}


# insper_palette() ----

#' Get an Insper Color Palette
#'
#' Returns a named character vector of hex color codes from an Insper palette.
#' When printed interactively, displays a visual color swatch. The result
#' behaves as a plain character vector and can be used directly anywhere
#' colors are accepted.
#'
#' @param palette Character. Palette name. Use \code{\link{show_insper_palettes}}
#'   to see all options.
#' @param n Integer or NULL. Number of colors to return. If NULL (default),
#'   returns all colors in the palette. If \code{n} exceeds the palette size,
#'   colors are interpolated smoothly using \code{\link[grDevices]{colorRampPalette}}.
#' @param reverse Logical. If TRUE, reverses the color order. Default FALSE.
#'
#' @return An object of class \code{insper_palette} (a named character vector of
#'   hex codes). Printing displays a visual swatch. Use \code{as.character()} to
#'   strip the class if needed.
#'
#' @details
#' Available palettes by type:
#' \itemize{
#'   \item \strong{Qualitative}: main, muted, colorblind, cidades
#'   \item \strong{Sequential}: vermelho, turquesa, verde, amarelo, laranja,
#'     rosa, roxo, cinza, azul, cidades_folhagem, cidades_solar,
#'     cidades_asfalto, cidades_tijolo
#'   \item \strong{Diverging}: vermelho_turquesa (default for diverging data),
#'     roxo_verde, laranja_roxo, rosa_verde, cidades_folhagem_asfalto,
#'     cidades_folhagem_tijolo
#' }
#'
#' @section Insper Cidades:
#' Palettes prefixed \code{cidades} belong to the Insper Cidades sub-brand
#' (Centro de Estudos das Cidades / Laboratório Arq.Futuro) and are built from
#' its own application manual rather than the institutional brand kit. They are
#' opt-in: nothing in the package defaults to them.
#'
#' \strong{Do not mix them with the institutional palettes in one chart.} The two
#' families sit close together in CIELAB — \code{asfalto} is only 6.6 dE from
#' \code{roxo}, and \code{solar} 8.8 dE from \code{laranja} — close enough that a
#' chart drawing from both reads as a rendering error rather than a design
#' choice. Pick one family per chart.
#'
#' The Cidades manual ships no tints or shades, so the four \code{cidades_*}
#' sequential ramps are derived: seven steps each, with the official color pinned
#' at position 4. For diverging data prefer \code{cidades_folhagem_asfalto},
#' which has the widest colorblind separation of any diverging palette in the
#' package; \code{cidades_folhagem_tijolo} is more symmetric in lightness (so it
#' reads better in greyscale) but pairs green against orange-red, which is hard
#' under red-green color vision deficiency.
#'
#' All palettes are built from the 2026 Insper brand kit except
#' \code{"colorblind"}, which is the Okabe-Ito set
#' (\url{https://jfly.uni-koeln.de/color/}) and contains no Insper tokens. It is
#' bundled as an accessibility fallback for when the brand hues in \code{"main"}
#' cannot be told apart by colorblind readers — \code{"main"} mixes red, green,
#' orange and yellow, which is a difficult combination under the common forms of
#' color vision deficiency. Use \code{"main"} for on-brand work and reach for
#' \code{"colorblind"} when distinguishability matters more than brand fidelity.
#'
#' @family colors
#' @seealso \code{\link{show_insper_palettes}},
#'   \code{\link{scale_color_insper_d}}, \code{\link{scale_color_insper_c}}
#' @export
#' @examples
#' # Get all colors from a palette
#' insper_palette("main")
#'
#' # Subset to n colors
#' insper_palette("vermelho", n = 3)
#'
#' # Reverse order
#' insper_palette("vermelho_turquesa", reverse = TRUE)
#'
#' # Use directly in a plot
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(color = insper_palette("vermelho", n = 1))
#'
#' # Use in manual scales
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() +
#'   scale_color_manual(values = insper_palette("main", n = 3))
insper_palette <- function(palette = "main", n = NULL, reverse = FALSE) {
  palette <- deprecate_palette_name(palette, user_env = rlang::caller_env())

  if (!palette %in% names(insper_palettes)) {
    cli::cli_abort(c(
      "Palette {.val {palette}} not found.",
      "i" = "Use {.fn show_insper_palettes} to see available palettes."
    ))
  }

  colors <- insper_palettes[[palette]]

  if (reverse) {
    colors <- rev(colors)
  }

  if (!is.null(n)) {
    if (n > length(colors)) {
      colors <- grDevices::colorRampPalette(colors, space = "Lab")(n)
    } else {
      colors <- colors[seq_len(n)]
    }
  }

  structure(colors, class = c("insper_palette", "character"), palette = palette)
}

#' @export
print.insper_palette <- function(x, ...) {
  position <- hex <- text_color <- NULL # R CMD check

  n <- length(x)
  text_colors <- vapply(as.character(x), get_contrast_text_color, character(1))
  df <- data.frame(
    position = seq_len(n),
    hex = as.character(x),
    text_color = unname(text_colors),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = position, y = 1, fill = hex)) +
    ggplot2::geom_tile(
      width = 0.9,
      height = 1,
      color = "white",
      linewidth = 1
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(
      ggplot2::aes(label = hex, color = text_color),
      size = 4,
      fontface = "bold",
      angle = 90
    ) +
    ggplot2::scale_color_identity() +
    ggplot2::theme_void() +
    ggplot2::labs(title = paste0("Insper palette: ", attr(x, "palette"))) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 13, face = "bold"),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )

  print(p)
  invisible(x)
}

#' @export
as.character.insper_palette <- function(x, ...) {
  x <- unclass(x)
  attributes(x) <- NULL
  x
}


# show_insper_palettes() ----

#' Show All Insper Color Palettes
#'
#' Displays all Insper palettes as a stacked swatch grid, optionally filtered
#' by type. Invisibly returns a data frame of palette metadata.
#'
#' @param type Character. Filter by palette type. One of \code{"all"},
#'   \code{"sequential"}, \code{"diverging"}, or \code{"qualitative"}.
#'   Default \code{"all"}.
#'
#' @return Invisibly returns a data frame with columns \code{name},
#'   \code{type}, \code{n_colors}, and \code{recommended_use}.
#'
#' @family colors
#' @seealso \code{\link{insper_palette}}, \code{\link{scale_color_insper_d}}
#' @export
#' @examples
#' # Show all palettes
#' show_insper_palettes()
#'
#' # Show only sequential palettes
#' show_insper_palettes("sequential")
#'
#' # Capture metadata
#' meta <- show_insper_palettes()
show_insper_palettes <- function(
  type = c("all", "sequential", "diverging", "qualitative")
) {
  hex <- position <- palette <- NULL # R CMD check

  type <- match.arg(type)

  meta <- palette_metadata()
  if (type != "all") {
    meta <- meta[meta$type == type, ]
  }

  rows <- lapply(seq_len(nrow(meta)), function(i) {
    pal_name <- meta$name[i]
    colors <- insper_palettes[[pal_name]]
    data.frame(
      palette = pal_name,
      position = seq_along(colors),
      hex = colors,
      stringsAsFactors = FALSE
    )
  })
  df <- do.call(rbind, rows)
  df$palette <- factor(df$palette, levels = rev(meta$name))

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = position, y = palette, fill = hex)
  ) +
    ggplot2::geom_tile(
      width = 0.9,
      height = 0.8,
      color = "white",
      linewidth = 0.5
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(add = 0.5)) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(hjust = 1, size = 9),
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold")
    ) +
    ggplot2::labs(title = "Insper Color Palettes")

  print(p)
  invisible(meta)
}
