removeGSE <-
  function(con, GSEid){

   user <- con$user
   password <- con$password
   host <- con$host
   dbname <- con$dbname


    query_GSE <- paste("SELECT expname FROM experiment WHERE expname='",GSEid,"'",sep="")
    rs <- dbSendQuery(con$connect, query_GSE)
    gse <- fetch (rs, n= -1)
    dbClearResult(rs)
    if(nrow(gse)==0){return(paste("Experiment",GSEid,"has not been loaded in the compendium yet",sep=" "))}

    GPLid <- GSEinDB(con, GSEid)$Chip
      
    dir <- path.package("compendiumdb")

    plFile <- paste(dir,"/scripts/Perl/deleteAllforGSE.pl",sep="")
    plFile <- gsub("^","\"",plFile)
    plFile <- gsub("$","\"",plFile) 

    system(paste("perl",plFile,GSEid,user,password,host,dbname))

    ## remove the corresponding GPLs if there are no experiments with this GPL ID left
    plFile <- paste(dir,"/scripts/Perl/deleteAllforGPL.pl",sep="")
    plFile <- gsub("^","\"",plFile)
    plFile <- gsub("$","\"",plFile)

    for (id in GPLid){
      GSEinDB <- GSEinDB(con)
      if (!(is.data.frame(GSEinDB)) || !(id %in% GSEinDB$Chip)){
       system(paste("perl",plFile,id,user,password,host,dbname))
     }
    }
    
    #detach(con)
}
