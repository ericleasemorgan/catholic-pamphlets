#!/usr/bin/perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# October  20, 2017 - first cut; based on earlier work


# configure
use constant FACETFIELD         => ( 'facet_subject', 'facet_author', 'facet_publisher', 'facet_place', 'facet_date', 'facet_year', 'facet_city', 'facet_tag', 'facet_person' );
use constant HIGHLIGHTDELIMITER => '*';
use constant HIGHLIGHTFEILD     => 'fulltext';
use constant ROWS               => 10;
use constant SNIPPETS           => 3;
use constant SOLR               => 'http://localhost:8983/solr/pamphlets';

# require
use strict;
use WebService::Solr;

# get input; sanity check
my $query = $ARGV[ 0 ];
if ( ! $query ) {

	print "Usage: $0 <query>\n";
	exit;
	
}

# initialize
my $solr = WebService::Solr->new( SOLR );
binmode( STDOUT, ':utf8' );

# build the search options
my %search_options = ();
$search_options{ 'facet.field' }    = [ FACETFIELD ];
$search_options{ 'facet' }          = 'true';
$search_options{ 'hl.fl' }          = HIGHLIGHTFEILD;
$search_options{ 'hl.simple.post' } = HIGHLIGHTDELIMITER;
$search_options{ 'hl.simple.pre' }  = HIGHLIGHTDELIMITER;
$search_options{ 'hl.snippets' }    = SNIPPETS;
$search_options{ 'hl' }             = 'true';
$search_options{ 'rows' }           = ROWS;

# search
my $response = $solr->search( $query, \%search_options );

# build a list of person facets
my @facets_person = ();
my $person_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_person } );
foreach my $facet ( sort { $$person_facets{ $b } <=> $$person_facets{ $a } } keys %$person_facets ) { push @facets_person, $facet . ' (' . $$person_facets{ $facet } . ')'; }

# build a list of tag facets
my @facets_tag = ();
my $tag_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_tag } );
foreach my $facet ( sort { $$tag_facets{ $b } <=> $$tag_facets{ $a } } keys %$tag_facets ) { push @facets_tag, $facet . ' (' . $$tag_facets{ $facet } . ')'; }

# build a list of subject facets
my @facets_subject = ();
my $subject_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_subject } );
foreach my $facet ( sort { $$subject_facets{ $b } <=> $$subject_facets{ $a } } keys %$subject_facets ) { push @facets_subject, $facet . ' (' . $$subject_facets{ $facet } . ')'; }

# build a list of author facets
my @facets_author = ();
my $author_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_author } );
foreach my $facet ( sort { $$author_facets{ $b } <=> $$author_facets{ $a } } keys %$author_facets ) { push @facets_author, $facet . ' (' . $$author_facets{ $facet } . ')'; }

# build a list of publisher facets
my @facets_publisher = ();
my $publisher_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_publisher } );
foreach my $facet ( sort { $$publisher_facets{ $b } <=> $$publisher_facets{ $a } } keys %$publisher_facets ) { push @facets_publisher, $facet . ' (' . $$publisher_facets{ $facet } . ')'; }

# build a list of place facets
my @facets_city = ();
my $city_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_city } );
foreach my $facet ( sort { $$city_facets{ $b } <=> $$city_facets{ $a } } keys %$city_facets ) { push @facets_city, $facet . ' (' . $$city_facets{ $facet } . ')'; }

# build a list of date facets
my @facets_year = ();
my $year_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_year} );
foreach my $facet ( sort { $$year_facets{ $b } <=> $$year_facets{ $a } } keys %$year_facets ) { push @facets_year, $facet . ' (' . $$year_facets{ $facet } . ')'; }

# get highlights
my $highlights = $response->content->{ 'highlighting' };

# get the total number of hits
my $total = $response->content->{ 'response' }->{ 'numFound' };

# get number of hits returned
my @hits = $response->docs;

# start the output
print "Your search found $total item(s) and " . scalar( @hits ) . " items(s) are displayed.\n\n";
print '    subject facets: ', join( '; ', @facets_subject ), "\n\n";
print '     author facets: ', join( '; ', @facets_author ), "\n\n";
print '  publisher facets: ', join( '; ', @facets_publisher ), "\n\n";
print '       city facets: ', join( '; ', @facets_city ), "\n\n";
print '       year facets: ', join( '; ', @facets_year ), "\n\n";
print '        tag facets: ', join( '; ', @facets_tag ), "\n\n";
print '     person facets: ', join( '; ', @facets_person ), "\n\n";

# loop through each document
for my $doc ( $response->docs ) {
	
	# parse
	my $system    = $doc->value_for(  'system' );
	my $author    = $doc->value_for(  'author' );
	my $title     = $doc->value_for(  'title' );
	my $publisher = $doc->value_for(  'publisher' );
	my $place     = $doc->value_for(  'place' );
	my $date      = $doc->value_for(  'date' );
	my $extent    = $doc->value_for(  'extent' );
	my $notes     = $doc->value_for(  'notes' );
	my $year      = $doc->value_for(  'year' );
	my $city      = $doc->value_for(  'city' );
	my $summary   = $doc->value_for(  'summary' );
	my @persons   = $doc->values_for( 'person' );
	my @subjects  = $doc->values_for( 'subject' );
	my @tags      = $doc->values_for( 'tag' );
			
	# create a list of snippets
	my @snippets = ();
	for ( my $i = 0; $i < SNIPPETS; $i++ ) {
	
		my $snippet  =  $highlights->{ $system }->{ fulltext }->[ $i ];
		$snippet     =~ s/\s+/ /g;
		$snippet     =~ s/^ +//;
		push( @snippets, $snippet );
		
	}
		
	# output
	print "          system: $system\n";
	print "          author: $author\n";
	print "           title: $title\n";
	print "       publisher: $publisher $place $date\n";
	print "          extent: $extent\n";
	print "           notes: $notes\n";
	print "            year: $year\n";
	print "            city: $city\n";
	print "         summary: $summary\n";
	print "       person(s): " . join( '; ', @persons ), "\n";
	print "      subject(s): " . join( '; ', @subjects ), "\n";
	print "          tag(s): " . join( '; ', @tags ), "\n";
	print "         snippet: " . join( ' ... ', @snippets ), "\n";
	print "\n";
	
}

# done
exit;


# convert an array reference into a hash
sub get_facets {

	my $array_ref = shift;
	
	my %facets;
	my $i = 0;
	foreach ( @$array_ref ) {
	
		my $k = $array_ref->[ $i ]; $i++;
		my $v = $array_ref->[ $i ]; $i++;
		next if ( ! $v );
		$facets{ $k } = $v;
	 
	}
	
	return \%facets;
	
}


