# @file prediction-modelSummary.R
#
# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of OhdsiShinyModules
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#' The module viewer for exploring prediction summary results 
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' 
#' @return
#' The user interface to the summary module
#'
#' @export
predictionModelSummaryViewer <- function(id) {
  ns <- shiny::NS(id)
  
  shiny::tagList(
    shinydashboard::box(
      collapsible = TRUE,
      collapsed = TRUE,
      title = "All Database Results For Selected Model Design",
      width = "100%",
      shiny::htmlTemplate(system.file("prediction-www", "main-modelSummaryHelp.html", package = utils::packageName()))
    ),
    shinydashboard::box(
      status = "warning",
      width = "100%",
      shiny::uiOutput(outputId = ns("performanceSummaryText"))
    ),
    shinydashboard::box(
      width = "100%",
      reactable::reactableOutput(ns('performanceSummaryTable'))
    )
  )
}

#' The module server for exploring prediction summary results 
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' @param connectionHandler the connection to the prediction result database
#' @param mySchema the database schema for the model results
#' @param myTableAppend a string that appends the tables in the result schema
#' @param modelDesignId a reactable id specifying the prediction model design identifier
#' @param databaseTableAppend a string that appends the database_meta_data table
#' 
#' @return
#' The server to the summary module
#'
#' @export
predictionModelSummaryServer <- function(
  id, 
  connectionHandler,
  mySchema,
  myTableAppend,
  modelDesignId,
  databaseTableAppend = myTableAppend
) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      withTooltip <- function(value, tooltip, ...) {
        shiny::div(style = "text-decoration: underline; text-decoration-style: dotted; cursor: help",
                   tippy::tippy(value, tooltip, ...))
      }
      
      selectedModelDesign <- shiny::reactive(
        getModelDesignInfo(
          connectionHandler = connectionHandler, 
          mySchema = mySchema, 
          myTableAppend = myTableAppend,
          modelDesignId = modelDesignId,
          databaseTableAppend = databaseTableAppend
          )
      )
      output$performanceSummaryText <- shiny::renderUI(selectedModelDesign())


      resultTable <- shiny::reactive(
        getModelDesignPerformanceSummary(
          connectionHandler = connectionHandler, 
          mySchema = mySchema, 
          myTableAppend = myTableAppend,
          modelDesignId = modelDesignId,
          databaseTableAppend = databaseTableAppend
        )
      )
      
      shinyInput <- function(FUN,id,num,label = NULL,...) {
        inputs <- character(num)
        for (i in seq_len(num)) {
          inputs[i] <- as.character(FUN(paste0(id,i),label=label,...))
        }
        inputs
      }
      
      output$performanceSummaryTable <- reactable::renderReactable({
        reactable::reactable(
          data = cbind(
              view = rep("",nrow(resultTable())),
              resultTable()[,!colnames(resultTable())%in% c('performanceId', 'developmentDatabaseId', 'modelDevelopment', 'modelDesignId')]
            ),
          
          columns = list(
            Dev = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "Dev Db", 
                "The database used to develop the model"
              )),
            Val = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "Val Db", 
                "The database used to evaluate the model"
              )),
            T = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "Target Pop", 
                "The patients who the risk model is applied to"
              )),
            O = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "Outcome", 
                "The outcome being predicted"
              )),
            TAR = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "TAR", 
                "The time-at-risk when the outcome is being predicted relative to the target pop index"
              ),
              sortable = TRUE
            ),
            type = reactable::colDef( 
              filterable = TRUE,
              header = withTooltip(
                "Type", 
                "Development contains the model and internal validation; Validation contains the external validation"
              ),
              sortable = TRUE
            ),
            
            view = reactable::colDef(
              name = "",
              sortable = FALSE,
              filterable = FALSE,
              cell = function() htmltools::tags$button("View Result")
            )
          ),
          onClick = reactable::JS(paste0("function(rowInfo, column) {
    // Only handle click events on the 'details' column
    if (column.id !== 'view') {
      return
    }


    // Send the click event to Shiny, which will be available in input$show_details
    // Note that the row index starts at 0 in JavaScript, so we add 1
    // if (window.Shiny) {
    if(column.id == 'view'){
      Shiny.setInputValue('",session$ns('view_details'),"', { index: rowInfo.index + 1 }, { priority: 'event' })
    }
    // }
  }")
          )
          
        )
        
      })
      
      performanceId <- shiny::reactiveVal(value = NULL)
      developmentDatabaseId <- shiny::reactiveVal(value = NULL)
      modelDevelopment <- shiny::reactiveVal(value = NULL)
      shiny::observeEvent(input$view_details, {
        #print('perf updated')
        performanceId(NULL)
        performanceId(resultTable()$performanceId[input$view_details$index])
        developmentDatabaseId(resultTable()$developmentDatabaseId[input$view_details$index])
        modelDevelopment(resultTable()$modelDevelopment[input$view_details$index])
      })
      
      return(
        list(
          developmentDatabaseId = developmentDatabaseId,
          performanceId = performanceId,
          modelDevelopment = modelDevelopment
        )
      )
      
    }
  )
}



getModelDesignPerformanceSummary <- function(
    connectionHandler, 
  mySchema, 
  myTableAppend = '',
  modelDesignId,
  databaseTableAppend
){
  
  if(is.null(modelDesignId())){
    modelDesignId(1)
  }
  
  ParallelLogger::logInfo("gettingDb summary")
  
  shiny::withProgress(message = 'Plotting distributions', value = 0, {
    
    shiny::incProgress(1/3, detail = paste("Extracting data"))
    
  sql <- "SELECT distinct 
     results.performance_id, 
     results.model_design_id, 
     results.development_database_id,
     results.validation_database_id,
     d.database_acronym AS Dev, 
     v.database_acronym AS Val,
     targets.cohort_name AS T, 
     outcomes.cohort_name AS O,
     results.execution_date_time as time_stamp,
       tars.tar_start_day, 
       tars.tar_start_anchor, 
       tars.tar_end_day, 
       tars.tar_end_anchor,
       ROUND(aucResult.auc, 3) as auroc,
       ROUND(auprcResult.auprc,4) as auprc,
       nResult.population_size, 
       oResult.outcome_count,
       ROUND(nTest.test_size*100.0/nResult.population_size, 1) as eval_percent,
       ROUND(oResult.outcome_count*100.0/nResult.population_size,4) as outcome_percent,
       results.model_development
       
       FROM (select * from @my_schema.@my_table_appendperformances where model_design_id = @model_design_id) AS results 
  
    inner join @my_schema.@my_table_appendmodel_designs as model_designs
    on model_designs.model_design_id = results.model_design_id
    -- and results.target_id = model_designs.target_id 
             -- and results.outcome_id = model_designs.outcome_id and 
             -- results.tar_id = model_designs.tar_id and
             -- results.population_setting_id = model_designs.population_setting_id
             -- and results.plp_data_setting_id = model_designs.plp_data_setting_id
             
        LEFT JOIN (SELECT cohort_id, cohort_name FROM @my_schema.@my_table_appendcohorts) AS targets ON results.target_id = targets.cohort_id
        LEFT JOIN (SELECT cohort_id, cohort_name FROM @my_schema.@my_table_appendcohorts) AS outcomes ON results.outcome_id = outcomes.cohort_id
        LEFT JOIN (select dd.database_id, md.cdm_source_abbreviation database_acronym 
                   from @my_schema.@database_table_appenddatabase_meta_data md inner join 
                   @my_schema.@my_table_appenddatabase_details dd 
                   on md.database_id = dd.database_meta_data_id) AS d ON results.development_database_id = d.database_id 
                   LEFT JOIN (select dd.database_id, md.cdm_source_abbreviation database_acronym 
                   from @my_schema.@database_table_appenddatabase_meta_data md inner join 
                   @my_schema.@my_table_appenddatabase_details dd 
                   on md.database_id = dd.database_meta_data_id) AS v ON results.validation_database_id = v.database_id 
        LEFT JOIN @my_schema.@my_table_appendtars AS tars ON results.tar_id = tars.tar_id
        LEFT JOIN (SELECT performance_id, value AS auc FROM @my_schema.@my_table_appendevaluation_statistics where metric = 'AUROC' and evaluation in ('Test','Validation') ) AS aucResult ON results.performance_id = aucResult.performance_id
        LEFT JOIN (SELECT performance_id, value AS auprc FROM @my_schema.@my_table_appendevaluation_statistics where metric = 'AUPRC' and evaluation in ('Test','Validation') ) AS auprcResult ON results.performance_id = auprcResult.performance_id
        LEFT JOIN (SELECT performance_id, sum(value) AS population_size FROM @my_schema.@my_table_appendevaluation_statistics where metric = 'populationSize' and evaluation in ('Train','Test','Validation') group by performance_id) AS nResult ON results.performance_id = nResult.performance_id
        LEFT JOIN (SELECT performance_id, sum(value) AS outcome_count FROM @my_schema.@my_table_appendevaluation_statistics where metric = 'outcomeCount' and evaluation in ('Train','Test','Validation') group by performance_id) AS oResult ON results.performance_id = oResult.performance_id
        LEFT JOIN (SELECT performance_id, value AS test_size FROM @my_schema.@my_table_appendevaluation_statistics where metric = 'populationSize' and evaluation in ('Test', 'Validation') ) AS nTest ON results.performance_id = nTest.performance_id;"
  

  summaryTable <- connectionHandler$queryDb(
    sql = sql, 
    my_schema = mySchema,
    my_table_append = myTableAppend,
    model_design_id = modelDesignId(),
    database_table_append = databaseTableAppend
  )
  
  shiny::incProgress(2/3, detail = paste("Data extracted"))
  
  
  summaryTable$t <- trimws(summaryTable$t)
  summaryTable$o <- trimws(summaryTable$o)
  
  summaryTable <- summaryTable %>% 
    dplyr::rename(`T Size` = "populationSize") %>% 
    dplyr::rename(`O Count` = "outcomeCount") %>%
    dplyr::rename(`Val (%)` = "evalPercent") %>%
    dplyr::rename(`O Incidence (%)` = "outcomePercent")
  
  summaryTable <- editTar(summaryTable)
  
  colnames(summaryTable) <- editColnames(cnames = colnames(summaryTable), 
                                         edits = c('AUROC','AUPRC', 'T', 'O', 'Dev','Val', 'TAR', 'Model'))
  
  summaryTable$T <- as.factor(summaryTable$T)
  summaryTable$O <- as.factor(summaryTable$O)
  
  summaryTable$type <- ifelse(summaryTable$modelDevelopment == 1, 'Development', 'Validation')
  
  shiny::incProgress(3/3, detail = paste("Finished"))
  
  ParallelLogger::logInfo("Got db summary")
  
  })
  
  return(summaryTable[,c('Dev', 'Val', 'T','O', 'modelDesignId',
                         'TAR', 'AUROC', 'AUPRC', 
                         'T Size', 'O Count','Val (%)', 'O Incidence (%)', 'timeStamp', 'performanceId', 'developmentDatabaseId', 'modelDevelopment', 'type')])
  
}

editTar <- function(summaryTable){
  
  summaryTable <- summaryTable %>% dplyr::mutate(TAR = paste0('(',trimws(.data$tarStartAnchor),' + ',.data$tarStartDay, ') - (',trimws(.data$tarEndAnchor),' + ',.data$tarEndDay, ')' )) %>%
    dplyr::select(-c("tarStartAnchor", "tarStartDay", "tarEndAnchor", "tarEndDay"))
  
  return(summaryTable)
}

editColnames <- function(cnames, edits){
  lwcnames <- tolower(cnames)
  
  for(edit in edits){
    if(tolower(edit)%in%lwcnames){
      cnames[tolower(edit)==lwcnames] <- edit
    }
  }
  return(cnames)
  
}



getModelDesignInfo <- function(
  connectionHandler, 
  mySchema, 
  myTableAppend,
  modelDesignId,
  databaseTableAppend
){
  
  modelType <- connectionHandler$queryDb(
    'select distinct model_type from @my_schema.@my_table_appendmodels where model_design_id = @model_design_id;',
    my_schema = mySchema,
    my_table_append = myTableAppend,
    model_design_id = modelDesignId()
  )
  
  result <- data.frame(
    modelDesignId = modelDesignId(),
    modelType = modelType
  )
  
  return(
    shiny::fluidRow(
      shiny::column(
        width = 4,
        shiny::tags$b("modelDesignId :"),
        modelDesignId()
      ),
      shiny::column(
        width = 8,
        shiny::tags$b("modelType :"),
        modelType
      )
    )
  )
  
}
