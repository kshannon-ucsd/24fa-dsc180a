
# Sepsis - Using Clinical Healthcare Data Science to Identify and Combat an Infectious Killer

## Data Science Capstone Project - DSC 180AB  

### Project Overview

This project aims to explore severe infection management and detection in inpatient ICU care, with a focus on sepsis, using the MIMIC-III dataset. In this phase, we focus on reproducing the results of the paper:
*Zador, Z., Landry, A., Cusimano, M.D., et al. Multimorbidity states associated with higher mortality rates in organ dysfunction and sepsis: a data-driven analysis in critical care.* (2019). Available at: [https://doi.org/10.1186/s13054-019-2486-6](https://doi.org/10.1186/s13054-019-2486-6)
Our goal is to affirm the original conclusions and methodologies around critical care patient subgroups, particularly those at higher risk of mortality due to organ dysfunction and sepsis. 

---

## Accessing the MIMIC Dataset

The MIMIC-III database is a freely accessible, de-identified dataset containing detailed clinical data for ICU patients. To access the data, follow these steps:

1. **Create a PhysioNet account** at [https://physionet.org](https://physionet.org) using your UCSD email.
2. Complete the required **CITI training course** for human research protection.
3. Upload your training certificate to PhysioNet.
4. **Apply for credentialing** on PhysioNet, listing Kyle Shannon (kshannon@ucsd.edu) as your supervisor.
5. Once approved, sign the **Data Use Agreement** for both MIMIC-III and MIMIC-IV datasets.
6. Download the datasets and store them in the `/mnt/mimic-data` folder in your project directory.

For more detailed instructions, see the official MIMIC-III documentation at [https://mimic.physionet.org](https://mimic.physionet.org).

---

## Repository Structure

This repository is organized into several key components, each designed to support the project's objectives of data preprocessing, analysis, and reproducibility:

### **1. Environment Setup**
- **Purpose**: Provides the infrastructure for a containerized development environment using Docker and VS Code.
- **Location**: `environment/`
- **Key Files**:
  - `docker-compose.yml`: Configures Docker containers for the app and PostgreSQL database.
  - `devcontainer.json`: Defines settings for the VS Code development container.
  - `.env.example`: A template for environment variables, including PostgreSQL and dataset paths.
  - `test_dependencies.py`: Ensures Python libraries are properly installed.
  - `test_connection.py`: Verifies PostgreSQL database connectivity and functionality.

### **2. Data Analysis**
- **Purpose**: Focuses on reproducing paper findings using patient data extracted from the MIMIC-III database.
- **Location**: `sql_queries/analysis/`
- **Key Components**:
  - **`table_one_statistics/`**: Contains SQL scripts for generating patient statistics categorized by age, gender, comorbidities, and admission type. These scripts aim to replicate and enhance Table One from the referenced paper.
  - **Utility Scripts**: Found in `sql_queries/utilities/`, these scripts create foundational views (`included_patients` and comorbidity counts) to ensure consistent and efficient analyses across multiple SQL queries.

### **3. Latent Class Analysis (LCA)**
- **Purpose**: Applies Latent Class Analysis to identify and categorize subgroups of ICU patients based on shared characteristics.
- **Location**: `LCA_Analysis/`
- **Key Files**:
  - `LCA_analysis.ipynb`: Performs the primary LCA, including data preprocessing, model training, and determining the optimal number of latent classes.
  - `LCA_post_analysis.ipynb`: Handles post-analysis, visualizing the results and interpreting subgroup characteristics.
  - `data/`: Stores raw and processed datasets used in the LCA workflow.
  - `utils/`: A directory containing reusable utility functions that support data handling, model training, and result visualization in the analysis notebooks.
  - `plots/`: Contains visual outputs, such as subgroup distributions and key insights.


## Prerequisites

Before setting up the development environment, ensure that you have the following tools installed:

1. **Docker**  
   Docker is used to create and manage containers. Install Docker Desktop for your operating system:
   - [Docker for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - [Docker for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - [Docker for Linux](https://docs.docker.com/engine/install/)

2. **Visual Studio Code (VS Code)**  
   VS Code is the recommended code editor for this project. Download and install from:
   - [VS Code Download](https://code.visualstudio.com/)

3. **VS Code Extensions**  
   Install the following extensions in VS Code:
   - **Docker**: Manages and interacts with Docker containers.
   - **Dev Containers**: Facilitates development inside containers.
   - **Remote Explorer**: Allows connecting to remote containers.
   You can install these extensions directly from the VS Code Marketplace.

4. **PostgreSQL Client (Optional)**  
   If you want to connect to the PostgreSQL database from your local machine, make sure to install a PostgreSQL client:
   - For macOS:  
     ```bash
     brew install postgresql
     ```
   - For Windows: Install via [PostgreSQL Windows Installer](https://www.postgresql.org/download/windows/).

---

## Development Environment Setup

### 1. Dev Container Setup

Follow the steps in the [environment README.md](environment/README.md) to configure the containerized environment and verify dependencies.


### 2. PostgreSQL Database Setup

Once inside the dev container, you will set up and connect to the PostgreSQL database:

- **Create the MIMIC Database**:  
  ```bash
  make create-user mimic datadir=/mnt/mimic-data DBHOST=db DBPORT=5432
  ```

- **Connect to the Database**:  
  ```bash
  psql -U postgres -d mimic
  ALTER DATABASE mimic SET search_path TO mimiciii;
  ```

For local access, ensure your Docker setup exposes port 5432 and use the `psql` command from your local machine to connect. For full instructions, see the `Accessing PostgreSQL Inside Container` document.

---

## Optional: DBeaver Database Access

You can also manage the PostgreSQL database using DBeaver. Here’s how to connect:

1. Open DBeaver and create a new PostgreSQL connection.
2. Use the following settings:
   - Host: `localhost`
   - Port: `5432`
   - Database: `mimic`
   - Username: `postgres`
   - Password: `postgres`

#### For troubleshooting, refer to the `DBeaver Connection Setup` document.
---
For further instructions if you encountered any errors, please check out our detailed documentation in the following drive: [![Google Drive](https://img.shields.io/badge/Google%20Drive-Download-blue?style=for-the-badge&logo=google-drive)](https://drive.google.com/drive/folders/1LXyeajgaP6ZGrZ3qHgaqk_2KS-99jof9?usp=share_link)


---

### Team Members:
- Ahmed Mostafa
- Bobby Zhu
- Tongxun Hu
