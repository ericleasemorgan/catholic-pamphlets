#!/usr/bin/env perl

# cluster-persons.pl - given a set of names, use levenshtein to normalize them and output sql update statements
# usage: ./bin/cluster-persons.pl > ./sql/persons-update.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# March 30, 2019 - on a plane back from florence


# configure
use constant ROUND      => 3;
use constant DRIVER     => 'SQLite';
use constant DATABASE   => './etc/pamphlets.db';
use constant GOODENOUGH => .83;
use constant SELECT     => 'SELECT COUNT( person ) AS c, person FROM persons GROUP BY person ORDER BY c desc;';

# require
use DBI;
use List::Util qw( min );
use strict;
require './lib/tfidf-toolbox.pl';

$| = 1;

# open database
my $driver   = DRIVER; 
my $database = DATABASE;
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

# find everybody
my $handle = $dbh->prepare( SELECT );
$handle->execute() or die $DBI::errstr;

# store the result for use
my @persons = ();
while( my $record = $handle->fetchrow_hashref ) { push( @persons, $$record{ 'person' } ) }

# process each possible combination of persons
my %goodenough = ();
my $count      = scalar( @persons );
for ( my $i = 0; $i < $count; $i++ ) {

	# re-initialize
	my $person = @persons[ $i ];
	
	# skip already processed persons
	next if ( $goodenough{ $person } );
	
	# debug
	print "\n--$person ($i of $count)\n";
	
	for ( my $j = $i + 1; $j <= $count; $j++ ) {
	
		# re-initialize
		my $name = @persons[ $j ];
	
		# skip already processed persons
		next if ( $goodenough{ $name } );
		
		# calculate similarity score; note case-insensitive comparison
		my $score = &round( &ratio( lc( $person ), lc( $name ) ), ROUND );

		if ( $score >= GOODENOUGH ) {
		
			# update list of good enough values
			$goodenough{ $name }++;
			
			# configure and create output
			my $target =  $person;
			$target    =~ s/'/''/g;
			$name      =~ s/'/''/g;
			print "UPDATE persons SET person = '$target' where person = '$name';\n";
	
		}

	}
	
}

# done
exit;

