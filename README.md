
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

5. **PhysioNet Account**  
   You need a PhysioNet account to access the MIMIC dataset. Complete the credentialing process on [PhysioNet](https://physionet.org) and the required CITI training.
---

## Development Environment Setup

### 1. Dev Container Setup

Our development environment leverages Docker and VS Code for consistent project builds. Here’s how to set up the environment:

- **Clone the Repository**:  
  ```bash
  git clone https://github.com/Bobby-Zhu/practice_dev_container.git
  cd practice_dev_container/.devcontainer
  ```

- **Run the Docker Image**:  
  ```bash
  docker-compose up --build
  ```

- **Attach VS Code to the Container**:
  In VS Code, use the command palette (Ctrl+Shift+P or Cmd+Shift+P) and select **Dev Containers: Attach to Running Container**.

More details on the setup process can be found in the `Setting up Dev Container` documentation.

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

For troubleshooting, refer to the `DBeaver Connection Setup` document.
---
For further instructions if you encountered any errors, please check out our detailed documentation in the following drive: [![Google Drive](https://img.shields.io/badge/Google%20Drive-Download-blue?style=for-the-badge&logo=google-drive)]([https://drive.google.com/your-google-drive-link](https://drive.google.com/drive/folders/1LXyeajgaP6ZGrZ3qHgaqk_2KS-99jof9?usp=share_link))

---

## Local File Mount

To add local files to the Docker container, update your `docker-compose.yml` and `devcontainer.json` files to include the local mount path. Use the following configurations:

```yaml
services:
  app:
    volumes:
      - /path/to/mimic/database/folder/mimic-data:/mnt/mimic-data:cached
```

For detailed steps on mounting files, see the `Adding a Local File Mount` document.

### Setup Summary:

Please ensure that you have modified the required paths to the data. Here are the files that you should have modified by now:

- devcontainer.json (mounts section)
- docker-compose.yml (volumes section)

---

### Team Members:
- Ahmed Mostafa
- Bobby Zhu
- Tongxun Hu
