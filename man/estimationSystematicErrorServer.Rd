% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimation-systematicError.R
\name{estimationSystematicErrorServer}
\alias{estimationSystematicErrorServer}
\title{The module server for rendering the systematic error objects}
\usage{
estimationSystematicErrorServer(
  id,
  selectedRow,
  inputParams,
  connectionHandler,
  resultsSchema,
  tablePrefix,
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

\item{metaAnalysisDbIds}{metaAnalysisDbIds}
}
\value{
the PLE systematic error content server
}
\description{
The module server for rendering the systematic error objects
}
