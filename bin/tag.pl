#!/usr/bin/perl

# tag.pl - list most significant keywords in a text; based on http://en.wikipedia.org/wiki/Tfidf
# usage: ./bin/tag.pl ./txt > ./tsv/tags.tsv

# Eric Lease Morgan <eric_morgan@infomotions.com>
# April 10, 2009 - first investigations; based on search.pl
# April 12, 2009 - added dynamic corpus
# March 16, 2019 - enhanced stopwords to include multiple languages


# define
use constant LOWERBOUNDS  => .01;
use constant NUMBEROFTAGS => 3;

my $directory = $ARGV[ 0 ];
if ( ! $directory ) { die "Usage $0 <directory>\n" }

# use/require
use strict;
use Lingua::StopWords qw( getStopWords );
require './lib/tfidf-toolbox.pl';

# initialize
my @corpus    = &corpus( $directory );
my $english   = &getStopWords( 'en' );
my $spanish   = &getStopWords( 'es' );
my $french    = &getStopWords( 'fr' );
my $stopwords = { %$english, %$spanish, %$french };

# index, sans stopwords
my %index = ();
foreach my $file ( @corpus ) { $index{ $file } = &index( $file, $stopwords ) }

# classify (tag) each document
my %terms = ();
foreach my $file ( @corpus ) {

	my $tags = &classify( \%index, $file, [ @corpus ] );
	my $found = 0;
		
	# list tags greater than a given score
	foreach my $tag ( sort { $$tags{ $b } <=> $$tags{ $a } } keys %$tags ) {
	
		if ( $$tags{ $tag } > LOWERBOUNDS ) {
		
			$file      =~ s/$directory\///e;
			my $system =  $file;
			$system    =~ s/\.txt//;
			print join( "\t", ( $system, $tag ) ), "\n";
			
			$terms{ $tag }++;
			
		}
		
		else { last }
	
	}
				
}

foreach ( sort { $terms{ $b } <=> $terms{ $a } } keys %terms ) {

	my $key   = $_;
	my $value = $terms{ $key };
	warn "$key\t$value\n";

}

# done; more fun!
exit;


