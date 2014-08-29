#!/usr/bin/perl -w
use DBI;
my($gse,$user, $passwd, $host, $dbname) = @ARGV;

my $input = $gse;

my $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;$sth_get_idExperiment = $dbh->prepare("SELECT idExperiment FROM experiment WHERE expname=?");
$sth_get_idExperiment = $dbh -> prepare ("select idExperiment from experiment where expname = ?");
$sth_get_hybid = $dbh->prepare("SELECT hybid FROM experiment_has_hyb WHERE idExperiment=?");
$sth_get_idsample = $dbh->prepare("SELECT idsample FROM hyb_has_sample WHERE hybid=?");
$sth_get_idhybresult = $dbh->prepare("SELECT idhybresult FROM hybresult WHERE hybid=?");
#$sth_get_idresultcolumn = $dbh->prepare("SELECT idresultcolumn FROM hybresult_has_resultcolumn WHERE idhybresult=?");
$sth_get_idGDS=$dbh->prepare("SELECT idGDS FROM hyb WHERE hybid=?");

$sth_del_experiment = $dbh->prepare("DELETE FROM experiment WHERE idExperiment=?");
$sth_del_experiment_has_hyb = $dbh->prepare("DELETE FROM experiment_has_hyb WHERE idExperiment=?");
$sth_del_hyb = $dbh->prepare("DELETE FROM hyb WHERE hybid=?");
$sth_del_hyb_has_sample = $dbh->prepare("DELETE FROM hyb_has_sample WHERE hybid=?");
$sth_del_sample = $dbh->prepare("DELETE FROM sample WHERE idsample=?");
$sth_del_hybresult = $dbh->prepare("DELETE FROM hybresult WHERE idhybresult=?");
$sth_del_expressionset = $dbh->prepare("DELETE FROM expressionset WHERE idExperiment=?");
$sth_del_hyb_has_description = $dbh -> prepare ("delete from hyb_has_description where hybid=?");
$sth_del_GDS = $dbh -> prepare("DELETE FROM gds WHERE idGDS=?");

$sth_get_idExperiment->execute($gse);
my $idExperiment = $sth_get_idExperiment->fetchrow();
print "Deleting $gse...\n";
my @hybid;
$sth_get_hybid->execute($idExperiment);
while ( $a = $sth_get_hybid->fetchrow() )
{
        push ( @hybid, $a );
}
foreach my $hyb_id(@hybid)
{

        $sth_del_hyb_has_description -> execute($hyb_id);
}

my @idGDS;
foreach my $this_hybid ( @hybid )
{
        my @idsample;
        $sth_get_idsample->execute($this_hybid);
        $sth_get_idGDS->execute($this_hybid);

        while ( $a = $sth_get_idsample->fetchrow() )
        {
                push ( @idsample, $a );
                $sth_del_sample->execute($a);
        }

        while ( $gds = $sth_get_idGDS->fetchrow() )
        {
                push ( @idGDS, $gds);
        }


        $sth_get_idhybresult->execute($this_hybid);
        my $idhybresult = $sth_get_idhybresult->fetchrow();
        if ( defined ($idhybresult) )
        {
                $sth_del_hybresult->execute($idhybresult);
        }

        $sth_del_hyb->execute($this_hybid);
        $sth_del_hyb_has_sample->execute($this_hybid);
}

$uniqGDSids = unique(\@idGDS);

foreach my $id(@$uniqGDSids){
	$sth_del_GDS->execute($id);
}
if ( defined ($idExperiment) )
{
        $sth_del_experiment->execute($idExperiment);
        $sth_del_experiment_has_hyb->execute($idExperiment);
        $sth_del_expressionset->execute($idExperiment);
}


$sth_get_idExperiment->finish();
$sth_get_hybid->finish();
$sth_get_idsample->finish();
$sth_get_idhybresult->finish();
$sth_get_idGDS->finish();

$sth_del_experiment->finish();
$sth_del_experiment_has_hyb->finish();
$sth_del_hyb->finish();
$sth_del_hyb_has_sample->finish();
$sth_del_sample->finish();
$sth_del_hybresult->finish();
$sth_del_hyb_has_description -> finish();
$sth_del_GDS -> finish();
$sth_del_expressionset -> finish();

$dbh->disconnect();


sub unique{
	my($arr)=@_;

	my %seen;
	my @uniq = grep {! $seen{$_}++} @$arr;
	return(\@uniq);
}
