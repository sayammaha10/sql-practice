-- Spotify Data Analysis

-- Create table
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

SELECT * FROM spotify_tracks;

-- Exploratory Data Analysis (EDA)

-- Count the total number of records
SELECT COUNT(*) FROM spotify_tracks;

-- Count the number of unique artists
SELECT COUNT(DISTINCT artist) FROM spotify_tracks;

-- Count the number of unique albums
SELECT COUNT(DISTINCT album) FROM spotify_tracks;

-- Identify the different album types
SELECT DISTINCT album_type FROM spotify_tracks;

-- Find the maximum and minimum track duration
SELECT
	MAX(duration_min) AS max_duration,
	MIN(duration_min) AS min_duration
FROM spotify_tracks;

-- Remove records with zero track duration
DELETE FROM spotify_tracks
WHERE duration_min = 0;

-- Identify the different channels
SELECT DISTINCT channel FROM spotify_tracks;

-- Identify the platforms where tracks are most played
SELECT DISTINCT most_played_on FROM spotify_tracks;

-- Data analysis and key business questions

-- 1. Find tracks with more than 1 billion streams.
SELECT * FROM spotify_tracks
WHERE stream > 1000000000;

-- 2. List unique albums and their artists.
SELECT DISTINCT
	album,
	artist
FROM spotify_tracks;

-- 3. Calculate the total number of comments for licensed tracks.
SELECT
	SUM("comments") AS total_comments
FROM spotify_tracks
WHERE licensed = TRUE;

-- 4. Find all tracks that belong to the single album type.
SELECT * FROM spotify_tracks
WHERE album_type = 'single';

-- 5. Count the number of tracks for each artist.
SELECT
	artist,
	COUNT(track) AS track_count
FROM spotify_tracks
GROUP BY artist;

-- 6. Calculate the average danceability for each album.
SELECT
	album,
	AVG(danceability) AS avg_danceability
FROM spotify_tracks
GROUP BY album;

-- 7. Find the top 5 tracks with the highest energy values.
SELECT
	track,
	energy
FROM spotify_tracks
ORDER BY energy DESC
LIMIT 5;

-- 8. List tracks along with their views and likes for official videos.
SELECT
	track,
	"views",
	likes
FROM spotify_tracks
WHERE official_video = TRUE;

-- 9. Calculate the total views for each album.
SELECT
	album,
	SUM("views") AS total_views
FROM spotify_tracks
GROUP BY album;

-- 10. Find tracks with more Spotify streams than YouTube views.
SELECT
	track,
	stream,
	"views"
FROM spotify_tracks
WHERE stream > "views";

-- 11. Find the top 3 most-viewed tracks for each artist using a window function.
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

-- 12. Find tracks with a liveness score above the overall average.
SELECT
	track,
	liveness
FROM spotify_tracks
WHERE liveness > (
	SELECT AVG(liveness)
	FROM spotify_tracks
);

-- 13. Calculate the difference between the highest and lowest energy values for each album.
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

-- 14. Find tracks with an energy-to-liveness ratio greater than 1.2.
SELECT
	track,
	energy,
	liveness,
	energy / liveness AS energy_liveness_ratio
FROM spotify_tracks
WHERE liveness <> 0 AND energy / liveness > 1.2;

-- 15. Calculate the cumulative sum of likes ordered by track views using a window function.
SELECT
	track,
	"views",
	likes,
	SUM(likes) OVER (
		ORDER BY "views" DESC
	) AS cumulative_likes
FROM spotify_tracks;