-- File: common_ctes.sql
-- Purpose: Contains centralized CTEs for patient selection and morbidity calculations

WITH included_patients AS (
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
        )
),
morbidity_counts AS (
    SELECT
        p.subject_id,
        p.hadm_id,
        p.icustay_id,
        p.deathtime,
        p.gender,
        p.age_at_admission,
        p.admission_type,
        EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days,
        EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days,
        (COALESCE(congestive_heart_failure, 0) +
         COALESCE(cardiac_arrhythmias, 0) +
         -- Add all other comorbidities
         COALESCE(depression, 0)
        ) AS disease_count
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id
)
