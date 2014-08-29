\name{GSMdescriptions}
\alias{GSMdescriptions}
\title{List sample annotation of samples in an experiment
}
\description{
  Extract the phenotypic data of each sample record
  (GSM) in the specified GSE in a tabular format 
}
\usage{
GSMdescriptions(conn, GSEid, GPLid = "")
}
\arguments{
  \item{conn}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character string specifying the GSE ID
  }
  \item{GPLid}{
    character vector specifying the GPL ID. The default value is
    \code{""}, in which case the phenotypic data will be
    extracted for each of the GPLs in a GSE
  }
}
\details{The function uses
  the corresponding GDS (if available for that GSE) in order to retrieve
  the phenotypic data. If a GDS is not available, it generates
  phenotypic data based on the sample characteristics, sample source,
  and sample title specified for each GSM. In case of a double-channel
  experiment sample characteristics and sample source are given for both channels.
}
  
\value{
  A character matrix containing a row for each GSM and columns for the
  phenotypic data and the GPL ID of the platform used. 
}
\author{
Umesh Nandal
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  GSMdescriptions(conn,"GSE1657")
 }
}
