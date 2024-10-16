# Practice Dev Container

## Project Overview

This project sets up a Python development environment using **Docker** with **Miniconda** and **PostgreSQL**. The environment is containerized using VS Code Dev Containers, allowing seamless collaboration and consistent development across different systems. Dependencies are managed using **Conda** and **pip**, and PostgreSQL is set up for database management.

## Features

- Python 3.12.4 with essential data science libraries (e.g., `numpy`, `pandas`, `scikit-learn`).
- PostgreSQL integration for database management.
- Containerized environment for reproducible development using VS Code Dev Containers.
- Easy setup with Conda and pip for package management.

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
   git clone https://github.com/Bobby-Zhu/practice_dev_container.git
   cd practice_dev_container

2. **Open the project in VS Code**:
   - Open VS Code and navigate to the project folder.
   - You will be prompted to "Reopen in Container." Choose this option to set up the containerized environment.

3. **Set up environment variables**:
   - Copy the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Modify the `.env` file with your PostgreSQL credentials (if applicable):
     ```bash
     POSTGRES_USER=your_username
     POSTGRES_PASSWORD=your_password
     POSTGRES_DB=your_database
     POSTGRES_HOST=your_hostname
     ```

4. **Container Initialization**:
   - VS Code will automatically build the Docker container and set up the development environment.
   - It will install all dependencies (both Conda and pip) as specified in the `environment.yml` file.
   - PostgreSQL will be started in a separate container.

5. **Verify dependencies**:
   - Run the `test_dependencies.py` script to ensure all required libraries are installed correctly:
     ```bash
     python test_dependencies.py
     ```
   - You should see a message indicating that all dependencies are successfully installed.
