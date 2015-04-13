\name{loadDataToCompendium}
\alias{loadDataToCompendium}
\title{Load GSE into the compendium database
}
\description{
  Load the data from SOFT files corresponding to the
  specified GSE and GPL(s) into the tables of the \code{MySQL}
  compendium database
}
\usage{
loadDataToCompendium(con, GSEid, GPLid = "", datadir = getwd())
}
\arguments{
  \item{con}{
    \code{list} containing a connection object specifying the user name
    and password to connect or interact with the compendium database
    (see \code{\link{connectDatabase}})
  }
  \item{GSEid}{
    character string specifying the GSE ID to be loaded into the

    compendium database
  }
  \item{GPLid}{
    character vector specifying  the GPL ID(s). The default value is
    \code{""} and will load all the GPL ID(s) corresponding to the GSE
    specified by \code{GSEid}.
  }
  \item{datadir}{
    directory where the BigMac directory used for storing the SOFT files
    downloaded from GEO has been created (see
    \code{\link{downloadGEOdata}}). The default directory is
    the current working directory.
  }
}
\details{
  The SOFT files downloaded from GEO using the function
  \code{\link{downloadGEOdata}} are parsed and loaded into the
  compendium database. This function can be called once all the
  SOFT files corresponding to the specified \code{GSEid} have been downloaded
  to the \code{BigMac} directory (see \code{\link{downloadGEOdata}}).
  The \code{BigMac} directory should be a subdirectory of the directory specified by the
  user via the argument \code{datadir}. The \code{GPLid} argument provides
  the option to only load the data for a specific platform.  
}
\author{
Umesh K. Nandal
}
\seealso{
  \code{\link{downloadGEOdata}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  downloadGEOdata("GSE1657")

  # GSE1657 has GPL96 and GPL97 platform data. Load only GPL96 data
  loadDataToCompendium(conn,"GSE1657","GPL96")

  # Load both GPL96 and GPL97 as a character vector
  loadDataToCompendium(conn,"GSE1657",c("GPL96","GPL97"))
  # Both platforms can also be loaded using the default value for GPLid

  # Load multiple GSEs to the compendium
  for (i in  c("GSE4251","GSE6495","GSE12597","GSE1657")){
   loadDataToCompendium(con=conn,GSEid=i)
  }
 }
}
