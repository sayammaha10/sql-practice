# Spotify Data Analysis using SQL

## Overview

This project analyzes Spotify track data using SQL. The analysis focuses on artists, albums, streams, views, likes, audio features, official videos, and listening platforms to answer a set of business questions.

## Objectives

- Explore the Spotify dataset and understand its structure.
- Analyze tracks, artists, albums, and album types.
- Compare Spotify streams with YouTube views.
- Analyze engagement metrics such as views, likes, and comments.
- Explore audio features such as danceability, energy, and liveness.
- Apply SQL techniques such as subqueries, CTEs, and window functions.

## Dataset

The project uses a Spotify tracks dataset containing information about artists, tracks, albums, album types, audio features, views, likes, comments, streams, licensing, official videos, and the platforms where tracks are most played.

## Schema

```sql
CREATE TABLE spotify_tracks (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    "views" FLOAT,
    likes BIGINT,
    "comments" BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```

## Business Problems and Solutions

### 1. Find tracks with more than 1 billion streams

```sql
SELECT *
FROM spotify_tracks
WHERE stream > 1000000000;
```

**Objective:** Identify tracks that have more than 1 billion streams.

### 2. List unique albums and their artists

```sql
SELECT DISTINCT
	album,
	artist
FROM spotify_tracks;
```

**Objective:** List the unique combinations of albums and their associated artists.

### 3. Calculate the total number of comments for licensed tracks

```sql
SELECT
	SUM("comments") AS total_comments
FROM spotify_tracks
WHERE licensed = TRUE;
```

**Objective:** Calculate the total comments received by tracks marked as licensed.

### 4. Find all tracks that belong to the single album type

```sql
SELECT *
FROM spotify_tracks
WHERE album_type = 'single';
```

**Objective:** Retrieve all tracks classified as singles.

### 5. Count the number of tracks for each artist

```sql
SELECT
	artist,
	COUNT(track) AS track_count
FROM spotify_tracks
GROUP BY artist;
```

**Objective:** Determine the number of tracks associated with each artist.

### 6. Calculate the average danceability for each album

```sql
SELECT
	album,
	AVG(danceability) AS avg_danceability
FROM spotify_tracks
GROUP BY album;
```

**Objective:** Calculate the average danceability score for tracks in each album.

### 7. Find the top 5 tracks with the highest energy values

```sql
SELECT
	track,
	energy
FROM spotify_tracks
ORDER BY energy DESC
LIMIT 5;
```

**Objective:** Identify the five tracks with the highest energy scores.

### 8. List tracks along with their views and likes for official videos

```sql
SELECT
	track,
	"views",
	likes
FROM spotify_tracks
WHERE official_video = TRUE;
```

**Objective:** Retrieve views and likes for tracks that have an official video.

### 9. Calculate the total views for each album

```sql
SELECT
	album,
	SUM("views") AS total_views
FROM spotify_tracks
GROUP BY album;
```

**Objective:** Calculate the total number of views across tracks in each album.

### 10. Find tracks with more Spotify streams than YouTube views

```sql
SELECT
	track,
	stream,
	"views"
FROM spotify_tracks
WHERE stream > "views";
```

**Objective:** Identify tracks where the number of Spotify streams is higher than the number of YouTube views.

### 11. Find the top 3 most-viewed tracks for each artist using a window function

```sql
SELECT
	artist,
	track,
	"views"
FROM (
	SELECT
		artist,
		track,
		"views",
		DENSE_RANK() OVER (
			PARTITION BY artist
			ORDER BY "views" DESC
		) AS "rank"
	FROM spotify_tracks
) AS ranked_tracks
WHERE "rank" <= 3;
```

**Objective:** Identify the three most-viewed tracks for each artist using a window function.

### 12. Find tracks with a liveness score above the overall average

```sql
SELECT
	track,
	liveness
FROM spotify_tracks
WHERE liveness > (
	SELECT AVG(liveness)
	FROM spotify_tracks
);
```

**Objective:** Identify tracks with a liveness score higher than the overall average.

### 13. Calculate the difference between the highest and lowest energy values for each album

```sql
WITH album_energy AS (
	SELECT
		album,
		MAX(energy) AS max_energy,
		MIN(energy) AS min_energy
	FROM spotify_tracks
	GROUP BY album
)
SELECT
	album,
	max_energy,
	min_energy,
	max_energy - min_energy AS energy_difference
FROM album_energy;
```

**Objective:** Calculate the difference between the highest and lowest energy scores for each album using a CTE.

### 14. Find tracks with an energy-to-liveness ratio greater than 1.2

```sql
SELECT
	track,
	energy,
	liveness,
	energy / liveness AS energy_liveness_ratio
FROM spotify_tracks
WHERE liveness <> 0
	AND energy / liveness > 1.2;
```

**Objective:** Identify tracks with an energy-to-liveness ratio greater than 1.2.

### 15. Calculate the cumulative sum of likes ordered by track views

```sql
SELECT
	track,
	"views",
	likes,
	SUM(likes) OVER (
		ORDER BY "views" DESC
	) AS cumulative_likes
FROM spotify_tracks;
```

**Objective:** Calculate the cumulative number of likes while ordering tracks by their views.

## SQL Concepts Used

- Table creation
- Data exploration
- Filtering with `WHERE`
- `DISTINCT`
- Aggregation with `COUNT`, `SUM`, `AVG`, `MAX`, and `MIN`
- `GROUP BY` and `ORDER BY`
- `LIMIT`
- Subqueries
- Common Table Expressions (CTEs)
- Window functions
- `DENSE_RANK()`
- Boolean filtering
- Arithmetic expressions
- Conditional filtering
- Cumulative calculations

## Conclusion

This project provides hands-on practice with SQL using a Spotify tracks dataset. It covers the process of exploring structured data and using SQL to answer a range of business-focused questions.

The analysis focuses on tracks, artists, albums, streams, views, likes, comments, audio features, official videos, and listening platforms while applying different SQL techniques for data analysis.

---

This project is part of my data analysis learning journey and demonstrates practical SQL skills through a Spotify data analysis project.