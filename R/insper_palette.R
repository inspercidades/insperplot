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
