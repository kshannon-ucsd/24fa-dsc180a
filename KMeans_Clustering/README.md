# Sepsis and Organ Dysfunction K-Means Clustering Analysis

## Overview
This folder implements a K-means clustering analysis on a filtered subset of the MIMIC-III dataset to identify distinct multimorbidity states that correlate with higher mortality rates in organ dysfunction and sepsis. The goal is to replicate findings from the paper titled "Multimorbidity states associated with higher mortality rates in organ dysfunction and sepsis: a data-driven analysis in critical care".

## Files
- `kmeans_by_age_group.py`: Python script for performing K-means clustering by age groups on the filtered subset of the MIMIC-III dataset.
- `kmeans_w_age.py`: Python script for K-means clustering including age as a variable in the dataset.
- `barplot_per_disease.py`: Python script to generate bar plots for disease prevalence per age group.
- `analysis.ipynb`: Jupyter notebook containing the detailed analysis, including data preprocessing, clustering, and visualization.

## Setup
1. Ensure you have the environment setup, check the environment folder README for directions.
2. patients_w_elixhauser_age_group

The data for this project comes from the PostgreSQL database. Follow these steps to extract the data:

1. Ensure you have the environment setup, check the environment folder README for directions.
2. **Open the psql Command Line**: Connect to your PostgreSQL database in the terminal, setting the search path to the `mimiciii` schema.
    ```bash
    psql "dbname=mimic user=postgres host=db port=5432 password=postgres options=--search_path=mimiciii"
    ```
3. **Run the \copy Command**: Copy and paste the SQL script `sql_queries/utilities/patients_w_elixhauser_age_group.sql` into the psql command line after connecting to the database. This script will save the results to `/workspaces/kmeans_clustering/data/patients_w_elixhauser_age_group.csv`. Ensure that the destination directory exists before executing the command to avoid errors. Repeat the same process for the SQL script in `sql_queries/utilities/patients_w_elixhauser_age.sql`
4. **Check the CSV File Output**: Confirm that the output files `patients_w_elixhauser_age.csv` and `patients_w_elixhauser_age_group.csv` has been created in the specified path. Ensure the path has write permissions. If you encounter a “No such file or directory” error, verify that the directory exists and has appropriate permissions.

## Running the Analysis
- Open the analysis notebook `analysis.ipynb`
- Run the cell that reads the data, then run the cell that contains your desired function. 

## Methodology
- Data is filtered from the MIMIC-III dataset focusing on specific Elixhauser categories relevant to the study.
- Patterns are visualized using bar plots and to demonstrate the prevalence and impact of various diseases within age groups to ensure that the patterns match what is presented in the paper.
- K-means clustering is applied to identify patterns in multimorbidity and provide a baseline model for the clustering analysis.
- The clusters are analyzed to determine their association with outcomes like mortality, organ dysfunction, and sepsis.

## Research Paper Reference
For the detailed methodology and original findings, refer to the paper:
Zador, Z., Landry, A., Cusimano, M.D., Geifman, N., "Multimorbidity states associated with higher mortality rates in organ dysfunction and sepsis: a data-driven analysis in critical care", Critical Care (2019).