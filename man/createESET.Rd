\name{createESET}
\alias{createESET}
\title{Create a Bioconductor ExpressionSet
}
\description{
  Given the identifier(s) of the GEO series record (GSE)
  creates an \code{ExpressionSet} from the data loaded in the compendium
  database
}
\usage{
createESET(con, GSEid, GPLid = "", parsing = TRUE)
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character vector specifying the GSE(s) to be converted to one or
    more ExpressionSets
  }
  \item{GPLid}{
    character vector specifying  the GPL(s). The default value is
    \code{""}, in which case a separate  \code{ExpressionSet} will be
    created for each of the GPLs in a GSE.
  } 
 \item{parsing}{
   logical, if set to its default value \code{TRUE}, the phenotypic data
   of the samples as available in the sample characteristics extracted
   from GEO will be parsed into separate columns.
 }
}
\details{
  This function generates an \code{ExpressionSet} instance for the
  specified GSE(s) from the data loaded in the compendium database. The
  \code{ExpressionSet} instance contains an \code{assayData} slot with
  all data related to the expression measurement parsed from GSE SOFT
  file. Probe annotation is provided in the \code{featureData} slot with
  all data parsed from the most recent annotation file provided for
  the corresponding GPL (if available at
  \url{ftp://ftp.ncbi.nlm.nih.gov/pub/geo/DATA/annotation/platforms/}).
  Sample annotation is provided in the
  \code{phenoData} slot and obtained by parsing the output of the
  function \code{\link{GSMdescriptions}}.
}
\value{
  Object(s) of class \code{ExpressionSet} (from the Biobase
  package). Each object of the ExpressionSet will be named according to
  the \code{GSEid} with its corresponding \code{GPLid(s)}. If a GSE
  consists of GSMs with a different number of features, a list of
  ExpressionSets is returned such that GSMs with the same features are
  grouped into one ExpressionSet.
}
\author{
Umesh Nandal
}
\seealso{
\code{\link{GSMdescriptions}}, \code{\link{updatePhenoData}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(dbname="compendium")

  # Create ExpressionSet for the samples in GSE1657 corresponding to GPL96
  createESET(conn,"GSE1657","GPL96")

  # Create ExpressionSet for the samples of both platforms present in GSE1657 (GPL96 & 
  # GPL97), i.e, set GPLid to default value
  createESET(conn,"GSE1657") # Default GPLid=""
  # Objects created are "esetGSE1657_GPL96" and "esetGSE1657_GPL97"
 }
}
