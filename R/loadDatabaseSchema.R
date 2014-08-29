loadDatabaseSchema <-
function(con, updateSchema = FALSE, file = ""){

  if(updateSchema){
    response <- readline("You have set updateSchema equal to 'TRUE'. This will update your current schema and delete all data in the compendium database. Type 'y' if you want to continue, type 'n' if you don't want to update the schema:\n")
    if(response=='y'){
      connect <- con$connect
      dir <- path.package("compendiumdb")
      if(file==""){
        file <- paste(dir,"/extdata/compendiumSchema.sql",sep="")
      }
	
      File <- readLines(file)
      dbFile <- gsub('^--.*',"",File)
      dbFile <- strsplit(paste(dbFile,collapse=""),";")
      dbFile <- unlist(dbFile)
		
      rs <- dbSendQuery(connect,paste("use",con$dbname))
      print("Loading database ...")
		
      for(i in 1:length(dbFile))
        {
          percent <- round((i*100)/length(dbFile))
          print(paste("....",percent,"%"))
          rs <- dbSendQuery(connect,dbFile[i])
        }
	
      ## Load organism table to the compendium database. This table has been constructed using information 
      ## from NCBI Taxonomy and from organism contained in GEO according to GEOmetadb
      orgFile <- paste(dir,"/extdata/compendiumOrganismTable.txt",sep="")
      query <- paste("LOAD DATA LOCAL INFILE '",orgFile,"' INTO TABLE organism FIELDS TERMINATED BY '@' LINES TERMINATED BY '\n' (ncbiorgid,officialname,shortname)",sep="")
      rs <- dbSendQuery(connect, query)	
	
      print("... Done!")
    }
  }else{print("Set updateSchema=TRUE to delete all the content of compendium database and reload the schema")}
}

