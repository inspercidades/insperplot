# Test Helpers for Font Availability

#' Skip test if Insper fonts are not registered
#'
#' Bundled fonts are registered on package load, so this should rarely skip.
#' Guards against edge cases in minimal CI environments.
skip_if_no_fonts <- function() {
  all_fonts <- unique(c(
    systemfonts::registry_fonts()$family,
    systemfonts::system_fonts()$family
  ))

  if (!"Inter" %in% all_fonts) {
    testthat::skip("Bundled Insper fonts not registered")
  }
}

#' Skip test if ragg device is not available
#'
#' Visual tests may render differently with different graphics devices.
#' This helper skips tests when ragg is not installed.
skip_if_no_ragg <- function() {
  if (!requireNamespace("ragg", quietly = TRUE)) {
    testthat::skip("ragg package not available")
  }
}
