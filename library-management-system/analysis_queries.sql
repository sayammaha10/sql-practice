-- Basic SQL Operations and Data Analysis

-- Task 1: Create a new book record
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an existing member's address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Task 3: Delete a record from the issued status table
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve all books issued by a specific employee
WHERE issued_emp_id = 'E101';

-- Task 5: List members who have issued more than one book
SELECT
	issued_member_id,
	COUNT(issued_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1;

-- CTAS (CREATE TABLE AS SELECT)
-- Task 6: Create a summary table showing each book and the number of times it has been issued
CREATE TABLE book_counts
AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as issued_no
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;

-- Task 7: Retrieve all books in a specific category
SELECT * FROM books
WHERE category = 'Fantasy';

-- Task 8: Calculate total rental income by category
SELECT
	b.category,
	SUM(b.rental_price)
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;

-- Task 9: List members who registered in the last 180 days
SELECT * from members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List employees with their branch managers and branch details
SELECT
	e1.*,
	b.manager_id,
	e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id
JOIN employees as e2
ON e2.emp_id = b.manager_id;

-- Task 11: Create a table of books with a rental price above a certain threshold
CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price >= 7.00;

-- Task 12: Retrieve the list of books that have not yet been returned
SELECT
	DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;