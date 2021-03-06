% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\name{dd_load}
\alias{dd_load}
\title{Load describe display
Retrieve output of from describe display plugin}
\usage{
dd_load(path)
}
\arguments{
\item{path}{file path}
}
\value{
object of class dd
}
\description{
Also performs some conversion of data structures to more
conveient form so that other functions do not have to repeatedly
recompute.  Some of these conversions could probably be moved into
the Describe Display plugin, but it may be easier to just do them
on the R side..
}
\author{
Hadley Wickham \email{h.wickham@gmail.com}
}
\seealso{
\code{\link{dd_example}} for an easier way of loading example
  files
}
\keyword{manip}

