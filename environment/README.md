# Setting Up a Containerized Python, R, and PostgreSQL Environment

## Overview

This guide sets up a comprehensive development environment using **Docker** with **Miniconda** and **PostgreSQL**. The environment is containerized using VS Code Dev Containers, allowing seamless collaboration and consistent development across different systems. Dependencies are managed using **Conda**, **pip**, and **CRAN** for R packages. **PostgreSQL** is set up for database management, and the environment supports both Python and R within **Jupyter Notebooks**.

## Features

- **Python 3.12.4** with essential data science libraries:
  - `ipykernel`
  - `scikit-learn`
  - `pandas`
  - `numpy`
  - `psycopg2`
  - `sqlalchemy`
  - `statsmodels`
  - `matplotlib`
  - `seaborn`
  - `networkx`
  - `scipy`
  - `flake8`
  - `pylca` (via pip)
  - `eralchemy` (via pip)
- **R** with essential packages:
  - `IRkernel`
  - `reticulate`
  - `reshape2`
  - `plyr`
  - `dplyr`
  - `poLCA`
  - `ggplot2`
  - `ggparallel`
  - `igraph`
  - `tidyr`
  - `knitr`
- **Jupyter Notebook** configured to use both Python and R kernels.
- **PostgreSQL** integration for database management.
- Containerized environment for reproducible development using **VS Code Dev Containers**.
- Pre-configured **VS Code** settings and extensions for an enhanced development experience.
- Easy setup with **Conda**, **pip**, and **CRAN** for package management.


## Development Environment Setup

### Prerequisites

Before you begin, ensure you have the following installed on your local machine:

1. **Docker**: Make sure Docker is installed and running.
   - [Install Docker](https://docs.docker.com/get-docker/)
   
2. **Visual Studio Code (VS Code)** with the **Remote - Containers extension**.
   - [Install VS Code](https://code.visualstudio.com/)
   - Install the **Remote - Containers** extension from the VS Code marketplace.

### Steps to Set Up the Project

1. **Clone the repository**:

   ```bash
   git clone https://github.com/kshannon-ucsd/24fa-dsc180a-team1.git

2. **Set up environment variables**:

   - Open VS Code:
     - Click on **File** > **Open Folder** and select the `24fa-dsc180a-team1` folder.
   - Navigate to the `.devcontainer` directory inside the `environment` folder:
     ```bash
     cd environment/.devcontainer
     ```
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Modify the `.env` file with your PostgreSQL credentials and other variables:
     ```bash
     POSTGRES_USER=your_username
     POSTGRES_PASSWORD=your_password
     POSTGRES_DB=your_database
     POSTGRES_HOST=localhost
     
     GITHUB_USER_NAME=your_github_username
     GITHUB_EMAIL=your_email@example.com

     PATH_TO_MIMIC_DATABASE_FOLDER=/path/to/mimic-iii-clinical-database-1.4/
     ```
     - **POSTGRES_USER**, **POSTGRES_PASSWORD**, **POSTGRES_DB**: Credentials for your PostgreSQL database.
     - **POSTGRES_HOST**: Should be set to `localhost` to connect within the container network.
     - **GITHUB_USER_NAME**, **GITHUB_EMAIL**: Your GitHub username and email for Git configuration within the container.
     - **PATH_TO_MIMIC_DATABASE_FOLDER**: The absolute path to your local MIMIC-III Clinical Database folder. Ensure you have the necessary permissions to access this path.

3. **Run Docker Image and Connect to Container**:

   **Option 1 (Recommended): Using Command Line**

   1. **Navigate to the `.devcontainer` directory**:  
      This ensures that Docker commands are executed from the correct location where the `docker-compose.yml` file is located.  
      ```bash
      cd environment/.devcontainer
      ```

   2. **Shut down any existing containers and remove images**:  
      ```bash
      docker-compose down --rmi all
      ```
      - This command stops all running containers and removes the associated Docker images to start fresh. The `--rmi all` flag removes all images, ensuring a clean rebuild.

   3. **Build and start the containers**:  
      ```bash
      docker-compose up --build
      ```
      - This command builds the containers from the `Dockerfile` and starts the development environment. The `--build` flag ensures that any changes to the Docker configuration or environment are applied during the build process.

   4. **Open VS Code and attach to the running container**:  
      - In VS Code, go to the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on Mac) and select **Dev Containers: Attach to Running Container**.
      - Choose the container you just started. This connects your VS Code session to the running container, allowing you to develop within the isolated environment.

   **Option 2: Using VS Code’s Container Features**

   - Use the **Dev Containers: Reopen in Container** command from the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on Mac).  
   - This option automatically starts the Docker container based on the `.devcontainer` configuration, eliminating the need for manual command-line steps.

4. **Container Initialization**:

   - VS Code will automatically build the Docker container and set up the development environment.
   - It will install all dependencies (both Conda and pip) as specified in the `environment.yml` file.
   - **PostgreSQL** will be started in a separate container.

5. **Verify Environment and Dependencies**

   ### Verify Python Dependencies

   - Run the `test_dependencies.py` script to ensure all required Python libraries are installed correctly:
     ```bash
     python test_dependencies.py
     ```
     - This script checks the Python environment and verifies the installation of required libraries such as `scikit-learn`, `pandas`, `numpy`, and more.

   ### Verify PostgreSQL Connection

   - Run the `test_connection.py` script to verify the connection to PostgreSQL and the database setup:
     ```bash
     python test_connection.py
     ```
     - This script connects to PostgreSQL, creates a test table, inserts sample data, and queries the table to confirm database functionality.

   - Ensure both scripts run without errors. If any issues occur, check the Python dependencies or database configurations and try again.
