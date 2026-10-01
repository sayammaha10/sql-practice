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

-- 4. Unique Customers by City
-- Count the number of unique customers who have made purchases in each city.
SELECT
	ci.city_name,
	COUNT(DISTINCT s.customer_id) AS unique_customers
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

-- 6. Top Selling Products by City
-- Identify the top 3 selling products in each city based on sales volume.
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

-- 7. Average Sales Amount per City
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

-- 8. Revenue-to-Rent Analysis
-- Compare the total revenue generated with the estimated rent in each city.
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

-- 9. Monthly Sales Growth
-- Calculate the monthly percentage growth or decline in sales for each city.
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

-- 10. Market Potential Analysis
-- Identify the top 3 cities based on total sales and show key market metrics.
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