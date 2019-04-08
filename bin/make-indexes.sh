#!/bin/bash

# make-indexes.sh - a brain-dead front-end to the index-building scripts

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June  30, 2017 - first cut
# March 15, 2019 - hacked on the way to Florence

# do the work
echo "Making title index"
./bin/make-title-index.pl     > ./indexes/titles.txt

echo "Making author index"
./bin/make-author-index.pl    > ./indexes/authors.txt

echo "Making subject index"
./bin/make-subject-index.pl   > ./indexes/subjects.txt

echo "Making publisher index"
./bin/make-publisher-index.pl > ./indexes/publishers.txt

echo "Making date index"
./bin/make-date-index.pl      > ./indexes/dates.txt
