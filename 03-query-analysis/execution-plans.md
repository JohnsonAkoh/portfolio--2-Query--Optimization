# Query Execution Plan Analysis

## Experiment 1: Student Department Search

### Objective
Analyse the performance of a query retrieving students belonging to a specific department.

### Original SQL Query
```sql
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
```

### Execution Results

| Performance Metric | Result |
|---|---:|
| Planning Time | 0.950 ms |
| Execution Time | 0.275 ms |
| Rows Returned | 200 |
| Rows Removed by Filter | 800 |
| Student Table Scan | Sequential Scan |
| Department Table Scan | Index Scan |

### Analysis
PostgreSQL used the primary-key index on the departments table to locate the Information Technology department.

However, it performed a sequential scan on the students table, examining all 1,000 student records and returning 200 matching records.

This indicates an opportunity to investigate whether creating an index on the `department_id` column in the students table improves query performance.

### Conclusion
The original query executed successfully with an execution time of 0.275 milliseconds. This measurement will serve as the baseline for comparison after optimization.
