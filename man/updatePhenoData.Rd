\name{updatePhenoData}
\alias{updatePhenoData}
\title{Update the phenotypic data of a set of samples
}
\description{
Curate and update the phenotypic data of a set of
GSMs and store the updated phenotypic data into the compendium database
}
\usage{
updatePhenoData(con, data)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
}
  \item{data}{
    \code{data.frame} object containing GSM IDs as rownames followed by
    columns containing updated annotation of the corresponding samples
}

}
\author{
Umesh Nandal
}
\examples{
 \dontrun{
  barcode <- c("GSM28491","GSM28479","GSM30659","GSM30655")
  cellLine <- c("primary culture","primary culture","transduced","transduced")
  tissue <- c("omental","omental","subcutaneous","subcutaneous")
  data <- data.frame(cellLine,tissue)
  rownames(data) <- barcode

  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  updatePhenoData(conn,data)
 }
}
