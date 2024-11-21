# Network Visualization Project

This directory contains the code for generating and visualizing networks based on co-occurrence matrices. It is designed to handle the data outputed from `LCA_post_analysis.ipynb` where the co-occurrence of diseases is analyzed.

## Directory Structure

- `network_vis.ipynb`: A Jupyter notebook that outlines the entire process of network visualization, from data preparation to the final output.
- `functions/create_cooccurrence_matrix.R`: R script to create a matrix that represents the co-occurrence of different conditions within the dataset.
- `functions/create_condition_network.R`: R script for constructing a network from condition data. It takes in the output from `create_cooccurrence_matrix.R` and formats it into a network structure.
- `functions/visualize_condition_network.R`: R script for visualizing the condition network. It takes the network created by `create_condition_network.R` and applies graphical techniques to visualize it. If desired, the visualizations will be save to the `network_visualization/plots` directory

## How to Navigate

1. **Preparation**: Start with the `create_cooccurrence_matrix.R` to build the foundational co-occurrence matrix from your dataset.
2. **Network Construction**: Use `create_condition_network.R` to convert the co-occurrence matrix into a network structure.
3. **Visualization**: Run `visualize_condition_network.R` to generate visual representations of the network.
4. **Analysis and Reporting**: Refer to `network_vis.ipynb` for a detailed walkthrough of the analysis, including additional steps and interpretations of the network visualization.

## Setup and Requirements

- **R Environment**: Ensure you are in the repository's docker environment.

## Running the Scripts

- **R Scripts**: Execute each script sequentially as described in the navigation section. Each script can be run in an R environment, either through an IDE like RStudio or from the command line.
- **Jupyter Notebook**: Open `network_vis.ipynb` in Jupyter Lab or Jupyter Notebook and run the cells sequentially to follow the analysis.

## Support

For any issues or questions, please open an issue in this repository or contact the project maintainer.