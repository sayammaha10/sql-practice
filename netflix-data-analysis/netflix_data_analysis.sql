-- Netflix Data Analysis

-- Create table
CREATE TABLE netflix_titles (
	show_id VARCHAR(10),
	"type" VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	"cast" VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(20),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);

SELECT * FROM netflix_titles;

-- Data analysis and key business questions

-- 1. Count the number of movies vs TV shows
SELECT
	"type",
	COUNT(show_id)
FROM netflix_titles
GROUP BY "type";

-- 2. Find the most common rating for movies and TV shows
SELECT
	"type",
	rating
FROM (
	SELECT
		"type",
		rating,
		COUNT(show_id),
		RANK() OVER(PARTITION BY "type" ORDER BY COUNT(show_id) DESC) AS ranking
	FROM netflix_titles
	GROUP BY "type", rating
) AS rating_rank
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix_titles
WHERE "type" = 'Movie' AND release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS individual_country,
	COUNT(show_id) AS content_count
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY individual_country
ORDER BY content_count DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT * FROM netflix_titles
WHERE
	"type" = 'Movie'
	AND duration IS NOT NULL
	AND duration LIKE '%min'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;