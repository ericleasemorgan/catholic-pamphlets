#!/usr/bin/env perl

# clean-persons.pl - given a TSV file of a certain shape, output identifiers and "cleaned" values
# usage: ./bin/clean-person.pl ./tsv/persons.tsv > ./tsv/persons-clean.tsv

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 2, 2019 - in Palo Alto the day after an IMLS meeting and three days after Florence


# require
use strict;

# sanity check
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <tsv>\n" }

# open the input and loop through each row
open TSV, " < $tsv" or die "Can't open $tsv ($!)\n";
while ( <TSV> ) {

	# parse
	chop;
	my ( $system, $person ) = split "\t";

	# do the work, the hard way
	$person =~ s/\d+//g;
	$person =~ s/[~]//g;
	$person =~ s/\*//g;
	$person =~ s/>//g;
	$person =~ s/<//g;
	$person =~ s/•//g;
	$person =~ s/=//g;
	$person =~ s/ \.//g;
	$person =~ s/://g;
	$person =~ s/°//g;
	$person =~ s/\\//g;
	$person =~ s/»//g;
	$person =~ s/«//g;
	$person =~ s/^— //g;
	$person =~ s/^" //g;
	$person =~ s/ \($//g;
	$person =~ s/-$//g;
	$person =~ s/—$//g;
	$person =~ s/ +/ /g;
	$person =~ s/^ //g;
	$person =~ s/ $//g;
	
	next if ( length( $person ) < 3 );
	next if ( ! $person );
	
	# output
	print join( "\t", ( $system, $person ) ), "\n";
		
}

# clean up and done
close TSV;
exit;