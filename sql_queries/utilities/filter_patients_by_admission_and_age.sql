-- Selecting unique patients meeting the study's inclusion criteria 
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