# Walmart Data Analysis using Python and SQL

## Overview

This project focuses on analyzing Walmart sales data using Python and SQL. The dataset was cleaned and prepared using Pandas, then loaded into PostgreSQL for querying and analysis. The project explores sales performance, customer purchasing patterns, payment methods, product categories, and branch-level trends.

## Objectives

- Clean and prepare the Walmart sales dataset using Python.
- Connect Python to PostgreSQL using SQLAlchemy and psycopg2.
- Load the cleaned data into a PostgreSQL database.
- Analyze sales, revenue, profit, customer purchasing patterns, and branch performance using SQL.
- Practice SQL concepts such as aggregation, grouping, date functions, window functions, CTEs, and ranking.

## Tools and Technologies

- **Python:** Data cleaning and preparation
- **Pandas:** Data manipulation
- **PostgreSQL:** Database management and SQL analysis
- **SQLAlchemy and psycopg2:** Python–PostgreSQL connectivity
- **python-dotenv:** Environment variable management
- **Jupyter Notebook:** Interactive analysis
- **Git and GitHub:** Version control

## Dataset

The project uses a Walmart sales dataset containing transaction details, branch and city information, product categories, unit prices, quantities, dates, payment methods, customer ratings, and profit margins.

## Database Schema

The cleaned data is stored in the PostgreSQL table `walmart_sales`.

The table includes the following columns:

- `invoice_id`
- `branch`
- `city`
- `category`
- `unit_price`
- `quantity`
- `date`
- `time`
- `payment_method`
- `rating`
- `profit_margin`
- `total`

The `total` column represents the total sales value for each transaction line, calculated by multiplying unit price by quantity.

## Data Cleaning and Preparation

The dataset was prepared using Python and Pandas through the following steps:

- Checked for and removed duplicate records.
- Checked for and removed missing values.
- Converted `unit_price` from a string containing a currency symbol to a numeric data type.
- Created the `total` column by multiplying `unit_price` by `quantity`.
- Loaded the cleaned data into PostgreSQL using SQLAlchemy.

## Analysis Questions and SQL Queries

### 1. What are the different payment methods, and how many transactions and items were sold with each method?

```sql
SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(quantity) AS items_sold
FROM walmart_sales
GROUP BY payment_method;
```

### 2. Which category received the highest average rating in each branch?

```sql
SELECT
    branch,
    category,
    avg_rating
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY AVG(rating) DESC
        ) AS branch_rank
    FROM walmart_sales
    GROUP BY branch, category
) AS ranked_categories
WHERE branch_rank = 1;
```

### 3. What is the busiest day of the week for each branch based on transaction volume?

```sql
SELECT
    branch,
    day_of_week,
    transaction_volume
FROM (
    SELECT
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_of_week,
        COUNT(*) AS transaction_volume,
        RANK() OVER(
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS day_rank
    FROM walmart_sales
    GROUP BY branch, day_of_week
) AS ranked_days
WHERE day_rank = 1;
```

### 4. Which cities generate the highest total revenue?

```sql
SELECT
    city,
    SUM(total) AS total_revenue
FROM walmart_sales
GROUP BY city
ORDER BY total_revenue DESC;
```

### 5. What are the average, minimum, and maximum ratings for each category in each city?

```sql
SELECT
    city,
    category,
    ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart_sales
GROUP BY city, category
ORDER BY city, category;
```

### 6. What is the total profit for each category, ranked from highest to lowest?

```sql
SELECT
    category,
    ROUND(SUM(total)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(total * profit_margin)::NUMERIC, 2) AS total_profit
FROM walmart_sales
GROUP BY category
ORDER BY total_profit DESC;
```

### 7. What is the most frequently used payment method in each branch?

```sql
SELECT
    branch,
    payment_method AS most_frequently_used,
    total_transaction
FROM (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_transaction,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) DESC
        ) AS payment_method_rank
    FROM walmart_sales
    GROUP BY branch, payment_method
) AS ranked_payment_methods
WHERE payment_method_rank = 1;
```

### 8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

```sql
SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS transaction_count
FROM walmart_sales
GROUP BY branch, shift
ORDER BY branch, shift;
```

### 9. Which branches experienced the largest decrease in revenue compared to the previous year?

```sql
WITH yearly_revenue AS (
    SELECT
        branch,
        EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS sales_year,
        SUM(total) AS total_revenue
    FROM walmart_sales
    GROUP BY branch, sales_year
),
revenue_change AS (
    SELECT
        branch,
        sales_year,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY branch
            ORDER BY sales_year
        ) AS previous_year_revenue
    FROM yearly_revenue
)
SELECT
    branch,
    sales_year,
    previous_year_revenue,
    total_revenue,
    ROUND(
        ((previous_year_revenue - total_revenue) / previous_year_revenue * 100)::NUMERIC,
        2
    ) AS revenue_decrease_percentage
FROM revenue_change
WHERE previous_year_revenue > total_revenue
ORDER BY revenue_decrease_percentage DESC
LIMIT 5;
```

## Conclusion

This project demonstrates a complete data analysis workflow, from cleaning and preparing data with Python to storing it in PostgreSQL and answering business questions with SQL. It strengthened my understanding of data preparation, database connectivity, sales analysis, aggregations, CTEs, and window functions as part of my data analysis learning journey.
