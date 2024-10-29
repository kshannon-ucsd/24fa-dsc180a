WITH unique_p AS (
    SELECT
    p.subject_id,
    p.dob,
    p.gender,
    icu.hadm_id,
    icu.icustay_id,
    icu.intime,
    icu.outtime,
    EXTRACT(YEAR FROM age(icu.intime, p.dob)) AS age_at_admission
FROM patients p
JOIN icustays icu ON p.subject_id = icu.subject_id
WHERE EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- patients who are 16 years or older
  AND icu.intime = (
      SELECT MIN(icu2.intime)
      FROM icustays icu2
      WHERE icu2.subject_id = icu.subject_id
  ) -- first admission time
ORDER BY p.subject_id;
)
SELECT 
    p.subject_id, 
    p.hadm_id, 
    p.gender, 
    MAX(p.age_at_admission) AS age_at_admission, -- Selecting an age from one the subject's records to avoid group by error
    MAX(
        CASE 
            WHEN c.itemid IN
            (
                762, 763, 3723, 3580,                     -- Weight Kg
                3581,                                     -- Weight lb
                3582,                                     -- Weight oz
                226512 -- Metavision: Admission Weight (Kg)
            ) 
                AND c.valuenum IS NOT NULL 
            THEN 1 
            ELSE 0 
        END
    ) AS any_weight_recorded
FROM 
    unique_p p -- table returned from filter_patients_by_admission_and_age
LEFT JOIN 
    chartevents c 
    ON p.subject_id = c.subject_id 
    AND p.hadm_id = c.hadm_id 
    AND p.icustay_id = c.icustay_id
WHERE 
    c.itemid IN (762, 763, 3723, 3580, 3581, 3582, 226512)
GROUP BY 
    p.subject_id, 
    p.hadm_id, 
    p.gender
HAVING 
    MAX(
        CASE 
            WHEN c.itemid IN (762, 763, 3723, 3580, 3581, 3582, 226512) 
                AND c.valuenum IS NOT NULL 
            THEN 1 
            ELSE 0 
        END
    ) > 0;