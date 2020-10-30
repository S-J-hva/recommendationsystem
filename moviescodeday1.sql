pi@raspberrypi:~ $ psql test
psql (11.7 (Raspbian 11.7-0+deb10u1))
Type "help" for help.

test=> \dt+
                        List of relations
 Schema |   Name   | Type  |  Owner   |    Size    | Description 
--------+----------+-------+----------+------------+-------------
 public | movies   | table | pi       | 8192 bytes | 
 public | movies10 | table | pi       | 4824 kB    | 
 public | movies2  | table | pi       | 8192 bytes | 
 public | movies3  | table | postgres | 8192 bytes | 
 public | movies4  | table | postgres | 4824 kB    | 
 public | mytable  | table | pi       | 8192 bytes | 
(6 rows)

test=> ALTER TABLE movies10 ADD lexemesSummary tsvector;
ALTER TABLE
test=> UPDATE movies10 SET lexemesSummary = to_tsvector(Summary);
UPDATE 5229
test=> SELECT url FROM movies10 WHERE lexemesSummary @@ to_tsquery('pirate');
                          url                          
-------------------------------------------------------
 pan
 the-pirates!-band-of-misfits
 pirates-of-the-caribbean-the-curse-of-the-black-pearl
 the-pirates-who-dont-do-anything-a-veggietales-movie
 pirates-of-the-caribbean-dead-men-tell-no-tales
 the-princess-bride
(6 rows)

test=> ALTER TABLE movies ADD rank float4; 
ALTER TABLE
test=> UPDATE movies10 SET rank = ts_rank(tsvectorSummary,plainto_tsquery((SELECT Summary FROM movies WHERE url=' pirates-of-the-caribbean-the-curse-of-the-black-pearl')));
ERROR:  column "tsvectorsummary" does not exist
LINE 1: UPDATE movies10 SET rank = ts_rank(tsvectorSummary,plainto_t...
                                           ^
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies WHERE url=' pirates-of-the-caribbean-the-curse-of-the-black-pearl')));
ERROR:  column "rank" of relation "movies10" does not exist
LINE 1: UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_ts...
                            ^
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies10 WHERE url=' pirates-of-the-caribbean-the-curse-of-the-black-pearl')));
ERROR:  column "rank" of relation "movies10" does not exist
LINE 1: UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_ts...
                            ^
test=> ALTER TABLE movies10 ADD rank float4;
ALTER TABLE
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies10 WHERE url=' pirates-of-the-caribbean-the-curse-of-the-black-pearl')));
UPDATE 5229
test=> CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url, rank, FROM movies10 WHERE rank >0.7 ORDER BY rank DESC LIMIT 50;
ERROR:  syntax error at or near "FROM"
LINE 1: ...endationsBasedOnSummaryField AS SELECT url, rank, FROM movie...
                                                             ^
test=> CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url, rank FROM movies10 WHERE rank >0.7 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> \dt+
                                     List of relations
 Schema |                Name                | Type  |  Owner   |    Size    | Description 
--------+------------------------------------+-------+----------+------------+-------------
 public | movies                             | table | pi       | 8192 bytes | 
 public | movies10                           | table | pi       | 16 MB      | 
 public | movies2                            | table | pi       | 8192 bytes | 
 public | movies3                            | table | postgres | 8192 bytes | 
 public | movies4                            | table | postgres | 4824 kB    | 
 public | mytable                            | table | pi       | 8192 bytes | 
 public | recommendationsbasedonsummaryfield | table | pi       | 8192 bytes | 
(7 rows)

test=> \copy (SELECT * FROM recommendationsBasedOnSummaryField) to '/home/pi/RSL/top50recommendations.csv' WITH csv;
COPY 0
test=> CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url, rank FROM movies10 WHERE rank >0.7 ORDER BY rank DESC LIMIT 50;
ERROR:  relation "recommendationsbasedonsummaryfield" already exists
test=> CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url, rank FROM movies10 WHERE rank >0.7 ORDER BY rank DESC LIMIT 50;
ERROR:  relation "recommendationsbasedonsummaryfield" already exists
test=> CREATE TABLE recommendationsBasedOnSummaryField2 AS SELECT url, rank FROM movies10 WHERE rank >0.5 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> CREATE TABLE recommendationsBasedOnSummaryField3 AS SELECT url, rank FROM movies10 WHERE rank >0.99 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> CREATE TABLE recommendationsBasedOnSummaryField4 AS SELECT url, rank FROM movies10 WHERE rank >0.1 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> 
test=> CREATE TABLE recommendationsBasedOnSummaryField5 AS SELECT url, rank FROM movies10 WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url, rank FROM movies10 WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;
ERROR:  relation "recommendationsbasedonsummaryfield" already exists
test=> insert into recommendationsBasedOnSummaryField select url, rank from movies10 where rank > 0.01 order by rank desc limit 50;
INSERT 0 0
test=> ALTER TABLE movies10 ADD lexemesSummary tsvector;
ERROR:  column "lexemessummary" of relation "movies10" already exists
test=> UPDATE movies10 SET lexemesSummary = to_tsvector(Summary)
test-> UPDATE movies10 SET lexemesSummary = to_tsvecotr(Summary);
ERROR:  syntax error at or near "UPDATE"
LINE 2: UPDATE movies10 SET lexemesSummary = to_tsvecotr(Summary);
        ^
test=> UPDATE movies10 SET lexemesSummary = to_tsvector(Summary);
UPDATE 5229
test=> SELECT * FROM movies10 where url='pirates-of-the-caribbean-the-curse-of-the-black-pearl';
test=> SELECT url FROM movies10 WHERE lexemesSummary @@ to_tsquery('pirate');
                          url                          
-------------------------------------------------------
 pirates-of-the-caribbean-dead-men-tell-no-tales
 the-princess-bride
 pan
 the-pirates!-band-of-misfits
 pirates-of-the-caribbean-the-curse-of-the-black-pearl
 the-pirates-who-dont-do-anything-a-veggietales-movie
(6 rows)

test=> ALTER TABLE movies10 ADD rank float4;
ERROR:  column "rank" of relation "movies10" already exists
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies10 WHERE url='pirates-of-the-caribbean-the-curse-of-the-black-pearl')));
UPDATE 5229
test=> CREATE TABLE recommendationsBasedOnSummaryField10 AS SELECT url, rank FROM movies10 WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;
SELECT 50
test=> \copy (SELECT * FROM recommendationsBasedOnSummaryField10) to '/home/pi/RSL/top50recommendations2.csv' WITH csv;
COPY 50
test=> CREATE TABLE recommendationsBasedOnSummaryField11 AS SELECT url, rank FROM movies10 WHERE rank > 0.7 ORDER BY rank DESC LIMIT 50;
SELECT 50
test=> \copy (SELECT * FROM recommendationsBasedOnSummaryField11) to '/home/pi/RSL/top50recommendations3.csv' WITH csv;
COPY 50
test=> ALTER TABLE movies10 ADD lexemestitle tsvector;
ALTER TABLE
test=> UPDATE movies10 SET lexemestitle = to_tsvector(title);
UPDATE 5229
test=> SELECT url FROM movies10 WHERE lexemestitle @@ to_tsquery('pirate');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemestitle @@ to_tsquery('Pirate');
 url 
-----
(0 rows)

test=> SELECT url FROM movies WHERE lexemesSummary @@ to_tsquery('furious');
ERROR:  column "lexemessummary" does not exist
LINE 1: SELECT url FROM movies WHERE lexemesSummary @@ to_tsquery('f...
                                     ^
test=> SELECT url FROM movies10 WHERE lexemessummary @@ to_tsquery('furious');
              url               
--------------------------------
 2-fast-2-furious
 butter
 fear-and-loathing-in-las-vegas
 kung-fu-panda-2
 machete-kills
 revenge-of-the-electric-car
 running-scared
 witless-protection
(8 rows)

test=> SELECT url FROM movies10 WHERE lexemessummary @@ to_tsquery('fast');
test=> SELECT url FROM movies10 WHERE lexemessummary @@ to_tsquery('fast furious');
ERROR:  syntax error in tsquery: "fast furious"
test=> SELECT url FROM movies10 WHERE lexemessummary @@ to_tsquery('fastfurious');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemessummary @@ to_tsquery('fast+furious');
              url               
--------------------------------
 2-fast-2-furious
 fear-and-loathing-in-las-vegas
 machete-kills
 revenge-of-the-electric-car
 running-scared
(5 rows)

test=> ALTER TABLE movies10 ADD rank float4;
ERROR:  column "rank" of relation "movies10" already exists
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies10 WHERE url=' 2-fast-2-furious')));
UPDATE 5229
test=> CREATE TABLE recommendationsbasedonsummaryfield12 AS SELECT url, rank FROM movies10 WHERE rank > 0.7 ORDER BY rank DESC LIMIT 50; 
SELECT 0
test=> UPDATE movies10 SET rank = ts_rank(lexemesSummary,plainto_tsquery((SELECT Summary FROM movies10 WHERE url='2-fast-2-furious')));
UPDATE 5229
test=> CREATE TABLE recommendationsbasedonsummaryfield13 AS SELECT url, rank FROM movies10 WHERE rank > 0.7 ORDER BY rank DESC LIMIT 50; 
SELECT 50
test=> \copy (SELECT * FROM recommendationsbasedonsummaryfield13) to '/home/pi/RSL/top50recommendations5.csv' WITH csv;
COPY 50
test=> SELECT url FROM movies10 WHERE lexemestitle @@ to_tsquery('fast+furious');
                 url                  
--------------------------------------
 fast-furious-6
 the-fast-and-the-furious
 the-fast-and-the-furious-tokyo-drift
 fast-furious
 2-fast-2-furious
(5 rows)

test=> UPDATE movies10 SET rank = ts_rank(lexemestitle,plainto_tsquery((SELECT title FROM movies WHERE url='2-fast-2-furious')));
UPDATE 5229
test=> \du
                                   List of roles
 Role name |                         Attributes                         | Member of 
-----------+------------------------------------------------------------+-----------
 pi        | Create role, Create DB                                     | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

test=> CREATE TABLE recommendationsBasedOnTitleField AS SELECT url, rank FROM movies10 WHERE rank > 0.7 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> UPDATE movies10 SET rank = ts_rank(lexemestitle,plainto_tsquery((SELECT title FROM movies10 WHERE url='2-fast-2-furious')));
UPDATE 5229
test=> CREATE TABLE recommendationsBasedOnTitleField2 AS SELECT url, rank FROM movies10 WHERE rank > 0.7 ORDER BY rank DESC LIMIT 50;
SELECT 0
test=> CREATE TABLE recommendationsbasedontitlefield3 AS SELECT url, rank FROM movies10 WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;
SELECT 5
test=> \copy (SELECT * FROM recommendationsbasedontitlefield3) to '/home/pi/RSL/top50recommendationstitle.csv; WITH csv;
COPY 5
test=> ALTER TABLE movies10 ADD lexemesStarring tsvector;
ALTER TABLE
test=> UPDATE movies10 SET lexemesStarring = to_tsvector(Starring);
UPDATE 5229
test=> SELECT url FROM movies10 WHERE lexemesStarring @@ to_tsquery('fast+furious');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemesStarring @@ to_tsquery('furious');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemesStarring @@ to_tsquery('fast');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemesStarring @@ to_tsquery('2-fast-2-furious');
 url 
-----
(0 rows)

test=> SELECT url FROM movies10 WHERE lexemesStarring @@ to_tsquery('diesel');
              url              
-------------------------------
 furious-7
 the-fast-and-the-furious
 fast-furious
 fast-five
 find-me-guilty
 babylon-ad
 the-fate-of-the-furious
 fast-furious-6
 the-pacifier
 the-last-witch-hunter
 a-man-apart
 guardians-of-the-galaxy-vol-2
 pitch-black
 riddick
 guardians-of-the-galaxy
 xxx
(16 rows)

test=> UPDATE movies10 SET rank = ts_rank(lexemesStarring,plainto_tsquery((SELECT Starring FROM movies10 WHERE url='2-fast-2-furious')));
UPDATE 5229
test=> CREATE TABLE recommendationsbasedonstarring AS SELECT url, rank FROM movies10 WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;
SELECT 18
test=> \copy (SELECT * FROM recommendationsbasedonstarring) to '/home/pi/RSL/top50recommendationsstarring.csv' WITH csv;
COPY 18
test=> 
