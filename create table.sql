CREATE TABLE talent_variable (
    tv_test_name TEXT,              
    tv_sub_test_name TEXT,          
    tv_meaning TEXT,
    behavior_example TEXT,
    tgv_name TEXT,                  
    note TEXT
);

CREATE TABLE dim_companies (company_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_areas (area_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_positions (position_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_departments (department_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_divisions (division_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_directorates (directorate_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_grades (grade_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_education (education_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_majors (major_id INT PRIMARY KEY, name TEXT);

CREATE TABLE dim_competency_pillars (pillar_code VARCHAR(3) PRIMARY KEY, pillar_label TEXT);

CREATE TABLE employees (
    employee_id TEXT PRIMARY KEY,
    fullname TEXT,
    nik_baru TEXT,
    company_id INT,
    area_id INT,
    position_id INT,
    department_id INT,
    division_id INT,
    directorate_id INT,
    grade_id INT,
    education_id INT,
    major_id INT,
    years_of_service_months INT
);

CREATE TABLE profiles_psych (
    employee_id TEXT PRIMARY KEY,
    pauli NUMERIC,
    faxtor NUMERIC,
    disc TEXT,
    first_char TEXT,
    second_char TEXT,
    first_word TEXT,
    second_word TEXT,
    disc_word TEXT,
    enneagram INT,
    mbti TEXT,
    iq NUMERIC,
    gtq1 INT, gtq2 INT, gtq3 INT, gtq4 INT, gtq5 INT,
    gtq_total INT,
    tiki1 INT, tiki2 INT, tiki3 INT, tiki4 INT
);

CREATE TABLE papi_scores (
    employee_id TEXT,
    scale_code TEXT,
    score INT,
    PRIMARY KEY (employee_id, scale_code)
);

CREATE TABLE strengths (
    employee_id TEXT,
    rank INT,
    theme TEXT,
    PRIMARY KEY (employee_id, rank)
);

CREATE TABLE performance_yearly (
    employee_id TEXT,
    year INT,
    rating INT,
    PRIMARY KEY (employee_id, year)
);

CREATE TABLE competencies_yearly (
    employee_id TEXT,
    pillar_code VARCHAR(3),
    year INT,
    score INT,
    PRIMARY KEY (employee_id, pillar_code, year)
);