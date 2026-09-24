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

-- Data analysis - Easy

-- 1. Retrieve the names of all tracks with more than 1 billion streams.
SELECT * FROM spotify_tracks
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.
SELECT DISTINCT
	album,
	artist
FROM spotify_tracks;