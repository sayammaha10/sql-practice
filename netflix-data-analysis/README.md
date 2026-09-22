# Netflix Data Analysis using SQL

## Overview

This project analyzes Netflix movies and TV shows using SQL. The analysis focuses on content types, ratings, release years, countries, genres, directors, actors, and content classifications to answer a set of business questions.

## Objectives

- Analyze the distribution of movies and TV shows.
- Identify the most common ratings for different content types.
- Explore content by release year, country, genre, and duration.
- Analyze directors and actors associated with Netflix content.
- Categorize content based on official ratings.

## Dataset

The project uses a Netflix movies and TV shows dataset containing information about titles, content types, directors, cast members, countries, release years, ratings, durations, genres, and descriptions.

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the number of movies vs TV shows

```sql
SELECT
	"type",
	COUNT(show_id)
FROM netflix_titles
GROUP BY "type";
```

**Objective:** Determine the distribution of movies and TV shows.

### 2. Find the most common rating for movies and TV shows

```sql
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
```

**Objective:** Identify the most common rating for each content type.

### 3. List all movies released in a specific year

```sql
SELECT * FROM netflix_titles
WHERE "type" = 'Movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the top 5 countries with the most content on Netflix

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS individual_country,
	COUNT(show_id) AS content_count
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY individual_country
ORDER BY content_count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the longest movie

```sql
SELECT * FROM netflix_titles
WHERE
	"type" = 'Movie'
	AND duration IS NOT NULL
	AND duration LIKE '%min'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

**Objective:** Find the longest movie based on its duration.

### 6. Find content added in the last 5 years

```sql
SELECT * FROM netflix_titles
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix within the last 5 years.

### 7. Find all movies and TV shows by director 'Steven Spielberg'

```sql
SELECT * FROM netflix_titles
WHERE director ILIKE '%Steven Spielberg%';
```

**Objective:** List all movies and TV shows associated with director Steven Spielberg.

### 8. List all TV shows with more than 5 seasons

```sql
SELECT * FROM netflix_titles
WHERE "type" = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the number of content items in each genre

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS content_count
FROM netflix_titles
GROUP BY genre;
```

**Objective:** Count the number of content items in each genre.

### 10. Find the top 5 years with the highest total volume of content released in the United States

```sql
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
	COUNT(show_id) AS total_content
FROM netflix_titles
WHERE country ILIKE '%United States%' AND date_added IS NOT NULL
GROUP BY added_year
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 years with the highest number of content items associated with the United States.

### 11. List all movies that are documentaries

```sql
SELECT * FROM netflix_titles
WHERE "type" = 'Movie' AND listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve movies classified under the documentaries genre.

### 12. Find all content without a director

```sql
SELECT * FROM netflix_titles
WHERE director IS NULL;
```

**Objective:** Identify content records that do not have a director listed.

### 13. Find the total number of movies featuring actor 'Samuel L. Jackson' released in the last 10 years

```sql
SELECT * FROM netflix_titles
WHERE
	"type" = 'Movie'
	AND "cast" ILIKE '%Samuel L. Jackson%'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Identify movies featuring Samuel L. Jackson that were released within the last 10 years.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in the United States

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS individual_actor,
	COUNT(show_id) AS movie_count
FROM netflix_titles
WHERE "type" = 'Movie' AND country ILIKE '%United States%'
GROUP BY individual_actor
ORDER BY movie_count DESC
LIMIT 10;
```

**Objective:** Identify the 10 actors with the highest number of appearances in movies associated with the United States.

### 15. Categorize content based on official ratings

```sql
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
```

**Objective:** Categorize content into 'Mature Content' and 'General Audience' based on official ratings and count the items in each category.

## SQL Concepts Used

- Table creation
- Filtering with `WHERE`
- Aggregation with `COUNT`
- `GROUP BY` and `ORDER BY`
- Subqueries
- Window functions
- `RANK()`
- Date and time functions
- String functions
- `STRING_TO_ARRAY()`
- `UNNEST()`
- `TRIM()`
- `SPLIT_PART()`
- `ILIKE`
- `CASE` expressions
- Type casting

## Conclusion

This project provides hands-on practice with SQL using a Netflix movies and TV shows dataset. It covers the process of exploring structured data and using SQL to answer a range of business-focused questions.

The analysis focuses on content distribution, ratings, release years, countries, genres, movie durations, directors, actors, and content classification based on official ratings.

---

This project is part of my data analysis learning journey and demonstrates practical SQL skills through a Netflix data analysis project.