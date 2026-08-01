## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: macOS (darwin) R 4.5.1
* GitHub Actions:
  - macOS-latest (release)
  - windows-latest (release)
  - ubuntu-latest (devel)
  - ubuntu-latest (release)
  - ubuntu-latest (oldrel-1)

## Downstream dependencies

There are currently no downstream dependencies for this package.

## URL notes

* `urlchecker::url_check()` reports a 404 for
  `https://ourworldindata.org/grapher/global-fossil-fuel-consumption`. The URL
  is valid and returns 200 in a browser and via `curl` — the server responds
  differently to the checker's request.

## Additional notes

* This package provides ggplot2 themes and color palettes based on Insper
  Instituto de Ensino e Pesquisa's visual identity. Insper is listed as
  copyright holder (`cph`) in `Authors@R`.
* This release removes three bundled palettes (`categorical_ito`,
  `categorical_tab`, `categorical_set`) that were not derived from the Insper
  brand — they were verbatim copies of `grDevices::palette.colors()` sets. Two
  of them were labelled colorblind-safe, which is not accurate for either. The
  Okabe-Ito set is retained under the clearer name `colorblind`. All three old
  names are soft-deprecated: they still resolve, with a `lifecycle` deprecation
  warning explaining the change, so no reverse dependencies break.
* This release also adds seven palettes for the Insper Cidades sub-brand, all
  prefixed `cidades`. They are opt-in — no scale or plot function defaults to
  them.
