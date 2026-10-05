#' Insper Scatter Plot
#'
#' Creates scatter plots with Insper's visual identity, with an optional
#' fitted line. Accepts both color and fill aesthetics, so outlined point
#' shapes can carry two mappings.
#'
#' @param data A data frame.
#' @param x <[`data-masked`][rlang::args_data_masking]> Variable for the
#'   x-axis.
#' @param y <[`data-masked`][rlang::args_data_masking]> Variable for the
#'   y-axis.
#' @param color Color aesthetic. Accepts one of the options below.
#'   \itemize{
#'     \item A bare column name, mapped to color (e.g., `color = Species`).
#'     \item A quoted color string, used as a static color (e.g.,
#'       `color = "blue"`).
#'     \item `NULL` (default), which uses Insper turquesa.
#'   }
#'   A mapped variable gets a discrete or continuous Insper scale to match its
#'   type.
#' @param fill Fill aesthetic, for outlined shapes 21 to 25. Accepts one of the
#'   options below.
#'   \itemize{
#'     \item A bare column name, mapped to fill (e.g., `fill = Species`).
#'     \item A quoted color string, used as a static fill (e.g.,
#'       `fill = "lightblue"`).
#'     \item `NULL` (default), for no fill.
#'   }
#' @param palette Character. Palette for mapped variables. Default is `"main"`.
#' @param add_smooth Logical. If `TRUE`, adds a fitted line with a confidence
#'   band. Default is `FALSE`.
#' @param smooth_method Character. Smoothing method: `"lm"` (default),
#'   `"loess"`, `"gam"`, or `"glm"`.
#' @param point_size Numeric. Point size. Default is 2.
#' @param point_alpha Numeric. Point opacity, from 0 to 1. Default is 1.
#' @param ... Additional arguments passed to [ggplot2::geom_point()], such as
#'   `shape` or `stroke`.
#'
#' @return A ggplot object.
#'
#' @details
#' Solid shapes (16 to 20) use only `color`. Outlined shapes (21 to 25) use
#' `color` for the outline and `fill` for the interior, so you can map a
#' different variable, or a static color, to each.
#'
#' @examplesIf has_insper_fonts()
#' # Simple scatter plot with default color
#' insper_scatterplot(mtcars, x = wt, y = mpg)
#'
#' # Discrete variable mapping
#' insper_scatterplot(mtcars, x = wt, y = mpg, color = factor(cyl))
#'
#' # With smooth line
#' insper_scatterplot(mtcars, x = wt, y = mpg, add_smooth = TRUE)
#'
#' # Extra arguments go to geom_point()
#' insper_scatterplot(mtcars, x = wt, y = mpg, size = 3, alpha = 0.5)
#'
#' # Shape 21 with static color and mapped fill
#' insper_scatterplot(mtcars, x = wt, y = mpg,
#'                    color = "white",
#'                    fill = factor(cyl),
#'                    shape = 21)
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_color_insper_d}}, \code{\link{scale_fill_insper_d}}
#' @export
insper_scatterplot <- function(
  data,
  x,
  y,
  color = NULL,
  fill = NULL,
  palette = "main",
  add_smooth = FALSE,
  smooth_method = "lm",
  point_size = 2,
  point_alpha = 1,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  if (!smooth_method %in% c("lm", "loess", "gam", "glm")) {
    cli::cli_abort(c(
      "{.arg smooth_method} must be one of: {.val lm}, {.val loess}, {.val gam}, or {.val glm}",
      "x" = "You supplied: {.val {smooth_method}}"
    ))
  }

  # Smart detection for color and fill
  palette_supplied <- !missing(palette)
  color_quo <- rlang::enquo(color)
  fill_quo <- rlang::enquo(fill)

  color_type <- detect_aesthetic_type(color_quo, "color", data)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static aesthetics
  if (
    palette_supplied &&
      color_type$type == "static_color" &&
      fill_type$type == "static_color"
  ) {
    warn_palette_ignored(color_type, palette, "color")
  }

  # Build base plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }}))

  # Determine which aesthetics to map
  has_color_mapping <- color_type$type == "variable_mapping"
  has_fill_mapping <- fill_type$type == "variable_mapping"

  # Build aesthetic mapping
  if (has_color_mapping && has_fill_mapping) {
    # Both color and fill are variable mappings
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(color = {{ color }}, fill = {{ fill }}),
        size = point_size,
        alpha = point_alpha,
        ...
      )

    # Add scales based on variable types
    if (color_type$is_continuous) {
      p <- p + scale_color_insper_c(palette = palette)
    } else {
      p <- p + scale_color_insper_d(palette = palette)
    }

    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }
  } else if (has_color_mapping) {
    # Only color is variable mapping
    geom_params <- list(size = point_size, alpha = point_alpha)

    # Check if shape supports fill before adding fill aesthetic
    dots <- list(...)
    user_shape <- dots$shape
    supports_fill <- !is.null(user_shape) &&
      is.numeric(user_shape) &&
      user_shape %in% 21:25

    if (fill_type$type == "static_color" && supports_fill) {
      geom_params$fill <- fill_type$value
    }

    p <- p +
      do.call(
        ggplot2::geom_point,
        c(
          list(mapping = ggplot2::aes(color = {{ color }})),
          geom_params,
          list(...)
        )
      )

    # Add appropriate color scale
    if (color_type$is_continuous) {
      p <- p + scale_color_insper_c(palette = palette)
    } else {
      p <- p + scale_color_insper_d(palette = palette)
    }
  } else if (has_fill_mapping) {
    # Only fill is variable mapping
    geom_params <- list(size = point_size, alpha = point_alpha)
    if (color_type$type == "static_color") {
      geom_params$color <- color_type$value
    } else {
      geom_params$color <- get_insper_colors("turquesa_2") # Default outline for filled shapes
    }

    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(fill = {{ fill }}),
        size = geom_params$size,
        alpha = geom_params$alpha,
        color = geom_params$color,
        ...
      )

    # Add appropriate fill scale
    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }
  } else {
    # Neither is variable mapping - use static colors
    geom_params <- list(
      color = if (color_type$type == "static_color") {
        color_type$value
      } else {
        get_insper_colors("turquesa_3") # Default
      },
      size = point_size,
      alpha = point_alpha
    )

    # Check if user provided a shape that supports fill (21-25)
    # Extract shape from ... if provided
    dots <- list(...)
    user_shape <- dots$shape

    # Only add fill if user provided it AND either:
    # 1. Shape supports fill (21-25), OR
    # 2. No shape specified (default shape 19 doesn't support fill, so skip)
    supports_fill <- !is.null(user_shape) &&
      is.numeric(user_shape) &&
      user_shape %in% 21:25

    if (fill_type$type == "static_color" && supports_fill) {
      geom_params$fill <- fill_type$value
    }

    # Build geom_point call with conditional fill parameter
    p <- p +
      do.call(
        ggplot2::geom_point,
        c(geom_params, list(...))
      )
  }

  # Add smooth line if requested
  if (add_smooth) {
    p <- p +
      ggplot2::geom_smooth(
        method = smooth_method,
        color = get_insper_colors("laranja_0"),
        fill = get_insper_colors("laranja_0"),
        alpha = 0.2
      )
  }

  p <- p + theme_insper()

  return(p)
}
