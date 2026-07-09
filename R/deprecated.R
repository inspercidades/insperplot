# Deprecated palette and color names ------------------------------------------
#
# The 2026 Insper brand kit replaced the old palette/color system. Old names
# are soft-deprecated for one release: they still resolve (mapped to the
# nearest 2026 equivalent) but emit a deprecation warning. Slated for removal
# in a future release.

# Retired palette names -> 2026 replacement.
deprecated_palettes <- c(
  reds = "vermelho",
  oranges = "laranja",
  teals = "turquesa",
  red_teal = "vermelho_turquesa",
  red_teal_ext = "vermelho_turquesa",
  bright = "main",
  contrast = "muted",
  categorical = "main",
  accent_red = "main",
  accent_teal = "main",
  # Renamed in 0.3.0 for naming consistency (Portuguese family names).
  grays = "cinza",
  diverging = "vermelho_turquesa"
)

# Version in which each palette name was deprecated (default "0.2.0").
deprecated_palettes_when <- c(
  grays = "0.3.0",
  diverging = "0.3.0"
)

# Retired individual color names -> 2026 token. Some old red/orange/magenta
# tints/shades have no exact brand equivalent and collapse to the nearest hue.
deprecated_colors <- c(
  off_white = "white",
  gray_light = "cinza_0",
  gray_med = "cinza_1",
  gray_meddark = "cinza_4",
  gray_dark = "cinza_4",
  reds1 = "vermelho",
  reds2 = "vermelho",
  reds3 = "vermelho",
  oranges1 = "laranja_0",
  oranges2 = "laranja_3",
  oranges3 = "laranja_2",
  magentas1 = "rosa_4",
  magentas2 = "rosa_4",
  magentas3 = "rosa_3",
  teals1 = "turquesa_3",
  teals2 = "turquesa_0",
  teals3 = "turquesa_2"
)

#' @keywords internal
#' @noRd
deprecate_palette_name <- function(palette, user_env = rlang::caller_env()) {
  if (
    length(palette) != 1 ||
      is.na(palette) ||
      !palette %in% names(deprecated_palettes)
  ) {
    return(palette)
  }
  replacement <- unname(deprecated_palettes[[palette]])
  when <- deprecated_palettes_when[palette]
  when <- if (is.na(when)) "0.2.0" else unname(when)
  lifecycle::deprecate_warn(
    when = when,
    what = I(sprintf("The %s palette", encodeString(palette, quote = "\""))),
    with = I(sprintf(
      "the %s palette",
      encodeString(replacement, quote = "\"")
    )),
    details = "Palettes were rebuilt for the 2026 Insper brand kit.",
    id = paste0("insperplot_palette_", palette),
    user_env = user_env
  )
  replacement
}

#' @keywords internal
#' @noRd
deprecate_color_name <- function(name, user_env = rlang::caller_env()) {
  if (length(name) != 1 || is.na(name) || !name %in% names(deprecated_colors)) {
    return(name)
  }
  replacement <- unname(deprecated_colors[[name]])
  lifecycle::deprecate_warn(
    when = "0.2.0",
    what = I(sprintf("The %s color", encodeString(name, quote = "\""))),
    with = I(sprintf("the %s color", encodeString(replacement, quote = "\""))),
    details = "Colors were rebuilt for the 2026 Insper brand kit.",
    id = paste0("insperplot_color_", name),
    user_env = user_env
  )
  replacement
}
