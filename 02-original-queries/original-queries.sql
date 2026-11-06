-- EXPERIMENT 3:
-- Department-Level Academic Performance Analysis

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
