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
### Experiment 1: Post-Index Performance Analysis

**Index created:** `idx_students_department_id`

**Indexed column:** `students.department_id`

After creating the index and running `ANALYZE students`, the original query was executed again using `EXPLAIN ANALYZE`.

**Post-index execution results:**
- Execution Time: 0.225 ms
- Planning Time: 1.008 ms
- Rows returned: 200
- Rows removed by filter: 800
- Scan method: Sequential Scan on students

**Comparison with baseline:**

| Metric | Before Index | After Index |
|---|---:|---:|
| Execution Time | 0.275 ms | 0.225 ms |
| Scan Method | Sequential Scan | Sequential Scan |

**Analysis:**

The execution time decreased from 0.275 ms to 0.225 ms, representing an observed reduction of approximately 18.2%.

However, PostgreSQL continued using a sequential scan instead of the newly created index. This is reasonable because the students table contains only 1,000 records, making a sequential scan potentially more efficient than an index scan.

The observed timing difference does not establish that the index caused the improvement. Further testing with larger datasets and repeated executions would provide stronger evidence.

**Conclusion:**

The index was created successfully, but PostgreSQL's query planner did not select it for this query. This experiment demonstrates that creating an index does not guarantee its use; PostgreSQL chooses an execution strategy based on estimated cost.
