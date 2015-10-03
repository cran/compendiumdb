\name{checkUpdates}
\alias{checkUpdates}
\title{Check whether GSE records have been updated on GEO
}
\description{
 Check whether GEO series (GSE) records loaded in the compendium database have been updated on GEO
}
\usage{
checkUpdates(con, GSEid = NULL)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
        character vector specifying the GSE ID(s). The default value
    is \code{NULL}, in which case the function performs a check for all
    GSEs present in the compendium database.
  }
}
\value{
 An object of class \code{data.frame} consisting of the GSE IDs that were updated after having been loaded in the compendium database,
 their last update date on GEO and the date on which they were loaded in the compendium database
}
\author{
Umesh K. Nandal
}
\note{If a GSE record has been updated on GEO, one can first remove the GSE from the compendium database
using the function \code{\link{removeGSE}} and then download the updated GSE record and reload the GSE into
the compendium database.
}
\seealso{
  \code{\link{removeGSE}}, \code{\link{downloadGEOdata}}, \code{\link{loadDataToCompendium}}

}

\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  ids <- checkUpdates(conn,"GSE18290")

 }
}
