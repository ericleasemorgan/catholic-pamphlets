#!/bin/bash

# make-db.sh - given a set of MARC records, build a rudimentary database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June    30, 2017 - first cut
# October 20, 2017 - added normalized data
# March   15, 2019 - hacked on the way to Florence


# configure
DB='./etc/pamphlets.db'
#MARC='./etc/pamphlets.mrc'
#TAGS='./etc/tags.tsv'
#MARC2SQL='./bin/marc2sql.pl'
#TAGS2SQL='./bin/tags2sql.pl'
#PERSONS2SQL='./bin/persons2sql.pl'
#PERSONS='./etc/persons-clean.tsv'
SQL='./sql/pamphlets.sql'

# extract sql
#$MARC2SQL $MARC
#$TAGS2SQL $TAGS > './tmp/tags.sql'
#$PERSONS2SQL $PERSONS > './tmp/persons.sql'

# build sql
cat './etc/schema.sql'          > $SQL
echo 'BEGIN TRANSACTION;'      >> $SQL
cat './tmp/bibliographics.sql' >> $SQL
cat './tmp/subjects.sql'       >> $SQL
cat './tmp/urls.sql'           >> $SQL
#cat './tmp/tags.sql'           >> $SQL
#cat './tmp/persons.sql'        >> $SQL
echo 'END TRANSACTION;'        >> $SQL

# build database
rm -rf $DB
cat $SQL | sqlite3 $DB

# sort titles; could be speeded up with a transaction 
./bin/sort-titles.pl

# update with normalized data; could be speeded up with a transaction 
#./bin/update-cities.pl
#./bin/update-years.pl

# ta-da!
echo "Done."
