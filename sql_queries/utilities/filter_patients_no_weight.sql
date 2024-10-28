SELECT 
    p.subject_id, 
    p.hadm_id, 
    p.gender, 
    MAX(p.age_at_admission) AS max_age_at_admission,
    MAX(
        CASE 
            WHEN c.itemid IN (762, 763, 3723, 3580, 3581, 3582, 226512) 
                AND c.valuenum IS NOT NULL 
            THEN 1 
            ELSE 0 
        END
    ) AS any_weight_recorded
FROM 
    unique_p p
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