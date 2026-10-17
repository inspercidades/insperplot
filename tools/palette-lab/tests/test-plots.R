pkgload::load_all("../..", quiet = TRUE)
source("plots.R")

colors <- c("#E50505", "#3ACC9F", "#730D9F", "#FFCC00")
map <- readRDS("data/brazil-states.rds")

plots <- list(
  make_bar_plot(colors, "horizontal", "#FFFFFF"),
  make_bar_plot(colors, "stacked", "#FFFFFF"),
  make_line_plot(colors, "series", "#FFFFFF"),
  make_line_plot(colors, "small_multiples", "#FFFFFF"),
  make_scatter_plot(colors, "groups", "#FFFFFF"),
  make_scatter_plot(colors, "bubble", "#FFFFFF"),
  make_histogram(colors, "#FFFFFF"),
  make_boxplot(colors, "#FFFFFF"),
  make_heatmap(colors, "#FFFFFF"),
  make_donut(colors, "#FFFFFF"),
  make_choropleth(colors, "#FFFFFF", map)
)

stopifnot(
  length(plots) == 11,
  all(vapply(plots, inherits, logical(1), "ggplot")),
  nrow(map) == 27
)

for (plot in plots) {
  ggplot2::ggplot_build(plot)
}

bar_fills <- ggplot2::ggplot_build(plots[[1]])$data[[1]]$fill
stopifnot(all(bar_fills %in% colors))
