#!/bin/bash

# db-update-final.sh - given yet another set of pre-created SQL files, update a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# April 5, 2019 - first cut


# configure
DB='./etc/pamphlets.db'
SQL='./sql/update-final.sql'
PERSONS='./sql/persons-ranks.sql'

# build sql
echo 'BEGIN TRANSACTION;'  > $SQL
cat $PERSONS              >> $SQL
echo 'END TRANSACTION;'   >> $SQL

# update database and done
cat $SQL | sqlite3 $DB
exit
