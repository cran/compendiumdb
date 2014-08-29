connectDatabase <-
function(user, password, host = "localhost", dbname = "compendium")
{
  Sys.setenv(CYGWIN="nodosfilewarning")
  connect <- dbConnect(MySQL(), user=user, password=password, host=host)

  rs <- dbSendQuery(connect,paste("use",dbname))
  return(list(connect=connect,user=user, password=password, host=host,dbname=dbname))
}

