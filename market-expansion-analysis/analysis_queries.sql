-- Data analysis and key business questions

-- 1. Coffee Consumers Count
-- Estimate the number of coffee consumers in each city based on 25% of the population.
SELECT
	city_name,
	population,
	ROUND(population * 0.25, 0) AS estimated_coffee_consumers
FROM city
ORDER BY estimated_coffee_consumers DESC;

-- 2. Total Revenue from Coffee Sales
-- Calculate the total revenue generated in each city during the last quarter of 2023.
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

-- 3. Sales Count for Each Product
-- Count the number of sales recorded for each product.
SELECT
	p.product_name,
	COUNT(s.sale_id) AS total_sales
FROM products AS p
LEFT JOIN sales AS s
ON p.product_id = s.product_id
GROUP BY p.product_name;

-- 4. Average Sales Amount per City
-- Calculate the average revenue generated per customer in each city.
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

-- 5. Customer Satisfaction by City
-- Calculate the average customer rating for each city.
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