library(testthat)

serverPlp <- "../resources/plpDatabase/databaseFile.sqlite"
connectionDetailsPlp <- DatabaseConnector::createConnectionDetails(
  dbms = 'sqlite',
  server = serverPlp
)

connectionHandlerPlp <- ResultModelManager::ConnectionHandler$new(connectionDetailsPlp)

resultDatabaseSettingsPlp <- list(
  dbms = 'sqlite', # should this be removed - can use connection
  tablePrefix = '',
  cohortTablePrefix = '',
  databaseTablePrefix = '',
  schema = 'main'
)

shiny::testServer(
  app = predictionSettingsServer, 
  args = list(
    modelDesignId = shiny::reactiveVal(NULL),
    developmentDatabaseId = shiny::reactiveVal(1),
    performanceId = shiny::reactiveVal(1),
    connectionHandler = connectionHandlerPlp,
    inputSingleView = shiny::reactiveVal('Design Settings'), # only works with this
    mySchema = resultDatabaseSettingsPlp$schema,
    myTableAppend = resultDatabaseSettingsPlp$tablePrefix
  ), 
  expr = {
    
    modelDesignId(1)
    session$setInputs(showAttrition  = T) 
    expect_true(!is.null(output$attrition))
    session$setInputs(showCohort  = T) 
    session$setInputs(showOutcome  = T) 
    session$setInputs(showRestrictPlpData  = T) 
    session$setInputs(showPopulation  = T) 
    session$setInputs(showCovariates  = T) 
    session$setInputs(showModel = T) 
    session$setInputs(showFeatureEngineering = T) 
    session$setInputs(showPreprocess = T) 
    session$setInputs(showSplit = T) 
    session$setInputs(showSample = T) 
    session$setInputs(showHyperparameters = T) 
    
    design <- getModelDesign(
      inputSingleView = inputSingleView,
      modelDesignId = modelDesignId,
      mySchema = mySchema, 
      connectionHandler = connectionHandler,
      myTableAppend = myTableAppend, 
      cohortTableAppend = ''  # add as input?
    )
    expect_true(class(design) == 'list')
    expect_true(!is.null(design$RestrictPlpData))
    
    # check reactive?
    
  })
