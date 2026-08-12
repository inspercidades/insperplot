#' Insper Violin Plot
#'
#' Create violin plots to visualize distributions using Insper's visual identity.
#' Optionally overlay boxplots and/or jittered points.
#'
#' @param data A data frame containing the data to plot
#' @param x Variable for x-axis (categorical)
#' @param y Variable for y-axis (numeric)
#' @param fill Fill aesthetic. Accepts either:
#'   \itemize{
#'     \item A bare column name for variable mapping (e.g., \code{fill = Species})
#'     \item A quoted color string for static fill (e.g., \code{fill = "purple"})
#'     \item \code{NULL} (default) to use default Insper turquesa
#'   }
#' @param palette Character. Color palette for variable mappings. Default is "main".
#' @param show_boxplot Logical. If TRUE, overlays a boxplot. Default is FALSE
#' @param show_points Logical. If TRUE, adds jittered points. Default is FALSE
#' @param violin_alpha Numeric. Transparency of violins (0-1). Default is 0.7
#' @param ... Additional arguments passed to \code{ggplot2::geom_violin()}
#' @return A ggplot2 object
#'
#' @examplesIf has_insper_fonts()
#' # Simple violin plot with default fill
#' insper_violin(iris, x = Species, y = Sepal.Length)
#'
#' # Static fill color
#' insper_violin(iris, x = Species, y = Sepal.Length, fill = "#E50505")
#'
#' # Variable fill mapping
#' insper_violin(iris, x = Species, y = Sepal.Length, fill = Species)
#'
#' # Custom palette
#' insper_violin(iris, x = Species, y = Sepal.Length, fill = Species, palette = "main")
#'
#' # With boxplot overlay and points
#' insper_violin(iris, x = Species, y = Sepal.Length,
#'               show_boxplot = TRUE, show_points = TRUE)
#'
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_d}}, \code{\link{insper_boxplot}}
#' @export
insper_violin <- function(
  data,
  x,
  y,
  fill = NULL,
  palette = "main",
  show_boxplot = FALSE,
  show_points = FALSE,
  violin_alpha = 0.7,
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Smart detection for fill
  palette_supplied <- !missing(palette)
  fill_quo <- rlang::enquo(fill)
  fill_type <- detect_aesthetic_type(fill_quo, "fill", data)

  # Warn if palette specified with static fill
  warn_palette_ignored(
    fill_type,
    if (palette_supplied) palette else NULL,
    "fill"
  )

  # Initialize plot based on fill type
  if (fill_type$type == "missing") {
    # Default: Insper turquesa
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_violin(
        fill = get_insper_colors("turquesa_0"),
        alpha = violin_alpha,
        ...
      )
  } else if (fill_type$type == "static_color") {
    # User-specified static color
    p <- ggplot2::ggplot(data, ggplot2::aes(x = {{ x }}, y = {{ y }})) +
      ggplot2::geom_violin(
        fill = fill_type$value,
        alpha = violin_alpha,
        ...
      )
  } else {
    # Variable mapping - violins are inherently discrete
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = {{ x }}, y = {{ y }}, fill = {{ fill }})
    ) +
      ggplot2::geom_violin(alpha = violin_alpha, ...) +
      scale_fill_insper_d(palette = palette)
  }

  # Add boxplot if requested
  if (show_boxplot) {
    p <- p + ggplot2::geom_boxplot(width = 0.2, alpha = 0.5, outlier.shape = NA)
  }

  # Add jittered points if requested
  if (show_points) {
    p <- p +
      ggplot2::geom_jitter(
        width = 0.1,
        alpha = 0.5,
        color = get_insper_colors("cinza_1")
      )
  }

  p <- p + theme_insper()

  return(p)
}
