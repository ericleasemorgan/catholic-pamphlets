#!/usr/bin/env python

# txt2ent.py - given a plain text file, output sets of named entities

# Eric Lease Morgan <eric_morgan@infomotions.com>
# March 18, 2019 - first cut; based on morphadorn.py and hacked in Florence


# configure
MODEL = 'en'

# require
import spacy
import sys
import re
import os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]
nlp  = spacy.load( MODEL )

# create a key
key = os.path.splitext( os.path.basename( file ) )[0]

# read the given file and unwrap it
document = open( file ).read()  
document = re.sub( '\r', '\n', document )
document = re.sub( '\n+', ' ', document )
document = re.sub( '\t',  ' ', document )
document = re.sub( ' +',  ' ', document )
document = re.sub( '^\W+', '', document )

# create an nlp object from the input
document = nlp( document )

# process each sentence
for sentence in document.sents :

	# re-initialize; convert to an nlp document
	sentence = sentence.as_doc()
		
	# process each entity in the sentence
	for item in sentence.ents :
		
		# parse and output
		entity  = item.text
		type    = item.label_
		
		# output, conditionally
		if ( type == 'PERSON' ) : print( "\t".join( ( key, entity ) ) )
			
# done
exit()
