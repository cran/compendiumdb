\name{GSEinDB}
\alias{GSEinDB}
\title{Retrieve information about a GSE loaded in the compendium database
}
\description{
Retrieve information about GEO series (GSE) records present in the compendium database
}
\usage{
GSEinDB(con, GSEid = NULL)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the
    user name and password to connect or interact with the
    compendium database (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character vector specifying the GSE ID(s). The default value
    is \code{NULL}, in which case the function returns an overview of all
    GSEs present in the compendium database.
  } 
}
\value{
  An object of class \code{data.frame} consisting of ten columns: i) ID of
  the record in the compendium database, ii) GSE ID, iii) educated
  guess on the experimental design of the experiment, iv) GPL ID, v) number of
  samples,  vi) user-specified tag for the experiment, (see
  \code{tagExperiment}), vii) NCBI taxonomy ID, viii) corresponding
  organism name, ix) GDS ID and x) date and time on which the data
  was loaded in the database
}
\author{
Umesh K. Nandal
}
\note{The value for the variable \code{experimentDesign} is determined by
  parsing the sample information provided by GEO. The variable can take
  the following values:
  i) SC: single-channel design, ii) DC: double-channel design, iii) DS:
  double-channel dye-swap design (if the same source name occurs in both
  channels) and iv) CR: double-channel common reference design (if the
  source name is equal for all samples in one of the two channels). The
  attribution of 'DS' and 'CR' labels makes assumptions on how source
  names are represented in GEO and should be interpreted with caution.
}

\seealso{
  \code{\link{GDSforGSE}}, \code{\link{GSEforGPL}}, \code{\link{tagExperiment}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  GSEinDB(conn,"GSE1657")
 }
}
