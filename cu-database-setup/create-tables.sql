-- MIVA MIT Portfolio 2
-- Project: Query Optimization
-- Database: Student Management System
-- DBMS: PostgreSQL

-- 1. Departments
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_code VARCHAR(20) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    faculty_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Students
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    registration_number VARCHAR(30) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20),
    admission_date DATE NOT NULL,
    department_id INTEGER NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- 3. Lecturers
CREATE TABLE lecturers (
    lecturer_id SERIAL PRIMARY KEY,
    staff_number VARCHAR(30) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    department_id INTEGER NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- 4. Courses
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_title VARCHAR(150) NOT NULL,
    credit_unit INTEGER NOT NULL CHECK (credit_unit > 0),
    department_id INTEGER NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- 5. Semesters
CREATE TABLE semesters (
    semester_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(20) NOT NULL,
    semester_name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    UNIQUE (academic_year, semester_name),
    CHECK (end_date > start_date)
);

-- 6. Course Offerings
CREATE TABLE course_offerings (
    offering_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id),
    semester_id INTEGER NOT NULL REFERENCES semesters(semester_id),
    lecturer_id INTEGER NOT NULL REFERENCES lecturers(lecturer_id),
    offering_code VARCHAR(30) UNIQUE NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0)
);

-- 7. Enrollments
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(student_id),
    offering_id INTEGER NOT NULL REFERENCES course_offerings(offering_id),
    enrollment_date DATE NOT NULL,
    enrollment_status VARCHAR(20) NOT NULL DEFAULT 'Enrolled',
    UNIQUE (student_id, offering_id)
);

-- 8. Results
CREATE TABLE results (
    result_id SERIAL PRIMARY KEY,
    enrollment_id INTEGER UNIQUE NOT NULL
        REFERENCES enrollments(enrollment_id),
    ca_score NUMERIC(5,2) NOT NULL
        CHECK (ca_score BETWEEN 0 AND 40),
    examination_score NUMERIC(5,2) NOT NULL
        CHECK (examination_score BETWEEN 0 AND 60),
    total_score NUMERIC(5,2) NOT NULL
        CHECK (total_score BETWEEN 0 AND 100),
    grade VARCHAR(2) NOT NULL,
    remarks VARCHAR(50),
    CHECK (total_score = ca_score + examination_score)
);
