# Query Execution Plan Analysis

## 1. Introduction

This document presents the baseline and post-index execution plan analysis for three SQL queries developed for the Student Management System case study.

The analysis uses PostgreSQL `EXPLAIN ANALYZE` to examine query execution strategies, execution time, planning time, table scans, join methods and opportunities for performance improvement.

The experiments investigate:

1. Student Department Search
2. Course Performance and Student Results Analysis
3. Department-Level Academic Performance

---

## 2. Experiment 1: Student Department Search

### 2.1 Objective

Analyse the performance of a query retrieving students belonging to a specific department.

### 2.2 Original SQL Query

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

### 2.3 Baseline Execution Results

| Performance Metric | Result |
|---|---:|
| Planning Time | 0.950 ms |
| Execution Time | 0.275 ms |
| Rows Returned | 200 |
| Rows Removed by Filter | 800 |
| Students Table Scan | Sequential Scan |
| Departments Table Scan | Index Scan |

### 2.4 Baseline Analysis

PostgreSQL used the primary-key index on the departments table to locate the Information Technology department.

However, it performed a sequential scan on the students table, examining 1,000 student records and returning 200 matching records.

This indicated an opportunity to investigate whether an index on `students.department_id` could improve query performance.

### 2.5 Indexing and Post-Index Analysis

Index created:

```sql
CREATE INDEX idx_students_department_id
ON students(department_id);

ANALYZE students;
```

Post-index execution results:

| Performance Metric | Result |
|---|---:|
| Planning Time | 1.008 ms |
| Execution Time | 0.225 ms |
| Rows Returned | 200 |
| Students Table Scan | Sequential Scan |

### 2.6 Performance Comparison

| Metric | Before Index | After Index |
|---|---:|---:|
| Execution Time | 0.275 ms | 0.225 ms |
| Scan Method | Sequential Scan | Sequential Scan |

The observed execution time decreased by approximately 18.2%.

However, PostgreSQL continued using a sequential scan rather than the newly created index. The timing difference does not establish that the index caused the improvement. Cache effects and execution variability may influence the measurements.

### 2.7 Conclusion

The index was created successfully, but PostgreSQL did not select it for this query. This demonstrates that creating an index does not guarantee its use. The query planner selects an execution strategy based on estimated cost and data characteristics.

---

## 3. Experiment 2: Course Performance and Student Results Analysis

### 3.1 Objective

Evaluate the performance of a multi-table SQL query retrieving student examination results for a specific course.

### 3.2 Original SQL Query

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

### 3.3 Baseline Execution Results

| Performance Metric | Result |
|---|---:|
| Planning Time | 3.248 ms |
| Execution Time | 3.940 ms |
| Rows Returned | 500 |
| Shared Buffer Hits | 3,043 |
| Join Strategy | Nested Loop and Hash Join |
| Sorting Method | Quicksort |

### 3.4 Baseline Analysis

PostgreSQL used the unique index on `courses.course_code` to locate the course with code `IT101`.

A sequential scan was performed on the enrollments table, examining 5,000 records. A sequential scan was also performed on the course_offerings table, examining 10 records.

Index scans were used on the students and results tables to retrieve matching records.

PostgreSQL used the quicksort method to arrange the final 500 records by student registration number.

The sequential scan on enrollments presented an opportunity to investigate indexing on the `offering_id` column.

The execution plan also estimated 26 rows at the top level but returned 500 rows, indicating a difference between estimated and actual cardinality.

### 3.5 Indexing and Post-Index Analysis

Index created:

```sql
CREATE INDEX IF NOT EXISTS idx_enrollments_offering_id
ON enrollments(offering_id);

ANALYZE enrollments;
```

Post-index execution results:

| Performance Metric | Result |
|---|---:|
| Planning Time | 10.314 ms |
| Execution Time | 3.968 ms |
| Rows Returned | 500 |
| Enrollments Scan | Sequential Scan |
| Join Method | Hash Join |

### 3.6 Performance Comparison

| Metric | Before Index | After Index |
|---|---:|---:|
| Execution Time | 3.940 ms | 3.968 ms |
| Planning Time | 3.248 ms | 10.314 ms |
| Rows Returned | 500 | 500 |
| Enrollments Scan | Sequential Scan | Sequential Scan |

The execution time increased slightly by approximately 0.71%.

PostgreSQL continued using a sequential scan on enrollments instead of the newly created index.

The planning time also increased, but planning-time variation should not be interpreted as evidence that the index caused slower query execution.

### 3.7 Conclusion

The index was successfully created, but PostgreSQL did not select it for this query. This experiment demonstrates that index effectiveness depends on query structure, table size, data distribution and the optimizer's cost estimates.

---

## 4. Experiment 3: Department-Level Academic Performance

### 4.1 Objective

Analyse academic performance across departments and courses by calculating student participation, average scores and the number of students achieving grade A.

### 4.2 Original SQL Query

```sql
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
```

### 4.3 Baseline Execution Results

| Performance Metric | Result |
|---|---:|
| Planning Time | 3.398 ms |
| Execution Time | 25.721 ms |
| Rows Returned | 10 |
| Records Processed | 5,000 |
| Main Operations | Hash Join, Sort and GroupAggregate |

### 4.4 Baseline Analysis

PostgreSQL performed sequential scans on the results and enrollments tables, processing 5,000 records from each.

It also scanned the smaller dimension tables, including departments, courses and course_offerings.

The execution plan used Hash Join operations to combine the tables, followed by sorting and GroupAggregate operations to produce the departmental course-performance summaries.

The sorting and aggregation operations represented important areas to monitor during performance analysis.

### 4.5 Indexing and Post-Index Analysis

The following indexes had already been created:

```sql
CREATE INDEX idx_students_department_id
ON students(department_id);

CREATE INDEX IF NOT EXISTS idx_enrollments_offering_id
ON enrollments(offering_id);
```

The department-level academic performance query was executed again using `EXPLAIN ANALYZE`.

Post-index execution results:

| Performance Metric | Result |
|---|---:|
| Planning Time | 6.352 ms |
| Execution Time | 19.449 ms |
| Rows Returned | 10 |
| Records Processed | 5,000 |
| Main Operations | Hash Join, Sort and GroupAggregate |

### 4.6 Performance Comparison

| Metric | Before Indexing | After Indexing |
|---|---:|---:|
| Execution Time | 25.721 ms | 19.449 ms |
| Planning Time | 3.398 ms | 6.352 ms |
| Rows Returned | 10 | 10 |
| Records Processed | 5,000 | 5,000 |

The observed execution time decreased by approximately 24.4%.

However, the execution plan did not show either newly created index being used. PostgreSQL continued using sequential scans and Hash Join operations.

The observed performance reduction therefore cannot be attributed directly to the indexes. Execution variability, caching and other database conditions may influence the difference.

### 4.7 Conclusion

The query executed successfully with a lower observed execution time. However, the execution plan indicates that sorting, joining and aggregation remain important operations.

Further testing with larger datasets and repeated executions would provide stronger evidence before concluding that a particular optimization caused the improvement.

---

## 5. Overall Findings

The three experiments demonstrate that PostgreSQL's query planner selects execution strategies based on estimated costs, table sizes, data distribution and query structure.

The indexing experiments produced the following observations:

1. The student department index was created successfully but was not selected by PostgreSQL.
2. The enrollment offering index was created successfully but was not selected for the course results query.
3. The department-level performance query showed a lower observed execution time, but the execution plan did not demonstrate the use of either newly created index.

These findings demonstrate that indexing alone does not guarantee improved query performance.

## 6. General Recommendation

For improved query performance in larger student management databases, the following practices are recommended:

- Analyse execution plans before creating indexes.
- Create indexes based on frequently used filtering and joining columns.
- Use `ANALYZE` to maintain current table statistics.
- Compare actual execution plans before and after optimization.
- Test with larger and representative datasets.
- Avoid creating unnecessary indexes because they introduce storage and maintenance overhead.

## 7. Conclusion

The execution-plan analysis provided practical insight into PostgreSQL query processing, including sequential scans, index scans, Hash Joins, Nested Loops, sorting and aggregation.

The experiments also demonstrated the importance of evidence-based query optimization. Rather than assuming that an index improves performance, database administrators should examine the actual execution plan and evaluate performance measurements before drawing conclusions.
