#!/u sr/bin/perl -w
use DBI;
use Date::Manip;
use POSIX qw(strftime);
my ($GSEid,$basedir, $user, $passwd, $host, $port, $dbname) = @ARGV;

$dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host:$port",$user,$passwd) or
die "Cannot open connection", "$DBI::errstr" ;

## SQL query
# SELECT statements
my $sth = $dbh->prepare(" SELECT hs.hybid, s.sampletitle, s.samplesource, s.samplecharacteristics FROM
				sample s INNER JOIN hyb_has_sample hs ON s.idsample=hs.idsample WHERE
				hs.hybid IN(SELECT hybid FROM experiment_has_hyb WHERE idExperiment=?) AND s.samplenumber=1");

my $sth_del = $dbh ->prepare("DELETE FROM hyb_has_description WHERE hybid IN(SELECT distinct hybid FROM experiment_has_hyb WHERE idExperiment=?)");
$sth_del->execute($GSEid);

# INSERT statements
my $sth_ins_descr = $dbh->prepare("insert into hyb_has_description (hybid,hyb_type,hyb_description) VALUES (?,?,?)");
my ($hybid,$sampletitle,$samplesource,$samplechar);
$sth->execute($GSEid);

my $numrows = $sth->rows;
#print $numrows;

while(($hybid,$sampletitle,$samplesource,$samplechar) = $sth->fetchrow())
{
  $sth_ins_descr->execute($hybid,"sampletitle",$sampletitle);
  $sth_ins_descr->execute($hybid,"samplesource",$samplesource);
  $sth_ins_descr->execute($hybid,"samplechar",$samplechar);
}

$sth->finish();
$sth_ins_descr->finish();
