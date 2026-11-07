# Query Optimization Performance Comparison

## 1. Introduction

This report presents the performance comparison of three SQL queries developed for the Student Management System database.

The experiments were conducted using PostgreSQL and pgAdmin 4. The `EXPLAIN ANALYZE` command was used to examine query execution plans, execution times, planning times, scan methods and join operations.

Two indexes were introduced:

- `idx_students_department_id` on `students.department_id`.
- `idx_enrollments_offering_id` on `enrollments.offering_id`.

## 2. Performance Comparison

The following table presents the baseline and post-index execution times.

| Experiment | Baseline (ms) | Post-index (ms) | Observed change |
|---|---:|---:|---:|
| Student Department Search | 0.275 | 0.225 | 18.18% reduction |
| Course Results Analysis | 3.940 | 3.968 | 0.71% increase |
| Department Academic Performance | 25.721 | 19.449 | 24.39% reduction |

## 3. Analysis of Results

### Experiment 1: Student Department Search

The execution time decreased from 0.275 ms to 0.225 ms.

However, PostgreSQL continued using a sequential scan on the students table instead of the newly created index.

The result indicates that the observed timing improvement cannot be attributed directly to index usage.

### Experiment 2: Course Results Analysis

The execution time increased slightly from 3.940 ms to 3.968 ms.

PostgreSQL continued using a sequential scan on the enrollments table and a Hash Join operation.

The new index on `enrollments.offering_id` was not selected by the query planner.

This demonstrates that indexes do not automatically improve every query.

### Experiment 3: Department-Level Academic Performance

The execution time decreased from 25.721 ms to 19.449 ms.

The execution plan used Hash Join, Sort and GroupAggregate operations. Sequential scans remained present on the larger tables.

Neither of the newly created indexes appeared in the execution plan.

The observed reduction therefore cannot be attributed directly to the indexes.

## 4. Key Findings

1. PostgreSQL uses cost-based optimization to select execution plans.
2. Creating an index does not guarantee that PostgreSQL will use it.
3. Sequential scans can be efficient for relatively small tables or when a substantial proportion of records must be processed.
4. Hash Join operations can be suitable for joining tables containing multiple records.
5. Sorting and aggregation can contribute significantly to query execution time.
6. Execution times can vary due to caching, system load and other database conditions.

## 5. Limitations

The experiments were conducted using a relatively small dataset containing 1,000 students and 5,000 enrollments.

Each reported execution time represents an individual measurement rather than an average of multiple controlled runs.

Consequently, the observed timing differences should not be treated as definitive evidence that the newly created indexes caused performance improvements.

Further testing with larger datasets and repeated executions would provide stronger evidence.

## 6. Conclusion

The experiments demonstrated how PostgreSQL's `EXPLAIN ANALYZE` facility can be used to investigate query performance and execution plans.

The indexing exercises provided practical evidence that the effectiveness of an index depends on query structure, data distribution, table size and the optimizer's cost estimates.

The project also demonstrated the importance of examining execution plans rather than assuming that an indexing operation will automatically improve performance.
