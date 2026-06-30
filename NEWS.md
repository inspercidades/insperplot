# insperplot 0.2.0

## Brand refresh (breaking changes)

The color system was rebuilt for the **2026 Insper brand kit**. The primary
color is now Vermelho (`#E50505`) and the secondary palette is organized into
six hue families (turquesa, verde, amarelo, laranja, rosa, roxo) plus the
cinza/azul neutrals.

* **Palettes renamed and reorganized.** Old names still work but emit a
  deprecation warning and will be removed in a future release:

  | Old palette                | New palette  |
  | -------------------------- | ------------ |
  | `reds`                     | `vermelho`   |
  | `oranges`                  | `laranja`    |
  | `teals`                    | `turquesa`   |
  | `red_teal`, `red_teal_ext` | `diverging`  |
  | `bright`                   | `main`       |
  | `contrast`                 | `muted`      |
  | `categorical`              | `main`       |
  | `accent_red`, `accent_teal`| `main`       |

* **New palettes:** `muted` (softer categorical); per-family sequential ramps
  `vermelho`, `turquesa`, `verde`, `amarelo`, `laranja`, `rosa`, `roxo`; and
  four diverging palettes `diverging` (= `vermelho_turquesa`), `roxo_verde`,
  `laranja_roxo`, and `rosa_verde`.

* **Default palettes changed.** Continuous scales now default to `turquesa`
  (was `teals`); plot functions default to the `main` categorical palette
  (was `categorical`).

* **Individual color names changed** (e.g. `teals1` → `turquesa_3`,
  `reds1` → `vermelho`, `gray_med` → `cinza_1`, `off_white` → `white`). Old
  names are deprecated, warn on use, and resolve to the nearest 2026 token.

## Other improvements

* Continuous scales now interpolate colors in CIELAB space for perceptually
  smoother gradients.
* The package hex logo was recolored to the 2026 brand red.
* **Reduced bundled fonts to Inter only.** EB Garamond and Playfair Display are
  no longer shipped — they were old-brand serif fallbacks not part of the 2026
  kit, in which Inter is the sole free font. Titles default to Georgia (a
  system font; the documented substitute for the primary GT Ultra) and now fall
  back directly to the system "serif" family where Georgia is unavailable. This
  trims the installed package by ~1.4 MB.

# insperplot 0.1.0

* Initial CRAN release.
* Custom ggplot2 theme: `theme_insper()` with configurable fonts, grid lines,
  borders, and title alignment.
* Bundled fonts: Inter, EB Garamond, and Playfair Display are shipped with
  the package and registered automatically on load via `systemfonts` — no
  manual download or setup required.
* Color palettes based on Insper's brand identity: sequential, diverging, and
  qualitative palettes accessible via `insper_palette()` and
  `show_insper_palettes()`.
* Discrete and continuous ggplot2 scales: `scale_color_insper_d()`,
  `scale_color_insper_c()`, `scale_fill_insper_d()`, `scale_fill_insper_c()`.
* High-level plot functions: `insper_timeseries()`, `insper_barplot()`,
  `insper_scatterplot()`, `insper_area()`, `insper_boxplot()`,
  `insper_violin()`, `insper_histogram()`, `insper_density()`,
  `insper_heatmap()`.
* Utility functions: `save_insper_plot()`, `format_num_br()`.
* Six bundled datasets for examples: `fossil_fuel`, `macro_series`,
  `macro_series_long`, `rec_buslines`, `rec_passengers`, `spo_metro`.
