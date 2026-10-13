-- User Performance Analysis

-- Create table
CREATE TABLE user_submissions (
    "id" SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;

-- Data analysis and key business questions

-- 1. Retrieve each user's total submissions and points earned.
SELECT
	username,
	COUNT(*) AS total_submissions,
	SUM(points) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;

-- 2. Calculate each user's daily average points.
SELECT
	TO_CHAR(submitted_at, 'DD-MM') AS "day",
	username,
	AVG(points) AS daily_avg_points
FROM user_submissions
GROUP BY "day", username
ORDER BY "day", username;

-- 3. Identify the top 3 users with the most positive submissions each day.
WITH daily_submissions AS (
	SELECT
		TO_CHAR(submitted_at, 'DD-MM') AS "day",
		username,
		SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS positive_submissions
	FROM user_submissions
	GROUP BY "day", username
	HAVING SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) > 0
),
ranked_users AS (
	SELECT
		"day",
		username,
		positive_submissions,
		DENSE_RANK() OVER (
			PARTITION BY "day"
			ORDER BY positive_submissions DESC
		) AS submission_rank
	FROM daily_submissions
)
SELECT
	"day",
	username,
	positive_submissions
FROM ranked_users
WHERE submission_rank <= 3
ORDER BY "day", submission_rank, username;

-- 4. Identify the top 5 users with the most incorrect submissions.
SELECT
    username,
    COUNT(*) AS incorrect_submissions
FROM user_submissions
WHERE points < 0
GROUP BY username
ORDER BY incorrect_submissions DESC
LIMIT 5;

--

SELECT
    username,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_submissions
FROM user_submissions
GROUP BY username
ORDER BY incorrect_submissions DESC
LIMIT 5;

-- 5. Identify the top 10 performers each week based on total points earned.
WITH weekly_performance AS (
	SELECT
		DATE_TRUNC('week', submitted_at)::DATE AS week_start,
		username,
		SUM(points) AS points_earned
	FROM user_submissions
	GROUP BY week_start, username
	HAVING SUM(points) > 0
),
ranked_users AS (
	SELECT
		week_start,
		username,
		points_earned,
		RANK() OVER (
			PARTITION BY week_start
			ORDER BY points_earned DESC
		) AS performance_rank
	FROM weekly_performance
)
SELECT
	week_start,
	username,
	points_earned,
	performance_rank
FROM ranked_users
WHERE performance_rank <= 10
ORDER BY week_start, performance_rank, username;