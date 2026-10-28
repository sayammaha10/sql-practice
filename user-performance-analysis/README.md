# User Performance Analysis using SQL

## Overview

This project analyzes user submission data using SQL to evaluate user performance, track points earned, and identify top-performing users. It explores submission activity, daily average points, incorrect submissions, and weekly performance rankings through practical SQL queries.

## Objectives

- Analyze user submission activity and total points earned.
- Calculate daily average points for each user.
- Identify users with the most positive submissions each day.
- Find users with the highest number of incorrect submissions.
- Rank top-performing users based on their weekly points earned.

## Dataset

The dataset contains user submission records, including user identifiers, question identifiers, points, submission timestamps, and usernames.

## Schema

The project uses a `user_submissions` table with the following structure:

```sql
CREATE TABLE user_submissions (
    "id" SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);
```

## Business Problems and Solutions

### 1. Retrieve each user's total submissions and points earned.

```sql
SELECT
    username,
    COUNT(*) AS total_submissions,
    SUM(points) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;
```

### 2. Calculate each user's daily average points.

```sql
SELECT
    TO_CHAR(submitted_at, 'DD-MM') AS "day",
    username,
    AVG(points) AS daily_avg_points
FROM user_submissions
GROUP BY "day", username
ORDER BY "day", username;
```

### 3. Identify the top 3 users with the most positive submissions each day.

```sql
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
```

### 4. Find the top 5 users with the highest number of incorrect submissions.

```sql
SELECT
    username,
    COUNT(*) AS incorrect_submissions
FROM user_submissions
WHERE points < 0
GROUP BY username
ORDER BY incorrect_submissions DESC
LIMIT 5;
```

### 5. Identify the top 10 performers each week based on total points earned.

```sql
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
```

### 6. Find each user's highest-scoring submission.

```sql
SELECT
    username,
    question_id,
    points AS highest_points,
    submitted_at
FROM (
    SELECT
        username,
        question_id,
        points,
        submitted_at,
        RANK() OVER (
            PARTITION BY username
            ORDER BY points DESC
        ) AS submission_rank
    FROM user_submissions
) AS ranked_submissions
WHERE submission_rank = 1
ORDER BY highest_points DESC, username;
```

### 7. Calculate Each User's Submission Success Rate

```sql
SELECT
    username,
    COUNT(*) AS total_submissions,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS successful_submissions,
    ROUND(
        100.0 * SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0),
        2
    ) AS success_rate
FROM user_submissions
GROUP BY username
ORDER BY success_rate DESC, total_submissions DESC;
```

### 8. Identify Questions with the Highest Failure Rates

```sql
SELECT
    question_id,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_attempts,
    ROUND(
        100.0 * SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate
FROM user_submissions
GROUP BY question_id
ORDER BY failure_rate DESC, total_attempts DESC;
```

## SQL Concepts Used

- Aggregate functions: `COUNT()`, `SUM()`, and `AVG()`
- Filtering and grouping using `WHERE`, `GROUP BY`, and `HAVING`
- Date and time functions: `TO_CHAR()` and `DATE_TRUNC()`
- Conditional aggregation using `CASE`
- Common Table Expressions (CTEs)
- Window functions: `RANK()` and `DENSE_RANK()`
- Sorting and limiting results using `ORDER BY` and `LIMIT`

## Conclusion

This project strengthened my understanding of SQL by applying aggregation, filtering, date and time functions, conditional logic, CTEs, and window functions to analyze user submission data. It demonstrates how SQL can be used to evaluate user performance, identify submission patterns, and rank top performers across different time periods as part of my data analysis learning journey.
