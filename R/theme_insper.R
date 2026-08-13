#' Insper Custom ggplot2 Theme
#'
#' A ggplot2 theme built on Insper's brand colors and typography, with
#' arguments for grid lines, borders, and title alignment.
#'
#' @param base_size Numeric. Base font size for all text elements in points.
#'   Default is 12. All other text sizes are calculated relative to this value.
#' @param font_title Character. Font family to use for plot titles and subtitles.
#'   Default is "Georgia" (serif, the documented substitute for Insper's primary
#'   GT Ultra). The theme automatically detects font availability and falls back
#'   to the system "serif" family if Georgia is unavailable.
#' @param font_text Character. Font family to use for all other text elements
#'   (axis labels, legend text, etc.). Default is "Inter" (sans-serif, from
#'   Insper's official template). Falls back to "Arial" then "sans" if unavailable.
#' @param grid Logical. Whether to display major grid lines. If TRUE, shows
#'   light gray grid lines. If FALSE, removes all grid lines. Minor grid lines
#'   are always removed. Default is TRUE.
#' @param border Character. Type of plot border to display. Must be one of:
#'   \itemize{
#'     \item "none" - No border or axis lines (default)
#'     \item "half" - Shows axis lines with ticks but no full border
#'     \item "closed" - Shows a complete rectangular border around the plot area
#'   }
#' @param align Character. Alignment of title and caption. Must be one of:
#'   \itemize{
#'     \item "panel" - Align to the plot panel area (default)
#'     \item "plot" - Align to the entire plot area including margins
#'   }
#' @param ... Additional arguments passed to \code{theme_minimal()}.
#'
#' @return A ggplot2 theme object that can be added to ggplot objects using the
#'   \code{+} operator.
#'
#' @details
#' The theme sets a white plot background, places a horizontal legend at the
#' top with a bold title, removes minor grid lines, and draws remaining
#' elements in Insper brand grays.
#'
#' **Fonts:**
#'
#' Titles use Georgia and body text uses Inter, following Insper's official
#' template. Inter is bundled with the package and registered automatically on
#' load. Georgia is a system font, and the documented substitute for Insper's
#' primary GT Ultra. Where either is unavailable, the theme falls back to the
#' system "serif" and "sans" families.
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' # Default
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper()
#'
#' # Minimal — no grid, clean background
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(grid = FALSE)
#'
#' # Presentation — larger text for slides
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 16, grid = FALSE)
#'
#' # Print / PDF — closed border, smaller text
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_insper(base_size = 11, border = "closed")
#'
#' @family themes
#' @seealso \code{\link[ggplot2]{theme_minimal}}, \code{\link[ggplot2]{theme}}
#' @importFrom ggplot2 element_blank element_line element_rect element_text unit theme theme_minimal rel margin %+replace% theme_sub_axis theme_sub_legend theme_sub_panel theme_sub_plot theme_sub_strip
#' @export
theme_insper <- function(
  base_size = 12,
  font_title = "Georgia",
  font_text = "Inter",
  grid = TRUE,
  border = "none",
  align = "panel",
  ...
) {
  # Input validation ----
  if (!is.logical(grid)) {
    cli::cli_abort("Argument `grid` must be one of `TRUE` or `FALSE`.")
  }

  valid_align <- c("panel", "plot")
  if (!align %in% valid_align) {
    cli::cli_abort(c(
      "{.arg align} must be one of {.val panel} or {.val plot}",
      "x" = "You supplied: {.val {align}}"
    ))
  }

  valid_border <- c("none", "half", "closed")
  if (!any(border %in% valid_border)) {
    cli::cli_abort(
      "Argument `border` must be one of 'none', 'half', or 'closed'."
    )
  }

  # Font detection and fallback ----
  font_title <- detect_font(
    font_title,
    fallback_chain = "serif"
  )
  font_text <- detect_font(
    font_text,
    fallback_chain = c("Arial", "sans")
  )

  # Colors ----
  off_white <- get_insper_colors("white")
  black <- get_insper_colors("black")

  # Conditional grid theme ----
  grid_theme <- if (grid) {
    theme_sub_panel(
      grid.major = element_line(
        linewidth = 0.35,
        color = get_insper_colors("cinza_0")
      )
    )
  } else {
    theme_sub_panel(grid.major = element_blank())
  }

  # Conditional border theme ----
  border_theme <- if (border == "half") {
    theme_sub_axis(
      line = element_line(),
      ticks = element_line(color = get_insper_colors("cinza_4")),
      ticks.length = unit(7, "pt")
    )
  } else if (border == "closed") {
    theme_sub_panel(border = element_rect(color = black, fill = NA)) +
      theme_sub_axis(
        ticks = element_line(color = get_insper_colors("cinza_4")),
        ticks.length = unit(7, "pt")
      )
  } else {
    theme()
  }

  # Build full theme ----
  # Note: `%+replace%` swaps whole elements, so the root `text` element must
  # keep its absolute size. Font family and base_size are passed to
  # theme_minimal() instead of overriding `text` here (which would drop
  # base_size and fall back to ggplot2's 11 pt default).
  full_theme <- theme_sub_panel(grid.minor = element_blank()) +
    theme_sub_plot(
      margin = margin(10, 15, 10, 15),
      title = element_text(
        size = rel(1.4),
        family = font_title,
        color = black,
        hjust = 0,
        margin = margin(b = 5)
      ),
      subtitle = element_text(
        size = rel(0.8),
        family = font_text,
        color = get_insper_colors("cinza_4"),
        hjust = 0,
        margin = margin(t = 3, b = 5)
      ),
      caption = element_text(
        size = rel(0.5),
        color = "gray40",
        hjust = 0,
        margin = margin(t = 3)
      ),
      title.position = align,
      caption.position = align
    ) +
    theme_sub_legend(
      position = "top",
      direction = "horizontal",
      title = element_text(face = "bold")
    ) +
    theme_sub_axis(
      text = element_text(size = rel(0.8), color = "gray10"),
      title = element_text(size = rel(1), color = black)
    ) +
    theme_sub_strip(text = element_text(size = rel(1), face = "bold")) +
    grid_theme +
    border_theme

  # Return final theme ----
  theme_minimal(
    base_size = base_size,
    base_family = font_text,
    paper = off_white,
    ...
  ) %+replace%
    full_theme
}

#' Insper Theme for Word and Print Documents
#'
#' A variant of [theme_insper()] with smaller text, sized for figures inserted
#' into Word documents and other print reports. A typical document figure is
#' about 15 cm (6 in) wide — at that size the default 12 pt base of
#' [theme_insper()] renders noticeably larger than the surrounding body text,
#' so this variant lowers the base to 10 pt.
#'
#' @param base_size Numeric. Base font size in points. Default is 10, sized
#'   for figures placed in text documents. All other text sizes are calculated
#'   relative to this value.
#' @param ... Additional arguments passed to [theme_insper()], such as
#'   \code{grid}, \code{border}, or \code{align}.
#'
#' @return A ggplot2 theme object that can be added to ggplot objects using
#'   the \code{+} operator.
#'
#' @examplesIf has_insper_fonts()
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   labs(title = "Fuel efficiency", x = "Weight (1000 lbs)", y = "MPG")
#'
#' # Smaller text for a figure destined for a Word document
#' p + theme_insper_doc()
#'
#' \dontrun{
#' # Save at document width and insert into Word without rescaling
#' save_insper_plot(p + theme_insper_doc(), "figure.png", width = 15)
#' }
#'
#' @family themes
#' @seealso [theme_insper()]
#' @export
theme_insper_doc <- function(base_size = 10, ...) {
  theme_insper(base_size = base_size, ...)
}


# Helper Functions --------------------------------------------------------

#' Resolve a requested font family against the available families
#'
#' Matches `name` against `available_fonts`, returning the resolved family
#' name or `NULL` if there is no acceptable match. Tries an exact match
#' (case-sensitive, then case-insensitive), then a word-boundary match.
#'
#' The word-boundary step is what makes resolution robust to modern variable
#' fonts, which are frequently registered with an optical-size or variant
#' suffix (e.g. "Inter 18pt", "Inter_18pt", "Helvetica Neue"). It accepts a
#' family where `name` appears as a whole token (at the start or after a
#' separator, and at the end or before a separator), so "Inter" matches
#' "Inter 18pt" but deliberately not "Interstate", "International", or
#' "SignPainter" — false positives the old naive substring match accepted.
#'
#' @param name Character. Requested font family.
#' @param available_fonts Character vector of available family names.
#' @return Character scalar (resolved family) or `NULL`.
#' @keywords internal
#' @noRd
match_font_family <- function(name, available_fonts) {
  if (name %in% available_fonts) {
    return(name)
  }
  lname <- tolower(name)
  lfonts <- tolower(available_fonts)
  exact_ci <- which(lfonts == lname)
  if (length(exact_ci) > 0) {
    return(available_fonts[exact_ci[1]])
  }

  seps <- c(" ", "_", "-")
  boundary_hit <- function(family) {
    starts <- gregexpr(lname, family, fixed = TRUE)[[1]]
    if (starts[1] == -1L) {
      return(FALSE)
    }
    ends <- starts + nchar(lname) - 1L
    before_ok <- starts == 1L |
      substr(family, starts - 1L, starts - 1L) %in% seps
    after_ok <- ends == nchar(family) |
      substr(family, ends + 1L, ends + 1L) %in% seps
    any(before_ok & after_ok)
  }
  hits <- vapply(lfonts, boundary_hit, logical(1))
  matches <- available_fonts[hits]
  if (length(matches) == 0) {
    return(NULL)
  }
  # Deterministic pick: prefer the "18pt" optical size (the default for body
  # text), then the shortest family name, then alphabetical order.
  is_18pt <- grepl("18pt", matches, ignore.case = TRUE)
  matches[order(!is_18pt, nchar(matches), matches)][1]
}

#' @keywords internal
#' @noRd
detect_font <- function(font_name, fallback_chain = "sans") {
  rlang::try_fetch(
    {
      # Check both registered (bundled) and system-installed fonts
      available_fonts <- unique(c(
        systemfonts::registry_fonts()$family,
        systemfonts::system_fonts()$family
      ))

      resolved <- match_font_family(font_name, available_fonts)
      if (!is.null(resolved)) {
        return(resolved)
      }

      for (fallback_font in fallback_chain) {
        if (fallback_font %in% c("serif", "sans", "mono")) {
          return(fallback_font)
        }
        resolved <- match_font_family(fallback_font, available_fonts)
        if (!is.null(resolved)) return(resolved)
      }

      fallback_chain[length(fallback_chain)]
    },
    error = function(cnd) {
      fallback_chain[length(fallback_chain)]
    }
  )
}
