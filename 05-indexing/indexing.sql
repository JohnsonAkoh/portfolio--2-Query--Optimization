-- MIVA MIT Portfolio 2
-- Query Optimization
-- Experiment 1: Indexing students.department_id

-- Create an index on the department_id column
CREATE INDEX idx_students_department_id
ON students(department_id);

-- Update table statistics
ANALYZE students;
