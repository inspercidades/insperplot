#' Insper Discrete Color and Fill Scales
#'
#' Discrete ggplot2 scales that map categories to colors from an Insper
#' palette. Levels take colors in palette order, so the brand colors appear
#' exactly as defined. Use them for categorical variables; for numeric
#' variables, see [scale_color_insper_c()].
#'
#' @param palette Character. Palette name. Default is `"main"`. Qualitative
#'   palettes (`"main"`, `"muted"`, `"colorblind"`, `"cidades"`) suit most
#'   categorical data. See [show_insper_palettes()] for all options.
#' @param reverse Logical. If `TRUE`, reverses the palette order. Default is
#'   `FALSE`.
#' @param ... Additional arguments passed to [ggplot2::discrete_scale()], such
#'   as `name` or `labels`.
#' @return A ggplot2 scale object.
#' @family scales
#' @seealso [insper_palette()], [theme_insper()], [scale_color_insper_c()]
#' @importFrom ggplot2 discrete_scale
#' @importFrom scales manual_pal
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_insper_d()
#'
#' ggplot(mtcars, aes(x = factor(cyl), fill = factor(gear))) +
#'   geom_bar() +
#'   scale_fill_insper_d(palette = "muted", name = "Gears")
scale_color_insper_d <- function(palette = "main", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = scales::manual_pal(insper_pal(palette, reverse = reverse)),
    ...
  )
}

#' @rdname scale_color_insper_d
#' @export
scale_colour_insper_d <- function(palette = "main", reverse = FALSE, ...) {
  scale_color_insper_d(palette = palette, reverse = reverse, ...)
}

#' @rdname scale_color_insper_d
#' @export
scale_fill_insper_d <- function(palette = "main", reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = scales::manual_pal(insper_pal(palette, reverse = reverse)),
    ...
  )
}


#' Insper Continuous Color and Fill Scales
#'
#' Continuous ggplot2 scales that map numeric values to a gradient built from
#' an Insper palette. Use them for numeric variables; for categorical
#' variables, see [scale_color_insper_d()].
#'
#' @param palette Character. Palette name. Default is `"turquesa"`. Sequential
#'   palettes suit ordered magnitudes, and diverging palettes (such as
#'   `"vermelho_turquesa"`) suit data with a meaningful midpoint. See
#'   [show_insper_palettes()] for all options.
#' @param reverse Logical. If `TRUE`, reverses the gradient. Default is
#'   `FALSE`.
#' @param ... Additional arguments passed to [ggplot2::scale_color_gradientn()]
#'   or [ggplot2::scale_fill_gradientn()], such as `name`, `limits`, or
#'   `labels`.
#' @return A ggplot2 scale object.
#' @family scales
#' @seealso [insper_palette()], [theme_insper()], [scale_color_insper_d()]
#' @importFrom ggplot2 scale_color_gradientn
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg, color = hp)) +
#'   geom_point() +
#'   scale_color_insper_c(palette = "turquesa")
#'
#' # Diverging palette for values around a midpoint
#' ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster() +
#'   scale_fill_insper_c(palette = "vermelho_turquesa")
scale_color_insper_c <- function(palette = "turquesa", reverse = FALSE, ...) {
  ggplot2::scale_color_gradientn(
    colours = insper_pal(palette, type = "continuous", reverse = reverse),
    ...
  )
}

#' @rdname scale_color_insper_c
#' @export
scale_colour_insper_c <- function(palette = "turquesa", reverse = FALSE, ...) {
  scale_color_insper_c(palette = palette, reverse = reverse, ...)
}

#' @rdname scale_color_insper_c
#' @importFrom ggplot2 scale_fill_gradientn
#' @export
scale_fill_insper_c <- function(palette = "turquesa", reverse = FALSE, ...) {
  ggplot2::scale_fill_gradientn(
    colours = insper_pal(palette, type = "continuous", reverse = reverse),
    ...
  )
}
