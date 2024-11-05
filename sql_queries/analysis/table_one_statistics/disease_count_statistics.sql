-- File: table_one_disease_count_statistics.sql
-- Purpose: This query generates patient statistics based on the number of diseases (comorbidities) for ICU admissions 
-- in the MIMIC-III dataset. It calculates metrics such as SOFA scores, length of stay (LOS) in both ICU and hospital, 
-- and mortality rates, including confidence intervals, categorized by disease count.

-- Step 1: Use the view for morbidity counts (already created as "mimiciii.morbidity_counts")

-- Step 2: Categorizing patients by disease count and calculating metrics
WITH disease_distribution AS (
    SELECT 
        -- Categorize patients based on the number of diseases
        CASE 
            WHEN mc.disease_count = 0 THEN '0 diseases'
            WHEN mc.disease_count = 1 THEN '1 disease'
            WHEN mc.disease_count = 2 THEN '2 diseases'
            WHEN mc.disease_count = 3 THEN '3 diseases'
            WHEN mc.disease_count = 4 THEN '4 diseases'
            WHEN mc.disease_count = 5 THEN '5 diseases'
            WHEN mc.disease_count = 6 THEN '6 diseases'
            WHEN mc.disease_count = 7 THEN '7 diseases'
            WHEN mc.disease_count >= 8 THEN '>7 diseases'
        END AS disease_category, -- Disease category label
        COUNT(*) AS patient_count, -- Total number of patients in each disease category
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
        -- Calculate percent mortality and 95% confidence interval
        100.0 * SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality,
        -- Correct calculation for mortality confidence interval using binomial proportion
        1.96 * SQRT(
            (SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*)) * 
            (1 - (SUM(CASE WHEN mc.deathtime IS NOT NULL THEN 1 ELSE 0 END)::float / COUNT(*))) / COUNT(*)
        ) * 100 AS mortality_ci -- Confidence interval for mortality percentage
    FROM 
        mimiciii.morbidity_counts mc
    JOIN 
        mimiciii.sofa s ON mc.icustay_id = s.icustay_id -- Join with SOFA score table for severity metrics
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
