GDSforGSE <-
function (con, GSEid) 
{
  connect <- con$connect

  ###########Get idExperiment for the GSE
  if(!is.character(GSEinDB(con,)))
    {
      results <- GSEinDB(con,)
      i <- which(results$Experiment %in% GSEid)
				
      if(length(i)==0){return(paste("Experiment",GSEid,"has not been loaded in the compendium yet",sep=" "))}

      results <- results[i,]
      j <- which(is.na(results[,"GDS"]))
      noGDS <- unique(results[j,"Experiment"]) ### GSE IDs without a GDS
      k <- which(!GSEid %in% results$Experiment) ### If GSE ID is not in the compendium

      results <- results[which(!is.na(results[,"GDS"])),]			
      if(nrow(results)==0){return(paste("Experiment",GSEid," does not have a GDS",sep=" "))}
      else if(length(noGDS)!=0){print(paste("Experiment",noGDS,"does not have a GDS",sep=" "))}
      if(length(k)!=0){print(paste("Experiment",GSEid[k],"has not been loaded in the compendium yet",sep=" "))}
      rownames(results)=c(1:nrow(results))
      results
    }else{
      return("No experimental data has been loaded in the compendium yet!")
    }	
}

