-- File: table_one_gender_statistics.sql
-- Purpose: This query generates gender-specific statistics for ICU admissions in the MIMIC-III dataset.
-- It calculates metrics such as median morbidity count, SOFA scores, length of stay (LOS) in both ICU and hospital, 
-- and mortality rates, including confidence intervals, grouped by gender.

-- Step 1: Using the view for morbidity counts (already created as "mimiciii.morbidity_counts")

-- Step 2: Calculating gender-specific metrics
WITH gender_distribution AS (
    SELECT 
        mc.gender, -- Gender of the patient
        COUNT(*) AS patient_count, -- Total number of patients in each gender group
        -- Calculate median morbidity count and IQR
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY mc.disease_count) AS median_morbidity_count, -- Median of disease counts
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY mc.disease_count) AS iqr_lower, -- Lower quartile of disease counts
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY mc.disease_count) AS iqr_upper, -- Upper quartile of disease counts
        -- Percentage of patients with more than one disease (multimorbidity) and confidence interval
        100.0 * SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity,
        1.96 * SQRT(
            (SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN mc.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS multimorbidity_ci, -- Confidence interval for percent multimorbidity
        -- Calculate mean SOFA score and 95% confidence interval
        AVG(s.sofa) AS mean_sofa,
        (AVG(s.sofa) - 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_lower_95ci,
        (AVG(s.sofa) + 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_upper_95ci,
        -- Calculate mean ICU LOS and 95% confidence interval
        AVG(mc.los_icu_days) AS mean_los_icu,
        (AVG(mc.los_icu_days) - 1.96 * STDDEV(mc.los_icu_days) / SQRT(COUNT(mc.subject_id))) AS los_icu_lower_95ci,
        (AVG(mc.los_icu_days) + 1.96 * STDDEV(mc.los_icu_days) / SQRT(COUNT(mc.subject_id))) AS los_icu_upper_95ci,
        -- Calculate mean hospital LOS and 95% confidence interval
        AVG(mc.los_hospital_days) AS mean_los_hospital,
        (AVG(mc.los_hospital_days) - 1.96 * STDDEV(mc.los_hospital_days) / SQRT(COUNT(mc.subject_id))) AS los_hospital_lower_95ci,
        (AVG(mc.los_hospital_days) + 1.96 * STDDEV(mc.los_hospital_days) / SQRT(COUNT(mc.subject_id))) AS los_hospital_upper_95ci,
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
    GROUP BY 
        mc.gender -- Group by gender to calculate metrics for each gender
)

-- Final output: Gender-specific summary statistics
SELECT 
    gender,
    patient_count, -- Total number of patients in the gender group
    100.0 * patient_count / SUM(patient_count) OVER () AS patient_percentage, -- Percentage of patients in the gender group
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
    gender_distribution
ORDER BY 
    gender; -- Order the output by gender
