dummyJson <- '
{
  "ConceptSets": [
    {
      "id": 0,
      "name": "a cat",
      "expression": {
        "items": [
          {
            "concept": {
              "CONCEPT_CLASS_ID": "Organism",
              "CONCEPT_CODE": "388623001",
              "CONCEPT_ID": 4303581,
              "CONCEPT_NAME": "Subfamily Felinae",
              "DOMAIN_ID": "Observation",
              "INVALID_REASON": "V",
              "INVALID_REASON_CAPTION": "Valid",
              "STANDARD_CONCEPT": "S",
              "STANDARD_CONCEPT_CAPTION": "Standard",
              "VOCABULARY_ID": "SNOMED"
            }
          }
        ]
      }
    }
  ],
  "PrimaryCriteria": {
    "CriteriaList": [
      {
        "Observation": {
          "CodesetId": 0
        }
      }
    ],
    "ObservationWindow": {
      "PriorDays": 0,
      "PostDays": 0
    },
    "PrimaryCriteriaLimit": {
      "Type": "First"
    }
  },
  "QualifiedLimit": {
    "Type": "First"
  },
  "ExpressionLimit": {
    "Type": "First"
  },
  "InclusionRules": [],
  "CensoringCriteria": [],
  "CollapseSettings": {
    "CollapseType": "ERA",
    "EraPad": 0
  },
  "CensorWindow": {},
  "cdmVersionRange": ">=5.0.0"
}
'


serverPlp <- "tests/resources/plpDatabase/databaseFile.sqlite"
connectionDetailsPlp <- DatabaseConnector::createConnectionDetails(
  dbms = 'sqlite',
  server = serverPlp
)

connection <- DatabaseConnector::connect(connectionDetailsPlp)
cohortDefinitions <- DatabaseConnector::querySql(connection, "SELECT * FROM main.cohort_definition;")
cohortDefinitions$JSON <- dummyJson
DatabaseConnector::insertTable(
  connection = connection,
  databaseSchema = "main",
  tableName = "cohort_definition",
  data = cohortDefinitions,
  dropTableIfExists = TRUE,
  createTable = TRUE
)
DatabaseConnector::disconnect(connection)
