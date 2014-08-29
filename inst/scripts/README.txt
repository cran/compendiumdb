BigMac - A directory that consists of Perl scripts for communicating with 
the Gene Expression Omnibus (GEO). Some Perl scripts are written to parse 
and load the data from SOFT files downloaded from GEO. The Perl scripts are 
grouped into sub-directories according to their functionality.


==== Scripts to download GEO SOFT files to the data/GEO directory ====
	getAllForGSE.pl


==== Scripts to load the SOFT files into the database =====
	deleteAllforGPL.pl
	deleteAllforGSE.pl
	load_notGDS.pl
	loadAllforGSEeset.pl
	loadGDS.pl
	loadGPL.pl
	loadGSM.pl
	loadGSMeset.pl
	parsingSoftFile_forESET.pl
	transpose.pl

========
annotation (directory)
	GPLxxx.annot files
	configuration (directory)
		configuration.txt
		gplLoadConf_GPL*.pl

========
COMPENDIUM(directory)
	compendiumSUB.pm
