# Shared plot appearance ----

plot_theme <- function(background) {
  ink <- if (background == "#FFFFFF") "#243139" else "#E5ECEF"
  grid <- if (background == "#FFFFFF") "#E2E9EC" else "#45545B"

  theme <- insperplot::theme_insper(
    base_size = 11,
    font_title = "Inter",
    font_text = "Inter"
  ) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = background, colour = NA),
      panel.background = ggplot2::element_rect(fill = background, colour = NA),
      panel.grid.major = ggplot2::element_line(colour = grid, linewidth = 0.3),
      text = ggplot2::element_text(colour = ink),
      axis.text = ggplot2::element_text(colour = ink),
      axis.title = ggplot2::element_text(colour = ink),
      legend.text = ggplot2::element_text(colour = ink),
      legend.title = ggplot2::element_text(colour = ink),
      legend.background = ggplot2::element_rect(fill = background, colour = NA),
      legend.key = ggplot2::element_rect(fill = background, colour = NA)
    )

  return(theme)
}

# Common plots ----

make_bar_plot <- function(colors, variant, background) {
  groups <- c("Economy", "Cities", "Research", "Education", "Culture")

  if (variant == "horizontal") {
    dat <- data.frame(
      group = factor(groups, levels = rev(groups)),
      value = c(92, 78, 64, 48, 31)
    )

    plot <- ggplot2::ggplot(
      dat,
      ggplot2::aes(x = group, y = value, fill = group)
    ) +
      ggplot2::geom_col(width = 0.7) +
      ggplot2::coord_flip() +
      ggplot2::scale_fill_manual(
        values = stats::setNames(
          rep(colors, length.out = length(groups)),
          groups
        )
      ) +
      ggplot2::labs(x = NULL, y = NULL) +
      plot_theme(background) +
      ggplot2::theme(legend.position = "none")
  } else {
    dat <- expand.grid(
      month = factor(
        c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
        levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun")
      ),
      group = factor(groups[1:4], levels = groups[1:4])
    )
    dat$value <- 18 + (seq_len(nrow(dat)) * 13 %% 23)

    plot <- ggplot2::ggplot(
      dat,
      ggplot2::aes(x = month, y = value, fill = group)
    ) +
      ggplot2::geom_col(position = "fill", width = 0.72) +
      ggplot2::scale_fill_manual(values = rep(colors, length.out = 4)) +
      ggplot2::scale_y_continuous(labels = scales::label_percent()) +
      ggplot2::labs(x = NULL, y = NULL, fill = NULL) +
      plot_theme(background) +
      ggplot2::guides(fill = ggplot2::guide_legend(nrow = 2, byrow = TRUE)) +
      ggplot2::theme(legend.position = "bottom")
  }

  return(plot)
}

make_line_plot <- function(colors, variant, background) {
  groups <- c("Economy", "Cities", "Research", "Education")
  dat <- expand.grid(
    month = seq_len(8),
    group = factor(groups, levels = groups)
  )
  group_index <- as.integer(dat$group)
  dat$value <- 28 +
    group_index * 8 +
    dat$month * (group_index %% 2 + 1) * 2 +
    round(sin(dat$month * 1.6 + group_index) * 6)

  plot <- ggplot2::ggplot(
    dat,
    ggplot2::aes(x = month, y = value, colour = group, group = group)
  ) +
    ggplot2::geom_line(linewidth = 1.1) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::scale_colour_manual(values = rep(colors, length.out = 4)) +
    ggplot2::scale_x_continuous(
      breaks = c(1, 3, 5, 7),
      labels = month.abb[c(1, 3, 5, 7)]
    ) +
    ggplot2::labs(x = NULL, y = NULL, colour = NULL) +
    plot_theme(background)

  if (variant == "small_multiples") {
    plot <- plot +
      ggplot2::facet_wrap(~group, nrow = 2) +
      ggplot2::theme(legend.position = "none")
  }

  return(plot)
}

make_scatter_plot <- function(colors, variant, background) {
  index <- seq_len(48)
  groups <- c("Economy", "Cities", "Research", "Education")
  group_index <- (index - 1) %% 4 + 1
  dat <- data.frame(
    x = 5 + floor((index - 1) / 4) * 3 + group_index * 0.6,
    y = 28 +
      group_index * 12 +
      floor((index - 1) / 4) * 1.4 +
      sin(index * 2.3) * 6,
    group = factor(groups[group_index], levels = groups),
    size = 2 + index %% 5
  )

  mapping <- if (variant == "bubble") {
    ggplot2::aes(x = x, y = y, colour = group, size = size)
  } else {
    ggplot2::aes(x = x, y = y, colour = group)
  }

  plot <- ggplot2::ggplot(dat, mapping) +
    ggplot2::geom_point(alpha = 0.82) +
    ggplot2::scale_colour_manual(values = rep(colors, length.out = 4)) +
    ggplot2::labs(x = NULL, y = NULL, colour = NULL, size = NULL) +
    plot_theme(background)

  if (variant == "bubble") {
    plot <- plot +
      ggplot2::scale_size_area(max_size = 9) +
      ggplot2::guides(size = "none")
  }

  return(plot)
}

# Technical plots ----

make_histogram <- function(colors, background) {
  plot <- ggplot2::ggplot(datasets::faithful, ggplot2::aes(x = eruptions)) +
    ggplot2::geom_histogram(
      binwidth = 0.25,
      boundary = 0,
      fill = colors[[1]],
      colour = background
    ) +
    ggplot2::labs(x = "Eruption duration (minutes)", y = "Count") +
    plot_theme(background)

  return(plot)
}

make_boxplot <- function(colors, background) {
  plot <- ggplot2::ggplot(
    datasets::iris,
    ggplot2::aes(x = Species, y = Sepal.Length, fill = Species)
  ) +
    ggplot2::geom_boxplot(width = 0.6, outlier.size = 1.5) +
    ggplot2::scale_fill_manual(values = rep(colors, length.out = 3)) +
    ggplot2::labs(x = NULL, y = "Sepal length (cm)") +
    plot_theme(background) +
    ggplot2::theme(legend.position = "none")

  return(plot)
}

# Other plot shapes ----

make_heatmap <- function(colors, background) {
  dat <- expand.grid(row = seq_len(9), column = seq_len(16))
  dat$value <- (sin(dat$row * 1.7 + dat$column * 0.54) +
    cos(dat$column * 1.13 - dat$row) +
    2) /
    4

  plot <- ggplot2::ggplot(
    dat,
    ggplot2::aes(x = column, y = row, fill = value)
  ) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradientn(colours = colors, name = NULL) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_equal() +
    ggplot2::labs(x = NULL, y = NULL) +
    plot_theme(background) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  return(plot)
}

make_donut <- function(colors, background) {
  dat <- data.frame(
    group = factor(
      c("Economy", "Cities", "Research", "Education", "Culture"),
      levels = c("Economy", "Cities", "Research", "Education", "Culture")
    ),
    value = c(34, 25, 18, 13, 10)
  )

  plot <- ggplot2::ggplot(dat, ggplot2::aes(x = 2, y = value, fill = group)) +
    ggplot2::geom_col(width = 1, colour = background, linewidth = 0.6) +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::xlim(0.5, 2.5) +
    ggplot2::scale_fill_manual(values = rep(colors, length.out = 5)) +
    ggplot2::labs(fill = NULL) +
    plot_theme(background) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  return(plot)
}

make_choropleth <- function(colors, background, map) {
  map$value <- (seq_len(nrow(map)) * 31 + floor(seq_len(nrow(map)) / 3) * 17) %%
    100

  plot <- ggplot2::ggplot(map, ggplot2::aes(fill = value)) +
    ggplot2::geom_sf(colour = background, linewidth = 0.25) +
    ggplot2::scale_fill_gradientn(colours = colors, name = "Sample value") +
    ggplot2::coord_sf(datum = NA) +
    plot_theme(background) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )

  return(plot)
}
