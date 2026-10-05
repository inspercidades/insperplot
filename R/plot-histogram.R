#' Insper Histogram
#'
#' Creates histograms with Insper's visual identity. The number of bins comes
#' from the Sturges, Freedman-Diaconis, or Scott rule, or from a count you
#' supply.
#'
#' @param data A data frame.
#' @param x <[`data-masked`][rlang::args_data_masking]> Numeric variable for
#'   the x-axis.
#' @param fill Fill aesthetic. Accepts one of the options below.
#'   \itemize{
#'     \item A quoted color string, used as a static fill (e.g., `"blue"`,
#'       `"#FF0000"`).
#'     \item A bare discrete column or factor expression, used for grouping
#'       (e.g., `Species` or `factor(cyl)`).
#'     \item `NULL` (default), which uses Insper red.
#'   }
#' @param palette Character. Palette for mapped variables. If `NULL`
#'   (default), uses `"main"`.
#' @param bins Numeric. Number of bins. Used only when
#'   `bin_method = "manual"`.
#' @param bin_method Character. Bin selection method: `"sturges"` (default),
#'   `"fd"` (Freedman-Diaconis), `"scott"`, or `"manual"`.
#' @param border_color Character. Color of the bar borders. Default is
#'   `"white"`.
#' @param zero Logical. If `TRUE` (default), draws a horizontal line at
#'   y = 0.
#' @param ... Additional arguments passed to [ggplot2::geom_histogram()].
#'
#' @return A ggplot object.
#'
#' @details
#' The four bin selection methods are described below.
#' \itemize{
#'   \item **Sturges**: \eqn{k = \lceil \log_2(n) + 1 \rceil}. Assumes roughly
#'     normal data and tends to undersmooth large samples.
#'   \item **Freedman-Diaconis**: Derives bin width from the IQR, so outliers
#'     move it less than the other two.
#'   \item **Scott**: Derives bin width from the standard deviation, assuming
#'     roughly normal data.
#'   \item **Manual**: Uses the bin count given in `bins`.
#' }
#'
#' @examplesIf has_insper_fonts()
#' # Simple histogram with Sturges method
#' insper_histogram(mtcars, x = mpg)
#'
#' # Using Freedman-Diaconis method
#' insper_histogram(mtcars, x = mpg, bin_method = "fd")
#'
#' # Manual bin specification
#' insper_histogram(mtcars, x = mpg, bin_method = "manual", bins = 15)
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{insper_density}}
#' @importFrom grDevices nclass.Sturges nclass.FD nclass.scott
#' @export
insper_histogram <- function(
  data,
  x,
  fill = NULL,
  palette = NULL,
  bins = NULL,
  bin_method = c("sturges", "fd", "scott", "manual"),
  border_color = "white",
  zero = TRUE,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  bin_method <- match.arg(bin_method)

  if (bin_method == "manual" && is.null(bins)) {
    cli::cli_abort(c(
      "{.arg bins} must be specified when bin_method = 'manual'",
      "i" = "Set a number of bins, e.g., bins = 30"
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
      "{.arg fill} must be discrete for a histogram.",
      "i" = "Convert the grouping variable to a factor."
    ))
  }

  # Use default palette if not specified
  if (is.null(palette)) {
    palette <- "main"
  }

  # Extract x values for bin calculation
  x_quo <- rlang::enquo(x)
  x_vals <- rlang::eval_tidy(x_quo, data)

  # Calculate number of bins based on method
  if (bin_method == "sturges") {
    n_bins <- nclass.Sturges(x_vals)
  } else if (bin_method == "fd") {
    n_bins <- nclass.FD(x_vals)
  } else if (bin_method == "scott") {
    n_bins <- nclass.scott(x_vals)
  } else {
    # manual
    n_bins <- bins
  }

  # Build plot based on fill type
  if (fill_type$type == "missing") {
    # No fill specified - use default Insper red
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_histogram(
        fill = get_insper_colors("vermelho"),
        color = border_color,
        bins = n_bins,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # Static color specified
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }})) +
      ggplot2::geom_histogram(
        fill = fill_type$value,
        color = border_color,
        bins = n_bins,
        ...
      )
  } else {
    # Variable mapping (discrete or continuous)
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, fill = {{ fill }})
    ) +
      ggplot2::geom_histogram(
        color = border_color,
        bins = n_bins,
        position = "identity",
        alpha = 0.7,
        ...
      )

    p <- p + scale_fill_insper_d(palette = palette)
  }

  # Add line at zero if requested
  if (zero) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linewidth = 1)
  }

  # Apply theme and scale
  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    theme_insper()

  return(p)
}
