% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_check.R
\name{cleanup_errors}
\alias{cleanup_errors}
\title{Cleanup data errors}
\usage{
cleanup_errors(data, errors, ignore_plausibility_check = FALSE)
}
\arguments{
\item{data}{a dataframe of the original data, i.e. the data to which the
\code{errors} parameter refers to}

\item{errors}{a dataframe of errors as produced by \code{check_data} to be
cleaned up}

\item{ignore_plausibility_check}{a boolean indicating whether the user wants
to ignore implausible data. If \code{TRUE}, the implausible data is
interpreted as being correct.}
}
\value{
a dataframe of the original data with cleaned up errors
}
\description{
\code{cleanup_errors} launches a step-by-step cleanup prompt which goes
over all incorrect rows found in the data (as discovered by
\code{check_data})
}
\keyword{internal}
