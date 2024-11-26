\copy (
select * from mimiciii.sofa
) TO '/workspaces/LCA_Analysis/data/raw_data/sofa.csv' WITH CSV HEADER;

\copy (
select * from mimiciii.angus
) TO '/workspaces/LCA_Analysis/data/raw_data/angus.csv' WITH CSV HEADER;

\copy (
select * from mimiciii.oasis
) TO '/workspaces/LCA_Analysis/data/raw_data/oasis.csv' WITH CSV HEADER;

\copy (
select * from mimiciii.patients
) TO '/workspaces/LCA_Analysis/data/raw_data/patients.csv' WITH CSV HEADER;

\copy (
WITH co_dx AS
(
	SELECT hadm_id
	, MAX(
    	CASE
    		WHEN icd9_code = '99592' THEN 1
      ELSE 0 END
    ) AS severe_sepsis
	, MAX(
    	CASE
    		WHEN icd9_code = '78552' THEN 1
      ELSE 0 END
    ) AS septic_shock
  from diagnoses_icd
  GROUP BY hadm_id
)
select
  adm.subject_id
  , adm.hadm_id
	, co_dx.severe_sepsis
  , co_dx.septic_shock
	, case when co_dx.severe_sepsis = 1 or co_dx.septic_shock = 1
			then 1
		else 0 end as sepsis
FROM admissions adm
left join co_dx
  on adm.hadm_id = co_dx.hadm_id
order by adm.subject_id, adm.hadm_id
) TO '/workspaces/LCA_Analysis/data/raw_data/sepsis.csv' WITH CSV HEADER;