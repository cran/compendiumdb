\name{GSEforGPL}
\alias{GSEforGPL}
\title{Retrieve information about a GSE for a given GPL
}
\description{
Retrieve information about GSE(s) corresponding to given GPL ID(s)
}
\usage{
GSEforGPL(con, GPLid)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GPLid}{
    character vector specifying the GPL ID(s)
  }
}
\value{
  An object of class \code{data.frame} returned by \code{GSEinDB} giving
  detailed information on the corresponding GSE(s).
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
  # Retrieve information about GSEs corresponding to three GPLs
  GSEforGPL(conn,c("GPL96","GPL97","GPL570"))
 }
}
