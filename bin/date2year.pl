#!/usr/bin/env perl

# date2year.pl - query a database for dates, convert them to years, and output SQL update statements
# usage: ./bin/date2year.pl > ./sql/years.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# March 30, 2019 - on a plane from Palo Alto via Florence; yikes!


# configure
use constant DRIVER     => 'SQLite';
use constant DATABASE   => './etc/pamphlets.db';
use constant SELECT     => 'SELECT system, date FROM titles ORDER BY system;';

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

# process each result
while( my $row = $handle->fetchrow_hashref ) {

	# re-initialize
	my $system = $$row{ 'system' };
	my $date   = $$row{ 'date' };
	my $year   = $date;

	# normalize
	$year =~ s/\D+//g;
	if ( ! $year ) { $year = '1900' }
	if ( length( $year ) == 2 ) { $year = $year . '00' }
	if ( length( $year ) == 3 ) { $year = $year . '0' }
	if ( length( $year )  > 4 ) { $year = substr( $year, 0, 4 ) }

	# output
	print "UPDATE titles SET year = '$year' WHERE system IS '$system';\n";
		
}

# done
exit;

