#' Palette generator used by the scale functions
#'
#' Resolves a palette name to hex codes. Unlike the exported
#' [insper_palette()], `type` decides what happens when `n` is at or below the
#' palette size: `"discrete"` takes the first `n` colors, keeping the brand
#' tokens exact, while `"continuous"` always interpolates in CIELAB, so a
#' gradient stays evenly spaced. `scale_*_insper_d()` passes the former and
#' `scale_*_insper_c()` the latter. Above the palette size both interpolate.
#'
#' Deprecated palette names resolve here, so the warning is attributed to the
#' user's frame rather than to the scale function.
#'
#' @param palette Character. Palette name.
#' @param n Integer or NULL. Number of colors. NULL uses the whole palette.
#' @param type Either "discrete" or "continuous".
#' @param reverse Logical. Reverse the palette before subsetting.
#' @return Character vector of hex codes, unnamed.
#' @keywords internal
#' @noRd
insper_pal <- function(
  palette = "main",
  n = NULL,
  type = "discrete",
  reverse = FALSE
) {
  palette <- deprecate_palette_name(palette, user_env = rlang::caller_env())

  if (!palette %in% names(insper_palettes)) {
    cli::cli_abort(
      "Palette {.val {palette}} not found. Available palettes: {.val {names(insper_palettes)}}"
    )
  }

  pal <- insper_palettes[[palette]]

  if (reverse) {
    pal <- rev(pal)
  }

  if (is.null(n)) {
    n <- length(pal)
  }

  if (type == "discrete" && n <= length(pal)) {
    pal <- pal[1:n]
  } else {
    pal <- grDevices::colorRampPalette(pal, space = "Lab")(n)
  }

  return(pal)
}
