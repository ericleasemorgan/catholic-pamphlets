#!/bin/bash

# db-initialize.sh - given a set of pre-created SQL files, create a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# June    30, 2017 - first cut
# October 20, 2017 - added normalized data
# March   15, 2019 - hacked on the way to Florence
# April    2, 2019 - made simpler


# configure
DB='./etc/pamphlets.db'
SQL='./sql/initialize.sql'
BIBLIOGRAPHICS='./sql/bibliographics.sql'
SUBJECTS='./sql/subjects.sql'
URLS='./sql/urls.sql'
SCHEMA='./sql/schema.sql'

# build sql
cat './etc/schema.sql'     > $SQL
echo 'BEGIN TRANSACTION;' >> $SQL
cat $BIBLIOGRAPHICS       >> $SQL
cat $SUBJECTS             >> $SQL
cat $URLS                 >> $SQL
echo 'END TRANSACTION;'   >> $SQL

# build database
rm -rf $DB
cat $SQL | sqlite3 $DB

# sort titles; could be speeded up with a transaction 
./bin/sort-titles.pl

# update with normalized data; could be speeded up with a transaction 
#./bin/update-cities.pl
#./bin/update-years.pl

# done
exit
