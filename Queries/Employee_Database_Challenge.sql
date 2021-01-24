-- 1. Number of Employees Retiring by Title (Retirement Titles)
-- Current employees born between 1/1/1952 & 12/31/1955
-- Important: Get most recent title of each employee

-- 1A) Get retirement-eligible employees with their titles and promotion dates
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	t.title,
	t.from_date,
	t.to_date
INTO retirement_titles
FROM employees AS e
	INNER JOIN titles AS t
		ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;
	
-- Use Distinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (emp_no) emp_no,
	first_name,
	last_name,
	title
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

-- Get number of employees retiring by title
SELECT title AS "Title", COUNT(emp_no) AS "No. Retiring"
INTO retiring_titles
FROM unique_titles
GROUP BY "Title"
ORDER BY "No. Retiring" DESC;

-- 2. Mentorship-Eligibility
-- Current employees eligible to participate in mentorship program (prospective retirees)
-- emp_no, first_name, last_name, birth_date, from_date, to_date, title
SELECT DISTINCT ON (e.emp_no) e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
	t.title
INTO mentorship_eligibility
FROM employees AS e
	INNER JOIN dept_employees AS de
		ON (e.emp_no = de.emp_no)
	INNER JOIN titles AS t
		ON (de.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND (de.to_date = ('9999-01-01'))
ORDER BY emp_no, to_date DESC;

-- Total number of employees eligible for retirement
SELECT SUM("No. Retiring") FROM retiring_titles;

-- Total number of employees eligible for mentorship program
SELECT COUNT(emp_no) FROM mentorship_eligibility;

-- How many roles will need to be filled?
-- Are there enough qualified employees in each department to mentor future employees?

-- Get departments for mentorship eligibility
SELECT me.emp_no,
	d.dept_name
INTO mentorship_dept
FROM mentorship_eligibility AS me
	INNER JOIN dept_employees AS de
		ON me.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no;

-- Get count of mentorship eligibility by department
SELECT dept_name,
	COUNT(emp_no)
INTO mentorship_no
FROM mentorship_dept
GROUP BY dept_name
ORDER BY COUNT(emp_no) DESC;

-- Get retirement-eligible employees with their departments and from/to dates
SELECT e.emp_no,
	de.dept_no,
	de.from_date,
	de.to_date
INTO ret_dept
FROM employees AS e
	INNER JOIN dept_employees AS de
		ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no;

-- Use Distinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (emp_no) emp_no,
	dept_no
INTO unique_dept
FROM ret_dept
ORDER BY emp_no, to_date DESC;

-- Add department names
SELECT ud.emp_no,
	d.dept_name
INTO unique_dept_name
FROM unique_dept AS ud
	LEFT JOIN departments AS d
		ON ud.dept_no = d.dept_no;
		
-- Get number of employees retiring by department
SELECT dept_name, COUNT(emp_no)
INTO retiring_dept
FROM unique_dept_name
GROUP BY dept_name
ORDER BY COUNT(emp_no) DESC;

-- Combine retirement/mentorship (mentorship_no) by department
SELECT rd.dept_name AS Department,
	rd.count AS No_Retiring,
	mn.count AS No_Eligible_for_Mentorship
INTO readiness_assessment
FROM retiring_dept AS rd
	FULL OUTER JOIN mentorship_no AS mn
		ON rd.dept_name = mn.dept_name;