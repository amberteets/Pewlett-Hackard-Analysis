-- Drop table if it already exists and removes connections to other tables
DROP TABLE IF EXISTS departments CASCADE;

-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);

DROP TABLE IF EXISTS dept_manager CASCADE;
CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

DROP TABLE IF EXISTS salaries CASCADE;
CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

-- Need to use 'composite primary key'
DROP TABLE IF EXISTS dept_employees CASCADE;
CREATE TABLE dept_employees (
	emp_no INT NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

DROP TABLE IF EXISTS titles CASCADE;
CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

-- -- Retirement eligibility
-- SELECT first_name, last_name
-- FROM employees
-- WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- -- Number of employees eligible for retirement
-- SELECT COUNT(first_name)
-- FROM employees
-- WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- -- Create retirement eligibility table to export to CSV
-- SELECT first_name, last_name
-- INTO retirement_info -- Sends output to new table named retirement_info
-- FROM employees
-- WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- SELECT * FROM dept_employees;

-- -- Update retirement_info to include employee #, dept #
-- -- My version
-- DROP TABLE retirement_info;

-- SELECT de.emp_no, de.dept_no, e.first_name, e.last_name 
-- INTO retirement_info
-- FROM employees AS e JOIN dept_employees AS de
-- 	ON e.emp_no = de.emp_no
-- WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- SELECT * FROM retirement_info;

-- -- Update retirement table to include employee #, first/last name, and if they are
-- -- currently employed with the company (module version)
-- DROP TABLE retirement_info;

-- SELECT emp_no, first_name, last_name
-- INTO retirement_info
-- FROM employees
-- WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- 	-- Now join with dept_employees table for if they left company
-- SELECT ri.emp_no, ri.first_name, ri.last_name, de.to_date
-- FROM retirement_info AS ri LEFT JOIN dept_employees AS de
-- 	ON ri.emp_no = de.emp_no
	
-- -- Create current_emp table for retirement-eligible workers still at company
-- SELECT ri.emp_no,
-- 	ri.first_name,
-- 	ri.last_name,
-- 	de.to_date
-- INTO current_emp
-- FROM retirement_info AS ri
-- 	LEFT JOIN dept_employees AS de
-- ON ri.emp_no = de.emp_no
-- WHERE de.to_date = ('9999-01-01');

-- -- Retiree employee count by department
-- SELECT de.dept_no, COUNT(ce.emp_no)
-- INTO retirement_dept
-- FROM current_emp AS ce
-- 	LEFT JOIN dept_employees AS de
-- ON ce.emp_no = de.emp_no
-- GROUP BY de.dept_no
-- ORDER BY de.dept_no ASC;

-- -- List 1: Retirees incl. Employee #, last name, first name, gender, salary

-- -- Make sure salaries to_date aligns with dept_emp to_date (it doesn't)
-- SELECT * FROM salaries
-- ORDER BY to_date DESC;

-- SELECT e.emp_no,
-- 	e.first_name,
-- 	e.last_name,
-- 	e.gender,
-- 	s.salary,
-- 	de.to_date
-- INTO emp_info
-- FROM employees AS e
-- 	INNER JOIN salaries AS s
-- ON (e.emp_no = s.emp_no)
-- 	INNER JOIN dept_employees AS de
-- ON (e.emp_no = de.emp_no)
-- WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
-- 	AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
-- 	AND (de.to_date = ('9999-01-01'));

-- -- List 2: Management
-- -- Manager's emp_no, department name/#, first name, last name, start and end dates
-- SELECT dm.dept_no,
-- 	d.dept_name,
-- 	dm.emp_no,
-- 	ce.first_name,
-- 	ce.last_name,
-- 	dm.from_date,
-- 	dm.to_date
-- INTO manager_info
-- FROM dept_manager AS dm
-- 	INNER JOIN departments AS d
-- 		ON (dm.dept_no = d.dept_no)
-- 	INNER JOIN current_emp AS ce
-- 		ON (dm.emp_no = ce.emp_no);

-- -- List 3: Add department to current employees
-- -- Need emp_no, first/last name, dept name
-- SELECT ce.emp_no,
-- 	ce.first_name,
-- 	ce.last_name,
-- 	d.dept_name
-- INTO dept_info
-- FROM current_emp AS ce
-- 	INNER JOIN dept_employees AS de
-- 		ON (ce.emp_no = de.emp_no)
-- 	INNER JOIN departments AS d
-- 		ON (de.dept_no = d.dept_no);
		
-- -- Skill Drill: Sales team retirees
-- -- Emp_no, first_name, last_name, dept_name=Sales
-- SELECT ri.emp_no,
-- 	ri.first_name,
-- 	ri.last_name,
-- 	d.dept_name
-- INTO sales_retirement
-- FROM retirement_info AS ri
-- 	INNER JOIN dept_employees AS de
-- 		ON ri.emp_no = de.emp_no
-- 	INNER JOIN departments AS d
-- 		ON de.dept_no = d.dept_no
-- WHERE (d.dept_name = 'Sales');

-- -- Skill Drill: Sales/Development team retirees
-- -- Emp_no, first_name, last_name, dept_name=Sales or Development
-- SELECT ri.emp_no,
-- 	ri.first_name,
-- 	ri.last_name,
-- 	d.dept_name
-- INTO sales_dev_retirement
-- FROM retirement_info AS ri
-- 	INNER JOIN dept_employees AS de
-- 		ON ri.emp_no = de.emp_no
-- 	INNER JOIN departments AS d
-- 		ON de.dept_no = d.dept_no
-- WHERE (d.dept_name IN ('Sales', 'Development'));