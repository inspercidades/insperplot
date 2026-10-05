#' Insper Area Plot
#'
#' Creates area charts of time series with Insper's visual identity. Supports
#' single, stacked, and overlapping areas.
#'
#' @details
#' ## Stacking
#'
#' Under the default `stacked = NULL`, areas stack when `fill` maps a variable
#' and overlap when `fill` is missing or a static color, where stacking would
#' have no effect anyway. Set `stacked = TRUE` or `stacked = FALSE` to choose
#' directly. Overlapping areas suit comparing group trajectories; stacked areas
#' suit part-to-whole.
#'
#' ## Line overlay
#'
#' A line is drawn on top of each area by default (`add_line = TRUE`), in the
#' fill color. Set `add_line = FALSE` to drop it, which helps when many groups
#' are stacked.
#'
#' @param data A data frame.
#' @param x <[`data-masked`][rlang::args_data_masking]> Time variable
#'   (numeric, `Date`, or `POSIXct`).
#' @param y <[`data-masked`][rlang::args_data_masking]> Value variable.
#' @param fill Fill aesthetic. Accepts one of the options below.
#'   \itemize{
#'     \item A quoted color string, used as a static color (e.g., `"#3ACC9F"`,
#'       `"grey40"`).
#'     \item A bare discrete column, used for grouping (e.g., `category`).
#'     \item A bare continuous column, mapped to a gradient (e.g.,
#'       `intensity`).
#'     \item `NULL` (default), which uses Insper turquesa.
#'   }
#'   The fill color also sets the line color when `add_line = TRUE`.
#' @param palette Character. Palette for mapped variables. If `NULL`
#'   (default), uses `"main"`.
#' @param stacked Logical or `NULL`. Whether to stack areas. If `NULL`
#'   (default), stacks only when `fill` maps a variable. See Details.
#' @param area_alpha Numeric. Area opacity, from 0 to 1. Default is 0.9.
#' @param fill_color Character. Area color, used only when `fill` is `NULL`.
#'   Default is `turquesa_3`. Prefer `fill = "<color>"`, which colors both the
#'   area and the line.
#' @param add_line Logical. If `TRUE` (default), draws a line on top of each
#'   area.
#' @param line_color Character. Line color, used only when `fill` is `NULL`.
#'   Default is `turquesa_2`, a lighter step of the turquesa ramp.
#' @param line_width Numeric. Line width. Default is 0.8.
#' @param line_alpha Numeric. Line opacity, from 0 to 1. Default is 1.
#' @param zero Logical. If `TRUE`, draws a horizontal line at y = 0. Default
#'   is `FALSE`.
#' @param ... Additional arguments passed to [ggplot2::geom_area()].
#'
#' @return A ggplot object.
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Single area: coal consumption since 1900
#' coal_data <- subset(fossil_fuel, fuel == "Coal" & year >= 1900)
#' insper_area(coal_data, x = year, y = consumption)
#'
#' # Mapping fill to a variable stacks the areas
#' recent_data <- subset(fossil_fuel, year >= 1950)
#' recent_data$fuel <- factor(recent_data$fuel, levels = c("Oil", "Gas", "Coal"))
#' insper_area(recent_data, x = year, y = consumption, fill = fuel) +
#'   labs(
#'     title = "Global Fossil Fuel Consumption",
#'     subtitle = "Primary energy consumption by fuel type (1950-present)",
#'     x = "Year",
#'     y = "Consumption (TWh)",
#'     fill = "Fuel Type"
#'   )
#'
#' # Overlapping areas, to compare trajectories
#' insper_area(recent_data, x = year, y = consumption,
#'             fill = fuel, stacked = FALSE) +
#'   labs(
#'     title = "Comparing Fuel Consumption Trends",
#'     subtitle = "Overlapping areas show individual trajectories",
#'     x = "Year",
#'     y = "Consumption (TWh)",
#'     fill = "Fuel Type"
#'   )
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}, \code{\link{insper_timeseries}}
#' @export
insper_area <- function(
  data,
  x,
  y,
  fill = NULL,
  palette = NULL,
  stacked = NULL,
  area_alpha = 0.9,
  fill_color = get_insper_colors("turquesa_3"),
  add_line = TRUE,
  line_color = get_insper_colors("turquesa_2"),
  line_width = 0.8,
  line_alpha = 1,
  zero = FALSE,
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

  # Use default palette if not specified
  if (is.null(palette)) {
    palette <- "main"
  }

  # Smart detection for stacked behavior
  # If stacked is NULL, auto-detect: stack when fill is a variable mapping
  has_fill_mapping <- fill_type$type == "variable_mapping"
  if (is.null(stacked)) {
    stacked <- has_fill_mapping
  }

  # Determine position
  position <- if (stacked && has_fill_mapping) "stack" else "identity"

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper turquesa
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_area(fill = fill_color, alpha = area_alpha, ...)

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          color = line_color,
          linewidth = line_width,
          alpha = line_alpha
        )
    }
  } else if (fill_type$type == "static_color") {
    # Static color specified - use for both area and line
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_area(fill = fill_type$value, alpha = area_alpha, ...)

    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          color = fill_type$value,
          linewidth = line_width,
          alpha = line_alpha
        )
    }
  } else {
    # Variable mapping - propagate to both fill and color
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_area(alpha = area_alpha, position = position, ...)

    # Apply appropriate fill scale
    if (fill_type$is_continuous) {
      p <- p + scale_fill_insper_c(palette = palette)
    } else {
      p <- p + scale_fill_insper_d(palette = palette)
    }

    # Add line with matching color mapping
    if (add_line) {
      p <- p +
        ggplot2::geom_line(
          ggplot2::aes(color = {{ fill }}),
          linewidth = line_width,
          alpha = line_alpha,
          position = position
        )

      # Apply appropriate color scale (same as fill)
      if (fill_type$is_continuous) {
        p <- p + scale_color_insper_c(palette = palette)
      } else {
        p <- p + scale_color_insper_d(palette = palette)
      }
    }
  }

  # Add line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  p <- p +
    theme_insper() +
    ggplot2::theme(
      panel.grid.minor.x = ggplot2::element_blank()
    )

  return(p)
}
