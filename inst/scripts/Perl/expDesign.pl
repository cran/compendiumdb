#!/usr/bin/perl
$|=1;
$/="\^SAMPLE";

use LWP::UserAgent;
use strict;
use Cwd;
use LWP::Simple;
use DBI;
use POSIX qw(strftime);

my ($gse,$gplref,$expid,$user, $passwd, $host, $port, $dbname)=@ARGV;

my $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host:$port",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;

my $sth_get_source=$dbh->prepare("SELECT hs.hybid,s.samplesource FROM sample s
				 INNER JOIN hyb_has_sample hs ON (s.idsample=hs.idsample)
				 INNER JOIN hyb ON hs.hybid=hyb.hybid
				 INNER JOIN chip ON hyb.idchip=chip.idchip
				 INNER JOIN experiment_has_hyb eh ON hyb.hybid=eh.hybid
				 WHERE eh.idExperiment=? AND s.samplenumber=? AND chip.db_platform_id=?");
my $sth_update_hyb=$dbh->prepare("UPDATE hyb SET hybdesign=? WHERE hybid=?");
my $sth_update_expdesign=$dbh->prepare("UPDATE hyb SET expdesign=? WHERE hybid=?");


my (@hybids,@hybids2,@samplesource1,@samplesource2); 
#@hybids=(1,2,3);

$sth_get_source->execute($expid,1,$gplref) or die "Died: ".$sth_get_source->errstr."\n";
while(my($hybid,$samplesource1)=$sth_get_source->fetchrow())
{
  if(defined($hybid)){
    push(@hybids,$hybid);
    push(@samplesource1,$samplesource1);
  }
}
$sth_get_source->finish();

$sth_get_source->execute($expid,2,$gplref) or die "Died: ".$sth_get_source->errstr."\n";
while(my($hybid,$samplesource2)=$sth_get_source->fetchrow())
{
  if(defined($hybid)){
    push(@hybids2,$hybid);
    push(@samplesource2,$samplesource2);
  }
}
$sth_get_source->finish();
my $design;

$design=hybDesign(\@hybids,\@samplesource1,\@samplesource2);
foreach(keys %$design){
  $sth_update_hyb->execute($$design{$_},$_);
}

if(@samplesource2){ ### Two-channel experiment
	
	### See http://perlmaven.com/unique-values-in-an-array-in-perl how to test for unique values
	my %seen1;
	my @count1=grep { ! $seen1{$_}++ } @samplesource1;
	my %seen2;
	my @count2=grep { ! $seen2{$_}++ } @samplesource2;

	if(scalar(@count1)==1 or scalar(@count2)==1 ){ ### Common reference design
	  foreach my $hybid(@hybids){		
	    $sth_update_expdesign->execute("CR",$hybid);
	  }
	}else{ ### Dye swap design or more than one group
	  #print grep { /-/ } values %$design;
	  if(grep { /-/ } values %$design){ ### Dye swap design
	    foreach my $hybid(@hybids){
	      $sth_update_expdesign->execute("DS",$hybid);
	    }
	  }else{ ### more than one group
	    foreach my $hybid(@hybids){
	      $sth_update_expdesign->execute("DC",$hybid);
	    }
	  }
	}
      }else{ ### One-channel experiment
	foreach my $hybid(@hybids){
	  $sth_update_expdesign->execute("SC",$hybid);
	}
      }

## if same platform has been used for single and double channel 
if(scalar(@hybids)!=scalar(@hybids2)){
	my %second = map {$_=>1} @hybids2;
    	my @only_in_first = grep { !$second{$_} } @hybids;		
	foreach my $hybid(@only_in_first){
	  $sth_update_expdesign->execute("SC",$hybid);
	}
}

$sth_update_expdesign->finish();

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

