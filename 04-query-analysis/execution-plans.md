## Experiment 2: Course Performance and Student Results Analysis

### Objective
Evaluate the performance of a multi-table SQL query retrieving student examination results for a specific course.

### Original SQL Query
```sql
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
```

### Execution Results

| Performance Metric | Result |
|---|---:|
| Planning Time | 3.248 ms |
| Execution Time | 3.940 ms |
| Rows Returned | 500 |
| Shared Buffer Hits | 3,043 |
| Join Strategy | Nested Loop and Hash Join |
| Sorting Method | Quicksort |

### Execution Plan Analysis

1. PostgreSQL used the unique index on `courses.course_code` to locate IT101.
2. A sequential scan was performed on the enrollments table, examining 5,000 records.
3. A sequential scan was performed on course_offerings, examining 10 records.
4. Index scans were used on students and results to retrieve matching records.
5. PostgreSQL used quicksort to arrange the final 500 records by student registration number.

### Optimization Opportunities

The sequential scan on enrollments presents an opportunity to investigate an index on `offering_id`.

The execution plan also estimated 26 rows at the top level but returned 500 rows. This difference indicates a cardinality estimation error worth investigating during optimization.

### Conclusion

The original query returned 500 records with an execution time of 3.940 milliseconds. Its execution plan revealed opportunities to investigate indexing and query-planner statistics. These findings will serve as the baseline for subsequent optimization experiments.
