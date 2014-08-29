GSEinDB <-
  function (con, GSEid = NULL) 
  {
    Sys.setenv(CYGWIN="nodosfilewarning")
    subGSEinDB <- function(con,GSEid=NULL)
    {      
      con <- con$connect
    
      query_GSM_inDB <- paste("SELECT eh.idExperiment as id_Compendium,count(h.hybid) as Samples, chip.db_platform_id as Chip, h.expdesign as experimentDesign FROM experiment_has_hyb eh 
                              INNER JOIN hyb h ON (eh.hybid =h.hybid) 
                              INNER JOIN chip ON h.idchip=chip.idchip 
                              GROUP BY  eh.idExperiment, h.idchip ORDER BY eh.idExperiment",sep="")
      
      query_GSEquery_inDB <- paste("SELECT distinct e.idExperiment as id_Compendium, e.expname as Experiment, e.tag as Tag, chip.db_platform_id as Chip, org.ncbiorgid as OrganismNCBIid, org.officialname as OrganismName, e.date_loaded 
                                   FROM experiment e 
                                   JOIN experiment_has_hyb eh ON e.idExperiment=eh.idExperiment 
                                   JOIN hyb ON eh.hybid=hyb.hybid 
                                   JOIN chip ON hyb.idchip=chip.idchip 
                                   JOIN organism org ON chip.idorganism=org.idorganism order by e.idExperiment",sep="")
      
      query_GDS_inDB <- paste("SELECT distinct e.idExperiment as id_Compendium, e.expname as Experiment, e.tag as Tag, chip.db_platform_id as Chip, gds.GDS 
                              FROM experiment e 
                              JOIN experiment_has_hyb eh ON e.idExperiment=eh.idExperiment 
                              JOIN hyb ON eh.hybid=hyb.hybid
                              JOIN gds on hyb.idGDS=gds.idGDS 
                              JOIN chip ON hyb.idchip=chip.idchip order by e.idExperiment",sep="")
      
      
      rs <- dbSendQuery(con, query_GSM_inDB)
      samples_inDB <- fetch (rs, n= -1)
      dbClearResult(rs)
      if(!nrow(samples_inDB)){
        stop("The compendium is empty. No GSE data has been loaded yet")
      }
      
      rs <- dbSendQuery(con, query_GSEquery_inDB)
      idExperiment_inDB <- fetch (rs, n= -1)
      Date <- idExperiment_inDB["date_loaded"]
      idExperiment_inDB <- idExperiment_inDB[-grep("date_loaded",colnames(idExperiment_inDB))]
      dbClearResult(rs)
      
      rs <- dbSendQuery(con, query_GDS_inDB)
      gds_inDB <- fetch (rs, n= -1)
      dbClearResult(rs)
      
      results <- merge(idExperiment_inDB,samples_inDB,by=c("id_Compendium","Chip"),all.x=TRUE)
      
      idExperiment_inDB_na<-is.na(idExperiment_inDB)      
      reshead <- c("id_Compendium","Experiment","experimentDesign","Chip","Samples","Tag","OrganismNCBIid","OrganismName","GDS")
      if(nrow(gds_inDB)!=0){
        y <- merge(results,gds_inDB,by=c("Experiment","Chip"),all.x=TRUE)
        y <- y[order(y$id_Compendium.x),c("id_Compendium.x","Experiment","experimentDesign","Chip","Samples","Tag.x","OrganismNCBIid","OrganismName","GDS")]
        rownames(y) <- c(1:nrow(y))
        results <- y
      }else{
        results <- results[,c("id_Compendium","Experiment","experimentDesign","Chip","Samples","Tag","OrganismNCBIid","OrganismName")]
        results <- cbind(results,NA)
      }
      
      colnames(results) <- reshead
      results <- cbind(results,Date)
      
      temp <- array(NA,dim=c(1,ncol(results)))
      colnames(temp) <- colnames(results)	
      
      noGSE=character()
      if(length(GSEid)!=0){
        for(id in GSEid){
          if(id %in% results[,"Experiment"]){ # For exact matching 
            temp <- rbind(temp,results[results$Experiment==id,])
          }else{ 
            noGSE <- c(noGSE,id)
          }
        }
        finalResult <- temp[-1,]
        if(length(noGSE)!=0){return(c(noGSE,"has not been loaded in the compendium yet"))}
        
        if(nrow(finalResult)){
          rownames(finalResult) <- c(1:nrow(finalResult))
          return(finalResult)
        }        
      }else{
        
        if((is.null(idExperiment_inDB_na))){
          return("The compendium is empty: no GSE data has been loaded yet")
        }else{ return(results)}
        
      }
      
    }
    
    possibleError <- tryCatch(
      subGSEinDB(con,GSEid=GSEid),
      error=function(e) e
    )
    
    if(length(grep("Table .* doesn't exist",as.character(possibleError)))){
      return("Please check if the database schema has already been loaded (see loadDatabaseSchema function)")
    }else if(length(grep("compendium is empty",as.character(possibleError)))){
      return("The compendium does not have any GSE data loaded. Load the data to the compendium using loadDataToCompendium function")
    }else if(length(grep("not been loaded in the compendium",as.character(possibleError)))){
      return(paste(possibleError,collapse=" "))
    }else {
      return(possibleError)
    }
  }
