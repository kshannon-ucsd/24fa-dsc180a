# Table One Statistics

The `table_one_statistics` folder contains SQL scripts designed to replicate and generate comprehensive patient statistics based on Table One in the main research paper, using data from the MIMIC-III dataset. Each SQL file provides insights into patient demographics, health metrics, and mortality rates, categorized to highlight trends across specific patient groups.

## Purpose

The main goal is to utilize reusable views to produce statistical summaries for specific ICU patient groups. By categorizing patients according to criteria such as age, gender, and disease count, we gain detailed insights into health outcomes, ICU length of stay, and mortality rates for each demographic.

### Patient Cohort Selection Criteria

The analyses focus on a well-defined ICU patient cohort that meets the following criteria:
- Aged between 16 and 95 years at ICU admission.
- Only includes each patient's first ICU stay.

This approach ensures that data consistency and accuracy are maintained across all generated statistics.

## Folder Structure and File Descriptions

To enhance code efficiency and avoid redundancy, two SQL scripts in the `/workspaces/sql_queries/utilities` folder create views that serve as foundational components across the various scripts in `table_one_statistics`. These views simplify the statistical generation process by providing pre-filtered patient cohorts and calculated comorbidities.

### Key SQL Scripts

Each SQL script in the `table_one_statistics` folder categorizes patients differently:

1. **`table_one_age_statistics.sql`** - Categorizes patients by age groups (e.g., 16-24, 25-44).
2. **`table_one_gender_statistics.sql`** - Analyzes patients by gender.
3. **`table_one_disease_count_statistics.sql`** - Categorizes based on the number of diseases (comorbidity count).
4. **`table_one_admission_type_statistics.sql`** - Categorizes patients by admission type (Elective or Non-Elective).
5. **`table_one_overall_statistics.sql`** - Provides a summary of overall patient statistics without categorization for a comprehensive view.

## Workflow: Running the SQL Scripts

To generate the patient statistics, follow these steps in the specified order:

1. **Run `filter_patients_by_age.sql` in `/workspaces/sql_queries/utilities`**  
   This script filters patients based on age and selects only their first ICU admission, creating the `included_patients` view. This view is referenced in all subsequent scripts.

2. **Run `calculate_morbidity_counts.sql` in `/workspaces/sql_queries/utilities`**  
   This script creates a view to calculate each patient’s morbidity count. It is referenced by the statistics scripts to consistently categorize patients based on health conditions.

3. **Run the SQL scripts in `table_one_statistics`**  
   Once the foundational views are in place, execute each SQL script in the `table_one_statistics` folder to produce statistics categorized by age, gender, disease count, admission type, or an overall summary. Each script uses the views established in the previous steps to ensure consistent filtering and calculation across analyses.

## Important Notes

- **Patient Group Size Difference**: The group of patients we analyzed slightly differs from the cohort in the main paper. Our selection contains 36,607 patients, compared to the original study's 36,390. While not identical, the close numbers allow for comparability with a high level of accuracy.
