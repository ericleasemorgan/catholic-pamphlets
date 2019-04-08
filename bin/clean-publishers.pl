#!/usr/bin/env perl

# clean-publishers.pl - given a set of publishers, use brute force to normalize their value and output SQL accordingly
# usage: ./bin/clean-publishers.pl > ./sql/publishers.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# April 2, 2019 - on a plane from Palo Alto via Florence; yikes!
# April 4, 2019 - tweaked


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/pamphlets.db';
use constant SELECT   => 'SELECT system, publisher FROM titles ORDER BY system';

# require
use DBI;
use strict;

# open database
my $driver   = DRIVER; 
my $database = DATABASE;
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

# search and process each row
my $handle = $dbh->prepare( SELECT );
$handle->execute() or die $DBI::errstr;
while( my $row = $handle->fetchrow_hashref ) { 

	# parse
	my $system    = $$row{ 'system' };
	my $publisher = $$row{ 'publisher' };
	
	# do the work
	$publisher =~ s/,$//g;
	$publisher =~ s/\]//g;
	$publisher =~ s/\[//g;
	$publisher =~ s/s\.n\.//g;
	$publisher =~ s/s\.n//g;
	$publisher =~ s/^,//g;
	$publisher =~ s/^The //g;
	$publisher =~ s/^ ;//g;
	
	$publisher =~ s/'/''/g;
	
	# output
	print "UPDATE titles SET publisher = '$publisher' WHERE system IS '$system';\n";
	
}

# done
exit;

