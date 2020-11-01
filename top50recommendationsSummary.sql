####code for recommendation system

#### create directory to work in named RSL

mkdir RSL

## go into the RSL directory to work in it

cd RSL 

## start interacting with database in postgres

psql test

## create a new table in the database

CREATE TABLE movies (
url text,
title text,
ReleaseDate text,
Distributor text,
Starring text, 
Summary text,
Director text,
Genre text, 
Rating text,
Runtime text,
Userscore text, 
Metascore text,
scoreCounts text
);


## Copy a dataset into the previously made table

\copy movies FROM '/home/pi/RSL/moviesFromMetacritic.csv' 
delimiter ';' csv header;

## if you want to see your favorite movie select it from the dataset, 
## not necessary for the process

SELECT * FROM movies where url='2-fast-2-furious'

## to find similar movies on the basis of summary/titles/starring use 'lexemes'. 
## lexemes finds similar words (lexeme)
## first add a column with a vector lexemes 

ALTER TABLE movies
ADD lexemesSummary tsvector;

## update the dataset with Summary as vector from lexemesSummary

UPDATE movies
SET lexemesSummary = to_tsvector(Summary)

## On the basis of words in the url of your favorite movie, we can get related movies

SELECT url FROm movies
WHERE lexemesSummary @@ to_tsquery('fast+furious')

## add a column rank float4 is to be done only once 
## this is to finish the recommendation system

ALTER TABLE movies
ADD rank float4;

## update the dataset again to include the vector

UPDATE movies
SET rank = ts_rank(lexemesSummary,plainto_tsquery((
SELECT Summary FROM movies WHERE url='2-fast-2-furious')));

## create new table with the recommendations based on the summary field
## with the words in the url to find different movies
## the rank is how much % the findings match with your favourite movie
## Descending from high (biggest match) to low with max 50 movies
## chose 0.01 1% for enough results

CREATE TABLE recommendationsBasedOnSummaryField AS SELECT url,
rank FROM movies WHERE rank > 0.01 ORDER BY rank DESC LIMIT 50;


## create .csv in the RSL directory with the table created from recommendations

\copy (SELECT * FROM recommendationsBasedOnSummaryField) to
'/home/pi/RSL/top50recommendationsSummary.csv' WITH csv 




