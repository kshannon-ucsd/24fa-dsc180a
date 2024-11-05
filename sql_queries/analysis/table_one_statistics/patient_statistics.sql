-- File: table_one_patient_statistics.sql
-- Purpose: This query generates overall patient statistics for ICU admissions in the MIMIC-III dataset. 
-- It calculates metrics such as SOFA scores, length of stay (LOS) in both ICU and hospital, and mortality rates, 
-- including confidence intervals for these estimates.

-- Step 1: Using the view for morbidity counts (already created as "mimiciii.morbidity_counts")

-- Step 2: Computing overall patient statistics
WITH patient_statistics AS (
    SELECT 
        COUNT(*) AS patient_count, -- Total number of patients
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS patient_percentage, -- Percentage of total patients

        -- Calculate median morbidity count and Interquartile Range (IQR)
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mc.disease_count) AS median_morbidity_count,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY mc.disease_count) AS iqr_lower, -- Lower quartile
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY mc.disease_count) AS iqr_upper, -- Upper quartile

        -- Percentage of patients with more than one disease (multimorbidity) and 95% confidence interval
        100.0 * SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity,
        1.96 * SQRT(
            (SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS multimorbidity_ci, -- Confidence interval for multimorbidity percentage

        -- Calculate mean SOFA score and 95% confidence interval
        AVG(s.sofa) AS mean_sofa,
        AVG(s.sofa) - 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa)) AS lower_95ci_sofa,
        AVG(s.sofa) + 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa)) AS upper_95ci_sofa,

        -- Calculate mean ICU LOS and 95% confidence interval
        AVG(mc.los_icu_days) AS mean_los_icu,
        AVG(mc.los_icu_days) - 1.96 * STDDEV(mc.los_icu_days) / SQRT(COUNT(mc.subject_id)) AS lower_95ci_los_icu,
        AVG(mc.los_icu_days) + 1.96 * STDDEV(mc.los_icu_days) / SQRT(COUNT(mc.subject_id)) AS upper_95ci_los_icu,

        -- Calculate mean hospital LOS and 95% confidence interval
        AVG(mc.los_hospital_days) AS mean_los_hospital,
        AVG(mc.los_hospital_days) - 1.96 * STDDEV(mc.los_hospital_days) / SQRT(COUNT(mc.subject_id)) AS lower_95ci_los_hospital,
        AVG(mc.los_hospital_days) + 1.96 * STDDEV(mc.los_hospital_days) / SQRT(COUNT(mc.subject_id)) AS upper_95ci_los_hospital,

        -- Calculate mortality rate and 95% confidence interval
        100.0 * SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality,
        1.96 * SQRT(
            (SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        mimiciii.morbidity_counts mc
    JOIN 
        mimiciii.sofa s ON mc.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
)

-- Final output: Overall summary statistics for the patient cohort
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
    patient_statistics;
