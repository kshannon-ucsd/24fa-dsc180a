-- File: table_one_disease_count_statistics.sql
-- Purpose: This query generates patient statistics based on the number of diseases (comorbidities) for ICU admissions 
-- in the MIMIC-III dataset. It calculates metrics such as SOFA scores, length of stay (LOS) in both ICU and hospital, 
-- and mortality rates, including confidence intervals, categorized by disease count.

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
        a.dischtime -- Hospital discharge time
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
            -- Ensure this is the first ICU admission for each patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),

-- Step 2: Calculating morbidity counts and LOS metrics for each patient
morbidity_counts AS (
    -- Compute the number of diseases (comorbidities) for each patient and calculate ICU and hospital LOS in days
    SELECT
        p.subject_id,
        p.hadm_id,
        p.icustay_id,
        p.deathtime, -- Date and time of death
        EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days, -- ICU LOS in days
        EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days, -- Hospital LOS in days
        -- Calculate the total number of diseases by summing the values of all comorbidity columns
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
        ) AS disease_count -- Total count of diseases for each patient
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id -- Join to calculate comorbidity scores
),

-- Step 3: Categorizing patients by disease count and calculating metrics
disease_distribution AS (
    SELECT 
        -- Categorize patients based on the number of diseases
        CASE 
            WHEN disease_count = 0 THEN '0 diseases'
            WHEN disease_count = 1 THEN '1 disease'
            WHEN disease_count = 2 THEN '2 diseases'
            WHEN disease_count = 3 THEN '3 diseases'
            WHEN disease_count = 4 THEN '4 diseases'
            WHEN disease_count = 5 THEN '5 diseases'
            WHEN disease_count = 6 THEN '6 diseases'
            WHEN disease_count = 7 THEN '7 diseases'
            WHEN disease_count >= 8 THEN '>7 diseases'
        END AS disease_category, -- Disease category label
        COUNT(*) AS patient_count, -- Total number of patients in each disease category
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
        -- Correct calculation for mortality confidence interval using binomial proportion
        1.96 * SQRT(
            (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN p.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        morbidity_counts p
    JOIN 
        mimiciii.sofa s ON p.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
    GROUP BY 
        disease_category -- Group by disease category
)

-- Final output: Patient statistics categorized by the number of diseases
SELECT 
    disease_category, -- Disease category
    patient_count, -- Total number of patients in the disease category
    100.0 * patient_count / SUM(patient_count) OVER () AS patient_percentage, -- Percentage of patients in the category
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
    percent_mortality - mortality_ci AS mortality_lower_95ci, -- Lower bound of CI for mortality percentage
    percent_mortality + mortality_ci AS mortality_upper_95ci -- Upper bound of CI for mortality percentage
FROM 
    disease_distribution
ORDER BY 
    disease_category; -- Order the output by disease category
