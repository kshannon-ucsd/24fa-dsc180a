# README for LCA Analysis Project

## Project Overview
This project focuses on performing Latent Class Analysis (LCA) to identify subgroups within a population based on patient characteristics. The analysis is aimed at understanding and categorizing different types of sepsis patients. The results of this analysis can be useful for healthcare research, policy-making, and targeted intervention strategies.

## What is LCA?
Latent Class Analysis (LCA) is a statistical technique used to discover hidden subgroups within a population by analyzing patterns in observed data. In healthcare and social sciences, LCA helps identify groups that share similar characteristics, which may not be immediately visible from raw data. Each group, or "class," represents individuals with similar patterns in their responses or attributes.

## Data and Features Used
The analysis is based on the following patient characteristics:
- **admission_type**: The type of admission (e.g., emergency, elective).
- **gender**: The gender of the patient.
- **age_at_admission**: The age of the patient at the time of admission.
- **30 Elixhauser indices**: A comprehensive set of comorbidity measures summarizing the presence of 30 different health conditions to capture patient health status and complexity.

## Project Structure
The project is organized as follows:
- **LCA_analysis.ipynb**: This Jupyter Notebook performs the primary LCA. It includes data preprocessing, model training, and the determination of the optimal number of latent classes.
- **LCA_post_analysis.ipynb**: This notebook handles the post-analysis phase, including interpretation and visualization of the LCA results. It generates insights into the characteristics of each identified subgroup.
- **utils/**: A directory containing reusable utility functions that support data handling, model training, and result visualization in the analysis notebooks.
- **data/**: Contains the dataset(s) used for LCA. The data is structured to include the key features mentioned above.
- **plots/**: Stores visual outputs from the analysis, including plots that illustrate the LCA results and the characteristics of each subgroup.
- **README.md**: This file, providing an overview of the project, its methodology, and its structure.

## Analysis Workflow
1. **Data Preprocessing**:
   - Data is cleaned and preprocessed to ensure consistency and reliability.
   - The selected features (`admission_type`, `gender`, `age_at_admission`, `30 Elixhauser indices`) are prepared for analysis.

2. **LCA Execution**:
   - The `LCA_analysis.ipynb` notebook runs the LCA, training the model to identify the optimal number of latent classes that best represent the data.

3. **Post-Analysis**:
   - The `LCA_post_analysis.ipynb` notebook interprets the results, providing a detailed view of each subgroup's characteristics.
   - Visualizations are created to illustrate the distribution and key attributes of the identified classes.

## Results
The final outputs, including subgroup characteristics and LCA plots, can be found in the `plots/` directory. These visualizations provide insights into how different patient groups are defined based on the selected features.

## Dependencies
- Python (version 3.x)
- Jupyter Notebook
- Libraries: `pandas`, `numpy`, `scikit-learn`, `matplotlib`, `seaborn`, and other data analysis and visualization tools.

## Usage
1. Open and run `LCA_analysis.ipynb` to perform the LCA on the dataset.
2. Run `LCA_post_analysis.ipynb` to interpret and visualize the results.
3. Review the generated plots in the `plots/` directory for a comprehensive understanding of the subgroups.

