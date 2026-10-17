# Palette lab

A local Shiny app for testing `insperplot` colors in static ggplot2 charts. It
includes tabbed variations of bars, lines, and scatter plots, plus a histogram,
boxplot, heatmap, donut chart, and Brazil state choropleth. Each chart uses
fixed sample data so palette changes are easy to compare.

From the package root, run:

```sh
Rscript -e 'shiny::runApp("tools/palette-lab")'
```

The app loads the package source, so edits to `insperplot` palettes are available
without installing the package. It requires `shiny`, `bslib`, `pkgload`,
`ggplot2`, `sf`, and the package's dependencies. Choose a package preset, edit its hex colors
(one per line), or switch the plot canvas between white and dark. Reset restores
the selected preset. Edits in the app are temporary; they do not change the
package palettes.

Plots use `theme_insper()` with Inter text and ggplot2 color scales. The
choropleth uses local 2020 IBGE state boundaries obtained through `geobr`, with
illustrative values. To refresh the boundaries, run
`Rscript scripts/export-map.R` from this directory; that optional step requires
`geobr`, `sf`, and a network connection.

Run `Rscript tests/test-plots.R` and `Rscript tests/test-server.R` from this
directory to check the chart construction and palette controls.
