-- Market Expansion Analysis

-- Drop existing tables
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import data in the following order
-- 1. City data
-- 2. Product data
-- 3. Customer data
-- 4. Sales data

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

-- End of schema