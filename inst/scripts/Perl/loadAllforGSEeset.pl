#!/usr/bin/perl -I BigMac/COMPENDIUM
$|=1;

use LWP::UserAgent;
#use warnings;
use strict;
use Cwd;
use LWP::Simple;
use DBI;
use POSIX qw(strftime);
use compendiumSUB;

my($gse, $dataLoc, $scriptsLocation, $user, $passwd, $host, $port, $dbname, $gpls) = @ARGV;

##################### Create loading_log.txt #########################################

my $basedir="$dataLoc/BigMac/data/GEO";
my $geodatabasedir = $dataLoc;
my $OS = $^O;
my $datetime = strftime "%Y-%m-%d %H:%M:%S", localtime;

$geodatabasedir =~ s/\//\\\"\/\\\"/g;
$geodatabasedir =~ s/\\\"//;
$geodatabasedir =~ s/$/\\\"/;

my $scriptdir = $scriptsLocation;
$scriptdir =~ s/\//\\\"\/\\\"/g;
$scriptdir =~ s/\\\"//;
$scriptdir =~ s/$/\\\"/;

my $input=$gse;
open TEMP_LOG_WRITE, ">$geodatabasedir/log.txt";
my $was_this_job_already_in_old_log = 0;
if ( -e "loading_log.txt" )
{
	open OLD_LOG_READ, "$geodatabasedir/loading_log.txt";
        while ( my $line = <OLD_LOG_READ> )
        {
                chomp($line);
                if ( $line =~ /^$input\b/ )
                {
                	$was_this_job_already_in_old_log = 1;
                        print TEMP_LOG_WRITE "$input\n";
                }
                else
                {
                	print TEMP_LOG_WRITE "$line\n";
                }
        }
        close OLD_LOG_READ;
}
unless ( $was_this_job_already_in_old_log )
{
	print TEMP_LOG_WRITE "$input";
}
close TEMP_LOG_WRITE;
unlink "loading_log.txt";
rename("log.txt","loading_log.txt");

####################### Get GDSs and GPLs for the GSE ##################################

my @GSE;
push(@GSE,$gse);
my %GDS_and_GPL_for_GDS = get_GPLs_and_GDSs_for_known_GSEs ( @GSE );
my $size = keys %GDS_and_GPL_for_GDS;
if($size==0){print "Please check if the data for $gse has been downloaded from GEO to your 'BigMac' directory. If not use the function downloadGEOdata to download it\n";exit;}
my @new_GPLs;
my @uniq_GPLs;
my @these_GPLs;
my @these_GDSs;

foreach my $this_GSE ( keys %GDS_and_GPL_for_GDS )
{
        @these_GPLs = @{ ${ $GDS_and_GPL_for_GDS{$this_GSE} } { "GPLs" } };
        @these_GDSs = @{ ${ $GDS_and_GPL_for_GDS{$this_GSE} } { "GDSs" } };
}

if(! keys %GDS_and_GPL_for_GDS){
        open FILE, "$dataLoc/BigMac/log/report_getAllForGSE.txt" or die "cannot open file\n";
	my @file=<FILE>;
	my $file=join("",@file);
	my @entries=split(/GSE\: /,$file);
	#print $entries[1];
	foreach my $line(@entries){
        	my @line=split(/\n/,$line);
	        if(grep(/$gse/,@line)){

	                foreach my $n(@line){
	                        #chomp($n);
	                        if($n=~/GPLs\: (.*)/){@these_GPLs=split(/ /,$1);}
	                        if($n=~/GDSs: (.*)/){@these_GDSs=split(/ /,$1);}
	                }
	        }
	}
}

print "GSE: $gse\n";
print "GPLs: @these_GPLs\n";
print "GDSs: @these_GDSs\n";

#@these_GDSs = ("GDS2368","GDS2366");

############################### Load GSE ##############################################

my $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host:$port",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;
my $sth_get_exp = $dbh->prepare("SELECT idExperiment FROM experiment WHERE expname=?");
my $sth_get_phenoInformation = $dbh->prepare("SELECT * FROM hyb_has_description WHERE hybid
							IN(SELECT hyb.hybid FROM hyb inner join experiment_has_hyb eh on hyb.hybid=eh.hybid
							WHERE eh.idExperiment=?)");

my $sth_ins_exp = $dbh->prepare("insert into experiment (expname,expdescr,addeddate,submissiondate,publicdate,lastupdatedate,date_loaded,pubmedid) VALUES (?,?,?,?,?,?,?,?)");

my $cpml = ""; 
my $subDate = "";
my $publicDate = "";
my $updateDate = "";
my @pubmedID;
my @gsm;
my @gpl;
my $dataCheck;

open GSE , "$dataLoc/BigMac/data/GEO/GSE/$gse.soft" or die "Can't open $dataLoc/BigMac/data/GEO/GSE/$gse.soft for read: $!\nPlease check if the file has been downloaded from GEO to your 'BigMac' directory. If not use the function downloadGEOdata() to download it\n";
while(my $regel=<GSE>)
{
	if($regel=~/\!Series_sample_id = (.*?)[\r|\n]/){push @gsm,$1;}
        elsif($regel=~/\!Series_platform_id = (.*?)[\r|\n]/){push @gpl,$1;}
        elsif($regel=~/\!Series_status = Public on (.*?)[\r|\n]/){$publicDate=$1;}
        elsif($regel=~/\!Series_submission_date = (.*?)[\r|\n]/){$subDate=$1;}
        elsif($regel=~/\!Series_last_update_date = (.*?)[\r|\n]/){$updateDate=$1;}
        elsif($regel=~/\!Series_pubmed_id = (.*?)[\r|\n]/){push @pubmedID,$1;}
        else{$cpml=$cpml.$regel;}
}
close GSE ;
my $pubid=join(",",@pubmedID);

print "Number of samples: ". scalar(@gsm)."\n";

open GSE , "$dataLoc/BigMac/data/GEO/GSE/$gse"."_family.soft" or die "Can't open $dataLoc/BigMac/data/GEO/GSE/$gse.family.soft for read.";
while(my $chunk=<GSE>){
	if($chunk=~/\!Sample_data_row_count = (.*?)[\r|\n]/){$dataCheck=$1;}

}
close GSE ;

if($dataCheck==0){
	print "Expression data for $gse is not available on GEO (check family.soft file for more details). Quitting data loading to compendium database\n";
	exit;
}

my $sum ="";
while($cpml=~/\!Series_summary = (.*?)[\r|\n]/sg)
{
        $sum=$sum.$1;
}
my $expid;
$sth_get_exp->execute($gse) or die "Died: ".$sth_get_exp->errstr."\n";
($expid) = $sth_get_exp->fetchrow();
if(defined($expid)){
warn "$gse has already been loaded\n";
}
else{
        my $ldate = strftime "%Y-%m-%d", localtime;
        $sth_ins_exp->execute($gse,$sum,$ldate,$subDate,$publicDate,$updateDate,$datetime,$pubid) or die "Died: ".$sth_ins_exp->errstr."\n";
        $expid = $dbh->{'mysql_insertid'};
	my $now = localtime time;
	print "Loading $gse starts at $now\n";
}

$sth_ins_exp->finish();
$sth_get_exp->finish();

########################## Load GPLs ##########################################################

# check if GPL is already loaded in db
my $sth = $dbh->prepare("SELECT * FROM chip WHERE db_platform_id=?");

if(scalar(@these_GPLs)==0){@these_GPLs=@gpl;}

if($gpls ne ""){
	@new_GPLs = split(/-/,$gpls);
	my %second = map {$_=>1} @these_GPLs;
	@these_GPLs = grep { $second{$_} } @new_GPLs; #common GPLs
	@uniq_GPLs = grep { !$second{$_} } @new_GPLs; 

	if(scalar(@these_GPLs)==0){print "@new_GPLs does not correspond to $gse\n";exit;}
 	if(scalar(@uniq_GPLs)!=0){print "@uniq_GPLs does not correspond to $gse\n"}
}

foreach my $GPL(@these_GPLs)
{
	$sth->execute($GPL) or die "Died: ".$sth->errstr."\n";

	if($sth->rows == 0){
		print "Loading $GPL ...\n";
		#my $datetime = strftime "%Y-%m-%d %H:%M:%S", localtime;
		my $cmnd;
		($cmnd) = "perl $scriptdir/Perl/loadGPL.pl $geodatabasedir/BigMac/annotation/configuration/gplLoadConf_$GPL.pl $user $passwd $host $port $dbname" ;
                $cmnd =~ s/\\//g;
	        my $flag = system($cmnd);
		if ($flag!=0)
		{
			open LOG_READ, "$geodatabasedir/loading_log.txt";
			open NEW_LOG_WRITE, ">$geodatabasedir/log.txt";
	    		while ( <LOG_READ> )
	   		{
	       		      last if $_ =~ /^$input\b/;
	       		      print NEW_LOG_WRITE "$_";
	    		}
	    		print NEW_LOG_WRITE "$input\t$GPL has not been loaded yet\n";
			while ( <LOG_READ> )
	    		{
	             		print NEW_LOG_WRITE "$_";
	    		}
	    		close NEW_LOG_WRITE;
	   		close LOG_READ;

	     		unlink "loading_log.txt";
	    		rename("log.txt","loading_log.txt");

			die;
		}
	}
	else {
		print "$GPL has already been loaded\n";
	}
	$sth->finish();
}

############################## Load GSMs #####################################################
my $sth_arr_id = $dbh->prepare("select hybid from hyb where barcode=?");

### delete queries for hybid which was not completely loaded earlier

my $sth_del_hyb				= $dbh->prepare("DELETE FROM hyb WHERE hybid=?");
my $sth_del_hyb_has_sample		= $dbh->prepare("DELETE FROM hyb_has_sample WHERE hybid=?");
my $sth_del_experiment_has_hyb		= $dbh->prepare("DELETE FROM experiment_has_hyb WHERE hybid=?");
my $sth_del_hybresult			= $dbh->prepare("DELETE FROM hybresult WHERE hybid=?");

my $sth_exp_has_hyb			= $dbh->prepare("SELECT count(*) FROM experiment_has_hyb WHERE idExperiment = ?;");

my $tot = scalar(@gsm);
my $x=1;
my ($rem,$count,$insert)=0;
my $now = localtime time;

print "Loading annotations of samples ... $now\n";

$sth_exp_has_hyb -> execute($expid);
my $hyb_loaded = $sth_exp_has_hyb->fetchrow();
$sth_exp_has_hyb -> finish();

my $sth_gplid = $dbh->prepare("SELECT distinct c.idchip, c.db_platform_id FROM chip c
                				INNER JOIN hyb h ON c.idchip=h.idchip
                                                INNER JOIN experiment_has_hyb eh on h.hybid=eh.hybid
                                                INNER JOIN experiment e on eh.idExperiment= e.idExperiment
                                                WHERE e.idExperiment= ?");

$sth_gplid -> execute($expid);
my @gplids;
my @idchips;
while( my ($idchip,$gplid)=$sth_gplid->fetchrow()){
	push(@gplids,$gplid);
        push(@idchips,$idchip);
}

if($hyb_loaded == scalar@gsm){
	print "Annotation of samples has already been loaded \n";
} else {
        foreach my $GPLref(@these_GPLs)
        {

                if(grep(/$GPLref/,@gplids)){
        		print "Annotation of samples for $GPLref has already been loaded \n";
	        } else{
                        print "Loading annotation of samples for $GPLref ...\n";
        	        $x=1;
                	print "samples: ";
			foreach my $gs(@gsm)
			{
				my $cmnd;
				($cmnd) = "perl -I $geodatabasedir/BigMac/COMPENDIUM $scriptdir/Perl/loadGSMeset.pl $gs $GPLref $x $geodatabasedir $expid $user $passwd $host $port $dbname" ;
                		$cmnd =~ s/\\//g;
			       	my $flag = system($cmnd);
		                $insert=1;
				if ($flag!=0){die};
				$x++;
			}
			print "Done!\n";
	          }
        }
}

$sth_arr_id->finish();
my $sth_expressionset = $dbh->prepare("SELECT DISTINCT c.db_platform_id from chip c INNER JOIN expressionset e ON c.idchip=e.idchip WHERE e.idExperiment=?");
$sth_expressionset -> execute($expid);
my @GPLeset;
while( my $GPLname=$sth_expressionset->fetchrow())
{
 	push(@GPLeset,$GPLname);
}
print "Loading R ExpressionSet ...\n";

my $GPLref=join("-",@these_GPLs);
my $flag=0;
if(scalar@GPLeset){
	my @newGPL;
        foreach my $GPLname(@these_GPLs){

        	if(grep(/$GPLname/,@GPLeset)){
        		print "ExpressionSet of samples for $GPLname has already been loaded\n";
	        } else{
                      	push(@newGPL,$GPLname);
                        $flag=1;
                }
	}

        $GPLref=join("-",@newGPL);

} else {
 	$flag=1;
}

if($flag){
		my ($cmnd) = "perl $scriptdir/Perl/parsingSoftFile_forESET.pl $gse $GPLref $scriptdir $geodatabasedir $expid $user $passwd $host $port $dbname" ;
		$cmnd =~ s/\\//g;
		my $flag = system($cmnd);
}

$sth_expressionset -> finish();

########################### Inserting the hybDesign to hyb table ############################
foreach my $GPLref(@these_GPLs){
	my ($cmnd) = "perl $scriptdir/Perl/expDesign.pl $gse $GPLref $expid $user $passwd $host $port $dbname" ;
	$cmnd =~ s/\\//g;
	my $flag = system($cmnd);
}

#@these_GDSs=();

############################### Load GDS Description into table hyb_has_description ######################################
my @GPLpheno;
my $sth_GDS= $dbh->prepare("SELECT idGDS FROM gds WHERE GDS=?");
my $sth_phenoCheck=$dbh -> prepare("SELECT DISTINCT c.db_platform_id FROM chip c
				INNER JOIN hyb ON hyb.idchip=c.idchip
                                INNER JOIN hyb_has_description h ON hyb.hybid=h.hybid
                                INNER JOIN experiment_has_hyb e ON h.hybid=e.hybid
                                WHERE e.idExperiment = ?");
$sth_phenoCheck -> execute($expid);
while (my $GPLname=$sth_phenoCheck->fetchrow()){
 	push(@GPLpheno,$GPLname);
}
$sth_phenoCheck->finish();

my $phenoflag=0;
my $gdsflag=1;
if(scalar@these_GDSs==0){$gdsflag=0;}

foreach my $GDS (@these_GDSs)
{
	if(-e "$dataLoc/BigMac/data/GEO/GDS_description/$GDS.txt"){
                print "The $GDS file is loaded here $dataLoc/BigMac/data/GEO/GDS_description/$GDS.txt\n"
	} else{
                print "No $GDS file found in $dataLoc/BigMac/data/GEO/GDS_description/\n";
                $gdsflag=0;
	}
}

if($gdsflag){
	foreach my $GDS (@these_GDSs)
	{
		print "Loading $GDS ...\n";
		$sth_GDS->execute($GDS);

		if (defined(my $idGDS = $sth_GDS->fetchrow()))
		{
			print "$GDS has already been loaded \n";
		}
		else
		{
	        foreach my $gdsGPL(@these_GPLs){
	                my ($cmnd)= "perl $scriptdir/Perl/loadGDS.pl $GDS $gse $gdsGPL $geodatabasedir/BigMac/data/GEO $user $passwd $host $port $dbname";
	                $cmnd =~ s/\\//g;
			my $flag=system($cmnd);
			if ($flag!=0){die};
	           }
		}

		$sth_GDS->finish();
	}
} else { ### If there is no GDS

	##check if the corresponding phenotypic data has already been loaded
        foreach my $GPLname(@these_GPLs){

        	if(grep(/$GPLname/,@GPLpheno)){
        		print "Phenotypic data of $gse for $GPLname has already been loaded \n";
	        } else{
                        $phenoflag=1;
                }
	}
        if($phenoflag)
        {
		print "Loading phenotypic data of $gse without GDS ...\n";
                my ($cmnd)= "perl $scriptdir/Perl/load_notGDS.pl $expid $geodatabasedir/BigMac/data/GEO $user $passwd $host $port $dbname";
                $cmnd =~ s/\\//g;
		my $flag=system($cmnd);
		if ($flag!=0){die};
	}
}

print "........Loading done!.........\n";

#Create loading_log.txt
open LOG_READ, "$geodatabasedir/loading_log.txt";
open NEW_LOG_WRITE, ">$geodatabasedir/log.txt";
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

unlink "loading_log.txt";
rename("log.txt","loading_log.txt");

$dbh->disconnect();

######### Subroutine ############

sub hybDesign {

my($hybids,$samplesrc1,$samplesrc2)=@_;
my $c=0;my %hash=();

for(my $i=0;$i<@$samplesrc1;$i++)
  {
    $hash{"$hybids->[$i]"}="NA";
  }

for(my $i=0;$i<@$samplesrc1;$i++)
  {
    if($hash{"$hybids->[$i]"} eq "NA")
      {
	$hash{"$hybids->[$i]"}="$c";
	for(my $j=$i+1;$j<=@$samplesrc1;$j++){
	  if($samplesrc1->[$i] eq $samplesrc1->[$j] && $samplesrc2->[$i] eq $samplesrc2->[$j]){
	    $hash{"$hybids->[$j]"}=$hash{"$hybids->[$i]"};
	  }elsif($samplesrc1->[$i] eq $samplesrc2->[$j] && $samplesrc2->[$i] eq $samplesrc1->[$j]){
	    $hash{"$hybids->[$j]"}= "-".$hash{"$hybids->[$i]"};
	  }
	}
	$c=$c+1;
      }
  }
return(\%hash);
}
