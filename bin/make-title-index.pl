#!/usr/bin/perl

# make-title-index.pl - create a list titles and all of their associated metadata; create the main index

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June    29, 2017 - first cut
# October 19, 2017 - changed the output to: 1) take up less space and 2) look more catalog card-like
# March   15, 2019 - hacked on the way to Florence


# configure
use constant DRIVER      => 'SQLite';
use constant DATABASE    => './etc/pamphlets.db';
use constant ABOUT       => qq(\n\nTitle (main) index to the Catholic Pamphlets Collection\n\nThis is a simple title index to the Hesburgh Libraries's Catholic Pamphlets Collection here at the University of Notre Dame. This "catalog" is to be used in conjunction with the suppliemental author, subject, date, and publisher indexes. Pour any or all of the files into your favorite text editor or word processor and then search & browse the collection. --Eric Lease Morgan (March 15, 2019)\n\n\n);
use constant LOWERBOUNDS => '0.5';

# require
use strict;
use DBI;

# initialize
my $driver   = DRIVER; 
my $database = DATABASE;
my $dbh      = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
$|           = 1;

# add some context
print ABOUT;

# find some titles
my $handle = $dbh->prepare( qq(SELECT * FROM titles ORDER BY title_sort ASC;) );
$handle->execute() or die $DBI::errstr;

# process each result
while( my $titles = $handle->fetchrow_hashref ) {
	
	# parse the title data
	my $title     = $$titles{ 'title' };
	my $author    = $$titles{ 'author' };
	my $statement = $$titles{ 'statement' };
	my $extent    = $$titles{ 'extent' };
	my $notes     = $$titles{ 'notes' };
	my $flesch    = $$titles{ 'flesch' };
	my $words     = $$titles{ 'words' };
	my $summary   = $$titles{ 'summary' };
	my $system    = $$titles{ 'system' };

	# get subjects
	my @subjects  = ();
	my $subhandle = $dbh->prepare( qq(SELECT subject FROM subjects WHERE system='$system' ORDER BY subject;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @subject = $subhandle->fetchrow_array ) { push @subjects, $subject[ 0 ] }

	# get tags
	my @tags = ();
	$subhandle = $dbh->prepare( qq(SELECT tag FROM tags WHERE system='$system' ORDER BY tag;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @tag = $subhandle->fetchrow_array ) { push @tags, $tag[ 0 ] }

	# get persons
	my $lowerbounds = LOWERBOUNDS;
	my @persons     = ();
	$subhandle      = $dbh->prepare( qq(SELECT DISTINCT( person ) FROM persons WHERE system='$system' AND rank > '$lowerbounds' ORDER BY person;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my $persons = $subhandle->fetchrow_hashref ) { push @persons, $$persons{ 'person' } }

	# get urls
	my %urls = ();
	$subhandle = $dbh->prepare( qq(SELECT url, type FROM urls WHERE system='$system';) );
	$subhandle->execute() or die $DBI::errstr;
	while( my $urls = $subhandle->fetchrow_hashref ) { $urls{ $$urls{ 'url' } } = $$urls{ 'type' } }

	# dump sort of like a catalog card
	print "$title\n";
	if ( $statement ) { print "  publisher: $statement\n" }
	if ( $extent )    { print "     extent: $extent\n" }
	if ( $words )     { print "      words: $words\n" }
	if ( $flesch )    { print "     flesch: $flesch\n" }
	if ( $notes )     { print "      notes: $notes\n" }
	if ( @persons )   { print "    persons: "; print join( '; ', @persons ), "\n" }
	if ( @subjects )  { print "   subjects: "; print join( '; ', @subjects ), "\n" }
	if ( @tags )      { print "   keywords: "; print join( '; ', @tags ), "\n" }
	foreach my $url ( keys( %urls ) ) { print "      links: $url (" . $urls{ $url } . ")\n" }
	if ( $summary )   { print "    summary: $summary\n" }
	print "\n\n\n";

}

# clean up and done
$dbh->disconnect();
exit;
