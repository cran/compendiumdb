# 1) Gets GDSs and GPLs found for user input, values are GSEs to which these GDSs and GPLs correspond
sub get_GPLs_and_GDSs_for_known_GSEs
{
        my ( @input_gse ) = @_;
        my %hash_GSE_GPL_GDS;
        my $eUtils_root = 'http://www.ncbi.nlm.nih.gov/entrez/eutils';
        my $eSearch_url = "$eUtils_root/esearch.fcgi";
        my $eSummary_url = "$eUtils_root/esummary.fcgi";
        my $retmax = 9999999;
        if ( scalar @input_gse )
        {
                my $term = make_query_string_from_array ( '[ACCN]', @input_gse );
                my @term_split_into_pieces = split_query_into_pieces ( $term, 7500, '|' );
                foreach my $this_term_part ( @term_split_into_pieces )
                {
                        my $page = my_get ("$eSearch_url?db=gds&retmax=$retmax&usehistory=y&term=($this_term_part)+AND+(gse[ETYP])");

                     	if ( $page =~ m/<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(.+?)<\/WebEnv>/s )
                	{
                                my $query_key = $1; my $WebEnv = $2;
                                my $page2 = my_get("$eSummary_url?db=gds&query_key=$query_key&WebEnv=$WebEnv");
                                # Get the results
                                my @summaries = $page2 =~ /(<DocSum>.+?<\/DocSum>)/gs;
                                foreach my $this_summary ( @summaries )
                                {
                                        #print "$this_summary\n\n"; sleep 1;
                                        my $this_GSE = '';
                                        # Get GSE accession from the current GSE description
                                        if ( $this_summary =~ /<Item Name="GSE" Type="String">(\d+?)<\/Item>/ )
                                        {
                                                $this_GSE = "GSE".$1;
                                                ${ $hash_GSE_GPL_GDS{$this_GSE} } { "GPLs" }  = [  ];
                                                ${ $hash_GSE_GPL_GDS{$this_GSE} } { "GDSs" } = [  ];

                                        }
					# Get GDSs for the current GSE
                                        if ( $this_summary =~ /<Item Name="GPL" Type="String">(.+?)<\/Item>/ )
                                        {
                                                my @GPL_for_this_gse = split ( ';', $1 );
                                                for ( my $i = 0; $i < scalar @GPL_for_this_gse; $i++ )
                                                {
                                                        $GPL_for_this_gse[$i] = "GPL".$GPL_for_this_gse[$i];
                                                }
                                                ${ $hash_GSE_GPL_GDS{$this_GSE} } { "GPLs" } = [ @GPL_for_this_gse ];

                                        }
                                        # Get GPLs for the current GSE
                                        if ( $this_summary =~ /<Item Name="GDS" Type="String">(.+?)<\/Item>/ )
                                        {
                                                my @GDS_for_this_gse = split ( ';', $1 );
                                                for ( my $i = 0; $i < scalar @GDS_for_this_gse; $i++ )

                                                {
                                                        $GDS_for_this_gse[$i] = "GDS".$GDS_for_this_gse[$i];
                                               }

                                               ${ $hash_GSE_GPL_GDS{$this_GSE} } { "GDSs" } = [ @GDS_for_this_gse ];
                                        }

                                } #foreach
                        }  #if($page....)
                }   # foreach my $this_term_part.....
        } #if...
        return %hash_GSE_GPL_GDS;
}

# 2) Make a query string from an input accessions' array
sub make_query_string_from_array
{
	my ( $field_specification, @array ) = @_;
        my $query_string = '';
	foreach my $this_element ( @array )
        {
        	unless ( length $query_string == 0 )
        	{
                	$query_string = $query_string."|";
                }

                $query_string = $query_string.$this_element.$field_specification;
        }

        return $query_string;
}

# 3)Split the long input string into several strings of the preferred length or shorter
# The string is "cut" on the input delimiters (each time the delimiter closest from the left to the preferred length point is chosen)
sub split_query_into_pieces
{
	my ( $entire_query, $required_length, $delimiter ) = @_;
        my @entire_query_array = split //, $entire_query;
        my @query_split_into_pieces;
        if ( scalar @entire_query_array <= $required_length )
        {
		push ( @query_split_into_pieces, join ( '', @entire_query_array ) );
        }
        else
        {
        	until ( scalar @entire_query_array < $required_length )
                {
                	my $where_to_split = $required_length - 1;
                        for( ; $entire_query_array[$where_to_split] ne $delimiter ; $where_to_split-- ) { ; }
                        my $another_piece = join ( '', splice (@entire_query_array,0,$where_to_split+1) );
                        chop ( $another_piece );
                        push ( @query_split_into_pieces, $another_piece );
                }
                push ( @query_split_into_pieces, join ( '', @entire_query_array ) );
        }

        return @query_split_into_pieces;
 }

# 4)Gets a page for the given url
# Tries 10 times with 1 second interval. If failed to get, prints warning about that.
sub my_get
{
	my ( $url ) = @_;
        my $page;
        print $page;
	for ( my $i = 0; $i < 10; $i++ )
        {
        	$page = get("$url");
                if ( defined ( $page ) )
                {
                	sleep 3;
                        last;
                }
                sleep 3;
        }

        unless ( defined ( $page ) )
        {
        	$page = '';
                #print "Error. Failed to get the page for url: $url\n\n";
	}

        return $page;
}

# 5)Download file or whole directory from FTP
sub download_file_from_ftp
{
        my( $ftp_site, $ftp_dir, $filename, $except, $local_dir ) = @_;
        my $error;

        if ( $filename ne "all" ) {
                print "\nDownloading $filename from $ftp_site/$ftp_dir...\n";
                my $ftp = Net::FTP  -> new( $ftp_site, reconnect => 1, Debug => 0, Passive => 1, BlockSize => 33554432, Timeout => 300 ) or print "Cannot connect to $ftp_site: $@\n";
                $ftp->login( "anonymous", '-anonymous@' ) or print "Cannot login ", $ftp->message, "\n";
                $ftp->cwd( "$ftp_dir" ) or print "Cannot change working directory ", $ftp->message, "\n";
                $ftp->binary();
                $ftp->get( "$filename", "$local_dir/$filename" ) or print "Get failed ", $ftp->message;
                $error=$ftp->message;
                $ftp->ls;
                $ftp->pwd;
                $ftp->quit;
        }
        else
        {
                print "\nDownloading all files from $ftp_site/$ftp_dir...\n";
                my $ftp = Net::FTP->new( $ftp_site, Debug => 1, Passive=>1 ) or print "Cannot connect to $ftp_site: $@\n";
                $ftp->login( "anonymous", '-anonymous@' ) or print "Cannot login ", $ftp->message, "\n";
                $ftp->cwd( "$ftp_dir" ) or print "Cannot change working directory ", $ftp->message, "\n";

                #BW issue with $newerr declaration
                my @filename=$ftp->ls or my $newerr=1;
                print "Filelist: @filename\n";
                push my @ERRORS, "Can't get file list $!\n" if $newerr;
                myerr( @ERRORS ) if $newerr;
                $ftp->binary();
                foreach my $this_filename ( @filename )
                {
                        if ( $this_filename ne $except )
                        {
                                $ftp->get( "$this_filename", "$local_dir/$this_filename" ) or print "Get failed ", $ftp->message;
                        }
                }
                $ftp->quit;
        }
        return $error;

}

# 6)Print errors
sub myerr
{
	my ( @ERRORS ) = @_;

	print "Error: \n";
        print "@ERRORS\n";
}


1;
