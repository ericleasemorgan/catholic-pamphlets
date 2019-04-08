#!/usr/bin/env bash

# file2txt.sh - convert a given file to plain text; a front-end to file2txt.py
# usage: find pdf -name '*.pdf' | parallel ./bin/file2txt.sh {} 

# Eric Lease Morgan <emorgan@nd.edu>
# January 8, 2019 - first cut, more or less


# configure
FILE2TXT='./bin/file2txt.py'
OUTPUT='./txt'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# compute output
LEAF=$( basename "$FILE" )
LEAF=${LEAF%.*}
OUTPUT="$OUTPUT/$LEAF.txt"

# do the work and done
echo "$FILE2TXT $FILE > $OUTPUT" >&2
if [[ ! -f $OUTPUT ]]; then $FILE2TXT $FILE > $OUTPUT; fi
exit