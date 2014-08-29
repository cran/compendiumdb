#!/usr/bin/perl -I BigMac/COMPENDIUM
# Data are inserted into the following tables by this script:
# hyb, experiment_has_hyb, sample, hyb_has_sample (by loadSampleData() subroutine)
# hybresult (4 columns remain unfilled)
#
use compendiumSUB;
use DBI;
use Date::Manip;
use POSIX qw(strftime);

my $sleep_before_connect = 5;

my ($gsm,$gplid,$x,$datadir,$expid,$user, $passwd, $host, $dbname) = @ARGV;
my $logdir = "$datadir/BigMac/log";
my $basedir = "$datadir/BigMac/data/GEO";
my (%sampledata);
my (%reporters);
redefDataHash();

$now_string = strftime "%H:%M:%S", localtime; ###### JUNE 9th 2011
#print $now_string."***"; ###### JUNE 9th 2011

#print $gsm."\t".$basedir."\t".$expid."\n"; ###Umesh
#sleep $sleep_before_connect;

$dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host",$user,$passwd) or
die "Cannot open connection", "$DBI::errstr" ;

#$dbh->{'RaiseError'} = 1;
#$dbh->{'AutoCommit'} = 0;
#$dbh -> do("FLUSH TABLES");
# Query's

my $sth = $dbh->prepare("SET FOREIGN_KEY_CHECKS = 0;");$sth->execute();
my $sth1 = $dbh->prepare("SET UNIQUE_CHECKS = 0;");$sth1->execute();

$sth_get_chip = $dbh->prepare("SELECT idchip FROM chip WHERE db_platform_id=?");

$sth_ins_hyb = $dbh->prepare("insert into hyb (idchip,barcode,Sample_data_row_count) VALUES (?,?,?)");
$sth_ins_hyb_exp = $dbh->prepare("insert into experiment_has_hyb (idExperiment,hybid) VALUES (?,?)");
$sth_ins_sample = $dbh->prepare("INSERT INTO sample (sampletitle, sampledesc, sampleorg, samplesource, " . "samplelabel, samplemolecule, sampleprovider, sampletreatment, samplecharacteristics, ". "samplegrowth, sampledataprocessing, providerid, samplenumber) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)");
$sth_ins_a2s = $dbh->prepare("insert into hyb_has_sample (hybid,idsample) VALUES (?,?)");
$sth_ins_hybresult = $dbh->prepare("insert into hybresult (hybid,loaddate,submissiondate) VALUES (?,?,?)");
my $sth_update_hyb=$dbh->prepare("UPDATE hyb SET load_data_count=? WHERE hybid=?");

# GSM soft file header example:
#^SAMPLE = GSM3004
#!Sample_title = zzMex67IP_v_TotalRNA 061601 slide 2b scan 3
#!Sample_geo_accession = GSM3004
#...
#!Sample_submission_date = Nov 25 2002
#...
#ID_REF =
#CH1_MEAN = Sample 1 Mean Intensity
#CH1_BKD_MEDIAN = Sample 1 Median Background Level
#CH1_BKD_MEAN = Sample 1 Mean Background Level
#VALUE = intermediate log ratio before taking the mean of duplicate ORFS, etc.
#!sample_table_begin
#ID_REF	CH1_MEAN	CH1_BKD_MEDIAN	CH1_BKD_MEAN	VALUE
#1	938	1307	1372	null

open GSM , "$basedir/GSM/$gsm.soft" or die "Can't open $basedir/GSM/$gsm.soft for read;$!";
LINE: while(<GSM>)
{
	if(/^\!Sample_geo_accession = (.*?)[\r|\n]/){$barcode=$1;}
        if(/^\!Sample_submission_date = (.*?)[\r|\n]/){$subdate=$1}
	if(/^\#(.*?) = (.*?)[\r|\n]/){push @cols,"$1";$columns{$1}=$2;}
        last LINE if(/^\!sample_table_begin(.*?)[\r|\n]/);
}
close GSM;

#Then we load Sample data
($hybid,$chipid) = &loadSampleData($gsm,$basedir,$gplid);

print "$x..";

$sth_get_chip->finish();
$sth_ins_hyb->finish();
$sth_ins_sample->finish();
$sth_ins_a2s->finish();

#Let's start with the result section
$sdate = UnixDate($subdate,"%Y-%m-%d");

$ldate = strftime "%Y-%m-%d", localtime;
$sth_ins_hybresult->execute($hybid,$ldate,$sdate) or die "Died: ".$sth_ins_hybresult->errstr."\n"; # insert into hybresult; 4 columns remain unfilled!
$idhybresult = $dbh->{'mysql_insertid'};

#Now get all probes for this hyb
$sth_reporters = $dbh->prepare("SELECT supplierspotid,r.idspot from reporter r,chip_has_reporter cr where cr.idchip=? and cr.idspot=r.idspot");
$sth_reporters->execute($chipid) or die "Died: ".$sth_reporters->errstr."\n";
while(@r = $sth_reporters->fetchrow()){
        $reporters{$r[0]}=$r[1];
}

$sth_ins_hybresult->finish();
$sth_reporters->finish();

open OUT,">>$logdir/loading_log.txt";
print OUT "\n$barcode\t";

close OUT;

# Insert data to hybresult_has_reporter and spot_column_value
$read=0;

open GSM , "$basedir/GSM/$gsm.soft" or die "Can't open $basedir/GSM/$gsm.soft for read;$!";
open OUTGSM, ">>$basedir/tempGSM.txt" or die "Can't open $basedir/tempGSM.txt for read;$!";

my $now_string = strftime "%Y %b %e %H:%M:%S", localtime; ###### JUNE 9th 2011
#print $now_string."_______"; ###### JUNE 9th 2011

my $linecount=0;

LINE: while(<GSM>)
{
	if(/^\!sample_table_begin(.*?)[\r|\n]/){$read=1;next LINE;}
 #       my $flag = 0;

	if($read==1)
	{
		s/\n//;s/\r//;
		@header = split (/\t/,$_);
		my $count = 0;
		for (@header)
		{
		      if ($_ eq "VALUE")
			{
        			$v_count = $count;
      			}
      			$count++;
    		}
		$read=2;next LINE;
  	}
  	if($read==2)
	{
	  	s/\n//;s/\r//;
	  	@blks=split/\t/;
	  	$spotid = $reporters{$blks[0]};
                last LINE if(/^\!sample_table_end/);
               	print OUTGSM "$columns{$cols[$v_count]},$idhybresult,$spotid,$blks[$v_count]\n";
                $linecount++;
	   }
}
close GSM;
close OUTGSM;

$sth_update_hyb->execute($linecount,$hybid) or die "Died: ".$sth_update_hyb->errstr."\n";
$sth_update_hyb->finish();

$now_string = strftime "%H:%M:%S", localtime; ###### JUNE 9th 2011
#print $now_string; ###### JUNE 9th 2011

$dbh->disconnect();

####################### Subroutines ############################################

sub loadSampleData()
{
	my ( $gsm, $basedir, $gplid ) = @_ ;
        my $chipid; my $hybid;
        open GSM , "$basedir/GSM/$gsm.soft" or die "Can't open $basedir/GSM/$gsm.soft for read;$!";
        while(<GSM>)
        {
                if(/\!Sample_platform_id = (.*?)[\r|\n]/){$sampledata{'platform'}=$1;}
                #print $sampledata{'platform'},"\n";
                if(/\!Sample_organism_ch1 = (.*?)[\r|\n]/){$sampledata{'org1'}=$sampledata{'org1'}.$1.";";}
                if(/\!Sample_organism_ch2 = (.*?)[\r|\n]/){$sampledata{'org2'}=$sampledata{'org2'}.$1.";";}
                if(/\!Sample_description = (.*?)[\r|\n]/){$sampledata{'descrip'}=$sampledata{'descrip'}.$1.";";}
                if(/\!Sample_data_processing = (.*?)[\r|\n]/){$sampledata{'dataproc'}=$1;}
                if(/\!Sample_source_name_ch1 = (.*?)[\r|\n]/){$sampledata{'source1'}=$1;}
                if(/\!Sample_source_name_ch2 = (.*?)[\r|\n]/){$sampledata{'source2'}=$1;}
                if(/\!Sample_label_ch1 = (.*?)[\r|\n]/){$sampledata{'label1'}=$1;}
                if(/\!Sample_label_ch2 = (.*?)[\r|\n]/){$sampledata{'label2'}=$1;}
                if(/\!Sample_molecule_ch1 = (.*?)[\r|\n]/){$sampledata{'mol1'}=$1;}
                if(/\!Sample_molecule_ch2 = (.*?)[\r|\n]/){$sampledata{'mol2'}=$1;}
                if(/\!Sample_title = (.*?)[\r|\n]/){$sampledata{'title'}=$1;}
                if(/\!Sample_characteristics_ch1 = (.*?)[\r|\n]/){$sampledata{'characteristics1'}=$sampledata{'characteristics1'}.$1.";;";}
                if(/\!Sample_characteristics_ch2 = (.*?)[\r|\n]/){$sampledata{'characteristics2'}=$sampledata{'characteristics2'}.$1.";;";}
                if(/\!Sample_biomaterial_provider_ch1 = (.*?)[\r|\n]/){$sampledata{'bioprovider1'}=$sampledata{'bioprovider1'}.$1.";";}
                if(/\!Sample_biomaterial_provider_ch2 = (.*?)[\r|\n]/){$sampledata{'bioprovider2'}=$sampledata{'bioprovider2'}.$1.";";}
                if(/\!Sample_treatment_protocol_ch1 = (.*?)[\r|\n]/){$sampledata{'treatment1'}=$sampledata{'treatment1'}.$1.";";}
                if(/\!Sample_treatment_protocol_ch2 = (.*?)[\r|\n]/){$sampledata{'treatment2'}=$sampledata{'treatment2'}.$1.";";}
                if(/\!Sample_growth_protocol_ch1 = (.*?)[\r|\n]/){$sampledata{'growth1'}=$sampledata{'growth1'}.$1.";";}
                if(/\!Sample_growth_protocol_ch2 = (.*?)[\r|\n]/){$sampledata{'growth2'}=$sampledata{'growth2'}.$1.";";}
                if(/\!Sample_data_row_count = (.*?)[\r|\n]/){$sampledata{'sampleDataCount'}=$1;}
        }
        close GSM;
        foreach $k (keys %sampledata)
        {
                if($sampledata{$k} eq ""){$sampledata{$k}="-";}
                chomp($sampledata{$k});
        }
        $sth_get_chip->execute($sampledata{'platform'}) or die "Died: ".$sth_get_chip->errstr."\n";
        #print "Loading $gsm...";
        @g = $sth_get_chip->fetchrow();
        ##print "De get chip id bevat:",@g,"\n";
        ($chipid)=$g[0]; # define $chipid
        #print "$gplid===$sampledata{'platform'}\n";
        if($gplid ne $sampledata{'platform'}){
		exit;
	}

        $sth_ins_hyb->execute($g[0],$barcode,$sampledata{'sampleDataCount'}) or die "Died: ".$sth_ins_hyb->errstr."\n"; undef @g; # insert into table 'hyb'
        $insertid_a = $dbh->{'mysql_insertid'};
        ($hybid)=$insertid_a; # define $hybid
        $sth_ins_hyb_exp->execute($expid,$hybid) or die "Died: ".$sth_ins_hyb_exp->errstr."\n"; # insert into table 'experiment_has_hyb'
        $sth_ins_sample->execute($sampledata{'title'},$sampledata{'descrip'},$sampledata{'org1'},$sampledata{'source1'},
                                                        $sampledata{'label1'},$sampledata{'mol1'},$sampledata{'bioprovider1'},
                                                        $sampledata{'treatment1'},$sampledata{'characteristics1'},$sampledata{'growth1'},
                                                        $sampledata{'dataproc'},$barcode,1) or die "Died: ".$sth_ins_sample->errstr."\n"; # insert into table 'sample'
        $insertid_s1 = $dbh->{'mysql_insertid'};
        $sth_ins_a2s->execute($insertid_a,$insertid_s1) or die "Died: ".$sth_ins_a2s->errstr."\n"; # insert into table 'hyb_has_sample'
        if($sampledata{'org2'} ne "-")
        {
                $sth_ins_sample->execute($sampledata{'title'},$sampledata{'descrip'},$sampledata{'org2'},$sampledata{'source2'},
                                                         $sampledata{'label2'},$sampledata{'mol2'},$sampledata{'bioprovider2'},
                                                         $sampledata{'treatment2'},$sampledata{'characteristics2'},$sampledata {'growth2'},
                                                         $sampledata{'dataproc'},$barcode,2) or die "Died: ".$sth_ins_sample->errstr."\n"; # insert into table 'sample'
                $insertid_s2 = $dbh->{'mysql_insertid'};
                $sth_ins_a2s->execute($insertid_a,$insertid_s2) or die "Died: ".$sth_ins_a2s->errstr."\n"; # insert into table 'hyb_has_sample'
        }
        redefDataHash();
        return($hybid,$chipid);
}

sub redefDataHash
{
        $sampledata{'org1'}="";
        $sampledata{'org2'}="";
        $sampledata{'dataproc'}="";
        $sampledata{'source1'}="";
        $sampledata{'source2'}="";
        $sampledata{'label1'}="";
        $sampledata{'label2'}="";
        $sampledata{'mol1'}="";
        $sampledata{'mol2'}="";
        $sampledata{'descrip'}="";
        $sampledata{'title'}="";
        $sampledata{'characteristics1'}="";
        $sampledata{'characteristics2'}="";
        $sampledata{'bioprovider1'}="";
        $sampledata{'bioprovider2'}="";
        $sampledata{'treatment1'}="";
        $sampledata{'treatment2'}="";
        $sampledata{'growth1'}="";
        $sampledata{'growth2'}="";
        $sampledata{'platform'}="";
}
