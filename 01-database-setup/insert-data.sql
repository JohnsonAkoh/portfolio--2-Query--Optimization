-- =====================================================
-- MIVA MIT ACADEMIC PORTFOLIO 2
-- PROJECT: QUERY OPTIMIZATION
-- CASE STUDY: STUDENT MANAGEMENT SYSTEM
-- DATABASE: PostgreSQL
-- PURPOSE: GENERATE AND INSERT SAMPLE DATA
-- =====================================================

-- IMPORTANT:
-- Run create-tables.sql first.
-- Run this script ONCE on empty tables.

-- 1. INSERT DEPARTMENTS
INSERT INTO departments
(department_code, department_name, faculty_name)
VALUES
('CSC', 'Computer Science', 'Faculty of Computing'),
('IT', 'Information Technology', 'Faculty of Computing'),
('PHY', 'Physics', 'Faculty of Science'),
('BUS', 'Business Administration', 'Faculty of Management'),
('ACC', 'Accounting', 'Faculty of Management');


-- 2. INSERT LECTURERS
INSERT INTO lecturers
(staff_number, first_name, last_name, email,
 phone_number, department_id)
VALUES
('LEC001', 'John', 'Adekunle', 'john.ade@university.edu', '08030000001', 1),
('LEC002', 'Mary', 'Okafor', 'mary.oka@university.edu', '08030000002', 2),
('LEC003', 'David', 'Bello', 'david.bel@university.edu', '08030000003', 3),
('LEC004', 'Grace', 'James', 'grace.jam@university.edu', '08030000004', 4),
('LEC005', 'Peter', 'Musa', 'peter.mus@university.edu', '08030000005', 5),
('LEC006', 'Sarah', 'Ibrahim', 'sarah.ibr@university.edu', '08030000006', 1),
('LEC007', 'Daniel', 'Eze', 'daniel.eze@university.edu', '08030000007', 2),
('LEC008', 'Esther', 'Yusuf', 'esther.yus@university.edu', '08030000008', 3),
('LEC009', 'Michael', 'Aina', 'michael.ain@university.edu', '08030000009', 4),
('LEC010', 'Ruth', 'Ojo', 'ruth.ojo@university.edu', '08030000010', 5);


-- 3. INSERT COURSES
INSERT INTO courses
(course_code, course_title, credit_unit, department_id)
VALUES
('CSC101', 'Introduction to Computing', 3, 1),
('CSC201', 'Database Management Systems', 3, 1),
('IT101', 'Fundamentals of Information Technology', 3, 2),
('IT201', 'Network Administration', 3, 2),
('PHY101', 'General Physics', 2, 3),
('PHY201', 'Electronics', 3, 3),
('BUS101', 'Principles of Management', 2, 4),
('BUS201', 'Business Communication', 2, 4),
('ACC101', 'Financial Accounting', 3, 5),
('ACC201', 'Management Accounting', 3, 5);


-- 4. INSERT SEMESTERS
INSERT INTO semesters
(academic_year, semester_name, start_date, end_date)
VALUES
('2025/2026', 'First Semester', '2025-09-01', '2025-12-20'),
('2025/2026', 'Second Semester', '2026-01-12', '2026-05-30');


-- 5. INSERT COURSE OFFERINGS
INSERT INTO course_offerings
(course_id, semester_id, lecturer_id, offering_code, capacity)
VALUES
(1, 1, 1, 'CSC101-2025-FS', 300),
(2, 1, 6, 'CSC201-2025-FS', 300),
(3, 1, 2, 'IT101-2025-FS', 300),
(4, 1, 7, 'IT201-2025-FS', 300),
(5, 1, 3, 'PHY101-2025-FS', 300),
(6, 2, 8, 'PHY201-2025-SS', 300),
(7, 2, 4, 'BUS101-2025-SS', 300),
(8, 2, 9, 'BUS201-2025-SS', 300),
(9, 2, 5, 'ACC101-2025-SS', 300),
(10, 2, 10, 'ACC201-2025-SS', 300);


-- 6. GENERATE 1,000 STUDENT RECORDS
INSERT INTO students
(registration_number, first_name, last_name, email,
 phone_number, date_of_birth, gender, admission_date, department_id)
SELECT
    'MIVA' || LPAD(n::TEXT, 5, '0'),
    'Student' || n,
    'Surname' || n,
    'student' || n || '@example.com',
    '080' || LPAD(n::TEXT, 8, '0'),
    DATE '2000-01-01' + (n % 2000),
    CASE
        WHEN n % 2 = 0 THEN 'Female'
        ELSE 'Male'
    END,
    DATE '2025-09-01',
    ((n - 1) % 5) + 1
FROM generate_series(1, 1000) AS n;


-- 7. GENERATE 5,000 ENROLLMENT RECORDS
INSERT INTO enrollments
(student_id, offering_id, enrollment_date, enrollment_status)
SELECT
    s.student_id,
    ((s.student_id + g.n - 2) % 10) + 1,
    DATE '2025-09-01',
    'Enrolled'
FROM students s
CROSS JOIN generate_series(1, 5) AS g(n);


-- 8. GENERATE 5,000 STUDENT RESULTS
INSERT INTO results
(enrollment_id, ca_score, examination_score,
 total_score, grade, remarks)
SELECT
    enrollment_id,

    ((enrollment_id * 7) % 41)::NUMERIC(5,2),

    ((enrollment_id * 11) % 61)::NUMERIC(5,2),

    (
        ((enrollment_id * 7) % 41) +
        ((enrollment_id * 11) % 61)
    )::NUMERIC(5,2),

    CASE
        WHEN (((enrollment_id * 7) % 41) +
              ((enrollment_id * 11) % 61)) >= 70 THEN 'A'

        WHEN (((enrollment_id * 7) % 41) +
              ((enrollment_id * 11) % 61)) >= 60 THEN 'B'

        WHEN (((enrollment_id * 7) % 41) +
              ((enrollment_id * 11) % 61)) >= 50 THEN 'C'

        WHEN (((enrollment_id * 7) % 41) +
              ((enrollment_id * 11) % 61)) >= 45 THEN 'D'

        ELSE 'F'
    END,

    'Generated test result'

FROM enrollments;


-- 9. VERIFY INSERTED RECORDS
SELECT 'Departments' AS table_name, COUNT(*) AS total_records FROM departments
UNION ALL
SELECT 'Lecturers', COUNT(*) FROM lecturers
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Semesters', COUNT(*) FROM semesters
UNION ALL
SELECT 'Course Offerings', COUNT(*) FROM course_offerings
UNION ALL
SELECT 'Students', COUNT(*) FROM students
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM enrollments
UNION ALL
SELECT 'Results', COUNT(*) FROM results;
