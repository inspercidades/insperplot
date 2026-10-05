#' Insper Density Plot
#'
#' Creates density plots with Insper's visual identity. Supports grouped
#' densities, with one color per group.
#'
#' @param data A data frame.
#' @param x <[`data-masked`][rlang::args_data_masking]> Numeric variable for
#'   the x-axis.
#' @param fill Fill aesthetic. Accepts one of the options below.
#'   \itemize{
#'     \item A quoted color string, used as a static color (e.g., `"purple"`,
#'       `"#9148B0"`).
#'     \item A bare discrete column or factor expression, used for grouping
#'       (e.g., `Species` or `factor(gear)`).
#'     \item `NULL` (default), which uses Insper turquesa.
#'   }
#'   The fill color also sets the density line color.
#' @param palette Character. Palette for mapped variables. If `NULL`
#'   (default), uses `"main"`.
#' @param fill_color Character. Area color, used only when `fill` is `NULL`.
#'   Default is `turquesa_3`. Prefer `fill = "<color>"`, which colors both the
#'   area and the line.
#' @param line_color Character. Line color, used only when `fill` is `NULL`.
#'   Default is `turquesa_2`, a lighter step of the turquesa ramp.
#' @param alpha Numeric. Area opacity, from 0 to 1. Default is 0.6.
#' @param bw Numeric or character. Bandwidth, either a number or the name of a
#'   bandwidth selector (`"nrd0"`, `"nrd"`, `"ucv"`, `"bcv"`, `"SJ"`). Default
#'   is `"nrd0"`.
#' @param adjust Numeric. Multiplier applied to the bandwidth. Default is 1.
#' @param kernel Character. Smoothing kernel. Default is `"gaussian"`.
#' @param ... Additional arguments passed to [ggplot2::geom_density()].
#'
#' @return A ggplot object.
#'
#' @examplesIf has_insper_fonts()
#' # Simple density plot (default turquesa)
#' insper_density(macro_series, x = ipca)
#'
#' # Static color
#' insper_density(macro_series, x = ipca, fill = "purple")
#'
#' # Grouped density plot (discrete variable)
#' insper_density(iris, x = Sepal.Length, fill = Species)
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_histogram}}
#' @export
insper_density <- function(
  data,
  x,
  fill = NULL,
  palette = NULL,
  fill_color = get_insper_colors("turquesa_3"),
  line_color = get_insper_colors("turquesa_2"),
  alpha = 0.6,
  bw = "nrd0",
  adjust = 1,
  kernel = "gaussian",
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Smart detection for fill aesthetic
  palette_supplied <- !missing(palette)
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)
  warn_palette_ignored(
    fill_type,
    if (palette_supplied) palette else NULL,
    "fill"
  )

  if (isTRUE(fill_type$is_continuous)) {
    cli::cli_abort(c(
      "{.arg fill} must be discrete for a density plot.",
      "i" = "Convert the grouping variable to a factor."
    ))
  }

  # Use default palette if not specified
  if (is.null(palette)) {
    palette <- "main"
  }

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper turquesa
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_density(
        fill = fill_color,
        color = line_color,
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # Static color specified - use for both fill and line
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_density(
        fill = fill_type$value,
        color = fill_type$value,
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )
  } else {
    # Variable mapping - propagate to both fill and color
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, fill = {{ fill }}, color = {{ fill }})
    ) +
      ggplot2::geom_density(
        alpha = alpha,
        bw = bw,
        adjust = adjust,
        kernel = kernel,
        ...
      )

    p <- p +
      scale_fill_insper_d(palette = palette) +
      scale_color_insper_d(palette = palette)
  }

  # Apply theme and scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    theme_insper()

  return(p)
}
