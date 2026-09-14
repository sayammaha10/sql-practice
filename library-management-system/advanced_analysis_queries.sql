-- Advanced SQL Operations and Data Analysis

-- Task 13: Identify members with overdue books
-- Retrieve members who have books overdue by more than 30 days.
-- Display member ID, member name, book title, issue date, and days overdue.
SELECT
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date - 30 as days_overdue
FROM issued_status as ist
JOIN members as m
ON ist.issued_member_id = m.member_id
JOIN books as b
ON ist.issued_book_isbn = b.isbn
LEFT JOIN return_status as rs
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
CALL add_return_record ('RS138', 'IS135', 'Good');