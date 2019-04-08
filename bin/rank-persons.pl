#!/usr/bin/env perl

# rank-persons.pl - given an identifier and number of documents, calculate and output tfidf scores for person

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# March 30, 2019 - on a plane back from florence
# March 31, 2019 - trying to parallelize


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/pamphlets.db';

# require
use DBI;
use strict;
use List::Util 'sum';
require './lib/tfidf-toolbox.pl';

# get input
my $system = $ARGV[ 0 ];
my $d      = $ARGV[ 1 ];
if ( ! $system or ! $d ) { die "Usage: $0 <system> <d>\n" }

# open database
my $driver   = DRIVER; 
my $database = DATABASE;
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

# count & tabulate the persons in the given document ($t)
my %persons = ();
my $handle  = $dbh->prepare( "SELECT COUNT( person ) AS c, person FROM persons WHERE system is '$system' GROUP BY person ORDER BY c;" );
$handle->execute() or die $DBI::errstr;
while( my $row = $handle->fetchrow_hashref ) { $persons{ $$row{ 'person' } } = $$row{ 'c' } }
my $t = sum( values %persons );

# process each person
foreach my $person ( sort( keys( %persons ) ) ) {

	# get the number of times this person appears
	my $n = $persons{ $person };
	
	# find out how many times this person appears in the whole database (h)
	my $name = $person;
	$name   =~ s/'/''/g;
	$handle =  $dbh->prepare( "SELECT COUNT( person ) AS c FROM persons WHERE person is '$name';" );
	$handle->execute() or die $DBI::errstr;
	my $row =  $handle->fetchrow_hashref;
	my $h   =  $$row{ 'c' };
	
	# calculate tfidf and output; maybe ought to output sql
	my $rank = &tfidf( $n, $t, $d, $h );
	$person =~ s/'/''/g;
	print ( "UPDATE persons SET rank = '$rank' where person = '$person' AND system = '$system';\n" );

}

# be polite and done
$handle->finish;
$dbh->disconnect;
exit;


