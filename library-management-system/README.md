# Library Management System using SQL

## Overview

This project implements a Library Management System using SQL. It covers database design, sample data insertion, CRUD operations, data analysis, CTAS queries, joins, subqueries, and stored procedures.

The project focuses on managing library branches, employees, members, books, issued books, and returned books while using SQL to perform practical data analysis.

## Objectives

- Design a relational database for a library management system.
- Create tables and establish relationships using primary and foreign keys.
- Insert and manage sample library data.
- Perform CRUD operations using SQL.
- Use CTAS to create summary and analysis tables.
- Analyze books, members, employees, branches, and borrowing activity.
- Use stored procedures to manage book issuance and returns.
- Identify overdue books and calculate fines.

## Project Structure

```text
Library Management System/
│
├── Schema.sql
├── insert_queries.sql
├── analysis_queries.sql
└── advanced_analysis_queries.sql
```

## Database Schema

The `Schema.sql` file creates the database tables and establishes relationships using primary and foreign keys.

The project includes the following tables:

- `branch`
- `employees`
- `books`
- `members`
- `issued_status`
- `return_status`

```sql
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(100),
    contact_no VARCHAR(20)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(25),
    "position" VARCHAR(15),
    salary INT,
    branch_id VARCHAR(10)
);

CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(20),
    rental_price FLOAT,
    status VARCHAR(10),
    author VARCHAR(40),
    publisher VARCHAR(55)
);

CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(25),
    member_address VARCHAR(75),
    reg_date DATE
);

CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(20),
    issued_emp_id VARCHAR(10)
);

CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(20)
);
```

## Sample Data

The `insert_queries.sql` file populates the database with sample records for:

- Members
- Branches
- Employees
- Books
- Issued books
- Returned books

It also includes additional data for recent book issues and damaged book returns.

## Basic SQL Operations and Data Analysis

The `analysis_queries.sql` file covers basic SQL operations and analysis.

### 1. Create a new book record

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

### 2. Update an existing member's address

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

### 3. Delete a record from the issued status table

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

### 4. Retrieve all books issued by a specific employee

```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```

### 5. List members who have issued more than one book

```sql
SELECT
    issued_member_id,
    COUNT(issued_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;
```

### 6. Create a summary table showing book issue counts

```sql
CREATE TABLE book_counts
AS
SELECT
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS issued_no
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

### 7. Retrieve all books in a specific category

```sql
SELECT *
FROM books
WHERE category = 'Fantasy';
```

### 8. Calculate total rental income by category

```sql
SELECT
    b.category,
    SUM(b.rental_price)
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

### 9. List members who registered in the last 180 days

```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

### 10. List employees with their branch managers and branch details

```sql
SELECT
    e1.*,
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON e1.branch_id = b.branch_id
JOIN employees AS e2
ON e2.emp_id = b.manager_id;
```

### 11. Create a table of books with a rental price above a certain threshold

```sql
CREATE TABLE expensive_books
AS
SELECT *
FROM books
WHERE rental_price >= 7.00;
```

### 12. Retrieve books that have not yet been returned

```sql
SELECT DISTINCT
    ist.issued_book_name
FROM issued_status AS ist
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations and Data Analysis

The `advanced_analysis_queries.sql` file covers more advanced SQL concepts, including stored procedures, CTAS, conditional logic, and additional data analysis.

### 13. Identify members with overdue books

```sql
SELECT
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date - 30 AS days_overdue
FROM issued_status AS ist
JOIN members AS m
ON ist.issued_member_id = m.member_id
JOIN books AS bk
ON ist.issued_book_isbn = bk.isbn
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE
    rs.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY ist.issued_member_id;
```

### 14. Update book status on return

```sql
CREATE OR REPLACE PROCEDURE add_return_record (
    p_return_id VARCHAR(10),
    p_issued_id VARCHAR(10),
    p_book_quality VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
BEGIN
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT
        issued_book_isbn
        INTO v_isbn
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Return recorded and book status updated successfully';
END;
$$;
```

### 15. Generate a branch performance report

```sql
SELECT
    b.branch_id,
    COUNT(ist.issued_id) AS book_issued,
    COUNT(rs.return_id) AS book_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
JOIN branch AS b
ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
JOIN books AS bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id;
```

### 16. Identify active members

```sql
CREATE TABLE active_members
AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
);
```

### 17. Identify employees with the most book issues

```sql
SELECT
    e.emp_name,
    COUNT(ist.issued_id) AS book_issued,
    b.branch_id
FROM issued_status AS ist
JOIN employees AS e
ON ist.issued_emp_id = e.emp_id
JOIN branch AS b
ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id
ORDER BY book_issued DESC
LIMIT 3;
```

### 18. Identify members with repeated damaged book returns

```sql
SELECT
    m.member_name,
    COUNT(rs.return_id) AS damaged_return_count
FROM return_status AS rs
JOIN issued_status AS ist
ON rs.issued_id = ist.issued_id
JOIN members AS m
ON ist.issued_member_id = m.member_id
JOIN books AS bk
ON ist.issued_book_isbn = bk.isbn
WHERE rs.book_quality = 'Damaged'
GROUP BY m.member_name
HAVING COUNT(rs.return_id) > 2;
```

### 19. Issue a book using a stored procedure

```sql
CREATE OR REPLACE PROCEDURE issue_book (
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(10),
    p_issued_book_isbn VARCHAR(20),
    p_issued_emp_id VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    SELECT
        status
        INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            CURRENT_DATE,
            p_issued_book_isbn,
            p_issued_emp_id
        );

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book record added successfully';
    ELSE
        RAISE NOTICE 'Book is currently not available';
    END IF;
END;
$$;
```

### 20. Create a table of overdue books and fines

```sql
CREATE TABLE overdue_fine
AS
SELECT
    ist.issued_member_id,
    COUNT(ist.issued_id) AS overdue_books,
    SUM((CURRENT_DATE - ist.issued_date - 30) * 0.5) AS total_fine
FROM issued_status AS ist
LEFT JOIN return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE
    rs.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
GROUP BY ist.issued_member_id;
```

## SQL Concepts Used

- Database schema design
- Primary keys and foreign keys
- `INSERT`, `UPDATE`, and `DELETE`
- `SELECT`
- Filtering with `WHERE`
- Aggregation with `COUNT` and `SUM`
- `GROUP BY` and `HAVING`
- `ORDER BY` and `LIMIT`
- `JOIN` and `LEFT JOIN`
- Subqueries
- CTAS (`CREATE TABLE AS`)
- Date and interval functions
- Stored procedures
- PL/pgSQL
- Conditional logic with `IF`
- `CURRENT_DATE`
- Data manipulation and analysis

## Conclusion

This project provides hands-on practice with SQL through a Library Management System. It covers the process of designing a relational database, creating and populating tables, managing records, and using SQL to answer practical business-focused questions.

The analysis focuses on book issues and returns, member activity, rental income, branch performance, employee performance, overdue books, damaged returns, and book availability.

---

This project is part of my data analysis learning journey and demonstrates practical SQL skills through a Library Management System project.