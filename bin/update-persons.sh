#!/bin/bash

# update-persons.sh - given a set of update statements, ... update the database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# March 30, 2019 - hacked on the way back from Florence


# configure
DB='./etc/pamphlets.db'
UPDATES='./etc/update-persons.sql'
SQL='./tmp/updates.sql';

# build sql
echo 'BEGIN TRANSACTION;'  > $SQL
cat $UPDATES              >> $SQL
echo 'END TRANSACTION;'   >> $SQL

cat $SQL | sqlite3 $DB
exit
