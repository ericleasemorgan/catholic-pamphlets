#!/usr/bin/env python

# txt2scores.sh - given a file, output some textual measures in the form of an SQL statement
# usage: find txt -name '*.txt' | parallel ./bin/txt2scores.py {} > ./sql/scores.sql

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut
# April 2, 2019 - on a plane from Palo Alto and afer Florence; yikes!
# April 5, 2019 - moved output to the titles table


# configure
COUNT=50
RATIO=0.05

# require
from textatistic import Textatistic
from gensim.summarization import summarize
import sys, re, os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# read input
file = sys.argv[ 1 ]

# compute the identifier
id = os.path.basename( os.path.splitext( file )[ 0 ] )

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# get all document statistics and summary
statistics = Textatistic( text )
summary = summarize( text, word_count=COUNT, split=False )
summary = re.sub( '\n+', ' ', summary )
summary = re.sub( '- ', '', summary )
summary = re.sub( '\s+', ' ', summary )
summary = re.sub( "'", "''", summary )

# parse out only the desired statistics
words     = statistics.word_count
flesch    = int( statistics.flesch_score )

# output SQL and done
print("UPDATE titles SET words = '%s', summary = '%s', flesch = '%s' where system = '%s';" % ( str( words ), summary, str( flesch ), str( id ) ) )
exit
