#!/usr/bin/perl

# update-marc.pl - hack a set of MARC records to "correct" their urls

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 15, 209 - in Chicago and on my way to Florence (Italy); stupid dirty data


# require
use strict;
use MARC::Batch;

# get input and do sanity check
my $marc = $ARGV[ 0 ];
if ( ! $marc ) { die "Usage: $0 <marcfile>\n" }

# initialize
my $batch = MARC::Batch->new( 'USMARC', $marc );

# turn off warnings because we have dirty data
$batch->strict_off;
$batch->warnings_off;

# process each item in the batch
while ( my $record = $batch->next ) { 
	
	# re-initialize
	my $found = 0;
	
	# process each 856 field
	foreach my $_856 ( $record->field( '856' ) ) {
	
		# check for value to update
		if ( $_856->subfield( 'u' ) =~ /repository/ ) {
		
			# get the sytem number
			my $system = $record->field( '001' )->as_string;
			
			# update, output, and flag
			$_856->update( u => "http://dh.crc.nd.edu/sandbox/pamphlets-repository/$system.pdf" );
			print $record->as_usmarc;
			$found = 1
			
		} 
		
		# be efficient
		last if ($found );
	}

}

# done
exit;


