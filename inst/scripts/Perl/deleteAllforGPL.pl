#!/usr/bin/perl -w
use DBI;
my ($gpl,$user, $passwd, $host, $port, $dbname) = @ARGV;

$dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host:$port",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;
$sth_get_idchip = $dbh->prepare("SELECT idchip FROM chip WHERE db_platform_id=?");
$sth_get_idspot = $dbh->prepare("SELECT idspot FROM chip_has_reporter WHERE idchip=?");
$sth_del_idchip = $dbh -> prepare ("delete from chip where idchip=?");
$sth_chip_has_reporter = $dbh -> prepare ("delete from chip_has_reporter where idchip=?");
$sth_reporter = $dbh -> prepare ("delete from reporter where idspot=?");

$sth_get_idchip->execute($gpl);
my $idchip = $sth_get_idchip->fetchrow();
my @idspot;
$sth_get_idspot->execute($idchip);
while ( $a = $sth_get_idspot->fetchrow() )
{
        push ( @idspot, $a );
}
foreach my $idspot(@idspot)
{
        $sth_reporter -> execute($idspot);
}

print "Deleting $gpl ...\n";
$sth_del_idchip -> execute($idchip);
$sth_chip_has_reporter -> execute($idchip);

$sth_get_idchip->finish();
$sth_get_idspot->finish();
$sth_del_idchip->finish();
$sth_chip_has_reporter->finish();
$sth_reporter->finish();
$dbh->disconnect();
