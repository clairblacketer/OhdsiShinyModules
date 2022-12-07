test_that("Java works outside testServer", {
  sql <- SqlRender::translate("SELECT TOP 10 * FROM x;", "postgresql")
  expect_true(sql == "SELECT  * FROM x LIMIT 10;") 
})

test_that("Java works outside testServer in Rmd", {
  rmdFile <- system.file("test.Rmd", package = "OhdsiShinyModules")
  htmlFile <- tempfile(fileext = ".html")
  rmarkdown::render(
    input = rmdFile, 
    intermediates_dir = tempdir(),
    output_dir = htmlFile, 
  )
  expect_true(file.exists(htmlFile)) 
})


shiny::testServer(
  app = counterServer, 
  expr = {
    
    expect_true(output$out == "TRUE")
    
  })
