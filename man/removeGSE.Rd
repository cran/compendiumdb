\name{removeGSE}
\alias{removeGSE}
\title{Remove a GSE from the compendium database
}
\description{
  Remove a GEO series (GSE) record and other entries corresponding to it from the compendium database
}
\usage{
removeGSE(con, GSEid)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character string specifying the GSE ID to be removed
  }
}
\details{
  A side effect of this function is that the corresponding GPL is also
  removed from the compendium database if the removed GSE was the only
  one with this GPL ID.
}
\author{
Umesh K. Nandal
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  removeGSE(conn,"GSE23183")
 }
}
