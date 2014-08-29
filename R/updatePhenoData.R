updatePhenoData<-
function(con, data)
{    
  if (class(data)!="data.frame") stop("Argument 'data' must be a data frame")
  if (length(grep("GSM",rownames(data)))!=nrow(data)) stop("All rownames of the dataframe 'data' should correspond to a GSM ID")
	
  connect <- con$connect
  barcode <- paste(rownames(data),collapse="','")
  barcode <- sub("^","'",barcode)
  barcode <- sub("$","'",barcode)

  db_query_hybid <- paste("SELECT hybid FROM hyb WHERE barcode IN(",barcode,")",sep="")
  rs <- dbSendQuery(connect,db_query_hybid)
  hybid <- fetch(rs,n=-1)
  if (nrow(hybid)!=nrow(data)) stop("All rownames of the data frame 'data' should be valid GSM IDs of a GSE loaded in the compendium")

  #print(hybid)
  db_delete_description<-paste("DELETE FROM hyb_has_description WHERE hybid IN(",paste(hybid[,1],collapse=","),")",sep="")
  rs <- dbSendQuery(connect,db_delete_description)
	
  newdata <- cbind(hybid,data)
  colnames(newdata) <- c("hybid",colnames(data))

  for(i in 1:nrow(newdata))
    {
      hybid <- newdata[i,1]
      for(j in 2:ncol(newdata))
        {
          hyb_type <- colnames(newdata)[j]
          hyb_description <- newdata[i,j]
          
          query_insert <- paste("INSERT INTO hyb_has_description (hybid,hyb_type,hyb_description) VALUES(",hybid,",'",hyb_type,"','",hyb_description,"')",sep="")
          dbSendQuery(connect,query_insert)
        }
    }
}
