#!/usr/bin/env bash

# rank-persons.sh - calculate and output tfidf scores for person; a front-end to rank-persons.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) Universfity of Notre Dame

# March 31, 2019 - on a plane to Palo Alto


# configure
DB='./etc/pamphlets.db'
COUNT='SELECT COUNT( DISTINCT( system ) ) FROM persons;'
SYSTEMS='SELECT DISTINCT( system ) FROM persons ORDER BY system;'
RANKPERSONS='./bin/rank-persons.pl'

# get number of documents
D=$( echo $COUNT | sqlite3 $DB )

# process each document and done; calculate tfidf
echo $SYSTEMS | sqlite3 $DB | parallel $RANKPERSONS {} $D
exit
