
-- schema.sql - a rudimentary bibliographic database schema

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame, and distributed under a GNU Public License

-- June    30, 2017 - first cut
-- October 19, 2017 - added url
-- March   15, 2019   - removed urls to there own table; removed items table


CREATE TABLE titles (
  author     TEXT,
  city       TEXT,
  date       TEXT,
  extent     TEXT,
  flesch     INT,
  notes      TEXT,
  oclc       TEXT,
  pages      TEXT,
  place      TEXT,
  publisher  TEXT,
  sentences  INT,
  statement  TEXT,
  summary    TEXT,
  system     TEXT PRIMARY KEY,
  title      TEXT,
  title_sort TEXT,
  words      INT,
  year       INT
);


CREATE TABLE tags (
  tag     TEXT,
  system  TEXT
);


CREATE TABLE persons (
  rank    FLOAT,
  person  TEXT,
  system  TEXT
);


CREATE INDEX persons_idx ON persons ( person, system );


CREATE TABLE subjects (
  subject TEXT,
  system  TEXT
);


CREATE TABLE urls (
  type   TEXT,
  system TEXT,
  url    TEXT
);