#!/bin/bash

# db-update.sh - given another set of pre-created SQL files, update a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# April 2, 2019 - first cut; on a plane from Palo Alto and back from Florence


# configure
DB='./etc/pamphlets.db'
SQL='./sql/update.sql'
CITIES='./sql/cities.sql'
PERSONS='./sql/persons.sql'
PUBLISHERS='./sql/publishers.sql'
SCORES='./sql/scores.sql'
TAGS='./sql/tags.sql'
YEARS='./sql/years.sql'

# build sql
echo 'BEGIN TRANSACTION;'  > $SQL
cat $CITIES               >> $SQL
cat $PERSONS              >> $SQL
cat $PUBLISHERS           >> $SQL
cat $SCORES               >> $SQL
cat $TAGS                 >> $SQL
cat $YEARS                >> $SQL
echo 'END TRANSACTION;'   >> $SQL

# update database and done
cat $SQL | sqlite3 $DB
exit
