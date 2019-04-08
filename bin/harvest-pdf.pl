#!/usr/bin/perl

# harvest-pdf.pl - cache digitized content locally

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# October 19, 2017 - first investigations


# configure
use constant DRIVER    => 'SQLite';
use constant DATABASE  => './etc/pamphlets.db';
use constant DIRECTORY => './pdf';

# require
use DBI;
use LWP::Simple qw( getstore );
use strict;

# initialize
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql       = '';
my $result    = '';
my $handle    = '';
binmode( STDOUT, ':utf8' );
 
# build sql query
$sql = "SELECT system, url FROM urls WHERE type IS 'PDF' ORDER BY system ASC;";		

# search
$handle = $dbh->prepare( $sql );
$result = $handle->execute() or die $DBI::errstr;

# process the result
while( my $row = $handle->fetchrow_hashref() ) {

	# re-initialize
	my $system   = $$row{ 'system' };
	my $url      = $$row{ 'url' };
	my $file     = DIRECTORY . "/$system.pdf";
	my $response = '';
	
	# get the file, if it does not exist
	if ( ! -e $file ) { $response = getstore( $url, $file ) }
	else { $response = 'already exists' }

	# echo our good work
	warn "    system: $system\n";
	warn "       url: $url\n";
	warn "      file: $file\n";
	warn "  response: $response\n";
	warn "\n";
			
}

# clean up and done
$dbh->disconnect();
exit;
