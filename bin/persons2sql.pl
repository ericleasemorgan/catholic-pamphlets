#!/usr/bin/env perl

# persons2sql.pl - give a list of system numbers and person names, output set of SQL insert statements
# usage: ./bin/persons2sql.pl ./tsv/persons.tsv > ./sql/persons.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 30, 2019 - first cut; on a plane in Florence


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
	my ( $system, $person ) = split( "\t", $_ );
	
	# escape
	$person =~ s/'/''/g;
	
	# re-initialize
	my $sql = "INSERT INTO persons ( 'system', 'person' ) VALUES ( '$system', '$person' );";
	
	# debug & output
	print "$sql\n";

}

# clean-up and done
close TSV;
exit;
