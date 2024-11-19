WITH included_patients AS (
    -- Selecting unique patients meeting the study's inclusion criteria
    SELECT
        p.subject_id,
        icu.hadm_id,
        a.admission_type,
        CASE 
            WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'
            ELSE 'Non-Elective' 
        END AS admission_category
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON p.subject_id = a.subject_id AND icu.hadm_id = a.hadm_id
    WHERE
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- Patients who are 16 years or older at ICU admission
        AND icu.intime = (
            -- Ensuring this is the first ICU admission for the patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),
morbidity_counts AS (
    -- Calculate the morbidity count (number of diseases) for each included patient based on hadm_id
    SELECT
        p.subject_id,
        p.hadm_id,
        p.admission_category,
        -- Sum the values of all comorbidity columns to get the number of diseases
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
        ) AS disease_count
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id
),
multimorbidity_stats AS (
    -- Identify patients with multimorbidity (disease count > 1) and calculate the total patients in each category
    SELECT 
        admission_category,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END) AS multimorbid_patients
    FROM 
        morbidity_counts
    GROUP BY 
        admission_category
),
percent_multimorbidity AS (
    -- Calculate percentage with multimorbidity and 95% CI
    SELECT
        admission_category,
        multimorbid_patients,
        total_patients,
        (multimorbid_patients::decimal / total_patients) * 100 AS percent_multimorbidity,
        -- Calculate 95% CI for the percentage (p ± 1.96 * sqrt((p * (1 - p)) / n))
        (multimorbid_patients::decimal / total_patients) * 100 - 
        1.96 * (SQRT((multimorbid_patients::decimal / total_patients) * (1 - (multimorbid_patients::decimal / total_patients)) / total_patients)) AS lower_95ci,
        (multimorbid_patients::decimal / total_patients) * 100 + 
        1.96 * (SQRT((multimorbid_patients::decimal / total_patients) * (1 - (multimorbid_patients::decimal / total_patients)) / total_patients)) AS upper_95ci
    FROM 
        multimorbidity_stats
)

-- Display final result
SELECT
    admission_category,
    multimorbid_patients,
    total_patients,
    percent_multimorbidity,
    lower_95ci,
    upper_95ci
FROM 
    percent_multimorbidity
ORDER BY 
    admission_category;



###Percent (95% CI) 
with multimorbidity
WITH included_patients AS (
    -- Selecting unique patients meeting the study's inclusion criteria
    SELECT
        p.subject_id,
        icu.hadm_id,
        a.admission_type,
        CASE 
            WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'
            ELSE 'Non-Elective' 
        END AS admission_category
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON p.subject_id = a.subject_id AND icu.hadm_id = a.hadm_id
    WHERE
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- Patients who are 16 years or older at ICU admission
        AND icu.intime = (
            -- Ensuring this is the first ICU admission for the patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),
morbidity_counts AS (
    -- Calculate the morbidity count (number of diseases) for each included patient based on hadm_id
    SELECT
        p.subject_id,
        p.hadm_id,
        p.admission_category,
        -- Sum the values of all comorbidity columns to get the number of diseases
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
        ) AS disease_count
    FROM
        included_patients p
    JOIN
        mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id
),
multimorbidity_stats AS (
    -- Identify patients with multimorbidity (disease count > 1) and calculate the total patients in each category
    SELECT 
        admission_category,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN disease_count > 1 THEN 1 ELSE 0 END) AS multimorbid_patients
    FROM 
        morbidity_counts
    GROUP BY 
        admission_category
),
percent_multimorbidity AS (
    -- Calculate percentage with multimorbidity and 95% CI
    SELECT
        admission_category,
        multimorbid_patients,
        total_patients,
        (multimorbid_patients::decimal / total_patients) * 100 AS percent_multimorbidity,
        -- Calculate 95% CI for the percentage (p ± 1.96 * sqrt((p * (1 - p)) / n))
        (multimorbid_patients::decimal / total_patients) * 100 - 
        1.96 * (SQRT((multimorbid_patients::decimal / total_patients) * (1 - (multimorbid_patients::decimal / total_patients)) / total_patients)) AS lower_95ci,
        (multimorbid_patients::decimal / total_patients) * 100 + 
        1.96 * (SQRT((multimorbid_patients::decimal / total_patients) * (1 - (multimorbid_patients::decimal / total_patients)) / total_patients)) AS upper_95ci
    FROM 
        multimorbidity_stats
)

-- Display final result
SELECT
    admission_category,
    multimorbid_patients,
    total_patients,
    percent_multimorbidity,
    lower_95ci,
    upper_95ci
FROM 
    percent_multimorbidity
ORDER BY 
    admission_category;



### Get sofa_scores
WITH included_patients AS (
    -- Selecting unique patients meeting the study's inclusion criteria
    SELECT
        p.subject_id,
        icu.hadm_id,
        a.admission_type,
        CASE 
            WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'
            ELSE 'Non-Elective' 
        END AS admission_category,
        icu.icustay_id,
        icu.intime,
        icu.outtime,
        a.admittime,
        a.dischtime
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON p.subject_id = a.subject_id AND icu.hadm_id = a.hadm_id
    WHERE
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- Patients who are 16 years or older at ICU admission
        AND icu.intime = (
            -- Ensuring this is the first ICU admission for the patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),
sofa_scores AS (
    -- Retrieve SOFA scores for included patients
    SELECT 
        ip.subject_id,
        ip.hadm_id,
        ip.admission_category,
        s.sofa
    FROM 
        included_patients ip
    JOIN 
        mimiciii.sofa s ON ip.subject_id = s.subject_id AND ip.icustay_id = s.icustay_id
),
los_calculations AS (
    -- Calculate LOS for ICU and Hospital
    SELECT
        ip.subject_id,
        ip.hadm_id,
        ip.admission_category,
        EXTRACT(EPOCH FROM (ip.outtime - ip.intime)) / 86400 AS los_icu,
        EXTRACT(EPOCH FROM (ip.dischtime - ip.admittime)) / 86400 AS los_hospital
    FROM 
        included_patients ip
)

-- Final selection with SOFA, LOS ICU, and LOS Hospital with 95% CI for each admission category
SELECT 
    ss.admission_category,
    -- SOFA score
    AVG(ss.sofa) AS mean_sofa,
    AVG(ss.sofa) - 1.96 * STDDEV(ss.sofa) / SQRT(COUNT(ss.sofa)) AS lower_95ci_sofa,
    AVG(ss.sofa) + 1.96 * STDDEV(ss.sofa) / SQRT(COUNT(ss.sofa)) AS upper_95ci_sofa,
    
    -- LOS ICU
    AVG(lc.los_icu) AS mean_los_icu,
    AVG(lc.los_icu) - 1.96 * STDDEV(lc.los_icu) / SQRT(COUNT(lc.los_icu)) AS lower_95ci_los_icu,
    AVG(lc.los_icu) + 1.96 * STDDEV(lc.los_icu) / SQRT(COUNT(lc.los_icu)) AS upper_95ci_los_icu,
    
    -- LOS Hospital
    AVG(lc.los_hospital) AS mean_los_hospital,
    AVG(lc.los_hospital) - 1.96 * STDDEV(lc.los_hospital) / SQRT(COUNT(lc.los_hospital)) AS lower_95ci_los_hospital,
    AVG(lc.los_hospital) + 1.96 * STDDEV(lc.los_hospital) / SQRT(COUNT(lc.los_hospital)) AS upper_95ci_los_hospital

FROM 
    sofa_scores ss
JOIN 
    los_calculations lc ON ss.subject_id = lc.subject_id AND ss.hadm_id = lc.hadm_id
GROUP BY 
    ss.admission_category
ORDER BY 
    ss.admission_category;



###Percent Mortality
(95% CI)
WITH included_patients AS (
    -- Selecting unique patients meeting the study's inclusion criteria
    SELECT
        p.subject_id,
        icu.hadm_id,
        a.admission_type,
        CASE 
            WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'
            ELSE 'Non-Elective' 
        END AS admission_category,
        a.deathtime
    FROM
        mimiciii.patients p
    JOIN
        mimiciii.icustays icu ON p.subject_id = icu.subject_id
    JOIN
        mimiciii.admissions a ON p.subject_id = a.subject_id AND icu.hadm_id = a.hadm_id
    WHERE
        EXTRACT(YEAR FROM age(icu.intime, p.dob)) >= 16 -- Patients who are 16 years or older at ICU admission
        AND icu.intime = (
            -- Ensuring this is the first ICU admission for the patient
            SELECT MIN(icu2.intime)
            FROM mimiciii.icustays icu2
            WHERE icu2.subject_id = icu.subject_id
        )
),
mortality_stats AS (
    -- Calculate mortality rate for each category
    SELECT
        admission_category,
        COUNT(*) AS total_patients,
        COUNT(CASE WHEN deathtime IS NOT NULL THEN 1 END) AS deaths,
        COUNT(CASE WHEN deathtime IS NOT NULL THEN 1 END)::float / COUNT(*) AS percent_mortality
    FROM 
        included_patients
    GROUP BY 
        admission_category
)

-- Final calculation with 95% CI
SELECT
    admission_category,
    total_patients,
    deaths,
    percent_mortality * 100 AS percent_mortality,
    (percent_mortality * 100) - (1.96 * SQRT((percent_mortality * (1 - percent_mortality)) / total_patients) * 100) AS lower_95ci,
    (percent_mortality * 100) + (1.96 * SQRT((percent_mortality * (1 - percent_mortality)) / total_patients) * 100) AS upper_95ci
FROM
    mortality_stats;