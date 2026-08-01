# Tests for get_insper_colors() (internal) ----

test_that("get_insper_colors returns all colors when no args", {
  cols <- insperplot:::get_insper_colors()
  expect_type(cols, "character")
  expect_true(length(cols) > 0)
})

test_that("get_insper_colors extracts specific colors by name", {
  red <- insperplot:::get_insper_colors("vermelho")
  expect_length(red, 1)
  expect_equal(unname(red), "#E50505")

  both <- insperplot:::get_insper_colors("vermelho", "turquesa_3")
  expect_length(both, 2)
  expect_named(both, c("vermelho", "turquesa_3"))
})

test_that("get_insper_colors errors on unknown names", {
  expect_error(insperplot:::get_insper_colors("notacolor"), "not found")
})


# Tests for insper_pal() (internal, used by scales) ----

test_that("insper_pal returns valid hex palette", {
  pal <- insperplot:::insper_pal("main")
  expect_type(pal, "character")
  expect_true(all(grepl("^#", pal)))
  expect_true(length(pal) > 0)
})

test_that("insper_pal validates palette names", {
  expect_error(insperplot:::insper_pal("invalid_palette"), "not found")
})

test_that("insper_pal reverse parameter works", {
  pal_normal <- insperplot:::insper_pal("vermelho")
  pal_reverse <- insperplot:::insper_pal("vermelho", reverse = TRUE)
  expect_equal(pal_normal, rev(pal_reverse))
})

test_that("insper_pal continuous type interpolates colors", {
  pal <- insperplot:::insper_pal("vermelho", n = 10, type = "continuous")
  expect_length(pal, 10)
  expect_true(all(grepl("^#", pal)))
})

test_that("insper_pal interpolates when n exceeds palette size", {
  pal <- insperplot:::insper_pal("vermelho", n = 20, type = "discrete")
  expect_length(pal, 20)
  expect_true(all(grepl("^#[0-9A-F]{6}$", pal, ignore.case = TRUE)))
})

test_that("insper_pal n=NULL returns full palette", {
  pal1 <- insperplot:::insper_pal("main")
  pal2 <- insperplot:::insper_pal("main", n = NULL)
  expect_equal(pal1, pal2)
})


# Tests for insper_palette() ----

test_that("insper_palette returns insper_palette class", {
  pal <- insper_palette("main")
  expect_s3_class(pal, "insper_palette")
  expect_s3_class(pal, "character")
})

test_that("insper_palette is a character vector", {
  pal <- insper_palette("vermelho")
  expect_true(is.character(pal))
  expect_true(all(grepl("^#", pal)))
})

test_that("insper_palette n parameter subsets colors", {
  pal <- insper_palette("vermelho", n = 3)
  expect_length(pal, 3)
})

test_that("insper_palette reverse parameter works", {
  normal <- insper_palette("vermelho")
  reversed <- insper_palette("vermelho", reverse = TRUE)
  expect_equal(as.character(normal), rev(as.character(reversed)))
})

test_that("insper_palette interpolates when n exceeds palette size", {
  pal <- insper_palette("vermelho", n = 20)
  expect_length(pal, 20)
  expect_true(all(grepl("^#[0-9A-F]{6}$", pal, ignore.case = TRUE)))
})

test_that("insper_palette errors on unknown palette", {
  expect_error(insper_palette("not_a_palette"), "not found")
})

test_that("as.character strips insper_palette class", {
  pal <- insper_palette("main")
  plain <- as.character(pal)
  expect_type(plain, "character")
  expect_false(inherits(plain, "insper_palette"))
})

test_that("insper_palette print method returns a ggplot invisibly", {
  skip_if_not_installed("ggplot2")
  pal <- insper_palette("main")
  # Capture print output — should not error
  expect_no_error(capture.output(print(pal)))
})

test_that("insper_palette works with all named palettes", {
  palettes <- names(insperplot:::insper_palettes)
  for (p in palettes) {
    expect_s3_class(insper_palette(p), "insper_palette")
  }
})


# Tests for the colorblind fallback palette ----

test_that("colorblind palette is the 8-color Okabe-Ito set", {
  pal <- insper_palette("colorblind")
  expect_length(pal, 8)
  expect_true(all(vapply(as.character(pal), is_valid_color, logical(1))))
  # Okabe-Ito without its leading black.
  expect_equal(
    as.character(pal),
    unname(grDevices::palette.colors(palette = "Okabe-Ito")[-1])
  )
})

test_that("no palette is named categorical_*", {
  expect_false(any(grepl(
    "^categorical_",
    names(insperplot:::insper_palettes)
  )))
})


# Tests for the Insper Cidades sub-brand palettes ----

# Official Cidades tokens, from the sub-brand application manual (June 2026).
cidades_tokens <- c(
  folhagem = "#019881",
  solar = "#FFA701",
  asfalto = "#7F1582",
  tijolo = "#FF4B01"
)

# CIELAB lightness, computed inline to avoid a farver dependency in tests.
lab_lightness <- function(hex) {
  rgb <- grDevices::col2rgb(hex) / 255
  lin <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  y <- 0.2126 * lin[1, ] + 0.7152 * lin[2, ] + 0.0722 * lin[3, ]
  ifelse(y > 0.008856, 116 * y^(1 / 3) - 16, 903.3 * y)
}

test_that("cidades palettes exist with the expected sizes", {
  expect_length(insper_palette("cidades"), 4)
  for (h in names(cidades_tokens)) {
    expect_length(insper_palette(paste0("cidades_", h)), 7)
  }
  expect_length(insper_palette("cidades_folhagem_asfalto"), 5)
  expect_length(insper_palette("cidades_folhagem_tijolo"), 5)
})

test_that("cidades qualitative palette is exactly the four official tokens", {
  expect_equal(
    as.character(insper_palette("cidades")),
    unname(cidades_tokens)
  )
})

test_that("each cidades ramp contains its official color at position 4", {
  # Lab interpolation rounds endpoints by a bit, so ramp_from_base() pins the
  # midpoint. Without that pin folhagem comes back as #009880, not #019881.
  for (h in names(cidades_tokens)) {
    pal <- as.character(insper_palette(paste0("cidades_", h)))
    expect_equal(pal[4], unname(cidades_tokens[[h]]))
  }
})

test_that("cidades sequential ramps decrease monotonically in lightness", {
  for (h in names(cidades_tokens)) {
    pal <- as.character(insper_palette(paste0("cidades_", h)))
    expect_true(all(diff(lab_lightness(pal)) < 0))
  }
})

test_that("cidades diverging palettes share the neutral midpoint", {
  for (p in c("cidades_folhagem_asfalto", "cidades_folhagem_tijolo")) {
    expect_equal(as.character(insper_palette(p))[3], "#F4F4F2")
  }
})

test_that("cidades palette shares no color with the institutional palettes", {
  # Structural guard for the do-not-mix rule: if a Cidades token ever collides
  # exactly with an institutional one, the two families stop being separable.
  institutional <- unique(unlist(
    insperplot:::insper_palettes[c("main", "muted")]
  ))
  expect_length(intersect(unname(cidades_tokens), institutional), 0)
})

test_that("cidades tokens are available as individual colors", {
  for (h in names(cidades_tokens)) {
    expect_equal(unname(get_insper_colors(h)), unname(cidades_tokens[[h]]))
  }
})


# Tests for retired categorical_* palette names ----

test_that("retired categorical_* names warn", {
  withr::local_options(lifecycle_verbosity = "warning")

  expect_warning(insper_palette("categorical_ito"), "deprecated")
  expect_warning(insper_palette("categorical_tab"), "deprecated")
  expect_warning(insper_palette("categorical_set"), "deprecated")
})

test_that("retired categorical_* names resolve to their replacements", {
  withr::local_options(lifecycle_verbosity = "quiet")

  expect_equal(
    as.character(insper_palette("categorical_ito")),
    as.character(insper_palette("colorblind"))
  )
  expect_equal(
    as.character(insper_palette("categorical_tab")),
    as.character(insper_palette("main"))
  )
  expect_equal(
    as.character(insper_palette("categorical_set")),
    as.character(insper_palette("main"))
  )
})

test_that("retired categorical_* names explain why they went away", {
  withr::local_options(lifecycle_verbosity = "warning")

  expect_warning(insper_palette("categorical_set"), "not colorblind-safe")
  expect_warning(insper_palette("categorical_ito"), "Okabe-Ito")
})


# Tests for palette metadata integrity ----
#
# `palette_metadata()` is four hand-maintained parallel vectors that can drift
# out of sync with `insper_palettes`. These guard against that.

test_that("palette_metadata covers exactly the defined palettes", {
  meta <- insperplot:::palette_metadata()
  expect_setequal(meta$name, names(insperplot:::insper_palettes))
  expect_false(anyDuplicated(meta$name) > 0)
})

test_that("palette_metadata n_colors matches the actual palettes", {
  meta <- insperplot:::palette_metadata()
  actual <- lengths(insperplot:::insper_palettes[meta$name])
  expect_equal(meta$n_colors, unname(actual))
})


# Tests for show_insper_palettes() ----

test_that("show_insper_palettes returns metadata data frame invisibly", {
  skip_if_not_installed("ggplot2")
  result <- show_insper_palettes()
  expect_s3_class(result, "data.frame")
  expect_named(result, c("name", "type", "n_colors", "recommended_use"))
})

test_that("show_insper_palettes type filter works", {
  skip_if_not_installed("ggplot2")
  seq_meta <- show_insper_palettes("sequential")
  expect_true(all(seq_meta$type == "sequential"))

  div_meta <- show_insper_palettes("diverging")
  expect_true(all(div_meta$type == "diverging"))
})

test_that("show_insper_palettes errors on invalid type", {
  expect_error(show_insper_palettes("invalid"), "should be one of")
})
