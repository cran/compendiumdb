\name{connectDatabase}
\alias{connectDatabase}
\title{Create connection with the MySQL compendium database
}
\description{
Allows the user to create a connection with the compendium database in the \code{MySQL} server
}
\usage{
connectDatabase(user, password, host = "localhost", dbname = "compendium", port = 3306)
}
\arguments{
  \item{user}{
    character string defining the \code{MySQL} user name to login to the database
  }
  \item{password}{
    character string defining the password required to connect to the \code{MySQL} database
  }
  \item{host}{
    character string defining the host name. The default value is
    \code{"localhost"}. One can also connect to a remote server by
    defining a valid value for the host name, e.g.,
    \code{"machinename.\domain.\org"}.
  }
  \item{dbname}{
    character string defining the name of the compendium database to
    which one wants to establish a connection. The default value is
    \code{"compendium"}.    
  }
\item{port}{
    port number used to connect to the \code{MySQL} server. The default 
    port number is 3306.
  }

}
\details{
The compendium database has to be created first, see the package
vignette for how to do this from the MySQL prompt.
}
\value{
A \code{list} with components
\item{connect }{a component of class \code{MySQLConnection} containing the connection to the \code{MySQL} database}
\item{user }{character string containing the user name}
\item{password }{character string containing the password}
\item{host }{character string containing the host name}
\item{port }{port number used to connect to the \code{MySQL} server}
\item{dbname }{character string containing the database name}
}
\author{
Umesh K. Nandal
}
\note{
Do not check the returned value of this function, since this might abort the current R session. 
\code{summary(conn)} can be used to check the returned \code{list}.
}

\examples{
 \dontrun{
  # Connect to a database with name "compendium"
  conn <- connectDatabase(user="usrname",password="passwd",host="localhost",dbname="compendium")
 }
}
\keyword{connect}
