createESET <-
function (con, GSEid, GPLid = "", parsing = TRUE) 
{
  connect <- con$connect
  user <- con$user
  password <- con$password
  host <- con$host
  dbname <- con$dbname
    
  idGSE <- GSEinDB(con,GSEid)

  if(GPLid==""){
    
    query_GSE <- paste("SELECT DISTINCT chip.db_platform_id FROM chip 
			INNER JOIN hyb ON chip.idchip=hyb.idchip 
			INNER JOIN experiment_has_hyb eh ON hyb.hybid=eh.hybid 
			INNER JOIN experiment e ON eh.idExperiment=e.idExperiment 
			WHERE e.expname='",GSEid,"'",sep="")
    rs <- dbSendQuery(connect, query_GSE)
    GPL <- fetch(rs, n = -1)
    dbClearResult(rs)
	
    if(nrow(GPL)==0){
      return(paste("Experiment with",GSEid,"has not been loaded in the compendium yet.",sep=" "))	
    }
    newEset <- c()
    for(i in 1:dim(GPL)[1]){
      esetX <- createESET(con=con,GSEid=GSEid,GPLid=GPL[i,1],parsing)
      newEset <- c(newEset,esetX)
    }

    newEset

  }else{

    esets <- list()

    expDesign <- idGSE[idGSE$Chip==GPLid,"experimentDesign"]
    query <- paste("SELECT count(*) FROM expressionset e
	   		INNER JOIN chip ON e.idchip=chip.idchip
                        INNER JOIN experiment ex ON e.idExperiment=ex.idExperiment
                        WHERE chip.db_platform_id =\'",GPLid,"\' and ex.expname=\'",GSEid,"\'",sep="")
	
    rs <- dbSendQuery(connect, query)
    rsError <- fetch(rs, n = -1)
    dbClearResult(rs)
	
    dir <- path.package("compendiumdb")

    scriptLoc <- paste(dir,"/scripts",sep="")
    scriptLoc <- gsub("^","\"",scriptLoc)
    scriptLoc <- gsub("$","\"",scriptLoc)

    plFile <- paste(dir,"/scripts/Perl/fetchESET.pl",sep="")
    plFile <- gsub("^","\"",plFile)
    plFile <- gsub("$","\"",plFile)
	
    if(rsError!=0){
      system(paste("perl",plFile,GSEid,GPLid,scriptLoc,user,password,host,dbname))
      
      load("output.RData")	
      system("mv output.RData oldOutput.RData")
      
      phenoData_all <- GSMdescriptions(conn=con,GSEid=GSEid,GPLid=GPLid)
      phenoData <- phenoData_all[which(phenoData_all[,"GPL"]==GPLid),]
			
      ### One-channel experiment: parsing 'samplechar' for phenodata ######
      if(length(grep("samplechar",colnames(phenoData)))){
        if(parsing && expDesign=="SC"){
          cat("Parsing phenoData")
          phenoData <- parseSampleAnnot(phenoData,"samplechar")				
        }
      }

      ### Two-channel experiment: parsing label columns for phenodata ######
      if(length(grep("samplesource_ch2",colnames(phenoData)))){
        if(parsing && expDesign%in%c("CR","DC","DS")){
          cat("Parsing phenoData")
          labels <- colnames(phenoData)[1:2]
          phenoData <- parseSampleAnnot(phenoData,labels[2])				
          phenoData <- parseSampleAnnot(phenoData,labels[1])					
        }
      }
	
      if(length(compendiumESet) > 1){
        for(i in 1:length(compendiumESet)){
          x <- match(colnames(exprs(compendiumESet[[i]])),rownames(phenoData))
          phenoD <- as.data.frame(phenoData[x,], row.names = NULL, optional = FALSE)
          phenoD <- new("AnnotatedDataFrame",data=phenoD)
          phenoData(compendiumESet[[i]])=phenoD
          annotation(compendiumESet[[i]])=GPLid
        }
      }else{
        phenoData <- as.data.frame(phenoData, row.names = NULL, optional = FALSE)
        phenoData <- new("AnnotatedDataFrame",data=phenoData)
        phenoData(compendiumESet) <- phenoData
        annotation(compendiumESet) <- GPLid
      }

	name <- paste("eset",GSEid,"_",GPLid,sep="")
	esets[name]<-compendiumESet

    }else{
      cat(paste("Platform ",GPLid," has been not loaded in the compendium for ",GSEid,"!\n",sep=""))
    }
    if(length(esets)){esets}
  }
}

