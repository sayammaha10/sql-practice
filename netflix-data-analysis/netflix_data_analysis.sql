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

-- 6. Find content added in the last 5 years
SELECT * FROM netflix_titles
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all movies and TV shows by director 'Steven Spielberg'
SELECT * FROM netflix_titles
WHERE director ILIKE '%Steven Spielberg%';

-- 8. List all TV shows with more than 5 seasons
SELECT * FROM netflix_titles
WHERE "type" = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS content_count
FROM netflix_titles
GROUP BY genre;

-- 10. Find the top 5 years with the highest total volume of content released in the United States
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
	COUNT(show_id) AS total_content
FROM netflix_titles
WHERE country ILIKE '%United States%' AND date_added IS NOT NULL
GROUP BY added_year
ORDER BY total_content DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT * FROM netflix_titles
WHERE "type" = 'Movie' AND listed_in ILIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix_titles
WHERE director IS NULL;

-- 13. Find the total number of movies featuring actor 'Samuel L. Jackson' released in the last 10 years
SELECT * FROM netflix_titles
WHERE
	"type" = 'Movie'
	AND "cast" ILIKE '%Samuel L. Jackson%'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in the United States
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS individual_actor,
	COUNT(show_id) AS movie_count
FROM netflix_titles
WHERE "type" = 'Movie' AND country ILIKE '%United States%'
GROUP BY individual_actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize content into 'Mature Content' or 'General Audience' based on official ratings and count the total number of items in each category
SELECT
	CASE
		WHEN rating IN ('R', 'TV-MA', 'NC-17') THEN 'Mature Content'
		ELSE 'General Audience'
	END AS content_category,
	COUNT(show_id) AS content_count
FROM netflix_titles
WHERE
	rating NOT LIKE '%min%'
	AND rating NOT IN ('NR', 'UR')
	AND rating IS NOT NULL
GROUP BY content_category;