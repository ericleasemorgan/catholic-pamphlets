
# Catholic pamphlets - A Framework for MARC-based catalogs &amp; indexes

Given a set of MARC records, this system will create an "enhanced" set of catalogs &amp; indexes.

This system is specifically designed for a set of MARC records describing Catholic pamphlets cataloged at the University of Notre Dame, but this system could be used as a framework for other sets of MARC records with URL's in 856 fields pointing to full text items. Here are some of the features &amp; functions of the "enhanced" set of indexes and online catalog:

   * saves rudimentary MARC bibliographic data to an SQLite database
   
   * caches the PDF files linked in each record's 856 field, and these items are intended for printing and reading
   
   * converts the PDF files to plain text, and in turn, the plain text is used to enhance the metadata description including statistically significant personal name entities and keywords, readability scores, and summaries of each item
   
   * saves the enhanced metadata to the database
   
   * reads the content of the database, combines it with the plain text, and indexes the whole using Solr
   
   * supports both a command-line and Web-based interfaces to the Solr index complete with Boolean logic, full text indexing, and faceted browse

   * outputs a title catalog and associated indexes (i.e. author, subject, publisher, and date), and these items are intended for printing as in an old fashioned but extremely functional catalog

Ultimately, this system is intended to demonstrate what can be with MARC data pointing to full text. 

This system runs from the command-line of Linux and Macintosh computers. It employs a number of computer technologies, including: bash, Perl, Python, SQLite, Tika, and Solr. It also implements a number of computing techniques to make processing faster, efficient, and "intelligent". These include: parallel processing when possible, relational database design, named-entity extraction, the Levenshtein algorithm for normalizing "dirty data", and term-frequency/inverse document frequency (TFIDF) to derive statistically significant named-entities &amp; keywords.

Here is an outline of how to get the system to work for you, but your mileage will because of the copyrighted nature of the linked PDF files:

   1. `git clone https://github.com/ericleasemorgan/catholic-pamphlets.git` - copy the repository to your file system
   
   2. `cd ./catholic-pamphlets` - change to the working directory
   
   3. `./bin/marc2sql.pl ./etc/pamphlets.mrc` - extract various bits of bibliographic information from the MARC data and cache the result as a set of SQL statements
   
   4. `./bin/db-initialize.sh` - create a rudimentary SQLite database from the cached SQL as per ./etc/schema.sql
   
   5. `./bin/clean-cities.pl > ./sql/cities.sql` - normalize the place values to cities, and cache the result as SQL
   
   6. `./bin/clean-publishers.pl > ./sql/publishers.sql` - normalize publisher values, and cache the result as SQL
   
   7. `./bin/date2year.pl > ./sql/years.sql` - normalize the date values to years, and cache the result as SQL
   
   8. `./bin/harvest-pdf.pl` - cache the PDF files linked from the MARC records
   
   9. `find pdf -name '*.pdf' | parallel ./bin/file2txt.sh {}` - find all the cached PDF files, and use Tika to convert them to plain text
   
   10. `./bin/tag.pl ./txt > ./tsv/tags.tsv` - employ TFIDF to generate zero or more keywords for each plain file and cache the result to a TSV file which the reader may want to normalize; this process is time-intensive
   
   11. `./bin/tags2sql.pl ./tsv/tags.tsv > ./sql/tags.sql` - convert the list of keywords into a set of SQL statements
   
   12. `find txt -name "*.txt" | parallel ./bin/txt2scores.py {} > ./sql/scores.sql &` - find all the plain text files, measure various features of each, and cache the result as a set of SQL statements; this process is time-intensive
   
   13. `./bin/txt2ent.sh > ./tsv/persons.tsv` - extract personal names from each plain text file and cache the result for later processing
   
   14. `./bin/clean-persons.pl ./tsv/persons.tsv > ./tsv/persons-clean.tsv` - use brute force to clean/normalize the person names
   
   15. `./bin/persons2sql.pl ./tsv/persons-clean.tsv  > ./sql/persons.sql` - convert the TSV representation of the person names into SQL
   
   16. `./bin/db-update.sh` - update the database with the good work done so far
   
   17. `./bin/cluster-persons.pl > ./sql/persons-update.sql` - use the Levenshtein algorithm to normalize person names some more, and output the result to a set of SQL
   
   18. `./bin/db-update-again.sh` - commit the results of the previous step to the database
   
   19. `./bin/rank-persons.sh > ./sql/persons-ranks.sql` - apply TFIDF to the normalized list of persons in order to justify their significance
   
   20. `./bin/db-update-final.sh` - finished with all of our processing; do the last commit to the database
   
   21. `./bin/make-indexes.sh` - loop through the database and output a catalog &amp; indexes intended for printing
   
   22. `./bin/index.pl` - loop through the database and electronically index the content with Solr according to ./etc/schema.xml
   
   23. `./bin/search.pl` - query the electronic index complete with faceted browse &amp; Boolean logic
   
   
---
Eric Lease Morgan &lt;emorgan@nd.edu&gt;   
April 10, 2019
