#' Brazilian Macroeconomic Time Series
#'
#' Monthly macroeconomic indicators from the Brazilian Central Bank (Banco Central
#' do Brasil), covering economic activity, inflation, industrial production,
#' services, and oil production.
#'
#' @format A data frame with 279 rows and 5 variables:
#' \describe{
#'   \item{date}{Date, first day of the month (YYYY-MM-DD)}
#'   \item{ibcbr_dessaz}{IBC-Br dessazonalizado (Seasonally adjusted Central Bank
#'     Economic Activity Index). Monthly economic activity indicator that serves
#'     as a proxy for GDP, base 2002 = 100}
#'   \item{ipca}{IPCA - Índice de Preços ao Consumidor Amplo (Broad Consumer
#'     Price Index). Monthly inflation rate in percent, official inflation measure
#'     used for monetary policy targeting}
#'   \item{ipi}{IPI - Índice de Produção Industrial (Industrial Production Index).
#'     Measures monthly industrial production, base 2012 = 100}
#'   \item{oil}{Produção de petróleo bruto (Crude oil production). Monthly crude
#'     oil production in thousands of barrels per day}
#' }
#'
#' @details
#' The Brazilian Central Bank publishes these indicators through its Time
#' Series Management System (SGS), under the codes below.
#'
#' \itemize{
#'   \item IPCA: 433
#'   \item IPI: 21859
#'   \item Oil production: 1389
#'   \item IBC-Br (seasonally adjusted): 24364
#' }
#'
#' @source Brazilian Central Bank (Banco Central do Brasil)
#'   \url{https://www3.bcb.gov.br/sgspub/}
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Plot inflation over time using insper_timeseries
#' recent_data <- subset(macro_series, date >= as.Date("2020-01-01"))
#' insper_timeseries(recent_data, x = date, y = ipca) +
#'   labs(
#'     title = "Brazilian Inflation (IPCA)",
#'     subtitle = "Monthly rate in percent (2020-present)",
#'     y = "IPCA (%)"
#'   )
"macro_series"


#' Brazilian Macroeconomic Time Series (Long Format)
#'
#' Long-format version of the \code{\link{macro_series}} dataset, with one row
#' per indicator per date. Faceted and grouped plots take this shape directly.
#'
#' @format A data frame with 1,116 rows and 3 variables:
#' \describe{
#'   \item{date}{Date, first day of the month (YYYY-MM-DD)}
#'   \item{name_series}{Character, name of the macroeconomic indicator.
#'     Values: "ibcbr_dessaz", "ipca", "ipi", "oil"}
#'   \item{value}{Numeric, value of the indicator on that date}
#' }
#'
#' @details
#' Pivoting \code{\link{macro_series}} from wide to long produces this table.
#' The values are the same. See \code{\link{macro_series}} for what each
#' indicator measures and where it comes from.
#'
#' @source Brazilian Central Bank (Banco Central do Brasil)
#'   \url{https://www3.bcb.gov.br/sgspub/}
#'
#' @seealso \code{\link{macro_series}} for the wide-format version
#' @keywords datasets
"macro_series_long"


#' Recife Bus Lines Data
#'
#' Data on bus lines in the Greater Recife metropolitan region from Insper's
#' Observatório Nacional de Mobilidade Sustentável (National Observatory of
#' Sustainable Mobility).
#'
#' @format A data frame with 694 rows and 4 variables:
#' \describe{
#'   \item{abbrev_company}{Character, abbreviated name of the bus company
#'     (e.g., "BOA" for Borborema Imperial Transportes)}
#'   \item{code_line}{Character, unique code identifier for the bus line}
#'   \item{name_company}{Character, full name of the bus company operating
#'     the line}
#'   \item{name_line}{Character, name and route description of the bus line,
#'     typically showing origin and destination points}
#' }
#'
#' @details
#' Reference table of bus lines and their operating companies. It shares the
#' \code{code_line} column with \code{\link{rec_passengers}}. Note that
#' \code{code_line} repeats across rows here, since a line can appear under
#' more than one company.
#'
#' @source Insper - Observatório Nacional de Mobilidade Sustentável
#'   \url{https://dataverse.datascience.insper.edu.br}
#'   DOI: 10.60873/FK2/TLFP8L
#'
#' @seealso \code{\link{rec_passengers}} for related passenger transport data
"rec_buslines"


#' Recife Bus Passengers Data
#'
#' Daily passenger count data for buses in the Greater Recife metropolitan
#' region from Insper's Observatório Nacional de Mobilidade Sustentável
#' (National Observatory of Sustainable Mobility).
#'
#' @format A data frame with 237,852 rows and 6 variables:
#' \describe{
#'   \item{abbrev_company}{Character, abbreviated name of the bus company}
#'   \item{name_company}{Character, full name of the bus company}
#'   \item{code_line}{Character, unique code identifier for the bus line}
#'   \item{name_line}{Character, name and route description of the bus line}
#'   \item{date}{Date, daily observation date (YYYY-MM-DD), from January 2024
#'     to March 2025}
#'   \item{passengers}{Numeric, total number of passengers transported on
#'     that date for the specific line}
#' }
#'
#' @details
#' One row per bus line per day, running from January 2024 to March 2025. The
#' company and route columns repeat the values in \code{\link{rec_buslines}},
#' which shares the \code{code_line} column.
#'
#' @source Insper - Observatório Nacional de Mobilidade Sustentável
#'   \url{https://dataverse.datascience.insper.edu.br}
#'   DOI: 10.60873/FK2/JEYM0J
#'
#' @seealso \code{\link{rec_buslines}} for bus line reference data
"rec_passengers"


#' São Paulo Metro Line 4 Station Data
#'
#' Monthly passenger entry data for stations on Line 4 (Yellow Line) of the São
#' Paulo Metro system.
#'
#' @format A data frame with 817 rows and 4 variables:
#' \describe{
#'   \item{date}{Date, monthly observations (YYYY-MM-DD)}
#'   \item{year}{Year as numeric}
#'   \item{name_station}{Character, name of the metro station. Covers the
#'     eleven stations on Line 4, from São Paulo - Morumbi to Luz}
#'   \item{value}{Numeric, number of passenger entries at the station on that date}
#' }
#'
#' @details
#' Line 4 (Yellow Line) runs from the western neighborhoods of São Paulo to the
#' city center, passing Paulista Avenue. Monthly entries run from January 2018 to
#' July 2024, a window that covers the pandemic drop and the recovery after it.
#'
#' @source São Paulo Metro Company (Companhia do Metropolitano de São Paulo)
"spo_metro"


#' Global Fossil Fuel Consumption
#'
#' Primary energy consumption from fossil fuels (coal, oil, and gas) measured
#' in terawatt-hours (TWh). Data covers global consumption from 1800 to recent years.
#'
#' @format A data frame with 228 rows and 5 variables:
#' \describe{
#'   \item{entity}{Character, name of the country or region (currently "World")}
#'   \item{code}{Character, country/region code (OWID_WRL for World)}
#'   \item{year}{Numeric, year of observation (1800-present)}
#'   \item{fuel}{Ordered factor with 3 levels: Oil, Gas, Coal.
#'     Levels are ordered for logical stacking in plots}
#'   \item{consumption}{Numeric, primary energy consumption in terawatt-hours
#'     (TWh)}
#' }
#'
#' @details
#' Global fossil fuel consumption since the Industrial Revolution, split by
#' fuel. The \code{fuel} factor is ordered Oil, Gas, Coal, which fixes the
#' stacking order in area charts.
#'
#' @source Our World in Data (OWID)
#'   \url{https://ourworldindata.org/grapher/global-fossil-fuel-consumption}
#'   License: CC BY 4.0
#'
#' @seealso \code{\link{insper_area}} for creating area plots with this data
"fossil_fuel"


#' Insper Brand Color Reference Table
#'
#' A flat, "one row per swatch" lookup table of every official Insper brand
#' color: primary, secondary (six hue families, five steps each), and the
#' neutral gray ramp + dark blue used in segment-specific applications.
#'
#' @format A data frame with 43 rows and 8 variables:
#' \describe{
#'   \item{hierarquia}{Character, color hierarchy: "Principais" (Vermelho,
#'     Branco, Preto), "Secundários" (Turquesa, Verde, Amarelo, Laranja, Rosa,
#'     Roxo), "Neutros" (Cinza, Azul), or "Cidades" (the Insper Cidades
#'     sub-brand: Folhagem, Solar, Asfalto, Tijolo)}
#'   \item{familia}{Character, hue family (e.g. "Vermelho", "Verde", "Cinza")}
#'   \item{nome}{Character, lowercase identifier for the specific swatch
#'     (e.g. "vermelho", "verde 0"..."verde 4"). Matches the `_N` suffix used
#'     internally in \code{data-raw/colors_palettes.R}, where `_0` is the
#'     family base and `_1`/`_2` are tints, `_3`/`_4` are shades}
#'   \item{amostra}{Character, hex code of the swatch (mirrors `hex`); in the
#'     companion \code{data-raw/insper_color_reference.xlsx} this column is
#'     rendered as a color-filled cell instead}
#'   \item{pantone}{Character, Pantone spot color reference, or "-" when the
#'     brand guide does not specify one (Branco, Preto, and all four Cidades
#'     colors — the Cidades manual gives CMYK only)}
#'   \item{rgb}{Character, "R, G, B" digital color values as printed in the
#'     brand guide}
#'   \item{hex}{Character, hexadecimal color code, uppercase with leading "#"}
#'   \item{acessibilidade}{Character, which text/logo color the brand guide
#'     permits on this background: "branco" (white only), "preto" (black
#'     only), or "ambos" (both pass). The guide only rules on the family base
#'     colors and neutrals; tints/shades are \code{NA}, as are the Cidades
#'     colors (that manual has no accessibility page). This column records what
#'     a brand guide rules, not what the package computes}
#' }
#'
#' @details
#' Values are transcribed from Insper's 2026 brand guide
#' (`data-raw/refs/insper-guia-de-marca.pdf`) via
#' \code{data-raw/colors_palettes.R}, the package's authoritative source for
#' brand hex codes. The "Neutros" rows (Cinza ramp and Azul) are not part of
#' the guide's main "2.1 Cores" section — they appear in segment-specific
#' pages (Pós-Graduação, Educação Executiva) — but are included here for a
#' complete quick-reference.
#'
#' The "Cidades" rows come from a second document, the Insper Cidades
#' application manual (`data-raw/refs/Manual de Aplicação - Insper Cidades.pdf`,
#' June 2026). Those four colors belong to the Centro de Estudos das Cidades /
#' Laboratório Arq.Futuro sub-brand and are close enough to the institutional
#' hues that the two families should not be mixed in one chart — see
#' \code{\link{insper_palette}}.
#'
#' The \code{acessibilidade} column condenses the guide's accessibility and
#' logo-background pages (white/black text contrast per background). Package
#' plot functions apply the same idea automatically via an internal
#' luminance-based helper when overlaying labels on colored bars.
#'
#' This dataset is a documentation/reference aid. For programmatic access to
#' brand colors in plots, use \code{\link{insper_palette}} or the
#' \code{scale_*_insper_*()} functions instead.
#'
#' @source Insper brand guide (2026) and the Insper Cidades application manual
#'   (June 2026), via \code{data-raw/create_color_reference_table.R}
#'
#' @seealso \code{\link{insper_palette}} for programmatic palette access;
#'   \code{\link{show_insper_palettes}} to preview palettes
#' @examples
#' head(insper_color_reference)
#'
#' # All swatches in the "Verde" family
#' subset(insper_color_reference, familia == "Verde")
"insper_color_reference"
