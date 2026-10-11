pkgload::load_all("../..", quiet = TRUE)
source("plots.R")

shiny::addResourcePath(
  "insper-fonts",
  normalizePath("../../inst/fonts/inter")
)

map <- readRDS("data/brazil-states.rds")
metadata <- insperplot:::palette_metadata()
palette_choices <- split(
  metadata$name,
  factor(metadata$type, levels = c("qualitative", "sequential", "diverging"))
)
initial_colors <- paste(insperplot::insper_palette("main"), collapse = "\n")

plot_tab <- function(title, id) {
  return(bslib::nav_panel(
    title,
    shiny::plotOutput(id, height = "320px")
  ))
}

plot_card <- function(title, id) {
  return(bslib::card(
    full_screen = TRUE,
    bslib::card_header(title),
    shiny::plotOutput(id, height = "320px")
  ))
}

ui <- bslib::page_sidebar(
  title = "Palette lab",
  window_title = "Palette lab · insperplot",
  fillable = FALSE,
  theme = bslib::bs_theme(
    version = 5,
    bg = "#F3F6F7",
    fg = "#0E171D",
    primary = "#E50505",
    base_font = "Inter",
    heading_font = "Inter"
  ),
  sidebar = bslib::sidebar(
    width = 310,
    title = "Palette",
    shiny::selectInput("palette", "Package preset", choices = palette_choices),
    shiny::textAreaInput(
      "colors",
      "Hex colors, one per line",
      value = initial_colors,
      rows = 8,
      resize = "vertical"
    ),
    shiny::div(
      class = "palette-actions",
      shiny::actionButton("add_color", "Add color"),
      shiny::actionButton("remove_color", "Remove last"),
      shiny::actionButton("reset_colors", "Reset")
    ),
    shiny::uiOutput("swatches"),
    shiny::radioButtons(
      "canvas",
      "Canvas",
      choices = c("White" = "#FFFFFF", "Dark" = "#243139"),
      selected = "#FFFFFF",
      inline = TRUE
    )
  ),
  shiny::tags$head(shiny::tags$link(rel = "stylesheet", href = "style.css")),
  bslib::layout_column_wrap(
    width = "430px",
    fill = FALSE,
    bslib::navset_card_underline(
      title = "Bars",
      full_screen = TRUE,
      plot_tab("Horizontal", "bar_horizontal"),
      plot_tab("Stacked", "bar_stacked")
    ),
    bslib::navset_card_underline(
      title = "Lines",
      full_screen = TRUE,
      plot_tab("Series", "line_series"),
      plot_tab("Small multiples", "line_small_multiples")
    ),
    bslib::navset_card_underline(
      title = "Scatter",
      full_screen = TRUE,
      plot_tab("Groups", "scatter_groups"),
      plot_tab("Bubble", "scatter_bubble")
    ),
    plot_card("Histogram", "histogram"),
    plot_card("Boxplot", "boxplot"),
    plot_card("Heatmap", "heatmap"),
    plot_card("Donut", "donut"),
    plot_card("Choropleth", "choropleth")
  )
)

server <- function(input, output, session) {
  colors <- shiny::reactive({
    entries <- unlist(strsplit(input$colors, "[[:space:],;]+"))
    entries <- entries[nzchar(entries)]
    shiny::validate(
      shiny::need(length(entries) >= 2, "Enter at least two hex colors."),
      shiny::need(
        all(grepl("^#[0-9A-Fa-f]{6}$", entries)),
        "Use six-digit hex colors such as #3ACC9F."
      )
    )
    return(toupper(entries))
  })

  background <- shiny::reactive(input$canvas)

  shiny::observeEvent(input$palette, {
    preset <- insperplot::insper_palette(input$palette)
    shiny::updateTextAreaInput(
      session,
      "colors",
      value = paste(preset, collapse = "\n")
    )
  })

  shiny::observeEvent(input$reset_colors, {
    preset <- insperplot::insper_palette(input$palette)
    shiny::updateTextAreaInput(
      session,
      "colors",
      value = paste(preset, collapse = "\n")
    )
  })

  shiny::observeEvent(input$add_color, {
    entries <- trimws(unlist(strsplit(input$colors, "[[:space:],;]+")))
    entries <- entries[nzchar(entries)]
    shiny::updateTextAreaInput(
      session,
      "colors",
      value = paste(c(entries, "#4E7890"), collapse = "\n")
    )
  })

  shiny::observeEvent(input$remove_color, {
    entries <- trimws(unlist(strsplit(input$colors, "[[:space:],;]+")))
    entries <- entries[nzchar(entries)]
    if (length(entries) > 2) {
      shiny::updateTextAreaInput(
        session,
        "colors",
        value = paste(head(entries, -1), collapse = "\n")
      )
    }
  })

  output$swatches <- shiny::renderUI({
    shiny::div(
      class = "swatches",
      lapply(colors(), function(color) {
        shiny::tags$span(
          class = "swatch",
          style = paste0("background-color: ", color),
          title = color,
          `aria-label` = color
        )
      })
    )
  })

  output$bar_horizontal <- shiny::renderPlot(
    {
      make_bar_plot(colors(), "horizontal", background())
    },
    res = 110,
    alt = "Horizontal bars for five sample categories"
  )
  output$bar_stacked <- shiny::renderPlot(
    {
      make_bar_plot(colors(), "stacked", background())
    },
    res = 110,
    alt = "Stacked shares for four categories over six months"
  )
  output$line_series <- shiny::renderPlot(
    {
      make_line_plot(colors(), "series", background())
    },
    res = 110,
    alt = "Four colored time series"
  )
  output$line_small_multiples <- shiny::renderPlot(
    {
      make_line_plot(colors(), "small_multiples", background())
    },
    res = 110,
    alt = "Four time series shown in separate panels"
  )
  output$scatter_groups <- shiny::renderPlot(
    {
      make_scatter_plot(colors(), "groups", background())
    },
    res = 110,
    alt = "Scatter plot with four colored groups"
  )
  output$scatter_bubble <- shiny::renderPlot(
    {
      make_scatter_plot(colors(), "bubble", background())
    },
    res = 110,
    alt = "Scatter plot with color groups and varying point sizes"
  )
  output$histogram <- shiny::renderPlot(
    {
      make_histogram(colors(), background())
    },
    res = 110,
    alt = "Histogram of eruption duration"
  )
  output$boxplot <- shiny::renderPlot(
    {
      make_boxplot(colors(), background())
    },
    res = 110,
    alt = "Boxplots of iris sepal length by species"
  )
  output$heatmap <- shiny::renderPlot(
    {
      make_heatmap(colors(), background())
    },
    res = 110,
    alt = "Heatmap of illustrative numeric values"
  )
  output$donut <- shiny::renderPlot(
    {
      make_donut(colors(), background())
    },
    res = 110,
    alt = "Donut chart with five sample categories"
  )
  output$choropleth <- shiny::renderPlot(
    {
      make_choropleth(colors(), background(), map)
    },
    res = 110,
    alt = "Brazil state map colored by illustrative values"
  )
}

shiny::shinyApp(ui, server)
