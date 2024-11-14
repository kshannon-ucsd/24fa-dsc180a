-- Export patient data with individual disease indicators to a CSV file using the psql \copy command

\copy (
    -- Step 1: Define a Common Table Expression (CTE) to select patients who meet age and admission criteria
    WITH included_patients AS (
        SELECT
            p.subject_id,  -- Unique patient ID
            icu.hadm_id,  -- Hospital admission ID
            icu.icustay_id,  -- ICU stay ID
            a.deathtime,  -- Date and time of death, if applicable
            p.gender,  -- Patient gender
            icu.intime AS icu_intime,  -- ICU admission time
            icu.outtime AS icu_outtime,  -- ICU discharge time
            a.admittime,  -- Hospital admission time
            a.dischtime,  -- Hospital discharge time
            EXTRACT(YEAR FROM age(icu.intime, p.dob)) AS age_at_admission,  -- Patient's age at ICU admission
            CASE 
                WHEN a.admission_type = 'ELECTIVE' THEN 'Elective'  -- Classify admission type
                ELSE 'Non-Elective' 
            END AS admission_type
        FROM
            mimiciii.patients p
        JOIN
            mimiciii.icustays icu ON p.subject_id = icu.subject_id
        JOIN
            mimiciii.admissions a ON icu.hadm_id = a.hadm_id
        WHERE
            EXTRACT(YEAR FROM age(icu.intime, p.dob)) BETWEEN 16 AND 95  -- Include patients aged between 16 and 95
            AND icu.intime = (
                SELECT MIN(icu2.intime)  -- Ensure the first ICU admission for the patient
                FROM mimiciii.icustays icu2
                WHERE icu2.subject_id = icu.subject_id
            )
    ),

    -- Step 2: Define another CTE to join selected patients with disease indicators
    patient_diseases AS (
        SELECT
            p.subject_id,
            p.hadm_id,
            p.icustay_id,
            p.deathtime,
            p.gender,
            p.age_at_admission,
            p.admission_type,
            EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days,  -- ICU length of stay in days
            EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days,  -- Hospital length of stay in days
            -- Individual disease indicators from the Elixhauser comorbidity index
            e.congestive_heart_failure,
            e.cardiac_arrhythmias,
            e.valvular_disease,
            e.pulmonary_circulation,
            e.peripheral_vascular,
            e.hypertension,
            e.paralysis,
            e.other_neurological,
            e.chronic_pulmonary,
            e.diabetes_uncomplicated,
            e.diabetes_complicated,
            e.hypothyroidism,
            e.renal_failure,
            e.liver_disease,
            e.peptic_ulcer,
            e.aids,
            e.lymphoma,
            e.metastatic_cancer,
            e.solid_tumor,
            e.rheumatoid_arthritis,
            e.coagulopathy,
            e.obesity,
            e.weight_loss,
            e.fluid_electrolyte,
            e.blood_loss_anemia,
            e.deficiency_anemias,
            e.alcohol_abuse,
            e.drug_abuse,
            e.psychoses,
            e.depression
        FROM
            included_patients p
        JOIN
            mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id  -- Join to retrieve individual disease indicators
    )

    -- Step 3: Select final fields for export, including disease indicators
    SELECT
        subject_id,
        hadm_id,
        icustay_id,
        deathtime,
        gender,
        age_at_admission,
        admission_type,
        los_icu_days,
        los_hospital_days,
        -- List each individual disease indicator (0 or 1)
        congestive_heart_failure,
        cardiac_arrhythmias,
        valvular_disease,
        pulmonary_circulation,
        peripheral_vascular,
        hypertension,
        paralysis,
        other_neurological,
        chronic_pulmonary,
        diabetes_uncomplicated,
        diabetes_complicated,
        hypothyroidism,
        renal_failure,
        liver_disease,
        peptic_ulcer,
        aids,
        lymphoma,
        metastatic_cancer,
        solid_tumor,
        rheumatoid_arthritis,
        coagulopathy,
        obesity,
        weight_loss,
        fluid_electrolyte,
        blood_loss_anemia,
        deficiency_anemias,
        alcohol_abuse,
        drug_abuse,
        psychoses,
        depression
    FROM
        patient_diseases
) TO '/workspaces/environment/LCA_Analysis/data/raw_data/LCA_raw_data.csv' WITH CSV HEADER;  -- Export result to CSV with headers
