\name{downloadGEOdata}
\alias{downloadGEOdata}
\title{Download a GSE from GEO
}
\description{
  Downloads the SOFT files for the GSE, GPLs, GSMs, and GDSs
  corresponding to the GSE identifier provided by the user from GEO to
  the user's local machine
}
\usage{
downloadGEOdata(GSEid, destdir = getwd())
}
\arguments{
  \item{GSEid}{
    character string specifying the GSE to be downloaded from GEO
  }
  \item{destdir}{
    directory where to store the SOFT files downloaded from GEO. The
    default directory is a subdirectory of the current working directory.
  }
}

\details{
  In the Gene Expression Omnibus (GEO) high-throughput experimental data
  is stored in SOFT (Simple Omnibus Format in Text) file
  format. Examples are the  series record (GSE), the sample record
  (GSM), the platform record (GPL), and the dataset record (GDS).
  More information about the different types of SOFT files can be
  found at \url{http://www.ncbi.nlm.nih.gov/geo/info/overview.html}. \cr
  The function \code{downloadGEOdata} creates a data directory called
  \code{BigMac} in a directory \code{destdir} specified by the user.
  The \code{BigMac} directory contains several subdirectories:
  \code{annotation}, \code{COMPENDIUM}, \code{data} and \code{log}.
  The \code{data} directory contains further subdirectories to store
  the downloaded \code{.soft} files corresponding to GSEs, GSMs, GPLs,
  and GDSs downloaded from GEO. More information about the structure of
  the \code{BigMac} directory can be found at
  \url{http://www.bioinformaticslaboratory.nl/twiki/bin/view/BioLab/CompendiumDB}.
}
\author{
Umesh Nandal
}
\note{
  If the \code{BigMac} directory already exists, the function
  \code{downloadGEOdata} will try to store the downloaded data
  in the existing directory structure. Therefore, in order to
  avoid errors do not change \code{BigMac}'s directory structure. 
}

\seealso{
\code{\link{loadDatabaseSchema}}, \code{\link{loadDataToCompendium}}
}
\examples{
 \dontrun{
  # This will download the files related to the specified GSE from GEO to the BigMac directory 
  # in the user's current working directory
  downloadGEOdata(GSEid="GSE23183")
 }
}
