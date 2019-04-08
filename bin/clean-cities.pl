#!/usr/bin/env perl

# clean-cities.pl - given a set of cities, use levenshtein to normalize them and output sql update statements

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# April 2, 2019 - on a plane from Palo Alto via Florence; yikes!


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/pamphlets.db';
use constant SELECT   => 'SELECT system, place FROM titles ORDER BY system';

# require
use DBI;
use strict;

# open database
my $driver   = DRIVER; 
my $database = DATABASE;
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

# find everybody
my $handle = $dbh->prepare( SELECT );
$handle->execute() or die $DBI::errstr;

# store the result for use
while( my $row = $handle->fetchrow_hashref ) { 

	# parse
	my $system = $$row{ 'system' };
	my $city   = $$row{ 'place' };
	
	# do the work
	$city =~ s/ ://g;
	$city =~ s/New-York/New York/g;
	$city =~ s/\[//g;
	$city =~ s/\]//g;
	$city =~ s/\\//g;
	$city =~ s/://g;
	$city =~ s/, .*//g;
	$city =~ s/\?//g;
	$city =~ s/S\.l\.//g;
	$city =~ s/S\.l//g;
	$city =~ s/^ +//g;
	$city =~ s/ +$//g;
	next if ( ! $city );
	
	# output
	print "UPDATE titles SET city = '$city' WHERE system IS '$system';\n";
	
}

# done
exit;

