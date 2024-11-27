\copy
    (
    SELECT 
        elixhauser_quan.*,
        unique_p.age_at_admission, 
        unique_p.gender
    FROM 
        unique_p
    LEFT JOIN 
        elixhauser_quan
    ON 
        elixhauser_quan.hadm_id = unique_p.hadm_id
    WHERE 
        unique_p.age_at_admission <= 95
        AND elixhauser_quan.congestive_heart_failure IS NOT NULL
        AND elixhauser_quan.cardiac_arrhythmias IS NOT NULL
        AND elixhauser_quan.valvular_disease IS NOT NULL
        AND elixhauser_quan.pulmonary_circulation IS NOT NULL
        AND elixhauser_quan.peripheral_vascular IS NOT NULL
        AND elixhauser_quan.hypertension IS NOT NULL
        AND elixhauser_quan.paralysis IS NOT NULL
        AND elixhauser_quan.other_neurological IS NOT NULL
        AND elixhauser_quan.chronic_pulmonary IS NOT NULL
        AND elixhauser_quan.diabetes_uncomplicated IS NOT NULL
        AND elixhauser_quan.diabetes_complicated IS NOT NULL
        AND elixhauser_quan.hypothyroidism IS NOT NULL
        AND elixhauser_quan.renal_failure IS NOT NULL
        AND elixhauser_quan.liver_disease IS NOT NULL
        AND elixhauser_quan.peptic_ulcer IS NOT NULL
        AND elixhauser_quan.aids IS NOT NULL
        AND elixhauser_quan.lymphoma IS NOT NULL
        AND elixhauser_quan.metastatic_cancer IS NOT NULL
        AND elixhauser_quan.solid_tumor IS NOT NULL
        AND elixhauser_quan.rheumatoid_arthritis IS NOT NULL
        AND elixhauser_quan.coagulopathy IS NOT NULL
        AND elixhauser_quan.obesity IS NOT NULL
        AND elixhauser_quan.weight_loss IS NOT NULL
        AND elixhauser_quan.fluid_electrolyte IS NOT NULL
        AND elixhauser_quan.blood_loss_anemia IS NOT NULL
        AND elixhauser_quan.deficiency_anemias IS NOT NULL
        AND elixhauser_quan.alcohol_abuse IS NOT NULL
        AND elixhauser_quan.drug_abuse IS NOT NULL
        AND elixhauser_quan.psychoses IS NOT NULL
        AND elixhauser_quan.depression IS NOT NULL
    ) 
TO '/workspaces/kmeans_clustering/data/patients_w_elixhauser_age.csv'
WITH CSV HEADER;