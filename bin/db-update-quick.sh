#!/bin/bash

# db-update.sh - given another set of pre-created SQL files, update a database

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, and distributed under a GNU Public License

# April 2, 2019 - first cut; on a plane from Palo Alto and back from Florence


./bin/marc2sql.pl ./etc/pamphlets.mrc
./bin/db-initialize.sh
./bin/clean-cities.pl > ./sql/cities.sql
./bin/clean-publishers.pl > ./sql/publishers.sql
./bin/date2year.pl > ./sql/years.sql
./bin/tags2sql.pl ./tsv/tags.tsv > ./sql/tags.sql
./bin/clean-persons.pl ./tsv/persons.tsv > ./tsv/persons-clean.tsv
./bin/persons2sql.pl ./tsv/persons-clean.tsv  > ./sql/persons.sql
./bin/db-update.sh
./bin/db-update-again.sh
./bin/db-update-final.sh