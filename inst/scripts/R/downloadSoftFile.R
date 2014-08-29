msg <- file("message.log", open="wt")
sink(msg,type="message")
sink(msg,type="output")
options(warn = -1, showWarnCalls=FALSE)
filename <- commandArgs(trailingOnly = T)

print(filename)
url1 <- "http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?targ=self&acc="
url2 <- "&form=text&view=full"

urlink <- paste(url1,filename[1],url2,sep="")
flag <- as.numeric(filename[3])

download.file(urlink,paste(filename[2],".soft",sep=""),mode="wget",quiet=TRUE)

if(flag){
  url3 <- "ftp://ftp.ncbi.nlm.nih.gov/pub/geo/DATA/SOFT/by_series/"
  softfile <- paste(filename[1],"_family.soft.gz",sep="")
  ftplink <-  paste(url3,filename[1],"/",softfile,sep="")
  download.file(ftplink,paste(filename[2],"_family.soft.gz",sep=""),mode="wget",quiet=TRUE)

  gseFamily <- gzfile(paste(filename[2],"_family.soft.gz",sep=""))
  write(readLines(gseFamily),paste(filename[2],"_family.soft",sep=""))
}
