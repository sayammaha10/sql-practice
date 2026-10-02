# Market Expansion Analysis using SQL

## Overview

This project analyzes sales, customer, product, city, and population data to identify cities with strong market potential for business expansion.

The analysis focuses on sales performance, customer behavior, customer satisfaction, revenue-to-rent comparison, monthly sales growth, and other city-level market metrics.

## Objectives

- Estimate the number of potential coffee consumers in each city.
- Analyze revenue generated across cities.
- Identify the most frequently sold products.
- Measure customer activity and satisfaction by city.
- Analyze revenue relative to estimated rent.
- Track monthly sales growth.
- Identify cities with the strongest market potential.

## Dataset

The project uses four related datasets:

- **City** — city population, estimated rent, and city ranking.
- **Customers** — customer information and their associated city.
- **Products** — product names and prices.
- **Sales** — sales transactions, dates, products, customers, revenue, and ratings.

## Schema

```sql
-- Create city table
CREATE TABLE city
(
	city_id INT PRIMARY KEY,
	city_name VARCHAR(15),
	population BIGINT,
	estimated_rent FLOAT,
	city_rank INT
);

-- Create customers table
CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(25),
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- Create products table
CREATE TABLE products
(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(35),
	price FLOAT
);

-- Create sales table
CREATE TABLE sales
(
	sale_id INT PRIMARY KEY,
	sale_date DATE,
	product_id INT,
	customer_id INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

## Business Problems and Solutions

### 1. Coffee Consumers Count

Estimate the number of coffee consumers in each city based on 25% of the population.

```sql
SELECT
	city_name,
	population,
	ROUND(population * 0.25, 0) AS estimated_coffee_consumers
FROM city
ORDER BY estimated_coffee_consumers DESC;
```

**Objective:** Estimate the potential coffee consumer base in each city.

### 2. Total Revenue from Coffee Sales

Calculate the total revenue generated in each city during the last quarter of 2023.

```sql
SELECT
	ci.city_name,
	SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id
WHERE
	EXTRACT(YEAR FROM s.sale_date) = 2023
	AND EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;
```

**Objective:** Compare city-level revenue during the last quarter of 2023.

### 3. Sales Count for Each Product

Count the number of sales recorded for each product.

```sql
SELECT
	p.product_name,
	COUNT(s.sale_id) AS total_sales
FROM products AS p
LEFT JOIN sales AS s
ON p.product_id = s.product_id
GROUP BY p.product_name;
```

**Objective:** Identify products with higher sales activity.

### 4. Unique Customers by City

Count the number of unique customers who have made purchases in each city.

```sql
SELECT
	ci.city_name,
	COUNT(DISTINCT s.customer_id) AS unique_customers
FROM city AS ci
JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s
ON c.customer_id = s.customer_id
GROUP BY ci.city_name;
```

**Objective:** Compare the number of purchasing customers across cities.

### 5. Customer Satisfaction by City

Calculate the average customer rating for each city.

```sql
SELECT
	ci.city_name,
	ROUND(AVG(s.rating), 2) AS avg_rating
FROM city AS ci
JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s
ON c.customer_id = s.customer_id
GROUP BY ci.city_name
ORDER BY avg_rating DESC;
```

**Objective:** Compare customer satisfaction across cities using average ratings.

### 6. Top Selling Products by City

Identify the top 3 selling products in each city based on sales volume.

```sql
SELECT * FROM (
	SELECT
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS total_orders,
		DENSE_RANK() OVER (
			PARTITION BY ci.city_name
			ORDER BY COUNT(s.sale_id) DESC
		) AS ranking
	FROM sales AS s
	JOIN products AS p
	ON s.product_id = p.product_id
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON c.city_id = ci.city_id
	GROUP BY ci.city_name, p.product_name
) AS product_ranking
WHERE ranking <= 3;
```

**Objective:** Identify the products with the highest sales volume in each city.

### 7. Average Sales Amount per City

Calculate the average revenue generated per customer in each city.

```sql
SELECT
	ci.city_name,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	ROUND(
		(SUM(s.total) / COUNT(DISTINCT s.customer_id))::NUMERIC,
		2
	) AS avg_sales_per_customer
FROM city AS ci
JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s
ON c.customer_id = s.customer_id
GROUP BY ci.city_name;
```

**Objective:** Compare the average revenue generated per customer across cities.

### 8. Revenue-to-Rent Analysis

Compare the total revenue generated with the estimated rent in each city.

```sql
SELECT
	ci.city_name,
	SUM(s.total) AS total_revenue,
	ci.estimated_rent,
	ROUND(
		(SUM(s.total) / ci.estimated_rent)::NUMERIC,
		2
	) AS revenue_to_rent_ratio
FROM city AS ci
JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s
ON c.customer_id = s.customer_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY revenue_to_rent_ratio DESC;
```

**Objective:** Compare city revenue against estimated rent as part of the expansion analysis.

### 9. Monthly Sales Growth

Calculate the monthly percentage growth or decline in sales for each city.

```sql
WITH monthly_sales AS (
	SELECT
		ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS "month",
		EXTRACT(YEAR FROM s.sale_date) AS "year",
		SUM(s.total) AS total_sale
	FROM sales AS s
	JOIN customers AS c
	ON c.customer_id = s.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY ci.city_name, "month", "year"
),
growth_ratio AS (
	SELECT
		city_name,
		"month",
		"year",
		total_sale AS current_month_sale,
		LAG(total_sale, 1) OVER (
			PARTITION BY city_name
			ORDER BY "year", "month"
		) AS last_month_sale
	FROM monthly_sales
)
SELECT
	city_name,
	"month",
	"year",
	current_month_sale,
	last_month_sale,
	ROUND(
		((current_month_sale - last_month_sale) / last_month_sale)::NUMERIC * 100,
		2
	) AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL
ORDER BY city_name, "year", "month";
```

**Objective:** Track month-over-month sales growth or decline for each city.

### 10. Market Potential Analysis

Identify the top 3 cities based on total sales and show key market metrics.

```sql
WITH city_sales AS (
	SELECT
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_customers,
		ROUND(
			SUM(s.total)::NUMERIC /
			COUNT(DISTINCT s.customer_id)::NUMERIC,
			2
		) AS avg_sale_per_customer
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1
),
city_rent AS (
	SELECT
		city_name,
		estimated_rent,
		ROUND(population * 0.25, 0) AS estimated_coffee_consumers
	FROM city
)
SELECT
	cr.city_name,
	cs.total_revenue,
	cr.estimated_rent,
	cs.total_customers,
	cr.estimated_coffee_consumers,
	cs.avg_sale_per_customer,
	ROUND(
		cr.estimated_rent::NUMERIC /
		cs.total_customers::NUMERIC,
		2
	) AS avg_rent_per_customer
FROM city_rent AS cr
JOIN city_sales AS cs
ON cr.city_name = cs.city_name
ORDER BY cs.total_revenue DESC
LIMIT 3;
```

**Objective:** Combine key sales, customer, population, and rent metrics to identify cities with strong market potential.

## SQL Concepts Used

- `SELECT` and `WHERE`
- `JOIN` and `LEFT JOIN`
- `GROUP BY`
- Aggregate functions such as `SUM()`, `COUNT()`, and `AVG()`
- `COUNT(DISTINCT)`
- `ORDER BY`
- `LIMIT`
- `EXTRACT()`
- `ROUND()`
- Type casting with `::NUMERIC`
- Common Table Expressions (CTEs)
- Window functions
- `LAG()`
- `DENSE_RANK()`
- `PARTITION BY`
- Subqueries

## Conclusion

This project provided hands-on practice with SQL by analyzing sales, customers, products, and city-level data to understand market performance and expansion potential.

The analysis helped strengthen practical SQL skills including joins, aggregation, CTEs, window functions, ranking, and time-based analysis.

---

This project is part of my data analysis learning journey and focuses on building practical SQL skills through real-world business analysis.