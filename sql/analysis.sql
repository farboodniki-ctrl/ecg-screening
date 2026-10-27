-- 1) Dataset size
SELECT COUNT(*) AS recordings, COUNT(DISTINCT patient_id) AS patients
FROM recordings;

-- 2) Number of ECGs per patient
SELECT n_ecgs, COUNT(*) AS patients
FROM (SELECT patient_id, COUNT(*) AS n_ecgs FROM recordings GROUP BY patient_id) t
GROUP BY n_ecgs
ORDER BY n_ecgs;

-- 3) Recordings per main diagnostic class (one ECG can have several classes)
SELECT s.diagnostic_class, COUNT(DISTINCT d.ecg_id) AS recordings
FROM diagnoses d
JOIN scp_statements s ON s.scp_code = d.scp_code
WHERE s.diagnostic = 1 AND s.diagnostic_class IS NOT NULL
GROUP BY s.diagnostic_class
ORDER BY recordings DESC;

-- 4) Average age and percent female per diagnostic class (each ECG counted once per class)
WITH cls AS (
    SELECT DISTINCT d.ecg_id, s.diagnostic_class
    FROM diagnoses d
    JOIN scp_statements s ON s.scp_code = d.scp_code
    WHERE s.diagnostic = 1 AND s.diagnostic_class IS NOT NULL
)
SELECT c.diagnostic_class,
       ROUND(AVG(r.age)::numeric, 1) AS avg_age,
       ROUND(100.0 * AVG(CASE WHEN p.sex = 1 THEN 1 ELSE 0 END), 1) AS pct_female
FROM cls c
JOIN recordings r ON r.ecg_id = c.ecg_id
JOIN patients p ON p.patient_id = r.patient_id
GROUP BY c.diagnostic_class
ORDER BY avg_age DESC;

-- 5) Time gap between consecutive ECGs of the same patient (window function)
SELECT patient_id, ecg_id, recording_date,
       recording_date - LAG(recording_date)
           OVER (PARTITION BY patient_id ORDER BY recording_date) AS gap_since_prev
FROM recordings
WHERE patient_id IN (SELECT patient_id FROM recordings GROUP BY patient_id HAVING COUNT(*) > 1)
ORDER BY patient_id, recording_date
LIMIT 50;