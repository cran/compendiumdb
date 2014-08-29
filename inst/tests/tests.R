## PM300114
##
## Code for testing functions of the compendiumdb package

library(compendiumdb)
conn <- connectDatabase(user="root",password="root",dbname="compendium")

########## function connectDatabase

## sensible error message when using a wrong username or password
conn <- connectDatabase("root","root")

########## function downloadGEOdata

## appropriate message for a GSE that has already been downloaded to the BigMac directory
downloadGEOdata("GSE1456")
## Remark: GSMs are always downloaded again

## appropriate message for a GSE that does not exist
downloadGEOdata("GSE123456")

## appropriate message for a GSE that is not public
downloadGEOdata("GSE50500")

########## function loadDataToCompendium

## appropriate messages if the data has already been loaded
loadDataToCompendium(conn,"GSE1456")

## appropriate message if the data has not been downloaded to BigMac directory yet
loadDataToCompendium(conn,"GSE1458")

## Loading data for a non-standard species (Danio rerio) is now also possible
loadDataToCompendium(conn,"GSE13371")

## This platform cannot be loaded in the current version of the package, since
## 'environmental samples' does not have a unique NCBI Taxonomy ID
loadDataToCompendium(conn,"GSE20501")

########## function GSEinDB

## regular output
GSEinDB(conn,"GSE1456")

## appropriate error message for a GSE not in the compendium
GSEinDB(conn,"GSE1458")

########## function GDSforGSE

## regular output
GDSforGSE(conn,"GSE5093")

## appropriate message for GSE without a GDS
GDSforGSE(conn,"GSE12589")

## appropriate message for a GSE not in the compendium
GDSforGSE(conn,"GSE12599")

########## function GSEforGPL

## regular output
GSEforGPL(conn,"GPL96")

## appropriate message for a GPL without a GSE in the compendium
GSEforGPL(conn,"GPL98")

########## function GSMdescriptions

## regular output
GSMdescriptions(conn,"GSE18290")

## appropriate error message for GSE (or a combination of GSE and GPL) not in the database
GSMdescriptions(conn,"GSE18920")
GSMdescriptions(conn,"GSE1456",GPLid="GPL98")

## regular output for a single-channel (SC) design: samplechar
GSEinDB(conn,"GSE1456")
desc = GSMdescriptions(conn,"GSE1456","GPL96")
head(desc)
class(desc)

## regular output for a common reference (CR) design: Cy3 & Cy5, common referenc in Cy5
GSEinDB(conn,"GSE24151")
desc = GSMdescriptions(conn,"GSE24151")
head(desc)
class(desc)

## regular output for a common reference (CR) design: Cy5 & Cy3, common reference in Cy3
GSEinDB(conn,"GSE4576")
desc = GSMdescriptions(conn,"GSE4576")
head(desc)
class(desc)

## regular output for a common reference (CR) design: cy3 & cy5, common reference in cy3
GSEinDB(conn,"GSE5093")
desc = GSMdescriptions(conn,"GSE5093")
head(desc)
class(desc)

## regular output for a dye-swap (DS) design: Cy3 & Cy5
GSEinDB(conn,"GSE12589")
desc = GSMdescriptions(conn,"GSE12589")
head(desc)
class(desc)

## regular output for a general double-channel (DC) design: Cy3 & Cy5.
GSEinDB(conn,"GSE25506")
desc = GSMdescriptions(conn,"GSE25506")
head(desc)
class(desc)

########## function createESET

## createESET with parsing=TRUE should remove leading spaces when parsing the phenoData: single-channel design
createESET(conn,"GSE4922")
pData(esetGSE4922_GPL96)$Lymph_node_status

## createESET with parsing=TRUE: a single ; in a tag should be handled OK now
head(pData(esetGSE4922_GPL96))

## createESET with parsing=TRUE should detect and correct sample characteristics without
## a tag (missing :)
createESET(conn,"GSE1456","GPL96")
head(pData(esetGSE1456_GPL96))

## createESET with parsing=TRUE: also works for a double-channel design
createESET(conn,"GSE4576")
head(pData(esetGSE4576_GPL3606))

## everything also works for a RT-PCR based miRNA experiment
createESET(conn,"GSE38716")
head(pData(esetGSE38716_GPL15695))

## everything also works for a whole genome aCGH experiment
createESET(conn,"GSE48835")
head(pData(esetGSE48835_GPL16707))

## everything also works for a whole genome methylation array
createESET(conn,"GSE40919")
head(pData(esetGSE40919_GPL16062))

## PM: everything also works for a whole genome ChIP array (Candida albicans)
createESET(conn,"GSE41237")

## featureData for a dataset with a .annot file
createESET(conn,"GSE11651")
head(fData(esetGSE11651_GPL2529))
tail(fData(esetGSE11651_GPL2529))

## featureData for a dataset without a .annot file
createESET(conn,"GSE12589")
head(fData(esetGSE12589_GPL6848))

## compare the expression values obtained via GEOquery and compendiumdb
library(GEOquery)
eset = getGEO("GSE11651")[[1]]
identical(exprs(eset)["1769308_at",],exprs(esetGSE11651_GPL2529)["1769308_at",])
identical(exprs(eset),exprs(esetGSE11651_GPL2529)[featureNames(eset),])

########## function removeGSE

## appropriate message when trying to remove a GSE not in the compendium yet
removeGSE(conn,"GSE1234")

######### function tagExperiment

## appropriate message when trying to tag a GSE not in the compendium yet
tagExperiment(conn,"GSE1234")

######### updatePhenoData

## appropriate message if the GSMs indicated as rownames are not in the compendium yet
barcode  <- c("GSM28491A","GSM28479A","GSM30659A","GSM30655A")
barcode  <- c("GSM28491A","GSM28479","GSM30659","GSM30655")
cellLine <- c("primary culture","primary culture","transduced","transduced")
tissue   <- c("omental","omental","subcutaneous","subcutaneous")
tab      <- data.frame(cellLine,tissue)
rownames(tab) <- barcode
tab
updatePhenoData(conn,tab)

## appropriate message if the rownames are no GSM IDs
barcode  <- c("GS28491","GS28479","GS30659","GS30655")
rownames(tab) <- barcode
updatePhenoData(conn,tab)

## appropriate message if the argument 'data' is not a data frame
updatePhenoData(conn,matrix(tab))

loadDataToCompendium(conn,"GSE20073")
