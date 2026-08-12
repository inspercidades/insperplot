# Package load hooks ----

# Registers the bundled Inter family with systemfonts. Registration is skipped
# when Inter is already installed system-wide: registering over a system font
# shadows it for the whole session, and the user's own copy should win.
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  font_dir <- system.file("fonts", package = "insperplot")
  if (!nzchar(font_dir)) {
    return()
  }

  existing <- unique(c(
    systemfonts::system_fonts()$family,
    systemfonts::registry_fonts()$family
  ))

  if (!"Inter" %in% existing) {
    systemfonts::register_font(
      name = "Inter",
      plain = file.path(font_dir, "inter", "Inter-Regular.ttf"),
      bold = file.path(font_dir, "inter", "Inter-Bold.ttf"),
      italic = file.path(font_dir, "inter", "Inter-Italic.ttf"),
      bolditalic = file.path(font_dir, "inter", "Inter-BoldItalic.ttf")
    )
  }
}
