#!/usr/bin/perl
$|=1;

use LWP::UserAgent;
use Cwd;
use LWP::Simple;
use DBI;
use POSIX qw(strftime);

my($gse, $gpl, $scriptsLocation, $user, $passwd, $host, $dbname) = @ARGV;

my $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;

## Deleting GSE using removeGSE() and reloading it or another dataset scrambles the eset filenames. That gives a problem in creating the .RData file.
## Hence sorting filenames is required
my $eset = $dbh->prepare("SELECT e.filename,substring(e.filename,5) AS number,e.filecontent FROM expressionset e
	   		INNER JOIN chip ON e.idchip=chip.idchip
                        INNER JOIN experiment ex ON e.idExperiment=ex.idExperiment
                        WHERE chip.db_platform_id = ? and ex.expname=? ORDER BY (number+0)");

$eset -> execute($gpl,$gse);
#$expSets=$eset -> fetchall_arrayref();
#if(!defined($eset->fetchrow())){ print "$gse has not been loaded in the compendium yet.\n"; exit;}
open OUT,">output.RData" or die "Can't open the file to write";
#binmode(OUT);
$count=0;
while( my ($filename,$filenum,$filecontent)=$eset->fetchrow()){
#foreach my $row (@$expSets) {
$count++;
#print @$row;
syswrite OUT, $filecontent;
}
#print "Loading expression data for $gse with $gpl from the compendium\n";

$eset -> finish();
$dbh->disconnect;
close OUT;
