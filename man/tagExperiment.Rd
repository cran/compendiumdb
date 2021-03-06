\name{tagExperiment}
\alias{tagExperiment}
\title{Tag an experiment with text labels
}
\description{
Tag an experiment with text labels
}
\usage{
tagExperiment(con, GSEid, tag)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character string specifying the GSE ID
  }
  \item{tag}{
    character string specifying the text labels with which to tag the
    GSE specified by \code{GSEid}
  }
}
\details{
  This function updates the value of the \code{tag} record for the
  specified GSE ID in the compendium database; see the variable
  \code{tagExperiment} of the data frame returned by the
  \code{link{GSEinDB}} function. Adding tags makes it easy to search for
  specific experiments.
}
\author{
Umesh K. Nandal
}
\seealso{
  \code{\link{GSEinDB}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  tagExperiment(conn,"GSE23183","HIV infection")
  GSEinDB(con=conn,"GSE23183")
 }
}
