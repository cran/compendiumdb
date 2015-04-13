\name{GSMdescriptions}
\alias{GSMdescriptions}
\title{List sample annotation of samples for a given GSE
}
\description{
  Extract the phenotypic data of each sample record
  (GSM) in the specified GSE in a tabular format 
}
\usage{
GSMdescriptions(con, GSEid, GPLid = "")
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character string specifying the GSE ID
  }
  \item{GPLid}{
    character string specifying the GPL ID. The default value is
    \code{""}, in which case the phenotypic data will be
    extracted for each of the GPLs in the GSE specified by \code{GSEid}.
  }
}
\details{The function uses
  the corresponding GDS (if available for that GSE) in order to retrieve
  the phenotypic data. If a GDS is not available, it generates
  phenotypic data based on the sample characteristics, sample source,
  and sample title specified for each GSM. In case of a double-channel
  experiment, sample characteristics and sample source are given for both channels.
}
  
\value{
  A character \code{matrix} containing a row for each GSM and columns for the
  phenotypic data and the GPL ID(s) of the platform used. 
}
\author{
Umesh K. Nandal
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  GSMdescriptions(conn,"GSE1657")
 }
}
