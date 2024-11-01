-- File: table_one_patient_statistics.sql
-- Purpose: This query generates overall patient statistics for ICU admissions in the MIMIC-III dataset. 
-- It calculates metrics such as SOFA scores, length of stay (LOS) in both ICU and hospital, and mortality rates, 
-- including confidence intervals for these estimates.

-- Selecting unique patients meeting the study's inclusion criteria
SELECT
    COUNT(DISTINCT p.subject_id) AS total_patients -- Total count of unique patients who meet the age and admission criteria
FROM
    patients p
JOIN
    icustays icu ON p.subject_id = icu.subject_id
WHERE
    EXTRACT(YEAR FROM age(icu.intime, p.dob)) BETWEEN 16 AND 95 -- Patients aged between 16 and 95 years at ICU admission
    AND icu.intime = (
        -- Ensuring this is the patient's first ICU admission
        SELECT MIN(icu2.intime)
        FROM icustays icu2
        WHERE icu2.subject_id = icu.subject_id
    );

-- Creating a CTE (Common Table Expression) for patient selection
WITH included_patients AS (
    -- Select patients who are 16-95 years old at ICU admission and have their first ICU stay
    SELECT
        p.subject_id,
        icu.hadm_id,
        icu.icustay_id,
        a.deathtime, -- Date and time of death, if applicable
        icu.intime AS icu_intime, -- ICU admission time
        icu.outtime AS icu_outtime, -- ICU discharge time
        a.admittime, -- Hospital admission time
        a.dischtime -- Hospital discharge time
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON icu.hadm_id = a.hadm_id
    WHERE
        -- Age filters: Patients must be at least 16 and not older than 95 at ICU admission
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 
        AND EXTRACT(YEAR FROM age(icu.intime, p.dob)) <= 95 
        AND icu.intime = (
            -- Ensure this is the first ICU admission for each patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),
morbidity_counts AS (
    -- Calculate morbidity (number of diseases) and length of stay metrics for each patient
    SELECT
        p.subject_id,
        p.hadm_id,
        p.icustay_id,
        p.deathtime,
        EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days, -- ICU length of stay in days
        EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days, -- Hospital length of stay in days
        -- Sum comorbidity values to calculate the total disease count
        (COALESCE(congestive_heart_failure, 0) +
         COALESCE(cardiac_arrhythmias, 0) +
         COALESCE(valvular_disease, 0) +
         COALESCE(pulmonary_circulation, 0) +
         COALESCE(peripheral_vascular, 0) +
         COALESCE(hypertension, 0) +
         COALESCE(paralysis, 0) +
         COALESCE(other_neurological, 0) +
         COALESCE(chronic_pulmonary, 0) +
         COALESCE(diabetes_uncomplicated, 0) +
         COALESCE(diabetes_complicated, 0) +
         COALESCE(hypothyroidism, 0) +
         COALESCE(renal_failure, 0) +
         COALESCE(liver_disease, 0) +
         COALESCE(peptic_ulcer, 0) +
         COALESCE(aids, 0) +
         COALESCE(lymphoma, 0) +
         COALESCE(metastatic_cancer, 0) +
         COALESCE(solid_tumor, 0) +
         COALESCE(rheumatoid_arthritis, 0) +
         COALESCE(coagulopathy, 0) +
         COALESCE(obesity, 0) +
         COALESCE(weight_loss, 0) +
         COALESCE(fluid_electrolyte, 0) +
         COALESCE(blood_loss_anemia, 0) +
         COALESCE(deficiency_anemias, 0) +
         COALESCE(alcohol_abuse, 0) +
         COALESCE(drug_abuse, 0) +
         COALESCE(psychoses, 0) +
         COALESCE(depression, 0)
        ) AS disease_count -- Total count of diseases based on comorbidity columns
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id -- Join with comorbidity table to calculate disease count
),
disease_distribution AS (
    -- Compute patient statistics, including SOFA score, LOS, and mortality rates
    SELECT 
        COUNT(*) AS patient_count, -- Total number of patients
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS patient_percentage, -- Percentage of total patients

        -- Median morbidity count and Interquartile Range (IQR)
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY disease_count) AS median_morbidity_count, -- Median of disease counts
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY disease_count) AS iqr_lower, -- Lower quartile of disease counts
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY disease_count) AS iqr_upper, -- Upper quartile of disease counts

        -- Percentage of patients with multimorbidity (more than one disease) and 95% confidence interval
        100.0 * SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity, -- Patients with more than one disease
        1.96 * SQRT(
            (SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS multimorbidity_ci, -- Confidence interval for percent multimorbidity

        -- Calculate mean SOFA score and 95% confidence interval
        AVG(s.sofa) AS mean_sofa,
        AVG(s.sofa) - 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa)) AS lower_95ci_sofa,
        AVG(s.sofa) + 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa)) AS upper_95ci_sofa,

        -- Calculate mean ICU length of stay and 95% confidence interval
        AVG(p.los_icu_days) AS mean_los_icu,
        AVG(p.los_icu_days) - 1.96 * STDDEV(p.los_icu_days) / SQRT(COUNT(p.subject_id)) AS lower_95ci_los_icu,
        AVG(p.los_icu_days) + 1.96 * STDDEV(p.los_icu_days) / SQRT(COUNT(p.subject_id)) AS upper_95ci_los_icu,

        -- Calculate mean hospital length of stay and 95% confidence interval
        AVG(p.los_hospital_days) AS mean_los_hospital,
        AVG(p.los_hospital_days) - 1.96 * STDDEV(p.los_hospital_days) / SQRT(COUNT(p.subject_id)) AS lower_95ci_los_hospital,
        AVG(p.los_hospital_days) + 1.96 * STDDEV(p.los_hospital_days) / SQRT(COUNT(p.subject_id)) AS upper_95ci_los_hospital,

        -- Calculate percent mortality and 95% confidence interval
        100.0 * SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality,
        1.96 * SQRT(
            (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        morbidity_counts p
    JOIN 
        mimiciii.sofa s ON p.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
)

-- Final output: Summary statistics for the patient cohort
SELECT 
    patient_count,
    patient_percentage,
    median_morbidity_count,
    CONCAT(iqr_lower, ' - ', iqr_upper) AS iqr_morbidity_count, -- IQR of disease counts
    percent_multimorbidity,
    percent_multimorbidity - multimorbidity_ci AS lower_95ci_multimorbidity, -- Lower bound of CI for multimorbidity
    percent_multimorbidity + multimorbidity_ci AS upper_95ci_multimorbidity, -- Upper bound of CI for multimorbidity
    mean_sofa,
    CONCAT(mean_sofa, ' (', lower_95ci_sofa, ', ', upper_95ci_sofa, ')') AS sofa_95ci, -- Mean SOFA with CI
    mean_los_icu,
    CONCAT(mean_los_icu, ' (', lower_95ci_los_icu, ', ', upper_95ci_los_icu, ')') AS los_icu_95ci, -- Mean ICU LOS with CI
    mean_los_hospital,
    CONCAT(mean_los_hospital, ' (', lower_95ci_los_hospital, ', ', upper_95ci_los_hospital, ')') AS los_hospital_95ci, -- Mean hospital LOS with CI
    percent_mortality,
    CONCAT(percent_mortality, ' (', percent_mortality - mortality_ci, ', ', percent_mortality + mortality_ci, ')') AS mortality_95ci -- Mortality percentage with CI
FROM 
    disease_distribution;
