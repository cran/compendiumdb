#!/usr/bin/perl -w
use DBI;
use POSIX qw(strftime);

# define connection to db

my ($conffile,$user,$passwd,$host,$dbname) = @ARGV;

sleep 5;

$dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;
# GPL filename (eg. GPL96.soft) and GPL directory are read from command line

require $conffile;
$conffile =~ /(.*?)\/BigMac\//;
my $dir = $1;
# Define some variables for storage of important info.
$pident=""; # platfrom identifier from GEO
$ptitle=""; # platform title
$pdistri=""; # platform distribution
$pprov=""; # platform provider
$pdescrip=""; # platform description
$ptech=""; # platform technology
$porg=""; # platform organism

my $datetime = strftime "%Y-%m-%d %H:%M:%S", localtime;

open GPL , "$dir/BigMac/data/GEO/GPL/$conf{'gpl'}.soft" or die "Can't open $dir/BigMac/data/GEO/GPL/$conf{'gpl'}.soft for read; $!";
while(<GPL>){
	if(/^\^PLATFORM\s=\s(.*?)[\r|\n]/){$pident=$1;}
	if(/^\!Platform_title\s=\s(.*?)[\r|\n]/){$ptitle=$1;}
	if(/^\!Platform_distribution\s=\s(.*?)[\r|\n]/){$pdistri=$1;}
	if(/^\!Platform_manufacturer\s=\s(.*?)[\r|\n]/){$pprov=$1;}
	if(/^\!Platform_description\s=\s(.*?)[\r|\n]/){$pdescrip=$pdescrip.$1;}
	if(/^\!Platform_technology\s=\s(.*?)[\r|\n]/){$ptech=$1;}
	if(/^\!Platform_organism\s=\s(.*?)[\r|\n]/){$porg=$1;}
	if(/^\!platform_table_begin/){last;}
}

if(-e "$dir/$conf{'gpl'}.soft"){
	open GPLANN , "$dir/$conf{'gpl'}.soft" or die "Can't open $dir/$conf{'gpl'}.soft for read; $!";
	while(<GPLANN>){if(/^\!platform_table_begin/){last;}}
	$annotation = <GPLANN>;undef $annotation; #row 1 contains column headers, so throw away
        ### Loading the annotation of GPL
	$sth_load_data =$dbh->prepare("LOAD DATA LOCAL INFILE ? INTO TABLE GPLannotation FIELDS TERMINATED BY '&' LINES TERMINATED BY '\n' (supplierspotid,GeneTitle,GeneSymbol,GeneID,UniGeneTitle,UniGeneSymbol,UniGeneID,NucleotideTitle,GI,GBaccession)");
	open OUT, ">$dir/gplannot.temp" or die "Can't open $dir/gplannot.temp for writing; $!";
	while($annotation = <GPLANN>){
		no warnings qw(uninitialized);
		if($annotation=~/\!platform_table_end/){last;}
	        chomp($annotation);$regel=~s/[\r|\n]//g;
		my @annot = split(/\t/,$annotation);
	        for($i=0;$i<10;$i++){
	        	print OUT "$annot[$i]"."&";
	        }
	        print OUT "\n";
	}
	$sth_load_data->execute("$dir/gplannot.temp");
	#system("rm $dir/gplannot.temp");
}

# close GPL;

# Define query for organism id based on $porg
$sth = $dbh->prepare("SELECT * FROM organism AS o WHERE o.officialname=? OR o.shortname=?");
$sth->execute($porg,$porg) or die "Died: ".$sth->errstr."\n";
@org=$sth->fetchrow_array();
$orgid = $org[0];

# Insert the chip info into the database
$sth = $dbh->prepare("INSERT INTO chip (idorganism,provider,description,title,distribution,technology,db_platform_id,date_loaded) " .
				 "VALUES(?,?,?,?,?,?,?,?)");
$sth->execute($orgid,$pprov,$pdescrip,$ptitle,$pdistri,$ptech,$pident,$datetime) or die "Died: ".$sth->errstr."\nThis platform cannot be loaded in the current version of the package, since '$porg' does not have a unique NCBI Taxonomy ID\n";
# obtain chip id from database
$idchip = $dbh->{'mysql_insertid'};

# Build reporter insert query
$cols="";$vals="";
foreach $key (sort hashValueAscendingNum (keys(%confdb))) {
	$cols .= "$key," ;
	if($confdb{$key} eq -1){$vals .= "NULL,";}
	else{$vals .= "?,";}
}
$cols.='annotationdate,featurenum';$vals.="'$datetime',?";
$sth=$dbh->prepare("INSERT INTO reporter($cols) VALUES($vals)");
$sth_chiprep = $dbh->prepare("INSERT INTO chip_has_reporter (idchip,idspot) VALUES (?,?)");
$regel = <GPL>;undef $regel; #row 1 contains column headers, so throw away

while($regel = <GPL>){
	if($regel=~/\!platform_table_end/){last;}
	chomp($regel);$regel=~s/[\r|\n]//g;
	@bl = split/\t/,$regel;
	undef @insvals ;
	foreach $key (sort hashValueAscendingNum (keys(%confdb))) {
		unless($confdb{$key} eq -1){push @insvals ,$bl[$confdb{$key}];}
	}
	#chop($insvals);
	unless(exists($probes{$bl[$confdb{'supplierspotid'}]})){$probes{$bl[$confdb{'supplierspotid'}]}=1;}
	else{$probes{$bl[$confdb{'supplierspotid'}]}++;}
	push @insvals ,$probes{$bl[$confdb{'supplierspotid'}]};
	$sth->execute(@insvals) or die "Died: ".$sth->errstr."\n";
	$idrep = $dbh->{'mysql_insertid'};
	$sth_chiprep->execute($idchip,$idrep) or die "Died: ".$sth->errstr."\n";
}
$sth->finish();
$dbh->disconnect();

sub hashValueAscendingNum {
   $confdb{$a} <=> $confdb{$b};
}
