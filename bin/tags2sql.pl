#!/usr/bin/env perl

# tags2sql.pl = give a list of system numbers and "tags" output a set of SQL insert statements
# usage: ./bin/tags2sql.pl ./tsv/tags.tsv > ./sql/tags.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 17, 2019 - first cut; in Florence


# require
use strict;

# get & check input
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <file>\n" }

# open the input and process each line
open TSV, " < $tsv" or die "Can't open $tsv ($!)\n";
while ( <TSV> ) {

	# parse
	chop;
	my ( $system, $tag ) = split( "\t", $_ );
	
	# re-initialize
	my $sql = "INSERT into tags ( 'system', 'tag' ) VALUES ( '$system', '$tag' );";
	
	# output
	print "$sql\n";

}

# clean-up and done
close TSV;
exit;
