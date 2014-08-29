GSEforGPL <-
function (con, GPLid) 
{
  connect <- con$connect

  ###########Get idExperiment for the GSE
  if(!is.character(GSEinDB(con,)))
    {
      results <- GSEinDB(con,)
      i <- which(results$Chip %in% GPLid)
      k <- which(!GPLid %in% results$Chip)
		
      if(length(i)==0){return(paste("Experiments corresponding to platform",GPLid,"have not yet been loaded in the compendium",sep=" "))}
      if(length(k)!=0){print(paste("Experiments corresponding to platform",GPLid[k],"have not yet been loaded in the compendium",sep=" "))}

      results <- results[i,]
      rownames(results) <- c(1:nrow(results))
      results
    }else{
      return("No experimental data has been loaded in the compendium yet!")
    }
}

