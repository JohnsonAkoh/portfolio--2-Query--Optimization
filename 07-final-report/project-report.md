# MIVA Open University
# Master of Information Technology

## Portfolio 2: Query Optimization

**Case Study:** Student Management System

**Database Management System:** PostgreSQL

**Database Administration Tool:** pgAdmin 4

**Student:** Johnson Abraham Akoh

---

## 1. Introduction

Database query optimization is an important aspect of database management. It involves analysing 
SQL queries and improving their execution efficiency to reduce processing time and resource consumption.

This project investigates query optimization techniques using a Student Management System database
implemented in PostgreSQL.

The project examines three SQL queries, evaluates their execution plans using `EXPLAIN ANALYZE`, introduces 
selected database indexes and compares query performance before and after indexing.

## 2. Project Objectives

The objectives of this project are to:

1. Design and implement a relational database for a Student Management System.
2. Populate the database with representative academic records.
3. Develop SQL queries involving filtering, multiple-table joins, sorting and aggregation.
4. Analyse query execution plans using PostgreSQL.
5. Identify potential indexing opportunities.
6. Evaluate the effects of indexing on query execution.
7. Document performance findings and optimization recommendations.

## 3. Database Environment

The project was implemented using PostgreSQL and pgAdmin 4.

The database name is `portfolio2_query_optimization`.

The database contains eight relational tables:

| Table | Description |
|---|---|
| departments | Academic departments |
| students | Student information |
| lecturers | Lecturer information |
| courses | Academic courses |
| semesters | Academic semesters |
| course_offerings | Courses offered in specific semesters |
| enrollments | Student course registrations |
| results | Students' academic results |

### 3.1 Dataset Summary

The database was populated with the following records:

| Table | Number of Records |
|---|---:|
| departments | 5 |
| lecturers | 10 |
| courses | 10 |
| semesters | 2 |
| course_offerings | 10 |
| students | 1,000 |
| enrollments | 5,000 |
| results | 5,000 |
| **Total** | **11,037** |

## 4. Methodology

The project followed these stages:

1. Database creation and table implementation.
2. Data insertion and verification.
3. Development of original SQL queries.
4. Baseline query performance analysis.
5. Identification of potential indexing opportunities.
6. Index creation and database statistics updates.
7. Re-execution of queries using `EXPLAIN ANALYZE`.
8. Performance comparison and documentation.

The PostgreSQL `EXPLAIN ANALYZE` command was used to examine actual 
execution time, planning time, scan methods, join operations, sorting and aggregation.

## 5. Original SQL Query Experiments

Three SQL queries were selected for the optimization experiments.

### 5.1 Experiment 1: Student Department Search

This query retrieves student information and department names
for students belonging to department ID 2.

The query uses an inner join between the students and departments tables 
and filters records using `department_id`.

**Baseline execution time:** 0.275 ms.

### 5.2 Experiment 2: Course Results Analysis

This query retrieves students' academic results for course IT101.

It joins students, enrollments, course_offerings, courses and results.
The query also sorts the returned records by student registration number.

**Baseline execution time:** 3.940 ms.

### 5.3 Experiment 3: Department-Level Academic Performance

This query calculates academic performance indicators for each department and course.

It uses aggregate functions including:

- `COUNT(DISTINCT ...)`
- `AVG()`
- `COUNT(*) FILTER (WHERE ...)`

The results are grouped by department and course and sorted accordingly.

**Baseline execution time:** 25.721 ms.

## 6. Indexing and Optimization Activities

Two additional indexes were created during the experiments.

### 6.1 Students Department Index

```sql
CREATE INDEX idx_students_department_id
ON students(department_id);

ANALYZE students;
```

This index was introduced to investigate filtering performance on the students table.

### 6.2 Enrollments Offering Index

```sql
CREATE INDEX idx_enrollments_offering_id
ON enrollments(offering_id);

ANALYZE enrollments;
```

This index was introduced to investigate the join between enrollments and course offerings.

### 6.3 Index Usage Findings

Post-index execution plans showed that PostgreSQL continued using sequential 
scans on the students and enrollments tables for the tested queries.

The optimizer selected these execution strategies based on its estimated costs.

This demonstrates that creating an index does not necessarily mean that PostgreSQL will use it.

## 7. Performance Comparison

The following table presents the measured baseline and post-index execution times.

| Experiment | Baseline (ms) | Post-index (ms) |
|---|---:|---:|
| Student Department Search | 0.275 | 0.225 |
| Course Results Analysis | 3.940 | 3.968 |
| Department Academic Performance | 25.721 | 19.449 |

### 7.1 Interpretation

**Experiment 1:** An observed execution-time reduction of approximately 18.18% was recorded.
However, PostgreSQL continued using a sequential scan.

**Experiment 2:** Execution time increased slightly by approximately 0.71%.
The new enrollments index was not selected by the optimizer.

**Experiment 3:** An observed execution-time reduction of approximately 24.39% was recorded.
The execution plan continued using sequential scans, Hash Join, Sort and GroupAggregate operations.

The observed timing differences cannot be attributed directly to the newly created indexes 
because neither index appeared in the relevant execution plans.

## 8. Discussion of Findings

The experiments demonstrated several important database optimization principles.

### 8.1 Sequential Scans

Sequential scans can be efficient when tables are relatively small or when a query needs a
substantial proportion of the available records.

### 8.2 Indexing

Indexes can improve data retrieval when the query planner determines that indexed access is more efficient.
However, unnecessary indexes can increase storage requirements and database maintenance overhead.

### 8.3 Join Operations

PostgreSQL selected Hash Join operations for several multi-table queries. These operations were suitable 
for processing the relationships in the tested dataset.

### 8.4 Sorting and Aggregation

The department-level academic performance query required sorting and aggregation across 5,000 joined records. 
These operations contributed to its processing workload.

### 8.5 Query Execution Analysis

The project demonstrated the importance of using actual execution plans rather than assuming that a query
or index is efficient based solely on its SQL structure.

## 9. Limitations

The project was conducted using a relatively small dataset containing 1,000 students and 5,000 enrollments.

Each performance result represents an individual execution measurement rather than an average of repeated controlled tests.

Execution times can vary due to caching, system load and other database conditions.

Further experiments with larger datasets, repeated executions and controlled testing environments would provide stronger performance evidence.

## 10. Recommendations

Based on the findings, the following recommendations are proposed:

1. Conduct repeated performance tests to establish reliable average execution times.
2. Test database performance with larger datasets.
3. Monitor query execution plans when database records increase.
4. Create indexes based on actual query workloads and measured performance.
5. Avoid creating unnecessary indexes.
6. Maintain accurate database statistics using PostgreSQL's `ANALYZE` functionality.
7. Investigate sorting and aggregation costs when optimizing analytical queries.

## 11. Conclusion

This project successfully demonstrated practical SQL query performance analysis 
and indexing experiments using PostgreSQL.

Three SQL queries were developed and evaluated using `EXPLAIN ANALYZE`.
Two additional indexes were created to investigate their potential performance benefits.

The results showed that PostgreSQL's cost-based optimizer does not automatically select newly created indexes.
Sequential scans and Hash Join operations remained appropriate for several of the tested workloads.

The project strengthened practical understanding of SQL query execution, indexing, database statistics, 
join operations and performance evaluation.

Overall, the project achieved its primary objective of demonstrating how query optimization techniques
can be investigated, measured and documented in a relational database environment.

## 12. Project Repository

The complete SQL scripts, execution-plan analyses, indexing scripts, performance 
comparison and final report are maintained in the GitHub repository:

**Portfolio 2 – Query Optimization**

https://github.com/JohnsonAkoh/portfolio--2-Query--Optimization
