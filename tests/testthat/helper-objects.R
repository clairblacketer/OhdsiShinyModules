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
