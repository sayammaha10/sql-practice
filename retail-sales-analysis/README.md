# Retail Sales Analysis SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis  
**Level:** Beginner  
**Database:** `retail_sales_db`

This project demonstrates SQL techniques used to clean, explore, and analyze retail sales data. The analysis covers database and table creation, data cleaning, exploratory data analysis, and business-focused SQL queries.

The project uses a `retail_sales` table containing transaction, customer, product category, pricing, cost, and sales information.

## Objectives

1. **Set up a retail sales database:** Create the `retail_sales_db` database and `retail_sales` table.
2. **Clean the data:** Identify and remove records containing `NULL` values.
3. **Explore the dataset:** Examine the total number of sales, unique customers, and available product categories.
4. **Analyze sales data:** Answer business questions related to sales, customers, categories, and transaction patterns.
5. **Practice SQL techniques:** Apply filtering, aggregation, grouping, date/time functions, CTEs, subqueries, and window functions.

## Project Structure

### 1. Database Setup

The project begins by creating a database named `retail_sales_db`.

A `retail_sales` table is created to store the sales data.

```sql
CREATE DATABASE retail_sales_db;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

The table contains information about transactions, customers, product categories, quantities, prices, cost of goods sold, and total sales.

### 2. Data Cleaning

The dataset is checked for missing values across all columns.

```sql
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

Records containing `NULL` values are then removed:

```sql
DELETE FROM retail_sales
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

### 3. Data Exploration

Basic exploratory queries are used to understand the dataset.

#### Total Number of Sales

```sql
SELECT COUNT(*) AS total_sales
FROM retail_sales;
```

#### Number of Unique Customers

```sql
SELECT COUNT(DISTINCT customer_id) AS customers
FROM retail_sales;
```

#### Unique Product Categories

```sql
SELECT DISTINCT category
FROM retail_sales;
```

## Data Analysis & Business Questions

The project answers the following business questions using SQL.

### 1. Sales Made on a Specific Date

Retrieve all sales made on `2022-11-05`.

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

### 2. Clothing Sales in November 2022

Retrieve all Clothing transactions where the quantity sold was greater than or equal to 4 during November 2022.

```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
    AND quantity >= 4
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
```

### 3. Total Sales by Category

Calculate the total sales for each product category.

```sql
SELECT
    category,
    SUM(total_sale) AS net_sale
FROM retail_sales
GROUP BY category;
```

### 4. Average Age of Beauty Customers

Calculate the average age of customers who purchased items from the `Beauty` category.

```sql
SELECT
    category,
    ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;
```

### 5. High-Value Transactions

Retrieve all transactions where the total sale amount is greater than `1000`.

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

### 6. Transactions by Gender and Category

Calculate the total number of transactions made by each gender within each product category.

```sql
SELECT
    gender,
    category,
    COUNT(transactions_id) AS no_of_transactions
FROM retail_sales
GROUP BY gender, category;
```

### 7. Best-Selling Month in Each Year

Calculate the average sale for each month and identify the month with the highest average sale in each year.

The query uses the `RANK()` window function to rank the months within each year.

```sql
SELECT
    year,
    month,
    average_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS average_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date)
) AS monthly_sales
WHERE rank = 1;
```

### 8. Top 5 Customers by Total Sales

Find the top 5 customers based on their total sales.

```sql
SELECT
    customer_id,
    SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;
```

### 9. Unique Customers by Category

Calculate the number of unique customers who purchased items from each category.

```sql
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;
```

### 10. Orders by Sales Shift

Classify transactions into three shifts based on the sale time:

- **Morning:** Before 12:00
- **Afternoon:** 12:00 to 17:00
- **Evening:** After 17:00

A `CASE` expression is used inside a CTE to assign each transaction to a shift and count the number of transactions in each shift.

```sql
WITH sales_by_shift AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)

SELECT
    shift,
    COUNT(transactions_id)
FROM sales_by_shift
GROUP BY shift;
```

## SQL Concepts and Techniques Used

- Database and table creation
- Data cleaning and `NULL` handling
- Data filtering with `WHERE`
- Aggregation with `COUNT()`, `SUM()`, and `AVG()`
- `COUNT(DISTINCT)`
- `GROUP BY`
- `ORDER BY`
- `LIMIT`
- Date filtering with `TO_CHAR()`
- Date and time extraction with `EXTRACT()`
- Conditional logic with `CASE`
- Common Table Expressions (CTEs)
- Subqueries
- Window functions with `RANK()`
- `PARTITION BY`
- Customer and category analysis

## Conclusion

This project provides hands-on practice with SQL through a retail sales dataset. It covers the process of setting up a database, cleaning incomplete records, exploring the data, and answering business-focused questions.

The analysis focuses on sales performance, customer behavior, product categories, high-value transactions, monthly sales patterns, top customers, and transaction distribution across different sales shifts.

## How to Use

1. **Create the database:** Run the database creation statement to create `retail_sales_db`.
2. **Create the table:** Run the `CREATE TABLE` statement to create the `retail_sales` table.
3. **Load the data:** Insert or import the retail sales data into the `retail_sales` table.
4. **Clean the data:** Run the `NULL` check and deletion query.
5. **Explore the data:** Run the exploratory queries.
6. **Run the analysis:** Execute the business analysis queries.

---

This project is part of my data analysis learning journey and demonstrates practical SQL skills through a retail sales analysis project.