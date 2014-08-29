#!/u sr/bin/perl -w
use DBI;
use strict;
use Date::Manip;
use POSIX qw(strftime);
my ($GDS,$GSE_input,$GPL,$basedir, $user, $passwd, $host, $dbname) = @ARGV;

my $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host",$user,$passwd) or
die "Cannot open connection", "$DBI::errstr" ;

## SQL Query
# SELECT statements
my $sth_hybid = $dbh->prepare("select hybid from hyb where barcode=?");
my $sth_GDS= $dbh->prepare("SELECT idGDS FROM gds WHERE GDS=?");

# INSERT statements
my $sth_ins_descr = $dbh->prepare("insert into hyb_has_description (hybid,hyb_type,hyb_description) VALUES (?,?,?)");
my $sth_ins_GDS = $dbh->prepare("insert into gds (idchip,GDS,datasetTitle,datasetDescription,datasetPUBMEDid) VALUES (?,?,?,?,?)");
my $sth_update_hyb = $dbh->prepare("UPDATE hyb SET idGDS=? WHERE hybid=?");

my $GSE_in;
$sth_GDS->finish();

open GDS , "$basedir/GDS_description/$GDS.txt" or die "Can't open $basedir/GDS_description/$GDS.txt for read;$!";
my $hyb_description;
my $gsm_list;
my @GSM;
my $hyb_type;
my($idGDS, $datasettitle, $datasetdesc, $datasetpubId);
my $datasetplatform;

LINE: while(<GDS>){

        my $line = $_;

	if(/^\!dataset_title = (.*?)[\r|\n]/){$datasettitle=$1;}
	if(/^\!dataset_description = (.*?)[\r|\n]/){$datasetdesc=$1;}
	if(/^\!dataset_pubmed_id = (.*?)[\r|\n]/){$datasetpubId=$1;}
        if(/^\!dataset_platform = (.*?)[\r|\n]/){
        	$datasetplatform=$1;
                if($GPL ne $datasetplatform){
        		#print "$GDS does not correspond to $GPL.\n";
	        	exit;
	        }
        }

        my $sth_get_chipid = $dbh -> prepare("SELECT idchip FROM chip WHERE db_platform_id=?");
        $sth_get_chipid -> execute($datasetplatform);
        my $chipid = $sth_get_chipid -> fetchrow();
        $sth_get_chipid -> finish();
	if(/^\!dataset_update_date = (.*?)[\r|\n]/)
	{
		$sth_ins_GDS -> execute($chipid,$GDS,$datasettitle,$datasetdesc,$datasetpubId);

		$sth_GDS->execute($GDS);
		$idGDS = $sth_GDS->fetchrow();
	}


        if ( ( $line =~ /^\!subset_description/ ) )
        {
                $line =~ /^\!subset_description = (.+)/;
                $hyb_description = $1;
        }

        if (( $line =~ /^!subset_sample_id/))
        {
		if ( $line =~ /^\!subset_sample_id =\n/ )
                {
                        $line = <GDS>;
                        chomp($line);
                        $gsm_list = $line;
                        @GSM = split (',',$gsm_list);
                }
                else
                {
                        $line =~ /^\!subset_sample_id =[\n| ](.*?)[\r|\n]/;
                        $gsm_list = $1;
                }
                @GSM = split( ',' , $gsm_list );
        }

        if(($line =~ /^!subset_type/))
        {
                $line =~ /^\!subset_type = (.+)/;
                $hyb_type=$1;
                chomp($hyb_type);
                foreach my $barcode (@GSM)
                {
                        $sth_hybid->execute($barcode);
                        my $hybid = $sth_hybid->fetchrow();

                        $sth_ins_descr->execute($hybid,$hyb_type,$hyb_description);
			   $sth_update_hyb->execute($idGDS,$hybid);
                 }
         }
}
