-- SQL Retail Sales Analysis
CREATE DATABASE retail_sales_db;


-- Create table
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
)

SELECT * FROM retail_sales;


-- Data cleaning
SELECT * FROM retail_sales
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

-- Remove records containing NULL values
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


-- Data exploration

-- Total number of sales
SELECT COUNT(*) as total_sales FROM retail_sales;

-- Number of unique customers
SELECT COUNT(DISTINCT customer_id) as customers FROM retail_sales;

-- List of unique product categories
SELECT DISTINCT category FROM retail_sales;


-- Data analysis and key business questions

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in November 2022
-- Q.3 Write a SQL query to calculate the total sales for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month and find the best-selling month in each year.
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and calculate the number of orders (Example: Morning < 12, Afternoon between 12 & 17, Evening > 17)


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in November 2022
SELECT * FROM retail_sales
WHERE category = 'Clothing'
	AND quantity >= 4
	AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales for each category.
SELECT
	category,
	SUM(total_sale) as net_sale
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT
	category,
	ROUND(AVG(age), 2) as average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
SELECT
	gender,
	category,
	COUNT(transactions_id) as no_of_transactions
FROM retail_sales
GROUP BY gender, category;

-- Q.7 Write a SQL query to calculate the average sale for each month and find the best-selling month in each year.
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

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT
	customer_id,
	SUM(total_sale) as total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT
	category,
	COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and calculate the number of orders (Example: Morning < 12, Afternoon between 12 & 17, Evening > 17)
WITH sales_by_shift AS (
	SELECT * ,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)

SELECT
	shift,
	count(transactions_id)
FROM sales_by_shift
GROUP BY shift;

-- End of project