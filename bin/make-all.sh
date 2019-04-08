#!/bin/bash

# make-all.sh - one script to rule them all; do all the work in one go

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June  30, 2017 - first cut
# March 15, 2019 - hacked on the way to Florence


# build database, and then generate indexes
./bin/make-db.sh
./bin/make-indexes.sh

# harvest PDF and transform into plain text
./bin/harvest-pdf.pl
find pdf -name '*.pdf' | parallel ./bin/file2txt.sh {}

# clean up
rm -rf ./tmp/*
rm -rf ./log/*

# voiula!
echo "Done"
