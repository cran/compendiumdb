\name{GDSforGSE}
\alias{GDSforGSE}
\title{Retrieve the GDS ID for a given GSE ID
}
\description{
Retrieve the GDS ID(s) corresponding to a given GSE ID
}
\usage{
GDSforGSE(con, GSEid)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}}
  }
  \item{GSEid}{
    character vector specifying the GSE ID(s)
  }
}
\details{
  The GEO staff manually curates part of the records in GEO and
  reassembles the biologically and statistically comparable records
  into a GDS. This function allows the user to check if the series
  record (GSE) has been manually curated by GEO and has a corresponding
  GDS ID.}
\value{
  An object of class data.frame returned by \code{GSEinDB}
}
\author{
Umesh Nandal
}
\seealso{
\code{\link{GSEinDB}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  GDSforGSE(conn,c("GSE1657","GSE1428"))
 }
}
