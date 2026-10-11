# Refresh the local 2020 IBGE state boundaries used by the choropleth.
states <- geobr::read_state(
  year = 2020,
  simplified = TRUE,
  showProgress = FALSE,
  verbose = FALSE
)
stopifnot(nrow(states) == 27)

states <- states |>
  sf::st_transform(5880) |>
  sf::st_simplify(dTolerance = 15000)

dir.create("data", showWarnings = FALSE)
saveRDS(
  states[, c("abbrev_state", "name_state", "geometry")],
  "data/brazil-states.rds"
)
