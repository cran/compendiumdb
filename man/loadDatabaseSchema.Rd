\name{loadDatabaseSchema}
\alias{loadDatabaseSchema}
\title{Load the compendium database schema
}
\description{
  Load a database schema file to the compendium database in the
  \code{MySQL} server
}
\usage{
  loadDatabaseSchema(con, updateSchema = FALSE , file = "")
}
\arguments{
   \item{con}{
     \code{list} containing a connection object specifying the user name
     and password to connect or interact with the compendium database
     (see \code{\link{connectDatabase}})
   }
  \item{updateSchema}{
    logical, default value is \code{FALSE}
  }
  \item{file}{
    character string, default value is \code{""}. In this case the \code{compendiaSchema.sql}
  database schema provided with the package is loaded.}
}
\details{
  See \url{http://www.bioinformaticslaboratory.nl/foswiki/bin/view/BioLab/CompendiumDB}
  for a detailed description of the database schema.
}
\author{
Umesh K. Nandal
}
\note{
  Execute this function only after having created the database
  specified in the connection object in the \code{MySQL} server. Set the \code{updateSchema}
  value \code{TRUE} only before filling the database with
  series record data for the first time, or if you want to delete all the records of the
  database and reload the schema. In the latter case the user will be prompted whether
  (s)he really wants to update the current schema and delete all data in
  the compendium database.
}

\seealso{
  \code{\link{connectDatabase}}
}
\examples{
 \dontrun{
  conn <- connectDatabase(user="usrname",password="passwd",dbname="compendium")
  loadDatabaseSchema(conn,updateSchema=TRUE)
 }
}
