-- MIVA Open University
-- Master of Information Technology
-- Portfolio 2: Query Optimization
-- Original Queries Re-executed After Indexing
-- Purpose: Evaluate query execution plans after index creation.

-- =====================================================
-- QUERY 1: STUDENT DEPARTMENT SEARCH
-- =====================================================

EXPLAIN ANALYZE
SELECT
    s.student_id,
    s.registration_number,
    s.first_name,
    s.last_name,
    d.department_name
FROM students s
JOIN departments d
    ON s.department_id = d.department_id
WHERE s.department_id = 2;


-- =====================================================
-- QUERY 2: COURSE RESULTS ANALYSIS
-- =====================================================

EXPLAIN ANALYZE
SELECT
    s.registration_number,
    s.first_name,
    s.last_name,
    c.course_code,
    c.course_title,
    r.ca_score,
    r.examination_score,
    r.total_score,
    r.grade
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
JOIN course_offerings co
    ON e.offering_id = co.offering_id
JOIN courses c
    ON co.course_id = c.course_id
JOIN results r
    ON e.enrollment_id = r.enrollment_id
WHERE c.course_code = 'IT101'
ORDER BY s.registration_number;


-- =====================================================
-- QUERY 3: DEPARTMENT-LEVEL ACADEMIC PERFORMANCE
-- =====================================================

EXPLAIN ANALYZE
SELECT
    d.department_name,
    c.course_code,
    c.course_title,
    COUNT(DISTINCT e.student_id) AS total_students,
    ROUND(AVG(r.total_score), 2) AS average_score,
    COUNT(*) FILTER (
        WHERE r.grade = 'A'
    ) AS students_with_grade_A
FROM departments d
JOIN courses c
    ON d.department_id = c.department_id
JOIN course_offerings co
    ON c.course_id = co.course_id
JOIN enrollments e
    ON co.offering_id = e.offering_id
JOIN results r
    ON e.enrollment_id = r.enrollment_id
GROUP BY
    d.department_name,
    c.course_code,
    c.course_title
ORDER BY
    d.department_name,
    c.course_code;
