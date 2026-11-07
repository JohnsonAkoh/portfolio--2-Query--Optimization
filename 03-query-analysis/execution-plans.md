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
### Experiment 2: Post-Index Performance Analysis

**Index created:** `idx_enrollments_offering_id`

**Indexed column:** `enrollments.offering_id`

After creating the index and running `ANALYZE enrollments`, the original Course Results Analysis query was executed again using `EXPLAIN ANALYZE`.

**Post-index execution results:**
- Execution Time: 3.968 ms
- Planning Time: 10.314 ms
- Rows returned: 500
- Enrollments scan method: Sequential Scan
- Join method: Hash Join

**Comparison with baseline:**

| Metric | Before Index | After Index |
|---|---:|---:|
| Execution Time | 3.940 ms | 3.968 ms |
| Planning Time | 3.248 ms | 10.314 ms |
| Rows Returned | 500 | 500 |
| Enrollments Scan | Sequential Scan | Sequential Scan |

**Analysis:**

The execution time increased slightly from 3.940 ms to 3.968 ms, a difference of approximately 0.71%.

The execution plan shows that PostgreSQL continued using a sequential scan on the enrollments table rather than the newly created index. It used a Hash Join to connect enrollments with course offerings.

This is a reasonable optimizer decision because the query processes 500 matching enrollment records from a table containing 5,000 records. A sequential scan may be more efficient than retrieving many records through an index.

The planning time also increased, but planning time can fluctuate between executions and should not be interpreted as evidence that the index caused slower query execution.

**Conclusion:**

The index was successfully created, but PostgreSQL did not select it for this query. The experiment demonstrates that index effectiveness depends on query structure, table size, data distribution, and the optimizer's cost estimates.
### Experiment 3: Post-Index Performance Analysis

**Indexes previously created:**
- `idx_students_department_id`
- `idx_enrollments_offering_id`

The Department-Level Academic Performance query was executed again using `EXPLAIN ANALYZE`.

**Post-index execution results:**
- Execution Time: 19.449 ms
- Planning Time: 6.352 ms
- Rows returned: 10
- Records processed: 5,000
- Main operations: Hash Join, Sort and GroupAggregate

**Comparison with baseline:**

| Metric | Before Indexing | After Indexing |
|---|---:|---:|
| Execution Time | 25.721 ms | 19.449 ms |
| Planning Time | 3.398 ms | 6.352 ms |
| Rows Returned | 10 | 10 |
| Records Processed | 5,000 | 5,000 |

**Analysis:**

The execution time decreased from 25.721 ms to 19.449 ms, representing an observed reduction of approximately 24.4%.

However, the execution plan does not show either of the newly created indexes being used. PostgreSQL continued using sequential scans and Hash Join operations to process the records.

The query also performed a sorting operation on 5,000 records before executing GroupAggregate to produce the 10 department/course summary rows.

The observed performance reduction cannot therefore be attributed directly to the newly created indexes. Execution variability, caching and other database conditions may influence the difference.

**Conclusion:**

The query executed successfully with a lower observed execution time. However, the execution plan indicates that sorting, joining and aggregation remain important operations. Further testing is required before concluding that a particular optimization caused the improvement.
Experiment 2: Course Performance and Student Results Analysis
Objective
Evaluate the performance of a multi-table SQL query retrieving student examination results for a specific course.

Original SQL Query
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
Execution Results
Performance Metric	Result
Planning Time	3.248 ms
Execution Time	3.940 ms
Rows Returned	500
Shared Buffer Hits	3,043
Join Strategy	Nested Loop and Hash Join
Sorting Method	Quicksort
Execution Plan Analysis
PostgreSQL used the unique index on courses.course_code to locate IT101.
A sequential scan was performed on the enrollments table, examining 5,000 records.
A sequential scan was performed on course_offerings, examining 10 records.
Index scans were used on students and results to retrieve matching records.
PostgreSQL used quicksort to arrange the final 500 records by student registration number.
Optimization Opportunities
The sequential scan on enrollments presents an opportunity to investigate an index on offering_id.

The execution plan also estimated 26 rows at the top level but returned 500 rows. This difference indicates a cardinality estimation error worth investigating during optimization.

Conclusion
The original query returned 500 records with an execution time of 3.940 milliseconds. Its execution plan revealed opportunities to investigate indexing and query-planner statistics. These findings will serve as the baseline for subsequent optimization experiments.
