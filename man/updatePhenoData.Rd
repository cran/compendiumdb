\name{updatePhenoData}
\alias{updatePhenoData}
\title{Update the phenotypic data of a GSE record
}
\description{
 Update the phenotypic data of a GEO series (GSE) record
 and store the updated phenotypic data into the compendium database
}
\usage{
updatePhenoData(con, GSEid, data)
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
  \item{data}{
    character \code{matrix} object containing all GSM IDs for  the GSE
    specified by \code{GSEid} as rownames followed by
    columns containing updated annotation of the corresponding samples. Column 
    names may different from those returned by \code{GMSdescriptions}. 
    This will overwrite the phenotypic data currently stored in the compendium 
    database and the user is prompted to confirm this.
}
}
\author{
Umesh K. Nandal
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  
  GSMdescriptions(conn,"GSE18290")
  tab <- GSMdescriptions(conn,"GSE18290")

  # As an example just replace the current annotation by the same annotation
  updatePhenoData(conn,"GSE18290",tab)
  GSMdescriptions(conn,"GSE18290")

 }
}
