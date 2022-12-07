counterUI <- function(id, label = "Counter") {
  ns <- NS(id)
  tagList(
    actionButton(ns("button"), label = label),
    verbatimTextOutput(ns("out"))
  )
}

# Define the server logic for a module
counterServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      count <- reactiveVal(0)
      observeEvent(input$button, {
        count(count() + 1)
      })
      output$out <- renderText({
        rmdFile <- system.file("test.Rmd", package = "OhdsiShinyModules")
        htmlFile <- tempfile(fileext = ".html")
        rmarkdown::render(
          input = rmdFile, 
          intermediates_dir = tempdir(),
          output_dir = htmlFile
        )
        return(file.exists(htmlFile))
      })
    }
  )
}
