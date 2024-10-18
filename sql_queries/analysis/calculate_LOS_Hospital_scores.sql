-- Calculate LOS Hospital scores by age bucket 
With subject_Helper As (
    SELECT
    p.subject_id,
    p.dob,
    p.gender,
    icu.hadm_id,
    icu.icustay_id,
    icu.intime,
    icu.outtime,
    EXTRACT(YEAR FROM age(icu.intime, p.dob)) AS age_at_admission
FROM mimiciii.patients p
JOIN mimiciii.icustays icu ON p.subject_id = icu.subject_id
WHERE EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- patients who are 16 years or older
  AND icu.intime = (
      SELECT MIN(icu2.intime)
      FROM mimiciii.icustays icu2
      WHERE icu2.subject_id = icu.subject_id
  ) -- first admission time
ORDER BY p.subject_id
),
Age_Helper As (
    Select 
    h.subject_id,
    h.age_at_admission,
    a.dischtime,
    a.admittime,
    CASE
        WHEN h.age_at_admission BETWEEN 16 AND 24  THEN '16-24'
        WHEN h.age_at_admission BETWEEN 25 AND 44 THEN '25-44'
        WHEN h.age_at_admission BETWEEN 45 AND 64 THEN '45-64'
        WHEN h.age_at_admission BETWEEN 65 AND 84 THEN '65-84'
        WHEN h.age_at_admission BETWEEN 85 AND 95 THEN '85-95'
    END AS age_bucket
    from subject_Helper h
    join mimiciii.admissions a
    on h.subject_id = a.subject_id and h.hadm_id = a.hadm_id
)

select ah.age_bucket,
count(ah.*) As Number_of_patients,
EXTRACT(EPOCH FROM AVG(ah.dischtime - ah.admittime)) / 86400 AS LOS_score
from Age_Helper ah
group by ah.age_bucket;