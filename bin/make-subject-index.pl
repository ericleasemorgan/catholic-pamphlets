#!/usr/bin/perl

# make-subject-index.pl - create a list subjects and their associated titles; a subject index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June  30, 2017 - first cut
# March 15, 2019 - hacked on the way to Florence


# configure
use constant DRIVER   => 'SQLite';
use constant DATABASE => './etc/pamphlets.db';
use constant PREFACE  => qq(\n\nSubject index to the Catholic Pamphlets Collection\n\n\tThis is the simpliest of subject indexes to Catholic Pamphlets Collection of the Hesburgh Libraries at the University of Notre Dame. Search & browse the index, and then cross-reference what you discover with the companion title index for more detail. --Eric Lease Morgan (March 15, 2019)\n\n\n);

# require
use strict;
use DBI;

# initialize
my $driver       = DRIVER; 
my $database     = DATABASE;
my $dbh          = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql          = '';
my $result       = '';
my $handle       = '';
my $subhandle    = '';
my $subsubhandle = '';
my $count        = 0;

# create a list of all the authors
$sql = qq(SELECT DISTINCT( subject ) FROM subjects ORDER BY subject ASC;);

# do the work
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# start the output
print PREFACE;

# output, disconnect, and done
while( my $row = $handle->fetchrow_hashref() ) {

	# the subject
	my $subject = $$row{ 'subject' };

	# echo and escape
	print "$subject\n";
	$subject =~ s/'/''/g;

	# build a did subquery
	$sql = qq(SELECT system FROM subjects WHERE subject='$subject';);
	$subhandle = $dbh->prepare( $sql );
	$result = $subhandle->execute() or die $DBI::errstr;
	while( my $systems = $subhandle->fetchrow_hashref() ) {
	
		# parse and increment
		my $system = $$systems{ 'system' };
		
		# build a title subsubquery
		$sql = qq(SELECT title FROM titles WHERE system='$system' ORDER BY title_sort;);
		$subsubhandle = $dbh->prepare( $sql );
		$result = $subsubhandle->execute() or die $DBI::errstr;
		while( my $titles = $subsubhandle->fetchrow_hashref() ) {
		
			# parse, increment, and output
			my $title = $$titles{ 'title' };
			$count++;
			print "\t$count. $title\n";
			
		}
		
	}
	
	# delimit and reset
	print "\n";
	$count = 0;
	
}

# clean up and done
$dbh->disconnect();
exit;
