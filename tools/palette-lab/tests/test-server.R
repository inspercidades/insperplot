app <- source("app.R")$value

shiny::testServer(app$serverFuncSource(), {
  session$setInputs(
    colors = "#123456\n#ABCDEF",
    canvas = "#243139"
  )

  stopifnot(
    identical(colors(), c("#123456", "#ABCDEF")),
    identical(background(), "#243139")
  )
})
