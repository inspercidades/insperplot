# insperplot 0.3.0

## Palette cleanup (breaking changes)

Every palette bundled with insperplot is now built from the Insper brand kit,
with one deliberate and clearly labelled exception. The three `categorical_*`
palettes were not Insper palettes at all — they were verbatim copies of
`grDevices::palette.colors()` sets — and shipping them under the Insper name
made it possible to build an off-brand chart while believing it was compliant.

* **`categorical_ito` renamed to `colorblind`.** Same colors (the Okabe-Ito
  palette, minus its leading black). The new name states what the palette is
  for. It remains the one bundled palette that is *not* derived from Insper
  tokens: it exists as an accessibility fallback for when the brand hues in
  `main` cannot be told apart by colorblind readers.

* **`categorical_tab` and `categorical_set` removed.** These were Tableau 10 and
  ColorBrewer Set1. Both were grouped under a source comment describing them as
  colorblind-safe, which is not true of either — Set1's red (`#E41A1C`) and
  green (`#4DAF4A`) are hard to distinguish under deuteranopia, and its
  `#FFFF33` yellow is nearly invisible on white. Neither added anything a user
  could not get from base R directly. Use `colorblind` if you need an accessible
  categorical set, or `grDevices::palette.colors()` if you specifically want
  Tableau or ColorBrewer colors.

  | Old palette       | New palette  |
  | ----------------- | ------------ |
  | `categorical_ito` | `colorblind` |
  | `categorical_tab` | `main`       |
  | `categorical_set` | `main`       |

  All three old names still resolve but emit a deprecation warning explaining
  the change, and will be removed in a future release.

## New: Insper Cidades palettes

Seven palettes for the Insper Cidades sub-brand (Centro de Estudos das Cidades —
Laboratório Arq.Futuro), built from its own application manual (June 2026) rather
than the institutional brand kit. All are opt-in — no scale or plot function
defaults to them.

* **`cidades`** — the four sub-brand colors as a qualitative palette: `folhagem`,
  `solar`, `asfalto`, `tijolo`. The manual prints the green as "Fohagem"; it
  ships here as `folhagem`, the correct Portuguese spelling.

* **`cidades_folhagem`, `cidades_solar`, `cidades_asfalto`, `cidades_tijolo`** —
  seven-step sequential ramps. The manual ships no tints or shades, so these are
  interpolated in CIELAB with the official color pinned at position 4.

* **`cidades_folhagem_asfalto`** (preferred) and **`cidades_folhagem_tijolo`** —
  diverging palettes sharing the same `#F4F4F2` midpoint as the institutional
  four. Prefer the asfalto pairing on screen: it has the widest colorblind
  separation of any diverging palette in the package. The tijolo pairing has
  better lightness symmetry for greyscale but pairs green against orange-red.

* The four colors are also available individually via `get_insper_colors()`, and
  appear in the `insper_color_reference` dataset under `hierarquia = "Cidades"`
  (now 43 rows, was 39). Their `acessibilidade` is `NA` — the Cidades manual has
  no accessibility page.

**Do not mix Cidades and institutional palettes in one chart.** The families sit
close together in CIELAB — `asfalto` is 6.6 ΔE from `roxo`, `solar` 8.8 ΔE from
`laranja` — close enough that a chart using both reads as a rendering error. The
new *Insper Cidades* section of the design-guide vignette covers this, along with
computed text-contrast guidance and when to pick each diverging palette.

## Documentation

* The `Accessibility` section of the *How to follow Insper's design guide*
  vignette is no longer a stub. It now explains why `main` is difficult under
  color vision deficiency, when to reach for `colorblind`, and how to use the
  brand guide's own text-contrast rules via the `insper_color_reference`
  dataset.

* The vignette's `Colors` section now documents palette provenance — which
  palettes are verbatim brand tokens, and which are derived (and how) — and
  explains the worked example that builds a categorical set out of the
  sequential ramps.

* `?insper_palette` now states which palettes are brand-derived and which is
  not.

* The package-level help topic (`?insperplot`) is back, generated from
  `DESCRIPTION` so it cannot drift out of date.

## Bug fixes

* The deprecation warnings for the `grays` and `diverging` palettes cited
  version 0.3.0. They were renamed in 0.2.0, which is what NEWS.md has always
  said, and the warnings now agree.

* Package URLs were updated for the GitHub organisation rename from
  `portalcidados` to `inspercidades`. The old documentation site no longer
  resolves.

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
  | `grays`                    | `cinza`      |
  | `diverging`                | `vermelho_turquesa` |

* **New palettes:** `muted` (softer categorical); per-family sequential ramps
  `vermelho`, `turquesa`, `verde`, `amarelo`, `laranja`, `rosa`, `roxo`,
  `azul`; and four diverging palettes `diverging` (= `vermelho_turquesa`),
  `roxo_verde`, `laranja_roxo`, and `rosa_verde`. The `azul` sequential palette
  is anchored on `#0E171D`, the Educação Executiva / Pós-Graduação segment
  color from the brand guide.

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
* New `theme_insper_doc()`: a variant of `theme_insper()` with a smaller 10 pt
  base size, sized for figures inserted into Word documents and other print
  reports.
* New `insper_color_reference` dataset: a one-row-per-swatch lookup table of
  every official Insper brand color (Pantone, RGB, and hex), with a companion
  "Color Reference Table" article on the package website. Includes an
  `acessibilidade` column recording which text/logo color the brand guide
  permits on each background ("branco", "preto", or "ambos").

## Bug fixes

* Plot functions no longer warn that `palette` is ignored when a static color is used with the default palette. They still warn when a static color is combined with an explicitly supplied `palette`.
* `theme_insper()` now actually applies `base_size`. Previously the internal
  theme construction replaced the root `text` element with a relative size,
  so all text rendered at ggplot2's 11 pt default regardless of the
  `base_size` argument.
* `insper_palette()` and `insper_pal()` now interpolate colors smoothly via
  `colorRampPalette()` in CIELAB space when `n` exceeds the palette size,
  instead of recycling colors with a warning. This produces perceptually
  meaningful results, especially for diverging palettes like `roxo_verde`.
* `insper_heatmap()` defaults to `palette = "vermelho_turquesa"` (was
  `"diverging"`), matching the renamed palette.

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
