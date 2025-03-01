% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimation-kaplainMeier.R
\name{estimationKaplanMeierServer}
\alias{estimationKaplanMeierServer}
\title{The module server for rendering the Kaplan Meier curve}
\usage{
estimationKaplanMeierServer(
  id,
  selectedRow,
  inputParams,
  connectionHandler,
  resultsSchema,
  tablePrefix,
  cohortTablePrefix,
  databaseTable,
  metaAnalysisDbIds = NULL
)
}
\arguments{
\item{id}{the unique reference id for the module}

\item{selectedRow}{the selected row from the main results table}

\item{inputParams}{the selected study parameters of interest}

\item{connectionHandler}{the connection to the PLE results database}

\item{resultsSchema}{the schema with the PLE results}

\item{tablePrefix}{tablePrefix}

\item{cohortTablePrefix}{cohortTablePrefix}

\item{databaseTable}{databaseTable}

\item{metaAnalysisDbIds}{metaAnalysisDbIds}
}
\value{
the PLE Kaplain Meier content server
}
\description{
The module server for rendering the Kaplan Meier curve
}
