# Deprecated palette/color names (2026 brand kit migration) --------------------

test_that("deprecated palette names warn and resolve to the new palette", {
  lifecycle::expect_deprecated(insper_palette("reds"))

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(
    as.character(insper_palette("reds")),
    as.character(insper_palette("vermelho"))
  )
  expect_identical(
    as.character(insper_palette("red_teal")),
    as.character(insper_palette("vermelho_turquesa"))
  )
  expect_identical(
    as.character(insper_palette("bright")),
    as.character(insper_palette("main"))
  )
})

test_that("palettes renamed in 0.3.0 warn and resolve to the new palette", {
  lifecycle::expect_deprecated(insper_palette("grays"), "0.3.0")
  lifecycle::expect_deprecated(insper_palette("diverging"), "0.3.0")

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(
    as.character(insper_palette("grays")),
    as.character(insper_palette("cinza"))
  )
  expect_identical(
    as.character(insper_palette("diverging")),
    as.character(insper_palette("vermelho_turquesa"))
  )
})

test_that("deprecated palette names work through insper_pal and scales", {
  lifecycle::expect_deprecated(insperplot:::insper_pal("teals"))

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(
    insperplot:::insper_pal("teals"),
    insperplot:::insper_pal("turquesa")
  )
  expect_s3_class(scale_fill_insper_d(palette = "contrast"), "ScaleDiscrete")
})

test_that("deprecated individual color names warn and resolve", {
  lifecycle::expect_deprecated(get_insper_colors("teals1"))

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_equal(
    unname(get_insper_colors("teals1")),
    unname(get_insper_colors("turquesa_3"))
  )
  expect_equal(
    unname(get_insper_colors("reds1")),
    unname(get_insper_colors("vermelho"))
  )
})

test_that("current palette and color names do not warn", {
  expect_no_warning(insper_palette("main"))
  expect_no_warning(insper_palette("turquesa"))
  expect_no_warning(get_insper_colors("vermelho"))
  expect_no_warning(get_insper_colors("cinza_0"))
})
