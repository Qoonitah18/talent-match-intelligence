SELECT MIN(gtq) AS min_gtq, MAX(gtq) AS max_gtq
FROM profiles_psych;

SELECT MIN(score) AS min_competency, MAX(score) AS max_competency
FROM competencies_yearly;

SELECT COUNT(*) AS jumlah_score_99
FROM competencies_yearly
WHERE score = 99.0;

DELETE FROM competencies_yearly
WHERE score = 99.0;

SELECT COUNT(*)
FROM competencies_yearly
WHERE score = 99.0;

SELECT MIN(score) AS min_papi, MAX(score) AS max_papi
FROM papi_scores;