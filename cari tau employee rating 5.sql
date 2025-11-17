SELECT 
    t1.employee_id, 
    t2.fullname,
    t3.name AS role,
    t1.rating
FROM 
    performance_yearly t1
JOIN 
    employees t2 ON t1.employee_id = t2.employee_id
LEFT JOIN 
    dim_positions t3 ON t2.position_id = t3.position_id
WHERE 
    t1.year = (SELECT MAX(year) FROM performance_yearly) -- Hanya ambil rating tahun terbaru
    AND t1.rating = 5.0 -- HANYA pilih High Performer
ORDER BY 
    t1.employee_id
LIMIT 10; -- Tampilkan 10 ID teratas untuk dipilih