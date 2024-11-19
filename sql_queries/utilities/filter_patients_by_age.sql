-- Create a view for the filtered and included patients
CREATE VIEW mimiciii.included_patients AS
SELECT
    p.subject_id,
    icu.hadm_id,
    icu.icustay_id,
    a.deathtime,
    icu.intime AS icu_intime,
    icu.outtime AS icu_outtime,
    a.admittime,
    a.dischtime,
    p.gender,
    EXTRACT(YEAR FROM age(icu.intime, p.dob)) AS age_at_admission,
    CASE
        WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'
        ELSE 'Non-Elective'
    END AS admission_type
FROM
    mimiciii.patients p
JOIN
    mimiciii.icustays icu ON p.subject_id = icu.subject_id
JOIN
    mimiciii.admissions a ON icu.hadm_id = a.hadm_id
WHERE
    EXTRACT(YEAR FROM age(icu.intime, p.dob)) BETWEEN 16 AND 95
    AND icu.intime = (
        SELECT MIN(icu2.intime)
        FROM mimiciii.icustays icu2
        WHERE icu2.subject_id = icu.subject_id
    );
