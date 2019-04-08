#!/usr/bin/perl

# make-publisher-index.pl - create a list publishers and their associated titles; a publisher index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June  30, 2017 - first cut
# March 15, 2019 - hacked on the way to Florence


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/pamphlets.db';
use constant PREFACE  => qq(\n\nPublisher index to the Catholic Pamphlets Collection\n\n\tThis is the simpliest of publisher indexes to Catholic Pamphlets Collection of the Hesburgh Libraries at the University of Notre Dame. Search & browse the index, and then cross-reference what you discover with the companion title index for more detail. --Eric Lease Morgan (March 15, 2019)\n\n\n);

# require
use strict;
use DBI;

# initialize
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql       = '';
my $result    = '';
my $handle    = '';
my $subhandle = '';
my $subsubhandle = '';
my $count     = 0;
binmode( STDOUT, ':utf8' );

# create a list of all the authors
$sql = qq(SELECT DISTINCT( publisher ) FROM titles ORDER BY publisher ASC;);

# do the work
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# start the output
print PREFACE;

# output, disconnect, and done
while( my $row = $handle->fetchrow_hashref() ) {

	# the author
	my $publisher = $$row{ 'publisher' };
	
	# only want titles with authors
	next if ( ! $publisher );
	
	# echo and escape
	print "$publisher\n";
	$publisher =~ s/'/''/g;

	# build a title subquery
	$sql = qq(SELECT title, system FROM titles WHERE publisher='$publisher' ORDER BY title_sort ASC;);
	$subhandle = $dbh->prepare( $sql );
	$result = $subhandle->execute() or die $DBI::errstr;
	while( my $titles = $subhandle->fetchrow_hashref() ) {
	
		# parse and increment
		my $title  = $$titles{ 'title' };
		my $system = $$titles{ 'system' };
		$count++;
		
		# echo
		print "\t$count. $title\n";
		
	}
	
	# delimit and reset
	print "\n";
	$count = 0;
	
}

# clean up and done
$dbh->disconnect();
exit;
