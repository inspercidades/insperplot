#' Save Insper Plot
#'
#' Wraps \code{\link[ggplot2]{ggsave}} with defaults for Insper-branded output:
#' dimensions in centimeters, a golden-ratio aspect, and the ragg device for
#' PNG files.
#'
#' @param plot ggplot object
#' @param filename File name
#' @param width Plot width, in \code{unit}. Derived from \code{height} and
#'   \code{asp_ratio} when not supplied.
#' @param height Plot height, in \code{unit}. Default is 8.
#' @param dpi Resolution
#' @param asp_ratio Aspect ratio (width / height). Default is the golden ratio (1.618).
#'   Used only when \code{width} is not supplied directly.
#' @param unit Units for \code{width} and \code{height}. Default \code{"cm"}.
#'   Passed to \code{\link[ggplot2]{ggsave}}.
#' @param device Graphics device to use. If NULL (default), uses
#'   \code{ragg::agg_png()} for PNG files when ragg is installed, otherwise the
#'   ggplot2 default. Pass a device function to override.
#' @param ... Additional arguments passed to ggsave
#'
#' @return The file path of the saved plot (invisibly), as returned by
#'   \code{\link[ggplot2]{ggsave}}.
#'
#' @examples
#' \dontrun{
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
#'   ggplot2::geom_point() +
#'   theme_insper()
#' save_insper_plot(p, tempfile(fileext = ".png"))
#' }
#'
#' @family utilities
#' @seealso \code{\link[ggplot2]{ggsave}}
#' @export
save_insper_plot <- function(
  plot,
  filename,
  asp_ratio = 1.618,
  width = height * asp_ratio,
  height = 8,
  dpi = 300,
  device = NULL,
  unit = "cm",
  ...
) {
  # Validate that plot is a ggplot object
  if (!ggplot2::is_ggplot(plot)) {
    cli::cli_abort(c(
      "{.arg plot} must be a ggplot object",
      "x" = "You supplied an object of class {.cls {class(plot)}}",
      "i" = "Create a plot using ggplot2 or insperplot functions first"
    ))
  }

  # Auto-detect ragg for PNG files if device not specified
  if (is.null(device) && grepl("\\.png$", filename, ignore.case = TRUE)) {
    if (requireNamespace("ragg", quietly = TRUE)) {
      device <- ragg::agg_png
      cli::cli_inform("Using {.pkg ragg} device for high-quality output.")
    }
  }

  out <- ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    device = device,
    bg = "white",
    unit = unit,
    ...
  )

  cli::cli_inform("Plot saved: {.file {filename}}")

  invisible(out)
}

#' Format Brazilian Numbers
#'
#' Format numbers in Brazilian style with decimal comma and thousand separator.
#' Supports currency and percentage formatting.
#'
#' @param x Numeric vector
#' @param digits Number of decimal places (default 0)
#' @param percent Logical. If TRUE, formats as percentage (multiplies by 100, adds \% suffix)
#' @param currency Logical. If TRUE, formats as Brazilian Real currency
#' @param ... Additional arguments passed to \code{\link[scales]{number}}
#' @return Formatted character vector
#' @family utilities
#' @export
#' @examples
#' # Basic number formatting
#' format_num_br(1234.56, digits = 2)
#'
#' # Currency formatting
#' format_num_br(1234.56, currency = TRUE, digits = 2)
#'
#' # Percentage formatting
#' format_num_br(0.1234, percent = TRUE, digits = 1)
#' format_num_br(0.1234, percent = TRUE, digits = 2)
format_num_br <- function(
  x,
  digits = 0,
  percent = FALSE,
  currency = FALSE,
  ...
) {
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be numeric")
  }
  if (percent) {
    return(scales::number(
      x * 100,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      suffix = "%",
      ...
    ))
  }

  if (currency) {
    return(scales::number(
      x,
      accuracy = 10^(-digits),
      big.mark = ".",
      decimal.mark = ",",
      prefix = "R$ ",
      ...
    ))
  }

  scales::number(
    x,
    accuracy = 10^(-digits),
    big.mark = ".",
    decimal.mark = ",",
    ...
  )
}


#' Check if string is a valid color
#'
#' Validates hex colors and named colors recognized by R's graphics device.
#' Used internally by smart detection functions to distinguish between
#' static color strings and column names.
#'
#' @param x Character vector of length 1
#'
#' @return Logical. TRUE if x is a valid color specification, FALSE otherwise.
#' @keywords internal
#' @examples
#' \dontrun{
#' is_valid_color("blue")         # TRUE
#' is_valid_color("#FF0000")      # TRUE
#' is_valid_color("#FF0000FF")    # TRUE (with alpha)
#' is_valid_color("bleu")         # FALSE
#' is_valid_color("Species")      # FALSE
#' }
is_valid_color <- function(x) {
  if (!is.character(x) || length(x) != 1) {
    return(FALSE)
  }

  # Check hex color pattern (#RGB, #RRGGBB, #RRGGBBAA)
  # Must check hex BEFORE col2rgb because col2rgb is too permissive
  if (grepl("^#", x)) {
    # For hex colors, only accept standard formats
    return(grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$", x))
  }

  # Check if grDevices recognizes it as a named color
  tryCatch(
    {
      grDevices::col2rgb(x)
      return(TRUE)
    },
    error = function(e) {
      return(FALSE)
    }
  )
}

#' Detect if aesthetic parameter is static color or variable mapping
#'
#' Determines whether a user-provided aesthetic parameter (color/fill) is a
#' static color string ("blue", "#FF0000") or a variable mapping (column name
#' or expression), so a plot function can accept both forms in one argument.
#'
#' @param quo Quosure from rlang::enquo()
#' @param param_name Character. Parameter name for error messages (e.g., "color", "fill")
#' @param data Data frame to evaluate variable in (optional). If provided, enables
#'   detection of continuous vs discrete variables.
#'
#' @return List with:
#'   \itemize{
#'     \item type: "missing", "static_color", or "variable_mapping"
#'     \item value: The static color value (if type = "static_color")
#'     \item is_continuous: Logical (if type = "variable_mapping" and data provided)
#'   }
#'
#' @keywords internal
#' @examples
#' \dontrun{
#' # In a function context:
#' my_plot <- function(data, x, y, color = NULL) {
#'   color_quo <- rlang::enquo(color)
#'   color_type <- detect_aesthetic_type(color_quo, "color", data)
#'
#'   if (color_type$type == "static_color") {
#'     # Use static color
#'     geom_point(color = color_type$value)
#'   } else if (color_type$type == "variable_mapping") {
#'     # Use aes() mapping
#'     geom_point(aes(color = {{color}}))
#'   }
#' }
#' }
detect_aesthetic_type <- function(quo, param_name = "parameter", data = NULL) {
  # Check if parameter was not provided
  if (rlang::quo_is_null(quo)) {
    return(list(type = "missing"))
  }

  expr <- rlang::quo_get_expr(quo)

  # Check if it's a string literal (static color)
  if (is.character(expr) && length(expr) == 1) {
    if (is_valid_color(expr)) {
      return(list(type = "static_color", value = expr))
    } else {
      cli::cli_abort(c(
        "{.arg {param_name}} = {.val {expr}} is not a valid color",
        "i" = "Use a bare column name for variable mapping: {.code {param_name} = column_name}",
        "i" = "Or use a valid color name/hex code: {.code {param_name} = \"blue\"}",
        "i" = "See {.code colors()} for valid color names"
      ))
    }
  }

  # It's a variable mapping (symbol or expression)
  # Detect if continuous or discrete
  if (!is.null(data)) {
    # Try to evaluate in data context to detect variable type
    tryCatch(
      {
        var_vals <- rlang::eval_tidy(quo, rlang::as_data_mask(data))
        is_continuous <- is.numeric(var_vals) && !is.factor(var_vals)
      },
      error = function(e) {
        # If evaluation fails, default to discrete
        # This can happen with complex expressions
        is_continuous <- FALSE
      }
    )
  } else {
    is_continuous <- FALSE # Can't determine without data
  }

  return(list(
    type = "variable_mapping",
    is_continuous = is_continuous
  ))
}

#' Warn if palette specified with static aesthetic
#'
#' Warns when a palette is supplied alongside a static color. The palette
#' argument applies to variable mappings (discrete or continuous scales) only,
#' so it has no effect on a static color and would otherwise be dropped
#' silently.
#'
#' @param aesthetic_type List returned from detect_aesthetic_type()
#' @param palette Character or NULL. The palette argument value
#' @param param_name Character. Name of the aesthetic parameter ("color" or "fill")
#'
#' @return NULL (called for side effect of warning)
#' @keywords internal
#' @examples
#' \dontrun{
#' # This will warn
#' warn_palette_ignored(
#'   list(type = "static_color", value = "blue"),
#'   palette = "main",
#'   param_name = "fill"
#' )
#' # Warning: `palette` argument ignored when `fill` is a static color
#'
#' # This will NOT warn (palette is used)
#' warn_palette_ignored(
#'   list(type = "variable_mapping"),
#'   palette = "main",
#'   param_name = "fill"
#' )
#' }
warn_palette_ignored <- function(aesthetic_type, palette, param_name) {
  if (!is.null(palette) && aesthetic_type$type == "static_color") {
    cli::cli_warn(c(
      "{.arg palette} argument ignored when {.arg {param_name}} is a static color",
      "i" = "The {.arg palette} parameter only applies when {.arg {param_name}} is a variable mapping",
      "i" = "Remove {.code palette = {.val {palette}}} or use a variable for {.arg {param_name}}"
    ))
  }
}

#' Check Whether Insper Fonts Are Available
#'
#' Returns \code{TRUE} when the session is interactive. Fonts are always
#' available because they are bundled with the package and registered
#' automatically on load. The interactive-only guard prevents examples from
#' running during \code{R CMD check}, where the graphics device may not
#' support custom fonts.
#'
#' @return Logical scalar.
#'
#' @examples
#' has_insper_fonts()
#'
#' @family utilities
#' @keywords internal
#' @export
has_insper_fonts <- function() {
  interactive()
}

#' Calculate Relative Luminance of a Color
#'
#' @param hex_color Character. Hex color code (e.g., "#E50505")
#' @return Numeric. Relative luminance value between 0 (black) and 1 (white)
#' @noRd
#' @keywords internal
calculate_luminance <- function(hex_color) {
  # Convert hex to RGB
  rgb_vals <- grDevices::col2rgb(hex_color)[, 1] / 255

  # Apply sRGB gamma correction
  rgb_linear <- ifelse(
    rgb_vals <= 0.03928,
    rgb_vals / 12.92,
    ((rgb_vals + 0.055) / 1.055)^2.4
  )

  # Calculate relative luminance (ITU-R BT.709)
  luminance <- 0.2126 *
    rgb_linear[1] +
    0.7152 * rgb_linear[2] +
    0.0722 * rgb_linear[3]

  return(unname(luminance))
}

#' Choose Contrasting Text Color for Background
#'
#' Picks the text color (dark or light) that provides the higher WCAG contrast
#' ratio against the given background color.
#'
#' @param bg_color Character. Background hex color code
#' @param dark_color Character. Text color for light backgrounds. Default "#2C2C2C"
#' @param light_color Character. Text color for dark backgrounds. Default "white"
#' @return Character. Either dark_color or light_color, whichever provides
#'   higher WCAG contrast ratio against \code{bg_color}
#' @noRd
#' @keywords internal
get_contrast_text_color <- function(
  bg_color,
  dark_color = "#2C2C2C",
  light_color = "white"
) {
  bg_lum <- calculate_luminance(bg_color)
  dark_lum <- calculate_luminance(dark_color)
  light_lum <- 1

  contrast_dark <- (max(bg_lum, dark_lum) + 0.05) /
    (min(bg_lum, dark_lum) + 0.05)
  contrast_light <- (light_lum + 0.05) / (bg_lum + 0.05)

  if (contrast_dark >= contrast_light) {
    dark_color
  } else {
    light_color
  }
}
