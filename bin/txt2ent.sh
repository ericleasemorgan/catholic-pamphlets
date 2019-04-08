#!/usr/bin/env bash

# txt2ent.sh - given a set of plain text file, output named entities; a front-end to txt2ent.py

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 28, 2019 - first documentation; in Florence


# set up multi-threading environment
OMP_NUM_THREADS=1
OPENBLAS_NUM_THREADS=1
MKL_NUM_THREADS=1
export OMP_NUM_THREADS
export OPENBLAS_NUM_THREADS
export MKL_NUM_THREADS

# find all the necessary files, do the work, and done
find txt -name '*.txt' | parallel ./bin/txt2ent.py {}
exit
