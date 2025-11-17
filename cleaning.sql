-- Cleaning profiles psych
-- Hitung Median IQ dari seluruh populasi karyawan
WITH MedianIQ AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY iq) AS median_iq_value
    FROM 
        profiles_psych
    WHERE 
        iq IS NOT NULL
)
-- Perbarui tabel profiles_psych
UPDATE profiles_psych
SET iq = miq.median_iq_value
FROM MedianIQ miq
WHERE iq IS NULL;

-- Hitung Median GTQ dari seluruh populasi karyawan
WITH MedianGTQ AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gtq) AS median_gtq_value
    FROM 
        profiles_psych
    WHERE 
        gtq IS NOT NULL
)
-- Perbarui tabel profiles_psych, ganti NULL dengan Median
UPDATE profiles_psych
SET gtq = mgtq.median_gtq_value
FROM MedianGTQ mgtq
WHERE gtq IS NULL;

-- Pastikan kolom mbti juga bersih dari NULL jika digunakan untuk visualisasi
UPDATE profiles_psych
SET mbti = COALESCE(mbti, 'UNKNOWN')
WHERE mbti IS NULL;

-- first and second word
UPDATE profiles_psych
SET 
    -- Ambil kata pertama (sebelum strip)
    first_word = SPLIT_PART(disc_word, '-', 1),
    -- Ambil kata kedua (setelah strip)
    second_word = SPLIT_PART(disc_word, '-', 2)
WHERE 
    disc_word IS NOT NULL 
    -- Pastikan ada strip di dalam disc_word sebelum membagi
    AND POSITION('-' IN disc_word) > 0;
	
-- null di disc
UPDATE profiles_psych
SET 
    -- Gabungkan huruf pertama dari kata 1 dan kata 2 di disc_word
    disc = 
        UPPER(LEFT(SPLIT_PART(disc_word, '-', 1), 1)) || 
        UPPER(LEFT(SPLIT_PART(disc_word, '-', 2), 1))
WHERE 
    disc IS NULL                        -- HANYA jika kolom disc kosong
    AND disc_word IS NOT NULL           -- DAN disc_word ada isinya
    AND POSITION('-' IN disc_word) > 0; -- DAN disc_word memiliki tanda strip pemisah
	
-- first dan second chara 
UPDATE profiles_psych
SET 
    -- Ambil karakter pertama dari kode DISC
    first_char = SUBSTRING(disc, 1, 1),
    -- Ambil karakter kedua dari kode DISC
    second_char = SUBSTRING(disc, 2, 1)
WHERE 
    disc IS NOT NULL 
    -- Pastikan panjang kode disc minimal 2 karakter
    AND LENGTH(disc) >= 2;
	
ALTER TABLE profiles_psych
DROP COLUMN enneagram;

-- Cleaning competencies (score)
-- 1. Hitung Median Score
WITH MedianCompetency AS (
    SELECT 
        pillar_code,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY score) AS median_score_value
    FROM 
        competencies_yearly
    WHERE 
        score IS NOT NULL
    GROUP BY 
        pillar_code
)
-- 2. Perbarui tabel competencies_yearly
UPDATE competencies_yearly c
SET score = mc.median_score_value
FROM MedianCompetency mc
WHERE c.score IS NULL
  AND c.pillar_code = mc.pillar_code;
  
-- Clenaing tabel talent
UPDATE talent_variable
SET 
    -- Ganti NULL di kolom logika TGV dengan nilai UNKNOWN_TGV
    tgv_name = COALESCE(tgv_name, 'UNKNOWN_TGV'), 
    
    -- Ganti NULL di kolom narasi dengan string kosong (''):
    tv_meaning = COALESCE(tv_meaning, ''),
    behavior_example = COALESCE(behavior_example, ''),
    note = COALESCE(note, '');
	
-- Cleaning papi_scores
WITH ScaleMedian AS (
    -- 1. Hitung Median Score untuk setiap scale_code PAPI
    SELECT 
        scale_code,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY score) AS median_score_value
    FROM 
        papi_scores
    WHERE 
        score IS NOT NULL
    GROUP BY 
        scale_code
)
-- 2. Perbarui tabel papi_scores
UPDATE papi_scores ps
SET score = sm.median_score_value
FROM ScaleMedian sm
WHERE ps.score IS NULL
  AND ps.scale_code = sm.scale_code;

-- 3. Verifikasi (Lihat apakah masih ada NULL yang tersisa di kolom score)
SELECT 
    scale_code, 
    COUNT(*) 
FROM 
    papi_scores 
WHERE 
    score IS NULL
GROUP BY 
    scale_code;
	
-- Cleaning strength
-- Ganti semua NULL di kolom theme dengan string 'UNKNOWN'
UPDATE strengths
SET theme = 'UNKNOWN'
WHERE theme IS NULL;

-- Cleaning performance_yearly 
-- (Dalam konteks studi kasus Analis Data yang berfokus pada 
-- penemuan pola keberhasilan (Success Pattern Discovery), 
-- baris dengan data kinerja yang hilang (rating IS NULL) 
-- tidak boleh digunakan dalam analisis, karena kita tidak tahu 
-- apakah karyawan tersebut adalah High Performer atau bukan.)
DELETE FROM performance_yearly
WHERE rating IS NULL;