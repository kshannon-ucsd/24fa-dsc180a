-- Create a view for calculating morbidity counts
CREATE VIEW mimiciii.morbidity_counts AS
SELECT
    p.subject_id,
    p.hadm_id,
    p.icustay_id,
    p.deathtime,
    p.gender,
    p.age_at_admission,
    p.admission_type,
    EXTRACT(EPOCH FROM (p.icu_outtime - p.icu_intime)) / 86400 AS los_icu_days,
    EXTRACT(EPOCH FROM (p.dischtime - p.admittime)) / 86400 AS los_hospital_days,
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
    mimiciii.included_patients p
JOIN
    mimiciii.elixhauser_quan e ON p.hadm_id = e.hadm_id;
