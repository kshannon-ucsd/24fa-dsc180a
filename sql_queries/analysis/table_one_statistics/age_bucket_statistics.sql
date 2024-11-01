-- File: table_one_age_bucket_statistics.sql
-- Purpose: This query generates age-bucket-specific statistics for ICU admissions in the MIMIC-III dataset.
-- It calculates metrics such as median morbidity count, SOFA scores, length of stay (LOS) in both ICU and hospital, 
-- and mortality rates, including confidence intervals, grouped by predefined age buckets.

-- Step 1: Selecting patients meeting the study's inclusion criteria
WITH included_patients AS (
    -- Select unique patients aged between 16 and 95 years at ICU admission and ensure it is their first ICU stay
    SELECT
        p.subject_id,
        icu.hadm_id,
        icu.icustay_id,
        a.deathtime, -- Date and time of death, if applicable
        icu.intime AS icu_intime, -- ICU admission time
        icu.outtime AS icu_outtime, -- ICU discharge time
        a.admittime, -- Hospital admission time
        a.dischtime, -- Hospital discharge time
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) AS age_at_admission -- Calculate age at ICU admission
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON icu.hadm_id = a.hadm_id
    WHERE
        -- Age filters: Include patients aged between 16 and 95 years
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16
        AND EXTRACT(YEAR FROM age(icu.intime, p.dob)) <= 95
        AND icu.intime = (
            -- Ensure this is the first ICU admission for the patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),

-- Step 2: Assigning patients to age buckets and calculating morbidity counts
age_buckets AS (
    -- Group patients into age buckets and calculate the number of comorbidities
    SELECT
        p.subject_id,
        p.hadm_id,
        p.icustay_id,
        p.deathtime, -- Date and time of death
        p.icu_intime, -- ICU admission time
        p.icu_outtime, -- ICU discharge time
        p.admittime, -- Hospital admission time
        p.dischtime, -- Hospital discharge time
        p.age_at_admission, -- Age at ICU admission
        EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days, -- ICU LOS in days
        EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days, -- Hospital LOS in days
        -- Calculate the total morbidity count by summing comorbidity values
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
        ) AS disease_count, -- Total count of diseases for each patient
        -- Categorize patients into age buckets
        CASE
            WHEN p.age_at_admission BETWEEN 16 AND 24 THEN '16-24'
            WHEN p.age_at_admission BETWEEN 25 AND 44 THEN '25-44'
            WHEN p.age_at_admission BETWEEN 45 AND 64 THEN '45-64'
            WHEN p.age_at_admission BETWEEN 65 AND 84 THEN '65-84'
            WHEN p.age_at_admission BETWEEN 85 AND 95 THEN '85-95'
        END AS age_bucket -- Age bucket classification
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id -- Join to calculate comorbidities
),

-- Step 3: Calculating metrics for each age bucket
age_distribution AS (
    SELECT 
        age_bucket, -- Age bucket
        COUNT(*) AS patient_count, -- Total number of patients in each age bucket
        -- Calculate median morbidity count and IQR
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY disease_count) AS median_morbidity_count,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY disease_count) AS iqr_lower, -- Lower quartile of disease counts
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY disease_count) AS iqr_upper, -- Upper quartile of disease counts
        -- Percentage of patients with more than one disease and confidence interval
        100.0 * SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity,
        1.96 * SQRT(
            (SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS multimorbidity_ci, -- Confidence interval for percent multimorbidity
        -- Calculate mean SOFA score and 95% confidence interval
        AVG(s.sofa) AS mean_sofa,
        (AVG(s.sofa) - 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_lower_95ci,
        (AVG(s.sofa) + 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_upper_95ci,
        -- Calculate mean ICU LOS and 95% confidence interval
        AVG(p.los_icu_days) AS mean_los_icu,
        (AVG(p.los_icu_days) - 1.96 * STDDEV(p.los_icu_days) / SQRT(COUNT(p.subject_id))) AS los_icu_lower_95ci,
        (AVG(p.los_icu_days) + 1.96 * STDDEV(p.los_icu_days) / SQRT(COUNT(p.subject_id))) AS los_icu_upper_95ci,
        -- Calculate mean hospital LOS and 95% confidence interval
        AVG(p.los_hospital_days) AS mean_los_hospital,
        (AVG(p.los_hospital_days) - 1.96 * STDDEV(p.los_hospital_days) / SQRT(COUNT(p.subject_id))) AS los_hospital_lower_95ci,
        (AVG(p.los_hospital_days) + 1.96 * STDDEV(p.los_hospital_days) / SQRT(COUNT(p.subject_id))) AS los_hospital_upper_95ci,
        -- Calculate percent mortality and 95% confidence interval
        100.0 * SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality,
        1.96 * SQRT(
            (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        age_buckets p
    JOIN 
        mimiciii.sofa s ON p.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
    GROUP BY 
        age_bucket -- Group by age bucket to calculate metrics
)

-- Final output: Age-bucket-specific summary statistics
SELECT 
    age_bucket, -- Age bucket
    patient_count, -- Total number of patients in the age bucket
    median_morbidity_count, -- Median morbidity count
    CONCAT(iqr_lower, ' - ', iqr_upper) AS iqr_morbidity_count, -- IQR of disease counts
    percent_multimorbidity, -- Percentage of patients with multimorbidity
    percent_multimorbidity - multimorbidity_ci AS lower_95ci_multimorbidity, -- Lower bound of CI for multimorbidity
    percent_multimorbidity + multimorbidity_ci AS upper_95ci_multimorbidity, -- Upper bound of CI for multimorbidity
    mean_sofa, -- Mean SOFA score
    sofa_lower_95ci, -- Lower bound of CI for mean SOFA score
    sofa_upper_95ci, -- Upper bound of CI for mean SOFA score
    mean_los_icu, -- Mean ICU LOS
    los_icu_lower_95ci, -- Lower bound of CI for mean ICU LOS
    los_icu_upper_95ci, -- Upper bound of CI for mean ICU LOS
    mean_los_hospital, -- Mean hospital LOS
    los_hospital_lower_95ci, -- Lower bound of CI for mean hospital LOS
    los_hospital_upper_95ci, -- Upper bound of CI for mean hospital LOS
    percent_mortality, -- Mortality percentage
    percent_mortality - mortality_ci AS lower_95ci_mortality, -- Lower bound of CI for mortality percentage
    percent_mortality + mortality_ci AS upper_95ci_mortality -- Upper bound of CI for mortality percentage
FROM 
    age_distribution
ORDER BY 
    age_bucket; -- Order the output by age bucket
