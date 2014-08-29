\name{GSEforGPL}
\alias{GSEforGPL}
\title{Retrieve the GSE ID for a given GPL ID
}
\description{
Retrieve the GSE ID(s) corresponding to a given GPL ID
}
\usage{
GSEforGPL(con, GPLid)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}}
  }
  \item{GPLid}{
    character vector specifying the GPL ID(s)
  }
}
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
  # Query to find GSEs for the character vector of GPL(s)
  GSEforGPL(conn,c("GPL96","GPL97","GPL570"))
 }
}
