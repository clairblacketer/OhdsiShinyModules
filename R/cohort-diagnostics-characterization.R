# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of PatientLevelPrediction
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

#' characterization
#' @description
#' Use for customizing UI
#'
#' @param id    Namespace Id - use namespaced id ns("characterization") inside diagnosticsExplorer module
#' @export
characterizationView <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shinydashboard::box(
      collapsible = TRUE,
      collapsed = TRUE,
      title = "Cohort Characterization",
      width = "100%",
      shiny::htmlTemplate(system.file("cohort-diagnostics-www", "cohortCharacterization.html", package = utils::packageName()))
    ),
    shinydashboard::box(
      width = NULL,
      shiny::radioButtons(
        inputId = ns("charType"),
        label = "Table type",
        choices = c("Pretty", "Raw"),
        selected = "Pretty",
        inline = TRUE
      ),
      shiny::fluidRow(
        shiny::column(
          width = 5,
          shinyWidgets::pickerInput(
            inputId = ns("targetCohort"),
            label = "Select Cohort",
            choices = NULL,
            options = shinyWidgets::pickerOptions(
              actionsBox = TRUE,
              liveSearch = TRUE,
              size = 10,
              maxOptions = 5, # Selecting even this many will be slow
              liveSearchStyle = "contains",
              liveSearchPlaceholder = "Type here to search",
              virtualScroll = 50
            )
          )
        ),
        shiny::column(
          width = 5,
          shinyWidgets::pickerInput(
            inputId = ns("targetDatabase"),
            label = "Select Database (s)",
            choices = NULL,
            multiple = TRUE,
            choicesOpt = list(style = rep_len("color: black;", 999)),
            options = shinyWidgets::pickerOptions(
              actionsBox = TRUE,
              liveSearch = TRUE,
              size = 10,
              liveSearchStyle = "contains",
              maxOptions = 5, # Selecting even this many will be slow
              liveSearchPlaceholder = "Type here to search",
              virtualScroll = 50
            )
          )
        )
      ),
      shiny::conditionalPanel(
        condition = "input.charType == 'Raw'",
        ns = ns,
        shiny::fluidRow(
          shiny::column(
            width = 4,
            shinyWidgets::pickerInput(
              inputId = ns("timeIdChoices"),
              label = "Temporal Window (s)",
              choices = NULL,
              multiple = TRUE,
              choicesOpt = list(style = rep_len("color: black;", 999)),
              selected = NULL,
              options = shinyWidgets::pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                maxOptions = 5, # Selecting even this many will be slow
                size = 10,
                liveSearchStyle = "contains",
                liveSearchPlaceholder = "Type here to search",
                virtualScroll = 50
              )
            )
          ),
          shiny::column(
            width = 4,
            shinyWidgets::pickerInput(
              inputId = ns("selectedRawAnalysisIds"),
              label = "Analysis name",
              choices = c(""),
              selected = c(""),
              inline = TRUE,
              multiple = TRUE,
              width = "100%",
              choicesOpt = list(style = rep_len("color: black;", 999)),
              options = shinyWidgets::pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                size = 10,
                liveSearchStyle = "contains",
                liveSearchPlaceholder = "Type here to search",
                virtualScroll = 50
              )
            )
          ),
          shiny::column(
            width = 4,
            shinyWidgets::pickerInput(
              inputId = ns("characterizationDomainIdFilter"),
              label = "Domain name",
              choices = c(""),
              selected = c(""),
              inline = TRUE,
              multiple = TRUE,
              width = "100%",
              choicesOpt = list(style = rep_len("color: black;", 999)),
              options = shinyWidgets::pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                size = 10,
                liveSearchStyle = "contains",
                liveSearchPlaceholder = "Type here to search",
                virtualScroll = 50
              )
            )
          )
        )
      ),
      shiny::conditionalPanel(
        ns = ns,
        condition = "input.charType == 'Pretty'",
        shiny::actionButton(label = "Generate Table", inputId = ns("generateReport"))
      ),
      shiny::conditionalPanel(
        ns = ns,
        condition = "input.charType == 'Raw'",
        shiny::actionButton(label = "Generate Table", inputId = ns("generateRaw"))
      ),
    ),
    shiny::conditionalPanel(
      condition = "input.generateReport > 0 && input.charType == 'Pretty'",
      ns = ns,
      shiny::uiOutput(outputId = ns("selections")),
      shinydashboard::box(
        width = NULL,
        shinycssloaders::withSpinner(
          reactable::reactableOutput(outputId = ns("characterizationTable"))
        ),
        reactableCsvDownloadButton(ns, "characterizationTable")
      )
    ),
    shiny::conditionalPanel(
      condition = "input.generateRaw > 0 && input.charType == 'Raw'",
      ns = ns,
      shiny::uiOutput(outputId = ns("selectionsRaw")),
      shinydashboard::box(
        width = NULL,
        shiny::fluidRow(
          shiny::column(
            width = 4,
            shiny::radioButtons(
              inputId = ns("proportionOrContinuous"),
              label = "Covariate type(s)",
              choices = c("All", "Proportion", "Continuous"),
              selected = "All",
              inline = TRUE
            ),
            shiny::p("Percentage displayed where only proportional data is selected")
          ),
          shiny::column(
            width = 4,
            shiny::radioButtons(
              inputId = ns("characterizationColumnFilters"),
              label = "Display",
              choices = c("Mean and Standard Deviation", "Mean only"),
              selected = "Mean only",
              inline = TRUE
            )
          ),
          shiny::column(
            width = 4,
            shinyWidgets::pickerInput(
              inputId = ns("selectedConceptSet"),
              label = "Subset to Concept Set",
              choices = NULL,
              options = shinyWidgets::pickerOptions(
                actionsBox = TRUE,
                liveSearch = TRUE,
                size = 10,
                liveSearchStyle = "contains",
                liveSearchPlaceholder = "Type here to search",
                virtualScroll = 50
              )
            )
          )
        ),
        shiny::tabsetPanel(
          type = "pills",
          shiny::tabPanel(
            title = "Group by Database",
            shinycssloaders::withSpinner(
              reactable::reactableOutput(outputId = ns("characterizationTableRaw"))
            ),
            reactableCsvDownloadButton(ns, "characterizationTableRaw")
          ),
          shiny::tabPanel(
            title = "Group by Time ID",
            shinycssloaders::withSpinner(
              reactable::reactableOutput(outputId = ns("characterizationTableRawGroupedByTime"))
            ),
            reactableCsvDownloadButton(ns, "characterizationTableRawGroupedByTime")
          )
        )
      )
    )
  )
}

prepareTable1 <- function(covariates,
                          prettyTable1Specifications,
                          cohort) {
  if (!all(
    is.data.frame(prettyTable1Specifications),
    nrow(prettyTable1Specifications) > 0
  )) {
    return(NULL)
  }
  keyColumns <- prettyTable1Specifications %>%
    dplyr::select(
      "labelOrder",
      "label",
      "covariateId",
      "analysisId",
      "sequence"
    ) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      covariates %>%
        dplyr::select(
          "covariateId",
          "covariateName"
        ) %>%
        dplyr::distinct(),
      by = c("covariateId")
    ) %>%
    dplyr::filter(!is.na(.data$covariateName)) %>%
    tidyr::crossing(
      covariates %>%
        dplyr::select(
          "cohortId",
          "databaseId"
        ) %>%
        dplyr::distinct()
    ) %>%
    dplyr::arrange(
      .data$cohortId,
      .data$databaseId,
      .data$analysisId,
      .data$covariateId
    ) %>%
    dplyr::mutate(
      covariateName = stringr::str_replace(
        string = .data$covariateName,
        pattern = "black or african american",
        replacement = "Black or African American"
      )
    ) %>%
    dplyr::mutate(
      covariateName = stringr::str_replace(
        string = .data$covariateName,
        pattern = "white",
        replacement = "White"
      )
    ) %>%
    dplyr::mutate(
      covariateName = stringr::str_replace(
        string = .data$covariateName,
        pattern = "asian",
        replacement = "Asian"
      )
    )

  covariates <- keyColumns %>%
    dplyr::left_join(
      covariates %>%
        dplyr::select(-"covariateName"),
      by = c(
        "cohortId",
        "databaseId",
        "covariateId",
        "analysisId"
      )
    ) %>%
    dplyr::filter(!is.na(.data$covariateName))

  space <- "&nbsp;"

  # labels
  tableHeaders <-
    covariates %>%
      dplyr::select(
        "cohortId",
        "databaseId",
        "label",
        "labelOrder",
        "sequence"
      ) %>%
      dplyr::distinct() %>%
      dplyr::group_by(
        .data$cohortId,
        .data$databaseId,
        .data$label,
        .data$labelOrder
      ) %>%
      dplyr::summarise(
        sequence = min(.data$sequence),
        .groups = "keep"
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        characteristic = paste0(
          "<strong>",
          .data$label,
          "</strong>"
        ),
        header = 1
      ) %>%
      dplyr::select(
        "cohortId",
        "databaseId",
        "sequence",
        "header",
        "labelOrder",
        "characteristic"
      ) %>%
      dplyr::distinct()

  tableValues <-
    covariates %>%
      dplyr::mutate(
        characteristic = paste0(
          space,
          space,
          space,
          space,
          .data$covariateName
        ),
        header = 0,
        valueCount = .data$sumValue
      ) %>%
      dplyr::select(
        "cohortId",
        "databaseId",
        "covariateId",
        "analysisId",
        "sequence",
        "header",
        "labelOrder",
        "characteristic",
        "valueCount"
      )

  table <- dplyr::bind_rows(tableHeaders, tableValues) %>%
    dplyr::mutate(sequence = .data$sequence - .data$header) %>%
    dplyr::arrange(.data$sequence) %>%
    dplyr::select(
      "cohortId",
      "databaseId",
      "sequence",
      "characteristic",
      "valueCount"
    ) %>%
    dplyr::rename("count" = "valueCount") %>%
    dplyr::inner_join(cohort %>%
                        dplyr::select(
                          "cohortId",
                          "shortName"
                        ),
                      by = "cohortId"
    ) %>%
    dplyr::group_by(
      .data$databaseId,
      .data$characteristic,
      .data$shortName
    ) %>%
    dplyr::summarise(
      sequence = min(.data$sequence),
      count = min(.data$count),
      .groups = "keep"
    ) %>%
    dplyr::ungroup() %>%
    tidyr::pivot_wider(
      id_cols = c(
        "databaseId",
        "characteristic",
        "sequence"
      ),
      values_from = "count",
      names_from = "shortName"
    ) %>%
    dplyr::arrange(.data$sequence)


  if (nrow(table) == 0) {
    return(NULL)
  }
  return(table)
}

characterizationModule <- function(
  id,
  dataSource,
  cohortTable = dataSource$cohortTable,
  databaseTable = dataSource$databaseTable,
  temporalAnalysisRef = dataSource$temporalAnalysisRef,
  analysisNameOptions = dataSource$analysisNameOptions,
  domainIdOptions = dataSource$domainIdOptions,
  characterizationTimeIdChoices = dataSource$characterizationTimeIdChoices,
  table1SpecPath = system.file("cohort-diagnostics-ref", "Table1SpecsLong.csv",
                               package = utils::packageName())
) {
  prettyTable1Specifications <- readr::read_csv(
    file = table1SpecPath,
    col_types = readr::cols(),
    guess_max = min(1e7),
    lazy = FALSE
  )

  # Analysis IDs for pretty table
  prettyTableAnalysisIds <- c(
    1, 3, 4, 5, 6, 7,
    203, 403, 501, 703,
    801, 901, 903, 904,
    -301, -201
  )

  shiny::moduleServer(id, function(input, output, session) {

    timeIdOptions <- getResultsTemporalTimeRef(dataSource = dataSource) %>%
      dplyr::arrange(.data$sequence)

    selectedTimeIds <- shiny::reactive({
      timeIdOptions %>%
        dplyr::filter(.data$temporalChoices %in% input$timeIdChoices) %>%
        dplyr::select("timeId") %>%
        dplyr::pull()
    })

    selectedDatabaseIds <- shiny::reactive(input$targetDatabase)
    targetCohortId <- shiny::reactive(input$targetCohort)

    getCohortConceptSets <- shiny::reactive({
      if (!hasData(input$targetCohort)) {
        return(NULL)
      }

      dataSource$conceptSets %>%
        dplyr::filter(.data$cohortId == input$targetCohort) %>%
        dplyr::mutate(name = .data$conceptSetName, id = .data$conceptSetId) %>%
        dplyr::select("id", "name")
    })

    shiny::observe({
      # Default time windows
      selectedTimeWindows <- timeIdOptions %>%
        dplyr::distinct() %>%
        dplyr::filter(.data$primaryTimeId == 1) %>%
        dplyr::filter(.data$isTemporal == 1) %>%
        dplyr::arrange(.data$sequence) %>%
        dplyr::pull("temporalChoices")

      shinyWidgets::updatePickerInput(session,
                                      inputId = "timeIdChoices",
                                      choices = timeIdOptions$temporalChoices %>% unique(),
                                      selected = selectedTimeWindows)

      cohortChoices <- cohortTable$cohortId
      names(cohortChoices) <- cohortTable$cohortName
      shinyWidgets::updatePickerInput(session,
                                      inputId = "targetCohort",
                                      choices = cohortChoices)


      databaseChoices <- databaseTable$databaseId
      names(databaseChoices) <- databaseTable$databaseName
      shinyWidgets::updatePickerInput(session,
                                      inputId = "targetDatabase",
                                      selected = databaseChoices[1],
                                      choices = databaseChoices)
    })

    conceptSetIds <- shiny::reactive({
      if (input$selectedConceptSet == "") {
        return(NULL)
      }
      input$selectedConceptSet
    })

    getResolvedConcepts <- shiny::reactive({
      output <- resolvedConceptSet(
        dataSource = dataSource,
        databaseIds = selectedDatabaseIds(),
        cohortId = targetCohortId()
      )
      if (!hasData(output)) {
        return(NULL)
      }
      return(output)
    })

    ### getMappedConceptsReactive ----
    getMappedConcepts <- shiny::reactive({
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Getting concepts mapped to concept ids resolved by concept set expression (may take time)", value = 0)
      output <- mappedConceptSet(dataSource = dataSource,
                                 databaseIds = selectedDatabaseIds(),
                                 cohortId = targetCohortId())
      if (!hasData(output)) {
        return(NULL)
      }
      return(output)
    })

    getFilteredConceptIds <- shiny::reactive({
      shiny::validate(shiny::need(hasData(selectedDatabaseIds()), "No data sources chosen"))
      shiny::validate(shiny::need(hasData(targetCohortId()), "No cohort chosen"))
      shiny::validate(shiny::need(hasData(conceptSetIds()), "No concept set id chosen"))
      resolved <- getResolvedConcepts()
      mapped <- getMappedConcepts()
      output <- c()
      if (hasData(resolved)) {
        resolved <- resolved %>%
          dplyr::filter(.data$databaseId %in% selectedDatabaseIds()) %>%
          dplyr::filter(.data$cohortId %in% targetCohortId()) %>%
          dplyr::filter(.data$conceptSetId %in% conceptSetIds())
        output <- c(output, resolved$conceptId) %>% unique()
      }
      if (hasData(mapped)) {
        mapped <- mapped %>%
          dplyr::filter(.data$databaseId %in% selectedDatabaseIds()) %>%
          dplyr::filter(.data$cohortId %in% targetCohortId()) %>%
          dplyr::filter(.data$conceptSetId %in% conceptSetIds())
        output <- c(output, mapped$conceptId) %>% unique()
      }

      if (hasData(output)) {
        return(output)
      } else {
        return(NULL)
      }
    })

    selectedConceptSets <- shiny::reactive(input$selectedConceptSet)

    selectionsPanel <- shiny::reactive({
      shinydashboard::box(
        status = "warning",
        width = "100%",
        shiny::fluidRow(
          shiny::column(
            width = 4,
            shiny::tags$b("Cohort :"),
            paste(cohortTable %>%
                    dplyr::filter(.data$cohortId %in% targetCohortId()) %>%
                    dplyr::select("cohortName") %>%
                    dplyr::pull(),
                  collapse = ", ")
          ),
          shiny::column(
            width = 8,
            shiny::tags$b("Database(s) :"),
            paste(databaseTable %>%
                    dplyr::filter(.data$databaseId %in% selectedDatabaseIds()) %>%
                    dplyr::select("databaseName") %>%
                    dplyr::pull(),
                  collapse = ", ")
          )
        )
      )
    })

    selectionsOutput <- shiny::eventReactive(input$generateReport, {
      selectionsPanel()
    })

    selectionsOutputRaw <- shiny::eventReactive(input$generateRaw, {
      selectionsPanel()
    })

    output$selections <- shiny::renderUI(selectionsOutput())
    output$selectionsRaw <- shiny::renderUI(selectionsOutputRaw())
    # Cohort Characterization -------------------------------------------------


    #### selectedRawAnalysisIds ----
    shiny::observe({
      analysisIdOptions <- NULL
      selectectAnalysisIdOptions <- NULL

      if (hasData(temporalAnalysisRef)) {
        analysisRefs <- temporalAnalysisRef %>%
          dplyr::select("analysisName", "analysisId") %>%
          dplyr::distinct() %>%
          dplyr::arrange(.data$analysisName)

        analysisIdOptions <- analysisRefs$analysisId
        names(analysisIdOptions) <- analysisRefs$analysisName
        selectectAnalysisIdOptions <- temporalAnalysisRef$analysisId
      }

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "selectedRawAnalysisIds",
        choicesOpt = list(style = rep_len("color: black;", 999)),
        choices = analysisIdOptions,
        selected = selectectAnalysisIdOptions
      )
    })

    ### characterizationDomainNameFilter ----
    shiny::observe({
      characterizationDomainOptionsUniverse <- NULL
      charcterizationDomainOptionsSelected <- NULL

      if (hasData(temporalAnalysisRef)) {
        characterizationDomainOptionsUniverse <- domainIdOptions
        charcterizationDomainOptionsSelected <- temporalAnalysisRef %>%
          dplyr::pull("domainId") %>%
          unique()
      }

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "characterizationDomainIdFilter",
        choicesOpt = list(style = rep_len("color: black;", 999)),
        choices = characterizationDomainOptionsUniverse,
        selected = charcterizationDomainOptionsSelected
      )
    })

    getPrettyCharacterizationData <- shiny::reactive({
      data <- dataSource$connectionHandler$queryDb(
        sql = "SELECT tcv.*, ref.analysis_id, ref.covariate_name
                FROM @results_database_schema.@table_name tcv
                INNER JOIN @results_database_schema.@ref_table_name ref ON ref.covariate_id = tcv.covariate_id
                WHERE ref.covariate_id IS NOT NULL
                {@analysis_ids != \"\"} ? { AND ref.analysis_id IN (@analysis_ids)}
                {@cohort_id != \"\"} ? { AND tcv.cohort_id IN (@cohort_id)}
                {@time_id != \"\"} ? { AND (time_id IN (@time_id) OR time_id IS NULL OR time_id = 0)}
                {@use_database_id} ? { AND database_id IN (@database_id)}
                {@filter_mean_threshold != \"\"} ? { AND tcv.mean > @filter_mean_threshold};",
        snakeCaseToCamelCase = TRUE,
        analysis_ids = prettyTableAnalysisIds,
        time_id = characterizationTimeIdChoices$timeId,
        use_database_id = !is.null(selectedDatabaseIds()),
        database_id = quoteLiterals(selectedDatabaseIds()),
        table_name = dataSource$prefixTable("temporal_covariate_value"),
        ref_table_name = dataSource$prefixTable("temporal_covariate_ref"),
        cohort_id = targetCohortId(),
        results_database_schema = dataSource$resultsDatabaseSchema,
        filter_mean_threshold = 0.0
      ) %>%
        dplyr::tibble() %>%
        tidyr::replace_na(replace = list(timeId = -1))
      data
    })

    ## cohortCharacterizationPrettyTable ----
    cohortCharacterizationPrettyTable <- shiny::eventReactive(input$generateReport, {
      data <- getPrettyCharacterizationData()
      if (!hasData(data)) {
        return(NULL)
      }

      if (!hasData(data)) {
        return(NULL)
      }

      data <- data %>%
        dplyr::select(
          "cohortId",
          "databaseId",
          "analysisId",
          "covariateId",
          "covariateName",
          "mean"
        ) %>%
        dplyr::rename("sumValue" = "mean")


      table <- data %>%
        prepareTable1(
          prettyTable1Specifications = prettyTable1Specifications,
          cohort = cohortTable
        )
      if (!hasData(table)) {
        return(NULL)
      }
      keyColumnFields <- c("characteristic")
      dataColumnFields <- intersect(
        x = colnames(table),
        y = cohortTable$shortName
      )

      countLocation <- 1
      countsForHeader <-
        getDisplayTableHeaderCount(
          dataSource = dataSource,
          databaseIds = data$databaseId %>% unique(),
          cohortIds = data$cohortId %>% unique(),
          source = "cohort",
          fields = "Persons"
        )

      displayTable <- getDisplayTableGroupedByDatabaseId(
        data = table,
        databaseTable = databaseTable,
        headerCount = countsForHeader,
        keyColumns = keyColumnFields,
        countLocation = countLocation,
        dataColumns = dataColumnFields,
        showDataAsPercent = TRUE,
        sort = FALSE,
        pageSize = 100
      )
      return(displayTable)
    })

    ## Output: characterizationTable ----
    output$characterizationTable <- reactable::renderReactable(expr = {
      data <- cohortCharacterizationPrettyTable()
      shiny::validate(shiny::need(hasData(data), "No data for selected combination"))
      return(data)
    })

    # Temporal characterization ------------
    rawCharacterizationOutput <- shiny::reactive({
      shiny::validate(shiny::need(length(selectedDatabaseIds()) > 0, "At least one data source must be selected"))
      shiny::validate(shiny::need(length(targetCohortId()) == 1, "One target cohort must be selected"))

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(
        message = paste0(
          "Retrieving characterization output for cohort id ",
          targetCohortId(),
          " cohorts and ",
          length(selectedDatabaseIds()),
          " data sources."
        ),
        value = 20
      )

      data <- dataSource$connectionHandler$queryDb(
        sql = "SELECT tcv.*,
                ref.covariate_name, ref.analysis_id, ref.concept_id,
                aref.analysis_name, aref.is_binary, aref.domain_id,
                tref.start_day, tref.end_day
                FROM @results_database_schema.@table_name tcv
                INNER JOIN @results_database_schema.@ref_table_name ref ON ref.covariate_id = tcv.covariate_id
                INNER JOIN @results_database_schema.@analysis_ref_table_name aref ON aref.analysis_id = ref.analysis_id
                LEFT JOIN @results_database_schema.@temporal_time_ref tref ON tref.time_id = tcv.time_id
                WHERE ref.covariate_id IS NOT NULL
                {@analysis_ids != \"\"} ? { AND ref.analysis_id IN (@analysis_ids)}
                {@domain_ids != \"\"} ? { AND aref.domain_id IN (@domain_ids)}
                {@cohort_id != \"\"} ? { AND tcv.cohort_id IN (@cohort_id)}
                {@time_id != \"\"} ? { AND (tcv.time_id IN (@time_id) OR tcv.time_id IS NULL OR tcv.time_id = 0)}
                {@use_database_id} ? { AND database_id IN (@database_id)}
                ",
        snakeCaseToCamelCase = TRUE,
        analysis_ids = input$selectedRawAnalysisIds %>% unique(),
        time_id = selectedTimeIds() %>% unique(),
        use_database_id = !is.null(selectedDatabaseIds()),
        database_id = quoteLiterals(selectedDatabaseIds()),
        domain_ids = quoteLiterals(input$characterizationDomainIdFilter %>% unique()),
        table_name = dataSource$prefixTable("temporal_covariate_value"),
        ref_table_name = dataSource$prefixTable("temporal_covariate_ref"),
        analysis_ref_table_name = dataSource$prefixTable("temporal_analysis_ref"),
        temporal_time_ref = dataSource$prefixTable("temporal_time_ref"),
        cohort_id = targetCohortId(),
        results_database_schema = dataSource$resultsDatabaseSchema
      ) %>%
        dplyr::tibble() %>%
        tidyr::replace_na(replace = list(timeId = -1)) %>%
        dplyr::mutate(temporalChoices = ifelse(is.na(.data$startDay),
                                               "Time Invariant",
                                               paste0("T (", .data$startDay, "d to ", .data$endDay, "d)")))
        return(data)
    })

    ## cohortCharacterizationDataFiltered ----
    cohortCharacterizationDataFiltered <- shiny::eventReactive(input$generateRaw, {
      cohortConcepSets <- getCohortConceptSets()
      cohortConcepSetOptions <- c("", cohortConcepSets$id)
      names(cohortConcepSetOptions) <- c("None selected", cohortConcepSets$name)
      shinyWidgets::updatePickerInput(session,
                                      inputId = "selectedConceptSet",
                                      selected = NULL,
                                      choices = cohortConcepSetOptions)

      data <- rawCharacterizationOutput()
      if (!hasData(data)) {
        return(NULL)
      }
      return(data)
    })

    rawTableReactable <- shiny::reactive({
      data <- cohortCharacterizationDataFiltered()
      if (is.null(data)) {
        return(NULL)
      }

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(
        message = "Post processing: Rendering table",
        value = 0
      )

      keyColumnFields <-
        c("covariateName", "analysisName", "temporalChoices", "conceptId")

      if (input$characterizationColumnFilters == "Mean and Standard Deviation") {
        dataColumnFields <- c("mean", "sd")
      } else {
        dataColumnFields <- c("mean")
      }
      countLocation <- 1


      if (!hasData(data)) {
        return(NULL)
      }

      countsForHeader <-
        getDisplayTableHeaderCount(
          dataSource = dataSource,
          databaseIds = data$databaseId %>% unique(),
          cohortIds = data$cohortId %>% unique(),
          source = "cohort",
          fields = "Persons"
        )

      data <- data %>%
        dplyr::select(
          "covariateName",
          "analysisName",
          "startDay",
          "endDay",
          "conceptId",
          "isBinary",
          "mean",
          "sd",
          "cohortId",
          "databaseId",
          "temporalChoices"
        )
      showAsPercentage <- any(input$proportionOrContinuous == "Proportion", all(data$isBinary == "Y"))
      if (input$proportionOrContinuous == "Proportion") {
        data <- data %>%
          dplyr::filter(.data$isBinary == "Y") %>%
          dplyr::select(-"isBinary")
      } else if (input$proportionOrContinuous == "Continuous") {
        data <- data %>%
          dplyr::filter(.data$isBinary == "N") %>%
          dplyr::select(-"isBinary")
      }

      if (hasData(selectedConceptSets())) {
        if (hasData(conceptSetIds())) {
          data <- data %>%
            dplyr::filter(.data$conceptId %in% getFilteredConceptIds())
        }
      }
      shiny::validate(shiny::need(hasData(data), "No data for selected combination"))

      getDisplayTableGroupedByDatabaseId(
        data = data,
        databaseTable = databaseTable,
        headerCount = countsForHeader,
        keyColumns = keyColumnFields,
        countLocation = countLocation,
        dataColumns = dataColumnFields,
        showDataAsPercent = showAsPercentage,
        sort = TRUE,
        pageSize = 100
      )
    })

    output$characterizationTableRaw <- reactable::renderReactable(expr = {
      data <- rawTableReactable()
      shiny::validate(shiny::need(hasData(data), "No data for selected combination"))
      return(data)
    })


    rawTableTimeIdReactable <- shiny::reactive({

      data <- cohortCharacterizationDataFiltered()

      if (is.null(data)) {
        return(NULL)
      }

      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(
        message = "Post processing: Rendering table",
        value = 0
      )

      showAsPercentage <- any(input$proportionOrContinuous == "Proportion", all(data$isBinary == "Y"))
      if (input$proportionOrContinuous == "Proportion") {
        data <- data %>%
          dplyr::filter(.data$isBinary == "Y") %>%
          dplyr::select(-"isBinary")
      } else if (input$proportionOrContinuous == "Continuous") {
        data <- data %>%
          dplyr::filter(.data$isBinary == "N") %>%
          dplyr::select(-"isBinary")
      }

      temporalChoicesVar <- data$temporalChoices %>% unique()

      data <-
        data %>% dplyr::inner_join(databaseTable %>%
                                     dplyr::select("databaseId", "databaseName"),
                                   by = "databaseId")

      if (hasData(selectedConceptSets())) {
        if (hasData(conceptSetIds())) {
          data <- data %>%
            dplyr::filter(.data$conceptId %in% getFilteredConceptIds())
        }
      }

      keyColumns <- c("covariateName", "analysisName", "conceptId", "databaseName")
      data <- data %>%
        dplyr::select(
          "covariateName",
          "analysisName",
          "databaseName",
          "temporalChoices",
          "conceptId",
          "mean",
          "sd"
        ) %>%
      tidyr::pivot_wider(
        id_cols = dplyr::all_of(keyColumns),
        names_from = "temporalChoices",
        values_from = "mean",
        names_sep = "_"
      ) %>%
        dplyr::relocate(dplyr::all_of(c(keyColumns, temporalChoicesVar))) %>%
        dplyr::arrange(dplyr::desc(dplyr::across(dplyr::starts_with("T ("))))

      if (any(stringr::str_detect(
        string = colnames(data),
        pattern = stringr::fixed("T (0")
      ))) {
        data <- data %>%
          dplyr::arrange(dplyr::desc(dplyr::across(dplyr::starts_with("T (0"))))
      }
      dataColumns <- temporalChoicesVar
      progress$set(
        message = "Rendering table",
        value = 80
      )

      getDisplayTableSimple(
        data = data,
        keyColumns = keyColumns,
        dataColumns = dataColumns,
        showDataAsPercent = showAsPercentage,
        pageSize = 100
      )
    })

    output$characterizationTableRawGroupedByTime <- reactable::renderReactable(expr = {
      data <- rawTableTimeIdReactable()
      shiny::validate(shiny::need(hasData(data), "No data for selected combination"))
      return(data)
    })
  })
}
