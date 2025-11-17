-- buat tabel summary
CREATE TABLE summary_insights (
    variable TEXT,
    category TEXT,
    avg_high NUMERIC,
    avg_non_high NUMERIC,
    difference NUMERIC
);

-- Competency
INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    c.pillar_code AS variable,
    'competency' AS category,
    AVG(CASE WHEN p.rating = 5 THEN c.score END),
    AVG(CASE WHEN p.rating < 5 THEN c.score END),
    AVG(CASE WHEN p.rating = 5 THEN c.score END) -
    AVG(CASE WHEN p.rating < 5 THEN c.score END)
FROM competencies_yearly c
JOIN performance_yearly p USING (employee_id, year)
GROUP BY c.pillar_code;

-- Psychometric
-- Papi
INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    ps.scale_code,
    'psychometric_papi',
    AVG(CASE WHEN p.rating = 5 THEN ps.score END),
    AVG(CASE WHEN p.rating < 5 THEN ps.score END),
    AVG(CASE WHEN p.rating = 5 THEN ps.score END) -
    AVG(CASE WHEN p.rating < 5 THEN ps.score END)
FROM papi_scores ps
JOIN performance_yearly p USING (employee_id)
GROUP BY ps.scale_code;

-- Profiles psych (IQ, gtq, disc, mbti)
INSERT INTO summary_insights
SELECT
    'iq', 'psychometric_profiles',
    AVG(CASE WHEN p.rating = 5 THEN psych.iq END),
    AVG(CASE WHEN p.rating < 5 THEN psych.iq END),
    AVG(CASE WHEN p.rating = 5 THEN psych.iq END) -
    AVG(CASE WHEN p.rating < 5 THEN psych.iq END)
FROM profiles_psych psych
JOIN performance_yearly p USING(employee_id);

INSERT INTO summary_insights
SELECT
    'gtq', 'psychometric_profiles',
    AVG(CASE WHEN p.rating = 5 THEN psych.gtq END),
    AVG(CASE WHEN p.rating < 5 THEN psych.gtq END),
    AVG(CASE WHEN p.rating = 5 THEN psych.gtq END) -
    AVG(CASE WHEN p.rating < 5 THEN psych.gtq END)
FROM profiles_psych psych
JOIN performance_yearly p USING(employee_id);

INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    LOWER(TRIM(ps.disc)) AS variable,
    'psychometric_disc',
    COUNT(*) FILTER (WHERE p.rating = 5)::NUMERIC,
    COUNT(*) FILTER (WHERE p.rating < 5)::NUMERIC,
    (COUNT(*) FILTER (WHERE p.rating = 5) - 
     COUNT(*) FILTER (WHERE p.rating < 5))::NUMERIC
FROM profiles_psych ps
JOIN performance_yearly p USING(employee_id)
GROUP BY LOWER(TRIM(ps.disc));

INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    'mbti_' || UPPER(REPLACE(ps.mbti, ' ', '')) AS variable,
    'psychometric_mbti',
    COUNT(*) FILTER (WHERE p.rating = 5)::NUMERIC,
    COUNT(*) FILTER (WHERE p.rating < 5)::NUMERIC,
    (COUNT(*) FILTER (WHERE p.rating = 5) -
     COUNT(*) FILTER (WHERE p.rating < 5))::NUMERIC
FROM profiles_psych ps
JOIN performance_yearly p USING(employee_id)
WHERE ps.mbti IS NOT NULL
GROUP BY UPPER(REPLACE(ps.mbti, ' ', ''));

-- Behavioural data (years, grade, education)
INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    s.theme AS variable,
    'behavior_strength',
    COUNT(*) FILTER (WHERE p.rating = 5 AND s.rank = 1)::NUMERIC,
    COUNT(*) FILTER (WHERE p.rating < 5 AND s.rank = 1)::NUMERIC,
    (COUNT(*) FILTER (WHERE p.rating = 5 AND s.rank = 1) -
     COUNT(*) FILTER (WHERE p.rating < 5 AND s.rank = 1))::NUMERIC
FROM strengths s
JOIN performance_yearly p USING(employee_id)
GROUP BY s.theme;

INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    'grade_' || g.name AS variable,
    'contextual_grade' AS category,
    COUNT(*) FILTER (WHERE p.rating = 5)::NUMERIC AS high_count,
    COUNT(*) FILTER (WHERE p.rating < 5)::NUMERIC AS non_high_count,
    (COUNT(*) FILTER (WHERE p.rating = 5) - 
     COUNT(*) FILTER (WHERE p.rating < 5))::NUMERIC AS difference
FROM employees e
JOIN dim_grades g ON e.grade_id = g.grade_id
JOIN performance_yearly p USING(employee_id)
GROUP BY g.name;

INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT
    'education_' || edu.name AS variable,
    'contextual_education' AS category,
    COUNT(*) FILTER (WHERE p.rating = 5)::NUMERIC AS high_count,
    COUNT(*) FILTER (WHERE p.rating < 5)::NUMERIC AS non_high_count,
    (COUNT(*) FILTER (WHERE p.rating = 5) - 
     COUNT(*) FILTER (WHERE p.rating < 5))::NUMERIC AS difference
FROM employees e
JOIN dim_education edu ON e.education_id = edu.education_id
JOIN performance_yearly p USING(employee_id)
GROUP BY edu.name
ORDER BY edu.name;

-- Filtering
-- by category
SELECT *
FROM summary_insights
WHERE difference > 0;

SELECT DISTINCT ON (category)
    category, variable, avg_high, avg_non_high, difference
FROM summary_insights
WHERE difference > 0
ORDER BY category, difference DESC;

--by difference
SELECT *
FROM summary_insights
WHERE difference > 0
ORDER BY difference DESC
LIMIT 10;
-- liat kepanjangan variable
SELECT 
    s.variable AS pillar_code,
    d.pillar_label AS pillar_name,
    s.avg_high,
    s.avg_non_high,
    s.difference
FROM summary_insights s
JOIN dim_competency_pillars d
    ON s.variable = d.pillar_code
WHERE s.variable IN ('SEA','QDD','LIE','VCU','CEX','FTC','STO','CSI','IDS','GDR')
ORDER BY s.difference DESC;

-- buat ulang competency
WITH new_competency AS (
    SELECT
        cy.pillar_code AS variable,
        'competency' AS category,
        AVG(CASE WHEN py.rating = 5 THEN cy.score END) AS avg_high,
        AVG(CASE WHEN py.rating <> 5 THEN cy.score END) AS avg_non_high,
        AVG(CASE WHEN py.rating = 5 THEN cy.score END)
          - AVG(CASE WHEN py.rating <> 5 THEN cy.score END) AS difference
    FROM competencies_yearly cy
    JOIN performance_yearly py USING (employee_id)
    GROUP BY cy.pillar_code
)
SELECT * FROM new_competency ORDER BY difference DESC;

-- hapus yang lama
DELETE FROM summary_insights
WHERE category = 'competency';

-- tambahkan yang baru ke tabel summary
INSERT INTO summary_insights (variable, category, avg_high, avg_non_high, difference)
SELECT * FROM (
    SELECT
        cy.pillar_code AS variable,
        'competency' AS category,
        AVG(CASE WHEN py.rating = 5 THEN cy.score END) AS avg_high,
        AVG(CASE WHEN py.rating <> 5 THEN cy.score END) AS avg_non_high,
        AVG(CASE WHEN py.rating = 5 THEN cy.score END)
          - AVG(CASE WHEN py.rating <> 5 THEN cy.score END) AS difference
    FROM competencies_yearly cy
    JOIN performance_yearly py USING (employee_id)
    GROUP BY cy.pillar_code
) sub;