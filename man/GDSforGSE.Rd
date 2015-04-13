\name{GDSforGSE}
\alias{GDSforGSE}
\title{Retrieve information about a GDS for a given GSE
}
\description{
Retrieve information about the GDS(s) corresponding to given GSE ID
}
\usage{
GDSforGSE(con, GSEid)
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
}
\details{
  The GEO staff manually curates part of the records in GEO and
  reassembles biologically and statistically comparable records
  into a GEO dataset (GDS). This function allows the user to check if the series
  record (GSE) has been manually curated by GEO and has a corresponding
  GDS ID.}
\value{
  An object of class \code{data.frame} returned by \code{GSEinDB} giving
  detailed information on the corresponding GDS(s).
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
  # Retrieve information about GDSs corresponding to GSE1657
  GDSforGSE(conn,c("GSE1657"))
 }
}
