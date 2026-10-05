#' Insper Heatmap
#'
#' Creates heatmaps, such as correlation matrices, with Insper's visual
#' identity. Accepts either a matrix or a data frame in long format.
#'
#' @param data A matrix (for example, from [cor()]) or a long data frame with
#'   columns `Var1`, `Var2`, and `value`.
#' @param show_values Logical. If `TRUE`, prints values on the tiles. Default
#'   is `FALSE`.
#' @param value_color Character. Color of the printed values. Default is
#'   `"white"`.
#' @param value_size Numeric. Size of the printed values. Default is 3.
#' @param palette Character. Palette for the continuous fill scale. Default is
#'   `"vermelho_turquesa"`.
#' @param ... Additional arguments passed to [ggplot2::geom_tile()].
#'
#' @return A ggplot object.
#'
#' @examplesIf has_insper_fonts()
#' # From a correlation matrix
#' cor_mat <- cor(mtcars[, 1:4])
#' insper_heatmap(cor_mat)
#'
#' # Print values on the tiles
#' insper_heatmap(cor_mat, show_values = TRUE)
#'
#' # Another diverging palette
#' insper_heatmap(cor_mat, palette = "roxo_verde")
#' @family plots
#' @seealso \code{\link{theme_insper}}, \code{\link{scale_fill_insper_c}}
#' @export
insper_heatmap <- function(
  data,
  show_values = FALSE,
  value_color = "white",
  value_size = 3,
  palette = "vermelho_turquesa",
  ...
) {
  # Input validation with cli
  if (!is.data.frame(data) && !is.matrix(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame or matrix",
      "x" = "You supplied an object of class {.cls {class(data)}}"
    ))
  }

  # Check if data is already in melted format
  is_melted <- is.data.frame(data) &&
    all(c("Var1", "Var2", "value") %in% names(data))

  if (!is_melted) {
    # Convert matrix/data frame to long format
    if (!is.matrix(data)) {
      if (!all(sapply(data, is.numeric))) {
        cli::cli_abort(c(
          "{.arg data} must contain only numeric columns when not pre-melted",
          "i" = "Or provide data in melted format with columns: Var1, Var2, value"
        ))
      }
      data <- as.matrix(data)
    }

    row_names <- rownames(data)
    if (is.null(row_names)) {
      row_names <- seq_len(nrow(data))
    }

    column_names <- colnames(data)
    if (is.null(column_names)) {
      column_names <- seq_len(ncol(data))
    }

    melted_data <- expand.grid(
      Var1 = row_names,
      Var2 = column_names
    )
    melted_data$value <- as.vector(data)
  } else {
    melted_data <- data
  }

  # Create plot
  p <- ggplot2::ggplot(
    melted_data,
    ggplot2::aes(x = Var1, y = Var2, fill = value)
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5, ...) +
    scale_fill_insper_c(palette = palette) +
    theme_insper() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::labs(fill = "Value")

  # Add value labels if requested
  if (show_values) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = round(value, 2)),
        color = value_color,
        size = value_size
      )
  }

  return(p)
}
