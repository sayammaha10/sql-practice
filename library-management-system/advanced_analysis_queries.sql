-- Advanced SQL Operations and Data Analysis

-- Task 13: Identify members with overdue books
-- Retrieve members who have books overdue by more than 30 days.
-- Display member ID, member name, book title, issue date, and days overdue.
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

-- Task 14: Update book status on return
-- Create a stored procedure to record a book return and update the book's status to 'yes' in the books table.

-- Stored Procedure
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
	-- Insert return record into return_status table
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

-- Call the procedure
CALL add_return_record('RS138', 'IS135', 'Good');

-- Task 15: Branch performance report
-- Generate a performance report for each branch.
-- Display the number of books issued, the number of books returned, and the total revenue generated from book rentals.
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

-- Task 16: Identify active members
-- Create a new table using CTAS containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
	SELECT
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
);

SELECT * FROM active_members;

-- Task 17: Identify employees with the most book issues
-- Find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of book issues processed, and branch.
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

-- Task 18: Identify members with repeated damaged book returns
-- Identify members who have returned books in damaged condition more than twice.
-- Display the member name and number of damaged returns.
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

-- Task 19: Issue a book using a stored procedure
-- Create a stored procedure that checks whether a book is available before issuing it.
-- If the book is available, create the issue record and update its status to 'no'.
-- If the book is unavailable, display a message indicating that the book is currently unavailable.
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
	-- Checking if the book is available
	SELECT
		status
		INTO v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN
		INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book record added successfully';
	ELSE
		RAISE NOTICE 'Book is currently not available';
	END IF;
END;
$$;

-- Call the procedure
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-7432-7357-1', 'E104');

-- Task 20: Create a table of overdue books and fines
-- Create a new table using CTAS that summarizes overdue books for each member.
-- Display the member ID, number of overdue books, and total fine.
-- Calculate the fine at $0.50 for each day overdue.
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

SELECT * FROM overdue_fine;