#!/usr/bin/perl

# index.pl - make the content searchable

# Eric Lease Morgan <emorgan@nd.edu>
# October 19, 2017 - first investigations

# configure
use constant DATABASE    => './etc/pamphlets.db';
use constant DRIVER      => 'SQLite';
use constant QUERY       => qq(SELECT * FROM titles ORDER BY system;);
use constant SOLR        => 'http://localhost:8983/solr/pamphlets';
use constant TEXT        => './txt';
use constant LOWERBOUNDS => '0.5';

# require
use DBI;
use strict;
use WebService::Solr;

# initialize
my $solr   = WebService::Solr->new( SOLR );
binmode( STDOUT, ':utf8' );
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
my $sql       = '';
my $result    = '';

# find titles
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# process each title
my $i = 0;
while( my $titles = $handle->fetchrow_hashref ) {
	
	my $city = '';
	
	# parse the title data
	my $system      = $$titles{ 'system' };
	my $date        = $$titles{ 'date' };
	my $author      = $$titles{ 'author' };
	my $concordance = $$titles{ 'concordance' };
	my $title     = $$titles{ 'title' };
	my $publisher = $$titles{ 'publisher' };
	my $place     = $$titles{ 'place' };
	my $statement = $$titles{ 'statement' };
	my $summary   = $$titles{ 'summary' };
	my $extent    = $$titles{ 'extent' };
	my $notes     = $$titles{ 'notes' };
	my $city      = $$titles{ 'city' };
	my $year      = $$titles{ 'year' };
	my $fulltext  = &slurp( TEXT . "/$system.txt" );

	# hmmm...
	if ( ! $city )    { $city = '' }
	if ( ! $summary ) { $summary = '' }
	
	# get persons
	my $lowerbounds = LOWERBOUNDS;
	my @persons    = ();
	my $subhandle  = $dbh->prepare( qq(SELECT DISTINCT( person ) FROM persons WHERE system='$system' AND rank > '$lowerbounds' ORDER BY person;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my $persons = $subhandle->fetchrow_hashref ) { push @persons, $$persons{ 'person' } }
	
	# get tags/keywords
	my @tags      = ();
	my $subhandle = $dbh->prepare( qq(SELECT tag FROM tags WHERE system='$system';) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @tag = $subhandle->fetchrow_array ) { push @tags, $tag[ 0 ] }
	
	# get subjects
	my @subjects       = ();
	my @facet_subjects = ();
	my $subhandle = $dbh->prepare( qq(SELECT subject FROM subjects WHERE system='$system';) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @subject = $subhandle->fetchrow_array ) {
	
		# update list of fully fleshed out subjects
		push @subjects, $subject[ 0 ];
		
		# build list of subject facets
		foreach my $facet ( split( ' -- ', $subject[ 0 ] ) ) { push @facet_subjects, $facet }
		
	}
	
	# debug; dump
	warn "           author: $author\n";
	warn "           extent: $extent\n";
	warn "           concordance: $concordance\n";
	warn "            notes: $notes\n";
	warn "        person(s): ", join( '; ', @persons ), "\n";
	warn "           tag(s): ", join( '; ', @tags ), "\n";
	warn "       subject(s): ", join( '; ', @subjects ), "\n";
	warn "        facets(s): ", join( '; ', @facet_subjects ), "\n";
	warn "        statement: $statement\n";
	warn "          summary: $summary\n";
	warn "           system: $system\n";
	warn "            title: $title\n";
	warn "             year: $year\n";
	warn "             city: $city\n";
	warn "\n";
	
	# create data
	my $solr_author          = WebService::Solr::Field->new( 'author'          => $author );
	my $solr_date            = WebService::Solr::Field->new( 'date'            => $date );
	my $solr_extent          = WebService::Solr::Field->new( 'extent'          => $extent );
	my $solr_concordance     = WebService::Solr::Field->new( 'concordance'     => $concordance );
	my $solr_facet_author    = WebService::Solr::Field->new( 'facet_author'    => $author );
	my $solr_facet_date      = WebService::Solr::Field->new( 'facet_date'      => $date );
	my $solr_facet_year      = WebService::Solr::Field->new( 'facet_year'      => $year );
	my $solr_facet_city      = WebService::Solr::Field->new( 'facet_city'      => $city );
	my $solr_facet_place     = WebService::Solr::Field->new( 'facet_place'     => $place );
	my $solr_facet_publisher = WebService::Solr::Field->new( 'facet_publisher' => $publisher );
	my $solr_fulltext        = WebService::Solr::Field->new( 'fulltext'        => $fulltext );
	my $solr_notes           = WebService::Solr::Field->new( 'notes'           => $notes );
	my $solr_place           = WebService::Solr::Field->new( 'place'           => $place );
	my $solr_publisher       = WebService::Solr::Field->new( 'publisher'       => $publisher );
	my $solr_system          = WebService::Solr::Field->new( 'system'          => $system );
	my $solr_summary         = WebService::Solr::Field->new( 'summary'         => $summary );
	my $solr_title           = WebService::Solr::Field->new( 'title'           => $title );
	my $solr_year            = WebService::Solr::Field->new( 'year'            => $year );
	my $solr_city            = WebService::Solr::Field->new( 'city'            => $city );

	# fill a solr document with simple fields
	my $doc = WebService::Solr::Document->new;
	$doc->add_fields( $solr_year, $solr_city, $solr_facet_year, $solr_facet_city, $solr_author, $solr_date, $solr_system, $solr_extent, $solr_facet_author, $solr_facet_date, $solr_facet_place, $solr_facet_publisher, $solr_fulltext, $solr_place, $solr_publisher, $solr_title, $solr_summary, $solr_concordance );

	# add complex fields
	foreach ( @facet_subjects ) { $doc->add_fields(( WebService::Solr::Field->new( 'facet_subject' => $_ ))) }
	foreach ( @persons )        { $doc->add_fields(( WebService::Solr::Field->new( 'facet_person' => $_ ))) }
	foreach ( @persons )        { $doc->add_fields(( WebService::Solr::Field->new( 'person'        => $_ ))) }
	foreach ( @subjects )       { $doc->add_fields(( WebService::Solr::Field->new( 'subject'       => $_ ))) }
	foreach ( @tags )           { $doc->add_fields(( WebService::Solr::Field->new( 'facet_tag'     => $_ ))) }
	foreach ( @tags )           { $doc->add_fields(( WebService::Solr::Field->new( 'tag'           => $_ ))) }

	# save/index
	$solr->add( $doc );

	$i++;
	#last if ( $i == 10 );
	
}

# done
exit;

sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}

