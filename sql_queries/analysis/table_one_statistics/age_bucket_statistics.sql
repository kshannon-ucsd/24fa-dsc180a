-- File: table_one_age_bucket_statistics.sql
-- Purpose: This query generates age-bucket-specific statistics for ICU admissions in the MIMIC-III dataset.
-- It calculates metrics such as median morbidity count, SOFA scores, length of stay (LOS) in both ICU and hospital, 
-- and mortality rates, including confidence intervals, grouped by predefined age buckets.

-- Step 1: Use the view for filtered patients (already created as "mimiciii.filtered_patients")
-- Step 2: Use the view for morbidity counts (already created as "mimiciii.morbidity_counts")

-- Step 3: Assigning patients to age buckets
WITH age_buckets AS (
    SELECT
        mc.subject_id,
        mc.hadm_id,
        mc.icustay_id,
        mc.deathtime,
        mc.age_at_admission,
        mc.los_icu_days,
        mc.los_hospital_days,
        mc.disease_count,
        -- Categorize patients into age buckets
        CASE
            WHEN mc.age_at_admission BETWEEN 16 AND 24 THEN '16-24'
            WHEN mc.age_at_admission BETWEEN 25 AND 44 THEN '25-44'
            WHEN mc.age_at_admission BETWEEN 45 AND 64 THEN '45-64'
            WHEN mc.age_at_admission BETWEEN 65 AND 84 THEN '65-84'
            WHEN mc.age_at_admission BETWEEN 85 AND 95 THEN '85-95'
        END AS age_bucket
    FROM
        mimiciii.morbidity_counts mc
),

-- Step 4: Calculating metrics for each age bucket
age_distribution AS (
    SELECT 
        ab.age_bucket, -- Age bucket
        COUNT(*) AS patient_count, -- Total number of patients in each age bucket
        -- Calculate median morbidity count and IQR
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ab.disease_count) AS median_morbidity_count,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ab.disease_count) AS iqr_lower, -- Lower quartile of disease counts
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ab.disease_count) AS iqr_upper, -- Upper quartile of disease counts
        -- Percentage of patients with more than one disease and confidence interval
        100.0 * SUM(CASE WHEN ab.disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity,
        1.96 * SQRT(
            (SUM(CASE WHEN ab.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN ab.disease_count > 1 THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS multimorbidity_ci, -- Confidence interval for percent multimorbidity
        -- Calculate mean SOFA score and 95% confidence interval
        AVG(s.sofa) AS mean_sofa,
        (AVG(s.sofa) - 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_lower_95ci,
        (AVG(s.sofa) + 1.96 * STDDEV(s.sofa) / SQRT(COUNT(s.sofa))) AS sofa_upper_95ci,
        -- Calculate mean ICU LOS and 95% confidence interval
        AVG(ab.los_icu_days) AS mean_los_icu,
        (AVG(ab.los_icu_days) - 1.96 * STDDEV(ab.los_icu_days) / SQRT(COUNT(ab.subject_id))) AS los_icu_lower_95ci,
        (AVG(ab.los_icu_days) + 1.96 * STDDEV(ab.los_icu_days) / SQRT(COUNT(ab.subject_id))) AS los_icu_upper_95ci,
        -- Calculate mean hospital LOS and 95% confidence interval
        AVG(ab.los_hospital_days) AS mean_los_hospital,
        (AVG(ab.los_hospital_days) - 1.96 * STDDEV(ab.los_hospital_days) / SQRT(COUNT(ab.subject_id))) AS los_hospital_lower_95ci,
        (AVG(ab.los_hospital_days) + 1.96 * STDDEV(ab.los_hospital_days) / SQRT(COUNT(ab.subject_id))) AS los_hospital_upper_95ci,
        -- Calculate percent mortality and 95% confidence interval
        100.0 * SUM(CASE WHEN ab.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality,
        1.96 * SQRT(
            (SUM(CASE WHEN ab.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN ab.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        age_buckets ab
    JOIN 
        mimiciii.sofa s ON ab.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
    GROUP BY 
        ab.age_bucket -- Group by age bucket to calculate metrics
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
