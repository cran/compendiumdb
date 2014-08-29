loadDataToCompendium <-
function(con, GSEid, GPLid = "", datadir = getwd()){

  user <- con$user
  password <- con$password
  host <- con$host
  dbname <- con$dbname

  x <- list.dirs(path=datadir,recursive=FALSE)
  if(length(grep("/BigMac$",x))==0){
    return(paste("Data directory BigMac is not present in",datadir,"!"))
  }else{
    #attach(con)
    GPLid <- paste(GPLid,collapse="-")
    dir <- path.package("compendiumdb")

    scriptLoc <- paste(dir,"/scripts",sep="")
    scriptLoc <- gsub("^","\"",scriptLoc)
    scriptLoc <- gsub("$","\"",scriptLoc) 
	
    dataLoc <- datadir
    dataLoc <- gsub("^","\"",dataLoc)
    dataLoc <- gsub("$","\"",dataLoc)
	
    plFile <- paste(dir,"/scripts/Perl/loadAllforGSEeset.pl",sep="")
    plFile <- gsub("^","\"",plFile)
    plFile <- gsub("$","\"",plFile) 

    system(paste("perl -I",paste(dataLoc,"/BigMac/COMPENDIUM",sep=""),plFile,GSEid,dataLoc,scriptLoc,user,password,host,dbname,GPLid))
    #system(paste("perl",plFile,GSEid,dataLoc,scriptLoc,user,password,host,dbname,GPLid))
    #detach(con)
  }
}

