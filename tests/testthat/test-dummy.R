test_that("Java works outside testServer", {
  sql <- SqlRender::translate("SELECT TOP 10 * FROM x;", "postgresql")
  expect_true(sql == "SELECT  * FROM x LIMIT 10;") 
})


shiny::testServer(
  app = counterServer, 
  expr = {
    
    expect_true(output$out == "SELECT  * FROM x LIMIT 10;")
    
  })
