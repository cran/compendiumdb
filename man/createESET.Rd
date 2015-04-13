\name{createESET}
\alias{createESET}
\title{Create a Bioconductor ExpressionSet
}
\description{
  Given the identifier of a GEO series (GSE) record 
  creates one or more \code{ExpressionSet}s from the data loaded in the compendium
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
    character string specifying the GSE ID to be converted to one or
    more ExpressionSets
  }
  \item{GPLid}{
    character string specifying  the GPL ID. The default value is
    \code{""}, in which case a separate  \code{ExpressionSet} will be
    created for each of the GPLs in the GSE specified by \code{GSEid}.
  } 
 \item{parsing}{
   logical, if set to its default value (\code{TRUE}) the phenotypic data
   of the samples as available in the sample characteristics extracted
   from GEO will be parsed into separate columns.
 }
}
\details{
  This function generates one or more ExpressionSets for the
  specified GSE from the data loaded in the compendium database. Each
  \code{ExpressionSet} contains an \code{assayData} slot with
  all data related to the expression measurements parsed from GSE SOFT
  file. Probe annotation is provided in the \code{featureData} slot with
  all data parsed from the most recent annotation file provided for
  the corresponding GPL (if available at
  \url{ftp://ftp.ncbi.nlm.nih.gov/pub/geo/DATA/annotation/platforms/}).
  Sample annotation is provided in the
  \code{phenoData} slot and obtained by parsing the output of the
  function \code{\link{GSMdescriptions}}.
}
\value{
  A \code{list} with components of class \code{ExpressionSet} (from the Biobase
  Bioconductor package). Each \code{ExpressionSet} is named according to
  the \code{GSEid} with its corresponding GPL ID(s). If a GSE
  consists of GSMs with a different number of features, multiple
  ExpressionSets are created such that GSMs with the same features are
  grouped into one ExpressionSet.
}
\author{
Umesh K. Nandal
}
\seealso{
\code{\link{GSMdescriptions}}, \code{\link{updatePhenoData}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(dbname="compendium")

  # Create ExpressionSet for the samples in GSE1657 corresponding to GPL96
  esets <- createESET(conn,"GSE1657","GPL96")
  # esets contains one component: "esetGSE1657_GPL96_SC"

  # Create ExpressionSet for the samples of both platforms present in GSE1657 (GPL96 & 
  # GPL97), i.e, set GPLid to default value
  esets <- createESET(conn,"GSE1657") # Default GPLid=""
  # esets contains two components: "esetGSE1657_GPL96_SC" and "esetGSE1657_GPL97_SC"
 }
}
