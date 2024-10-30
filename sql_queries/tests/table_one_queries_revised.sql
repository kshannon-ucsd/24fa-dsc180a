morbidity_counts AS (
    -- Calculate the morbidity count for each included patient
    SELECT
        fp.subject_id,
        fp.hadm_id,
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
         COALESCE(depression, 0)) AS disease_count
    FROM 
        filtered_patients fp
    JOIN 
        mimiciii.elixhauser_quan e ON fp.hadm_id = e.hadm_id
),
metrics AS (
    -- Calculate all required metrics for the filtered cohort
    SELECT
        COUNT(*) AS total_patients,
        
        -- Median Morbidity Count (IQR)
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY disease_count) AS median_morbidity_count,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY disease_count) AS Q1_morbidity_count,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY disease_count) AS Q3_morbidity_count,
        
        -- Percent with Multimorbidity (more than 1 disease)
        100.0 * SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_multimorbidity,

        -- SOFA Score (Mean and 95% CI)
        AVG(sofa.sofa) AS mean_sofa,
        1.96 * STDDEV(sofa.sofa) / SQRT(COUNT(*)) AS ci_sofa,

        -- ICU Length of Stay (Mean and 95% CI)
        AVG(EXTRACT(EPOCH FROM (icu.outtime - icu.intime)) / 86400) AS mean_los_icu,
        1.96 * STDDEV(EXTRACT(EPOCH FROM (icu.outtime - icu.intime)) / 86400) / SQRT(COUNT(*)) AS ci_los_icu,

        -- Hospital Length of Stay (Mean and 95% CI)
        AVG(EXTRACT(EPOCH FROM (a.dischtime - a.admittime)) / 86400) AS mean_los_hospital,
        1.96 * STDDEV(EXTRACT(EPOCH FROM (a.dischtime - a.admittime)) / 86400) / SQRT(COUNT(*)) AS ci_los_hospital,

        -- Percent Mortality
        100.0 * SUM(CASE WHEN a.deathtime IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS percent_mortality
    FROM 
        morbidity_counts mc
    JOIN 
        mimiciii.sofa sofa ON mc.subject_id = sofa.subject_id AND mc.hadm_id = sofa.hadm_id
    JOIN 
        mimiciii.icustays icu ON mc.hadm_id = icu.hadm_id
    JOIN 
        mimiciii.admissions a ON mc.hadm_id = a.hadm_id
)

-- Final output of metrics with calculated CIs
SELECT
    total_patients,
    median_morbidity_count,
    CONCAT(Q1_morbidity_count, ' - ', Q3_morbidity_count) AS iqr_morbidity_count,
    percent_multimorbidity,
    1.96 * SQRT((percent_multimorbidity / 100) * (1 - (percent_multimorbidity / 100)) / total_patients) AS ci_multimorbidity,
    mean_sofa,
    ci_sofa,
    mean_los_icu,
    ci_los_icu,
    mean_los_hospital,
    ci_los_hospital,
    percent_mortality,
    1.96 * SQRT((percent_mortality / 100) * (1 - (percent_mortality / 100)) / total_patients) AS ci_mortality
FROM 
    metrics;
