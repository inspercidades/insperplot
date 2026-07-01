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

* `urlchecker::url_check()` reports 403/404 errors for `https://www.insper.edu.br/` and `https://ourworldindata.org/grapher/global-fossil-fuel-consumption`. Both URLs are valid and accessible in a browser — the servers block automated user agents.

## Additional notes

* This is an update from the current CRAN release (0.1.0).
* This release rebuilds the color system for the 2026 Insper brand kit. Palette
  and individual-color names were reorganized; the retired names are
  soft-deprecated (they still resolve, with a `lifecycle` deprecation warning)
  and slated for removal in a future release, so no reverse dependencies break.
* Bundled fonts were reduced to Inter only (EB Garamond and Playfair Display
  were removed), trimming the installed package size.
* This package provides ggplot2 themes and color palettes based on Insper Instituto de Ensino e Pesquisa's visual identity.
* The package includes a disclaimer that it is an unofficial package created by an Insper employee, not an official Insper product.
