-- 1. Hitung Median Skor STO dari seluruh populasi
WITH MedianSTO AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY score) AS median_sto_value,
        (SELECT MAX(year) FROM competencies_yearly) AS current_year
    FROM 
        competencies_yearly
    WHERE 
        score IS NOT NULL 
        AND pillar_code = 'STO'
)
-- 2. Sisipkan baris baru (Median STO) untuk karyawan yang tidak memiliki data STO terbaru
INSERT INTO competencies_yearly (employee_id, pillar_code, year, score)
SELECT 
    e.employee_id, 
    'STO' AS pillar_code, 
    ms.current_year AS year, 
    ms.median_sto_value AS score
FROM 
    employees e
CROSS JOIN 
    MedianSTO ms
WHERE NOT EXISTS (
    -- Hanya sisipkan jika karyawan tersebut TIDAK memiliki skor STO di tahun terbaru
    SELECT 1 
    FROM competencies_yearly cy 
    WHERE cy.employee_id = e.employee_id 
    AND cy.pillar_code = 'STO' 
    AND cy.year = ms.current_year
);