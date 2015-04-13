#!/usr/bin/perl
$|=1;
$/="\^SAMPLE";

use LWP::UserAgent;
use strict;
use Cwd;
use LWP::Simple;
use File::Copy;
use DBI;
use POSIX qw(strftime);

my ($gse,$gplref,$scriptdir, $dataLoc,$expid,$user, $passwd, $host, $port, $dbname)= @ARGV;

#####---------(BLOCK1) Read and parse the SOFT file for getting data -----------#######
open GSE , "$dataLoc/BigMac/data/GEO/GSE/$gse"."_family.soft" or die "Can't open $dataLoc/BigMac/data/GEO/GSE/$gse.family.soft for read.";
my @data;
my @dataRowCount;
my @samples;
my @head;
my @gpl;
my @GPLref=split(/-/,$gplref);
my $now = localtime time;
my ($c,$d);
my @map;
my $OS = $^O;

$scriptdir =~ s/\//\\\"\/\\\"/g;
$scriptdir =~ s/\\\"//;
$scriptdir =~ s/$/\\\"/;

if($OS eq "MSWin32"){
    $scriptdir =~ s/\\/\\\\/g;
}else{
    $scriptdir =~ s/\"//g;	#### use it when calling the script in Linux/Mac
}

print "Loading samples data ... $now\n";
print "Reading GSE SOFT file ...\n";
while(my $chunk=<GSE>)
  {	
    $chunk=~s/\^SAMPLE//;
    $chunk=~s/^ =/\^SAMPLE =/;
    if($chunk=~/\^SAMPLE = (.*?)[\r|\n]/){ push(@samples,"$1\n");}
    if($chunk=~/\!Sample_platform_id = (.*?)[\r|\n]/){ $d=$1; push(@gpl,"$d\n");}
    if($chunk=~/\!Sample_data_row_count = (.*?)[\r|\n]/){ $c=$1; push(@dataRowCount,"$c\n"); push @map,"$c"."-"."$d";}

    if($chunk=~/sample_table_begin\n(.*?)\!sample_table_end/s)
      {
	my $match=$1;
	if($match=~/(ID_REF.*?)[\r|\n]/){ push(@head,$1);}
      }
  }
close GSE;
#### Parsing DONE -----------####
$now = localtime time;

##----------------------------------------------------------
my %hsh;
my @array = split(/\@/,join('',@data));
my @headers= grep { !$hsh{$_}++ }@head;

#print "@headers\n";
####----(BLOCK2) If there are different numbers of columns in different samples, the lowest number of cols will be used further --- ####
if(scalar@headers!=1){
  my %hash;
  foreach my $val(@headers){
    my $len2 = scalar(split(/\t/,$val));
    $hash{$len2}=$val;
  }
  my @sorted = sort { $a<=>$b } keys %hash;
  @headers=split(/\t/,$hash{$sorted[0]});
}else{
  @headers=split(/\t/,$headers[0]);
}
####----(BLOCK3) Retrieve columns present in all the samples ------####

#print "@headers\n";
### --- create file sample to list GSM ids of all the samples --- ###
open SAMPLE, ">samples" or die "Can't open file to print output";
print SAMPLE @samples;
close SAMPLE;

####-----(BLOCK4) Create the datafiles for all the headers or columns -- ###
$now = localtime time;
print "Parsing expression data for each sample ... $now\n";
my $i=1;

open GSE , "$dataLoc/BigMac/data/GEO/GSE/$gse"."_family.soft" or die "Can't open $dataLoc/BigMac/data/GEO/GSE/$gse.family.soft for read.";
my $array="";
while(my $chunk=<GSE>){
  $now = localtime time;
  #print ".";

  open OUT, ">tempFile" or die "Can't open file to print output";
  if($chunk=~/sample_table_begin\n(.*?)\!sample_table_end/s){$array=$1;}
  print OUT $array;
  close OUT;

  my $cmd="perl $scriptdir/Perl/transpose.pl < tempFile > tOutput";
  $cmd =~ s/\\//g;
  system($cmd);
	
  $/="\n";
  open IN ,"tOutput" or die "Can't open input file";
  my @input=<IN>;
  close IN;
  $/="\^SAMPLE";

  if($i!=1){
    chop $dataRowCount[$i-2];
    chop $samples[$i-2];
    chop $gpl[$i-2];
	
    for(my $j=0;$j<scalar(@headers);$j++){
      chomp $headers[$j];
      chop $input[$j];
      $input[$j]=~s/\t$/\tNA/;
      $headers[$j]=~s/ /\_/g;
      #sleep 5;
      open FILE , ">>$headers[$j]" or die "Can't open input file";
      print FILE "$dataRowCount[$i-2]"."-"."$gpl[$i-2]\t$samples[$i-2]\t$input[$j]\n";
      close FILE;
    }
  }
  $i++;
}
print " Done!\n";
$now = localtime time;
$/="\n";
print "Creating ExpressionSets ... $now\n";
my $dbh;my $err;

###===== finding unique sample data row count values =======
foreach my $GPLref(@GPLref){

  #### --- creating annotation file -- ####
  my @annot;
  my $softflag=1;
  if(-e "$dataLoc/BigMac/annotation/$GPLref.annot"){
    open GPL , "$dataLoc/BigMac/annotation/$GPLref.annot" or die "Can't open $dataLoc/BigMac/annotation/$GPLref.annot file to read.";
  } else {
    open GPL , "$dataLoc/BigMac/data/GEO/GPL/$GPLref.soft" or die "Can't open $GPLref.soft file to read.";
    print "No annotation file has been downloaded yet for $GPLref ...\n";
    $softflag=0;
  }
  open WGPL , ">gpl.annot" or die "Can't open gpl.annot file to read.";
  while(<GPL>)
    {
      if(/^\!platform_table_begin/../^\!platform_table_end/)
	{
	  $_=~s/\!platform_table.*\n//;
	  push(@annot,$_);
	}
    }
  print WGPL @annot;
  close GPL;
  close WGPL;
  #print "$softflag\n";
	
  #####----(BLOCK5) Create featureData for expression set ---########
  if($softflag){
    my $cmd="perl $scriptdir/Perl/transpose.pl < gpl.annot > gpl";
    $cmd =~ s/\\//g;
    system($cmd);

    open GPL , "gpl" or die "Can't open GPL file to read.";
    my @gpl=<GPL>;
    close GPL;
    open NEWGPL , ">gpl" or die "Can't open new GPL file to write.";
    print NEWGPL @gpl[0..9];
    close NEWGPL;

    $cmd="perl $scriptdir/Perl/transpose.pl < gpl > gplnew";
    $cmd =~ s/\\//g;
    system($cmd);
  }else{
    system(`cp -rf gpl.annot gplnew.annotation`)
  }

  print "Calculating data row count of each sample with $GPLref ... $now\n";
  my @result= grep(/$GPLref/,@map);
  my %hsh;
  my @uniqRowCount=grep { !$hsh{$_}++ }@result;
  #print "@uniqRowCount";

  #########################################################
  ####---------(BLOCK6) Create the datafiles of columns with samples differing in data row count --- ####
  my $part=0;my $c=0;my $rowCount;
  print "Number of sample sets based on different data row counts = ";
  print scalar @uniqRowCount; print "\n";

  foreach my $no(@uniqRowCount){
    chomp $no;$part++;
    $rowCount=$hsh{$uniqRowCount[$c]};$c++;
    my $cols;
    for(my $j=0;$j<scalar(@headers);$j++){
      chomp $headers[$j];
      $headers[$j]=~s/ /\_/g;
      open FILE , "$headers[$j]" or die "Can't open input file";
      my @file=<FILE>;
      close FILE;
      my @p=grep(/^$no/,@file);
      $cols=scalar(@p);
      my $filename="$headers[$j]".".set"."$part";
      open SET , ">interim" or die "Can't open input file";
      if($j==0){
	print SET $p[0];
      }elsif($rowCount==$cols){
	print SET @p;
      }else{
	#print "NEXT\n";
	next;
      }
      close SET;
      my $cmd="perl $scriptdir/Perl/transpose.pl < interim > $filename";
      $cmd =~ s/\\//g;
      system($cmd);
    }
    ####---(BLOCK7) create R object of class ExpressionSet of the nth set ---- ####
    my $rfile=$scriptdir."/R/esetGeneration.R";
    my $str="ExpressionSet "."$part";
    print "$str ... ";
    my $str="set"."$part";
    if(scalar(@uniqRowCount) > 1 && $part == scalar(@uniqRowCount)){
      my $cmd="Rscript $rfile *$str $no $cols $part";
      $cmd =~ s/\\//g;
      $err=`$cmd`;
    }else{
      my $cmd="Rscript $rfile *$str $no $cols 0";
      $cmd =~ s/\\//g;
      $err=`$cmd`;
    }
		
    if($err=~m/Error/){
      print "An error occurred when creating the ExpressionSet: check message.log\n";
      exit;
    }
    $now = localtime time;
    print "$now\n";
  }

  ######---(BLOCK8) Inserting ExpressionSet into the database ---------############

  my $maxLimit=10000;

  $dbh = DBI->connect("dbi:mysql:dbname=$dbname:$host:$port",$user,$passwd) or die "Cannot open connection", "$DBI::errstr" ;
  my $select = $dbh->prepare("SELECT idchip FROM chip WHERE db_platform_id = ?");
  my $insert = $dbh->prepare("INSERT INTO expressionset (idExperiment,idchip,filename,filetype,filesize,filecontent) VALUES (?,?,?,?,?,?)");
  my $update = $dbh->prepare("UPDATE experiment SET esetFileSize = ? WHERE idExperiment = ?");
  my ($data,$temp)="";
  my $filesize = -s "eset.RData";
  #print "$filesize\n";
  $select -> execute($GPLref);
  my $idchip = $select->fetchrow();

  $update -> execute($filesize,$expid);
  $update -> finish();
  my $line;
  $i=1;
  open MYFILE, "eset.RData" or die "Can't open the file to read";
  binmode(MYFILE);

  {
    use bytes;
    while (read(MYFILE,$line,$maxLimit)) {
      $i++;
      #print "$i..";
      my $filename="eset".$i;
      $insert -> execute($expid,$idchip,$filename,".RData",length($line),$line);
    }
    close MYFILE;
  }
  $insert -> finish();
}
$dbh->disconnect;

my $directory = "outputs";
unless(-e $directory or mkdir $directory) {
        die "Unable to create $directory\n";
}

foreach my $file(@headers){
    my @files=glob ($file."*"); ## get the list of files
	move("$_", "$directory/$_") for @files;
}
my @files=("interim","tempFile","tOutput","samples",glob ("gpl*"), glob ("esetset*"));
move("$_","$directory/$_") for @files;

`rm -rf $directory`;
