#!/usr/bin/perl 
$|=1;

######################################### Defining Variables ##################################################

use compendiumSUB;
use LWP::UserAgent;
use Net::FTP;
use warnings;
use strict;
use Cwd;
use LWP::Simple;

my($gse, $bigMacLocation,$scriptsLoc) = @ARGV;

my $geodatabasedir = "$bigMacLocation/BigMac/data/GEO";
my $input = $gse;
my @GSE_to_reload;
my @oldEpochs;
my @epochs;
my @finalEpoch;
my $folder = "$geodatabasedir/GPL"; ### updated 9-3-2011
my $annotdir = $bigMacLocation;
my $found = 0;
my $target;
my $softfilepath = $geodatabasedir;
my $OS = $^O;

$geodatabasedir =~ s/\//\\\"\/\\\"/g;
$geodatabasedir =~ s/\\\"//;
$geodatabasedir =~ s/$/\\\"/;

###########################################################################################################

#################################### To create log file ###################################################

open (INPUTLOG,"$bigMacLocation/BigMac/log/log_getAllForGSE.txt");

while (<INPUTLOG>)
{
	my $string=$_;
	chomp ($string);
	$string =~ s/\r//;
	push(@GSE_to_reload,$string);
}
close INPUTLOG;

##########################################################################################################

my $CUR_DIR = $bigMacLocation ;
my @GSE;
push(@GSE,$gse);


############################### Get GPLs and GDSs for the GSE ############################################

my %GDS_and_GPL_for_GDS = get_GPLs_and_GDSs_for_known_GSEs ( @GSE );
my @these_GPLs;
my @these_GDSs;
my $hi=0;
if(! keys %GDS_and_GPL_for_GDS){ print "This is not a valid public GSE or http://www.ncbi.nlm.nih.gov/entrez/eutils is down. Please check and try again later \n"; exit;}
foreach my $this_GSE ( keys %GDS_and_GPL_for_GDS )
{
	@these_GPLs = @{ ${ $GDS_and_GPL_for_GDS{$this_GSE} } { "GPLs" } };
        @these_GDSs = @{ ${ $GDS_and_GPL_for_GDS{$this_GSE} } { "GDSs" } };
        print "GSE: $this_GSE\n";
        print "GPLs: @these_GPLs\n";
        print "GDSs: @these_GDSs\n\n";
}

#########################################################################################################


if(-e "$folder/epoch.txt") {
	open(FH, "< $folder/epoch.txt") || die "Cannot open: $folder/epoch.txt";

	@oldEpochs = <FH>;
	@epochs = @oldEpochs;
	close FH;
}

opendir(DIR,"$bigMacLocation/BigMac/data/GEO/GPL");
my @gplfiles=readdir(DIR);
my $gplTag=1;
close DIR;

opendir(DIR,"$bigMacLocation/BigMac/annotation/configuration");
my @configfiles=readdir(DIR);
close DIR;

my $configfiles=join("|",@configfiles);

##################### Creating configuration file for each GPL ##########################################

foreach my $GPL (@these_GPLs)
{
	$gplTag=1;
	foreach my $file(@gplfiles)
        {
	       if($file =~ /$GPL\.soft/)
	       {
               	$gplTag=0;
			if($configfiles =~ /$GPL\.pl/)
	       	{	
              		$gplTag=0;
			}else{$gplTag=1;}
               }
        }

	############ Creating or updating epoch.txt ###################################
	if($gplTag)
        {
		foreach my $epoch (@oldEpochs)
	        {
			chomp($epoch);
			$epoch =~ s/.annot.gz\/.*//g;
			if($epoch eq $GPL) {
				$found = 1;
				$target = $epoch;
			}
		}

		if($found == 1) {
			foreach my $epoch (@epochs)
	                {
				if($epoch =~ /^$target/) {
					print "Removing epoch date for: ",$target,"\n";
					next; #### Is there any use of next here? There is no more code to skip to go to the next iteration.
				}
				else
	                        {
					push(@finalEpoch, $epoch);
				}
			}
		}
		else
	        {
			@finalEpoch = @epochs;
		}

		open (FH, "> $folder/epoch.txt") || die "Cannot open: $folder/epoch.txt";

		foreach my $line (@finalEpoch)
	        {
			#print $line,"\n";
			if($line =~ /^GPL.*/) {
				print FH $line,"\n";
			}
		}
		close FH;

		########################################################################

		################### Create configuration files for GPL ################################

	      my $page = get ("http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc=$GPL");
	      $page =~ s/\n//g;
	      $page =~ /Organism(.+?)a><\/td>/;
	      my $organism = $1;
	      my @organisms = $organism =~ /\)\">(.*?)<\//g;
	      my $organism_flag = 0;
		my $l=0;
		my @GB_ACC;
	        foreach my $organisms (@organisms)
	        {
	        	if ($organisms ne "Homo sapiens" & $organisms ne "Mus musculus" & $organisms ne "Rattus norvegicus")
	                {
	                	$organism_flag = 1;
	                  last;
	                }
	        }

	        open (INPUT,"$annotdir/BigMac/annotation/configuration/configuration.txt");
	        open (OUT1, ">$annotdir/BigMac/annotation/configuration/gplLoadConf_$GPL.pl");

	        while (<INPUT>)
	        {
		        my $string = $_;
	                chomp ($string);
	                print OUT1 "$string\n";
	        }

		chomp ($GPL);
	        $GPL =~ s/ //g;


	        if ($organism_flag == 0)
	        {
	                $page =~ /Data table header descriptions(.+?)<\/table>/;
	                my $part = $1;
	       	        my $double;
        	          my @columns = $part =~ /<strong>(.*?)<\/strong>/g;
	                my $j = 0;

	                foreach my $column (@columns)
	                {
				chomp ($column);

	        		if ($column eq "GB_ACC")
	        		{
				  push (@GB_ACC,$l);
				  $j++;
				}
	       			$l++;
	                }

			if ($j==1)
	                {
			        print OUT1 "\$confdb{'gbaccession'}= $GB_ACC[0];\n";
	                }
			else
			{
				print OUT1  "\$confdb{'gbaccession'}= -1;\n";
			}
		}
	      else
	      {
	      	print OUT1  "\$confdb{'gbaccession'}= -1;\n";
		}

		print OUT1  "\$conf{'gpl'} = \"$GPL\";";
		close OUT1;
		close INPUT;
	}
}

#########################################################################################

###################### Download headers of GDS.soft files ###############################

my @GDS_log;
my $dirPATH = $CUR_DIR;

$dirPATH =~ s/\//\\\"\/\\\"/g;
$dirPATH =~ s/\\\"//;
$dirPATH =~ s/$/\\\"/;

$scriptsLoc =~ s/\//\\\"\/\\\"/g;
$scriptsLoc =~ s/\\\"//;
$scriptsLoc =~ s/$/\\\"/;

if($OS eq "linux"){
	$scriptsLoc =~ s/\"//g;        	#### use it when calling the script in Linux
	$dirPATH =~ s/\"//g; 		#### use it when calling the script in Linux
}else{
	$scriptsLoc =~ s/\\/\\\\/g;
	$dirPATH =~ s/\\/\\\\/g;
}

opendir(DIR,"$bigMacLocation/BigMac/data/GEO/GDS_description");
my @files=readdir(DIR);
my $gdsTag=1;
close DIR;


foreach my $GDS (@these_GDSs)
{
	foreach my $file(@files)
        {
	       if($file =~ /$GDS\.txt/)
	       {
			print $file." has already been downloaded \n";
               		$gdsTag=0;
               }
        }

	if($gdsTag)
        {
		unless(-s "$geodatabasedir/GDS_description/$GDS.txt")
		{
			print "\nCurrently downloading $GDS\n";
			my $ncbi_dataset_filename = $GDS.".soft.gz";

	                ################## Download #################################

			my $local_dir = $CUR_DIR;

			my $if_downloaded = download_file_from_ftp ( "ftp.ncbi.nlm.nih.gov", "pub/geo/DATA/SOFT/GDS", $ncbi_dataset_filename, '', $local_dir );
                        #print $if_downloaded;
			if( !$if_downloaded )
			{
				print "$ncbi_dataset_filename was not downloaded";
			}else{
				#Unzip and delete archived files
				system ("Rscript $scriptsLoc/gzipScript.R $dirPATH/$ncbi_dataset_filename $dirPATH/$GDS");
				open (INPUT, "$bigMacLocation/$GDS.soft")|| die "Cannot open the file. Make sure that the path for destdir is correct.";
				#print "$CUR_DIR/$GDS.soft\n";
				my $descr="";
				while ( <INPUT> )
				{
				        $descr = $descr.$_;
				        last if ( ( $_ =~ /^!dataset_table_begin/ ) );
				}
				open (OUT, ">$softfilepath/GDS_description/$GDS.txt");
				print OUT "$descr";
				close OUT;
				close INPUT;
				unlink ("$CUR_DIR/$GDS.soft");
				if (!(-e "$geodatabasedir/GDS_description/$GDS.txt"))
				{
					push(@GDS_log,$GDS);
				}
                        }
		}
	}
}

######################################################################################################

########################## Download GSE file ##########################################################

my($slaap) = 0;
my($url,$cmnd);

my $comment = "\nDownloading $gse.soft ...\n";
print "$comment";

opendir(DIR,"$bigMacLocation/BigMac/data/GEO/GSE");
@files=readdir(DIR);
my $gseTag=1;
close DIR;

foreach my $file(@files)
{
	if($file =~ /$gse\.soft/)
	{
		print $file." has already been downloaded \n";
               	$gseTag=0;
        }
}

my $rfile=$scriptsLoc."/downloadSoftFile.R";

if($OS eq "linux"){
	$rfile=~ s/\"//g;           #### use it when calling the script in Linux
	$geodatabasedir =~ s/\"//g; #### use it when calling the script in Linux
}else{
	$rfile =~ s/\\/\\\\/g;
	$geodatabasedir =~ s/\\/\\\\/g;
}

my $errorMsg;
if($gseTag)
{
	$errorMsg = system("Rscript $rfile $gse $geodatabasedir/GSE/$gse 0");
       	my $local_dir = "$softfilepath/GSE";
        my $gseFamily = "$gse"."_family";
        my $ncbi_gseFamily_filename="$gseFamily".".soft.gz";
        my $if_downloaded = download_file_from_ftp ( "ftp.ncbi.nlm.nih.gov", "pub/geo/DATA/SOFT/by_series/$gse", $ncbi_gseFamily_filename, '', $local_dir );
        system ("Rscript $scriptsLoc/gzipScript.R $geodatabasedir/GSE/$ncbi_gseFamily_filename $geodatabasedir/GSE/$gseFamily");
        #print $errorMsg;
	sleep($slaap);
}
if($errorMsg)
{
 	print "Problem in connecting to ftp.ncbi.nlm.nih.gov, $gse.soft has not been downloaded. Please retry \n";
        `rm -rf BigMac`;
        exit;
}
	my @gsm;
	my @gpl;
	splice ( @gsm, 0 );
	splice ( @gpl, 0 );

	########################## Creating report file ######################################################

	open GSE , "$softfilepath/GSE/$gse.soft" or die "\nCan't open $softfilepath/GSE/$gse.soft for read;$!";
	my $string_GSE;
	while(<GSE>)
	{
		if(/\!Series_sample_id = (.*?)[\r|\n]/){push @gsm,$1;}
		if(/\!Series_platform_id = (.*?)[\r|\n]/){push @gpl,$1;}
		$string_GSE= $_;
	}
	close GSE ;
	my $flag_GSE=0;
	if(!(-e "$geodatabasedir/GSE/$gse.soft"))
	{
		$flag_GSE=1;
	}
	my $GSE_in_report=0;
	open (INPUTREPORT,"$bigMacLocation/BigMac/log/report_getAllForGSE.txt");
	while (<INPUTREPORT>)
	{
		my $string = $_;
		chomp($string);
		$string =~ s/\r//;

		if ($string eq "GSE: $gse")
		{
			$GSE_in_report=1;
		}
	}
	close INPUTREPORT;
	if ($GSE_in_report==0)
	{
		open (REPORT, ">>$bigMacLocation/BigMac/log/report_getAllForGSE.txt"); # Create a log file with all GSM and GPL identifiers which correspond to the GSE
		print REPORT "GSE: $gse\n";
		print REPORT "GPLs: @gpl"; print REPORT "\n";
		print REPORT "GDSs: @these_GDSs";print REPORT "\n";
		print REPORT "GSMs: @gsm "; print REPORT "\n\n";
		close REPORT;
	}


############################### Downloading GPL file & creating log file ##################################################

my $x;
$x=1;
my @GPL_log;

print "Downloading platform files ...\n";

foreach my $gp(@gpl)
{
$gplTag=1;
my $annotTag=1;

opendir(DIR,"$bigMacLocation/BigMac/annotation");
my @annotfiles=readdir(DIR);
close DIR;

print "Platform $gp ($x of ".scalar(@gpl).") --->\n";

	foreach my $file(@gplfiles)
        {
	       if($file =~ /$gp\.soft/)
	       {
			print $file." has already been downloaded \n";
               	$gplTag=0;

			foreach my $file1(@annotfiles)
			  {
			    if($file1 =~ /$gp\.annot/)
			      {
				print $file1." has already been downloaded \n";
				$annotTag=0;
			      }
			  }
               }
        }


	if($gplTag)
        {
		unless(-s "$geodatabasedir/GPL/$gp.soft")
		 {

			my $ncbi_gpl_filename = $gp.".annot.gz";

	                ################## Download #################################

			my $local_dir = $CUR_DIR;
			print "Downloading annotation file for $gp ...\n";

			#Download annotation file from NCBI ftp site, unzip and delete archived files
			if($annotTag)
			{
				my $if_downloaded = download_file_from_ftp ( "ftp.ncbi.nlm.nih.gov", "pub/geo/DATA/annotation/platforms", $ncbi_gpl_filename, '', $local_dir );
                        #print "$if_downloaded\n";
				if ( $if_downloaded=~/No such file or directory/ )
				{
					print "$ncbi_gpl_filename has not been downloaded\n";
				} else {
					system ("Rscript $scriptsLoc/gzipScript.R $dirPATH/$ncbi_gpl_filename $dirPATH/$gp");
                                        open ANNOTGPL, "$bigMacLocation/$gp.soft" or die "Can't open $bigMacLocation/$gp.soft for read;$!";

					my @annotgpl=<ANNOTGPL>;
					close ANNOTGPL;

					open ANNOT, ">$bigMacLocation/BigMac/annotation/$gp.annot" or die "Can't open $bigMacLocation/BigMac/annotation/$gp.annot for read;$!";
					print ANNOT @annotgpl;
					close ANNOT;
	                                }
			}

			sleep($slaap);

			print "Downloading SOFT file ...\n";
			# Download SOFT file containing the headers of the platform
			system("Rscript $rfile $gp $geodatabasedir/GPL/$gp 0");

			## Check if GPL file has been completely downloaded, if not write the GPLid into log file
			if (-e "$geodatabasedir/GPL/$gp.soft")
			{
				open GPL , "$geodatabasedir/GPL/$gp.soft" or die "Can't open $geodatabasedir/GPL/$gp.soft for read;$!";
				my $string_GPL;
				while(<GPL>)
				{
					$string_GPL = $_;
				}
				close GPL;
				chomp ($string_GPL);

	                        $string_GPL =~ s/\r//;

				if (!($string_GPL eq "!platform_table_end"))
				{
					push (@GPL_log,$gp);
					unlink "$geodatabasedir/GPL/$gp.soft";
				}
			}
			else
			{
				push (@GPL_log,$gp);
			}
	       }
        }
$x++;
}

########################## Downloading GSM files & creating log ################################################
opendir(DIR,"$bigMacLocation/BigMac/data/GEO/GSM");
@files=readdir(DIR);
my $gsmTag=1;
close DIR;

$x=1;
my @GSM_log;

print "Downloading GSM files ...\n";
print "Number of samples = ". scalar@gsm."\n";
my $gseFamily=$gse."_family.soft";

$/="\^SAMPLE";

open FAMILY, "$bigMacLocation/BigMac/data/GEO/GSE/$gseFamily" or die "Cannot open the file $geodatabasedir/GSE/$gseFamily";

my $i=0;
while(my $chunk=<FAMILY>){
	if($i!=0){
		print "$i..";
		open OUT,">$bigMacLocation/BigMac/data/GEO/GSM/$gsm[$i-1].soft" or print "Cannot open $bigMacLocation/BigMac/data/GEO/GSM/$gsm[$i-1].soft file to write\n";
		$chunk=~s/\^SAMPLE//;
		$chunk=~s/^ =/\^SAMPLE =/;
		print OUT $chunk;
		close OUT;
	}
        $i++;
}
$/="\n";

print "Done!\n";

########## Create log_getAllForGSE.txt file ###################

open LOG_READ, "$bigMacLocation/BigMac/log/log_getAllForGSE.txt";
open NEW_LOG_WRITE, ">$bigMacLocation/BigMac/log/log.txt";
while ( <LOG_READ> )
{
        last if $_ =~ /^$input\b/;
        print NEW_LOG_WRITE "$_";
}
print NEW_LOG_WRITE "$input\tdone\n";
while ( <LOG_READ> )
{
        print NEW_LOG_WRITE "$_";
}
close NEW_LOG_WRITE;
close LOG_READ;

unlink "$bigMacLocation/BigMac/log/loading_log.txt";
rename("$bigMacLocation/BigMac/log/log.txt","$bigMacLocation/BigMac/log/loading_log.txt");
