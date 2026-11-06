-- MIVA MIT Portfolio 2
-- Query Optimization
-- Experiment 1: Indexing students.department_id

-- Create an index on the department_id column
CREATE INDEX idx_students_department_id
ON students(department_id);

-- Update table statistics
ANALYZE students;

-- Experiment 2: Indexing enrollments.offering_id

-- Create an index on the offering_id column
CREATE INDEX IF NOT EXISTS idx_enrollments_offering_id
ON enrollments(offering_id);

-- Update table statistics
ANALYZE enrollments;
