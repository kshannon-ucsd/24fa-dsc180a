import matplotlib.pyplot as plt
import seaborn as sns
import utils.modeling as modeling
import numpy as np
import os

def save_plot(output_dir,name):
    """
    Save plots created from visualization to the 'out_dir/name'
    Parameters:
    - output_dir: output directoty that would be used with name to create save path of the plot
    - name: name of the plot that would be used with output_dir to create save path of the plot

    Returns:
    - None
    """
    os.makedirs(output_dir, exist_ok=True)
    plt.savefig(f"{output_dir}/{name}.png")


def plot_subgroup_characteristics(df, bubble_size_scale=10, save_plots=True, output_dir="plots"):
    """
    Creates a bubble plot of subgroup characteristics by multimorbidity count and a box plot
    of age distribution within subgroups.
    
    Parameters:
    - df (pd.DataFrame): DataFrame containing 'class_assignment', 'count_morbidity', 'percent', and 'age_at_admission' columns.
    - bubble_size_scale (float): Scaling factor for bubble sizes in the bubble plot. Default is 10.
    - save_plots (bool): Whether to save the plots as images. Default is False.
    - output_dir (str): Directory to save the plots if save_plots=True. Default is "plots".
    
    Returns:
    - None (displays the plots and optionally saves them to the specified directory).
    """
    # Create the figure
    plt.figure(figsize=(15, 8))
    
    # Bubble Plot
    plt.subplot(1, 2, 1)
    scatter = plt.scatter(
        x=df['class_assignment'],
        y=df['count_morbidity'],
        s=df['percent'] * bubble_size_scale,  # Scale bubble size
        alpha=1,
        c=df['class_assignment'],  # Color by subgroup
        cmap='Set1'  # Color map
    )
    plt.xlabel("Subgroup")
    plt.ylabel("Multimorbidity count")
    plt.title("Subgroup Characteristics by Multimorbidity Count and Percentage")
    
    # Legend for bubble sizes
    for size in [10, 20, 30]:  # Adjust sizes to match your `percent` range
        plt.scatter([], [], s=size * bubble_size_scale, color='gray', alpha=0.5, label=str(size) + '%')
    plt.legend(
        title="Percent",
        loc="upper left",
        bbox_to_anchor=(1.05, 1),
        scatterpoints=1,
        frameon=True,
        labelspacing=1.2,
        borderpad=1.2
    )
    
    # Box Plot
    plt.subplot(1, 2, 2)
    sns.boxplot(
        data=df,
        x="class_assignment",
        y="age_at_admission",
        palette="Set1"
    )
    plt.xlabel("Subgroup")
    plt.ylabel("Age (years)")
    plt.title("Boxplot of Age Distribution in Subgroups")
    
    # Display or save the plots
    plt.tight_layout()
    if save_plots:
        save_plot(output_dir,"subgroup_characteristics_plots")

    plt.show()



def plot_roc_curves(df, feature_columns, colors, save_plots=True, output_dir="plots", cv_splits=10):
    """
    Plots ROC curves for each unique class in `class_assignment` with one-vs-all AUC-ROC evaluation.
    
    Parameters:
    - df (pd.DataFrame): DataFrame containing data and class assignments.
    - feature_columns (list): List of feature columns for logistic regression.
    - colors (list): List of colors for each class's ROC curve.
    - cv_splits (int): Number of splits for cross-validation. Default is 10.
    
    Returns:
    - None (displays the plot)
    """
    plt.figure(figsize=(10, 8))
    
    # Iterate over unique classes and plot ROC for each
    for i, class_label in enumerate(sorted(df["class_assignment"].unique())):
        print(f"Processing class {class_label} vs. all")
        
        # Calculate ROC data
        fpr, tpr, auc_score = modeling.calculate_auc_for_class(df, class_label, feature_columns, cv_splits)
        print(f"Cross-validated AUC-ROC for class {class_label} vs. all: {auc_score:.3f}")
        
        # Plot ROC curve for the class
        plt.plot(fpr, tpr, color=colors[i % len(colors)], lw=2, linestyle='--',
                 label=f"CV - Class {class_label} (AUC = {auc_score:.2f})")
    
    # Plot the diagonal for random guessing
    plt.plot([0, 1], [0, 1], color='gray', linestyle='--', lw=2)
    
    # Customize the plot
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('1 - Specificity (False Positive Rate)')
    plt.ylabel('Sensitivity (True Positive Rate)')
    plt.title('ROC Curves for Each Subgroup')
    plt.legend(loc="lower right")
    plt.grid()
    if save_plots:
        save_plot(output_dir,"roc_curves_plots")
    plt.show()



def plot_subgroup_bar_plot(df,output_dir="plots"):
    # Get the colormap
    cmap = plt.cm.get_cmap('tab10')

    # Create bar plots for each subgroup
    fig, axes = plt.subplots(2, 3, figsize=(18, 10), sharey=True)
    axes = axes.flatten()

    for i, (class_id, row) in enumerate(df.iterrows()):
        ax = axes[i]
        # Assign a different color from the colormap to each bar
        colors = [cmap(j / len(row)) for j in range(len(row))]
        row.plot(kind='bar', ax=ax, color=colors, edgecolor='black')
        ax.set_title(f'Subgroup {class_id}')
        ax.set_ylabel('Prevalence')
        ax.set_xlabel('Condition')
        ax.set_xticklabels(row.index, rotation=45, ha='right')

    plt.tight_layout()
    save_plot(output_dir,"subgroup_bar_plot")
    plt.show()


def plot_polar_subgroup(df,output_dir="plots"):
    """
    Generate polar bar plots for each subgroup (e.g., class assignments), showing condition prevalence.
    
    Parameters:
        df (DataFrame): A DataFrame where each row corresponds to a subgroup (class) and columns are conditions.
    """
    # Get the colormap
    cmap = plt.cm.get_cmap('tab10')

    # Create polar bar plots for each subgroup
    fig, axes = plt.subplots(2, 3, subplot_kw={'projection': 'polar'}, figsize=(18, 10))
    axes = axes.flatten()

    for i, (class_id, row) in enumerate(df.iterrows()):
        ax = axes[i]
        # Number of conditions
        num_conditions = len(row)
        
        # Angles for the bars
        angles = np.linspace(0, 2 * np.pi, num_conditions, endpoint=False)
        
        # Bar heights (prevalence)
        heights = row.values
        
        # Colors for bars
        colors = [cmap(j / num_conditions) for j in range(num_conditions)]
        
        # Create the bars
        bars = ax.bar(angles, heights, color=colors, edgecolor='black', width=2 * np.pi / num_conditions)
        
        # Label only the top 6 highest bars for clarity
        top6_indices = row.nlargest(6).index
        for angle, height, label in zip(angles, heights, row.index):
            if label in top6_indices:
                ax.text(
                    angle, 
                    height + 0.05,  # Position slightly above the bar
                    label, 
                    fontsize=10, 
                    ha='center', 
                    va='bottom'
                )
        
        # Set plot aesthetics
        ax.set_title(f'Subgroup {class_id}', va='bottom', fontsize=10)
        ax.set_theta_zero_location("N")
        ax.set_theta_direction(-1)
        ax.set_yticks([])  # Hide radial gridlines
        ax.set_xticks([])  # Remove default tick labels

    # Adjust layout
    plt.tight_layout()
    save_plot(output_dir,"plot_polar_subgroup")
    plt.show()



def plot_polar_all(mean_prevalence, output_dir="plots"):
    """
    Generate a polar bar plot normalized to 50% prevalence.
    
    Parameters:
        mean_prevalence (Series): A pandas Series containing the mean prevalence of conditions.
    """
    # Number of conditions
    num_conditions = len(mean_prevalence)
    
    # Angles for the bars
    angles = np.linspace(0, 2 * np.pi, num_conditions, endpoint=False)
    
    # Bar heights (normalized prevalence)
    heights = mean_prevalence.values
    
    # Create polar plot
    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw={'projection': 'polar'})
    
    # Assign colors to bars (optional: single gray color)
    bars = ax.bar(
        angles, 
        heights, 
        color='gray', 
        edgecolor='black', 
        width=2 * np.pi / num_conditions
    )
    
    
    # Set labels
    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.set_xticks(angles)
    ax.set_xticklabels(mean_prevalence.index, fontsize=8, rotation=45, ha='right')
    
    # Title and legend
    ax.set_title('Polar Bar Plot (Capped at 50% Prevalence)', va='bottom', fontsize=14)
    ax.legend(loc='upper right', fontsize=10)

    # Show plot
    plt.tight_layout()
    save_plot(output_dir,"plot_polar_all")
    plt.show()

def plot_boxplot_by_subgroup(df, score_column,output_dir="plots"):
    """
    Plot a boxplot for a given score column grouped by subgroups.

    Parameters:
    - df (DataFrame): The DataFrame containing the data.
    - score_column (str): The name of the column to plot (e.g., 'SOFA score' or 'OASIS score').
    - title (str): Title for the subplot (e.g., 'A', 'B').
    - ylabel (str): Label for the y-axis (e.g., 'SOFA score', 'OASIS score').

    Returns:
    - None
    """
    # Ensure 'class_assignment' column is renamed to 'Subgroup'
    df.rename(columns={'class_assignment': 'Subgroup'}, inplace=True)

    # Create the boxplot
    plt.figure(figsize=(8, 6))
    sns.boxplot(
        data=df,
        x='Subgroup',
        y=score_column,
        palette='tab10',
        order=sorted(df['Subgroup'].unique())  # Ensure consistent subgroup ordering
    )

    plt.ylabel(f"{score_column} score")
    plt.xlabel('Subgroup')
    plt.tight_layout()
    save_plot(output_dir,"plot_boxplot_by_subgroup")
    plt.show()

def plot_bar(data, y_label="Percent prevalence", colors=("red", "blue"),output_dir="plots"):
    """
    Create bar plots with error bars and distinct colors for each attribute.
    """
    x = np.arange(len(data.index))  # Subgroups
    bar_width = 0.35  # Width of each bar
    fig, ax = plt.subplots(figsize=(8, 6))

    # Iterate through conditions and ensure different coloring for each attribute
    for i, column in enumerate(data.columns):
        offsets = x + (i * bar_width)  # Adjust position of each bar
        ax.bar(
            offsets,
            data[column],
            width=bar_width,
            label=column,
            color=colors[i % len(colors)],  # Use different colors for attributes
            edgecolor="black"
        )

    # Set axis labels and ticks
    ax.set_ylabel(y_label, fontsize=12)
    ax.set_xlabel("Subgroup", fontsize=12)
    ax.set_xticks(x + bar_width / 2)  # Center the ticks
    ax.set_xticklabels(data.index, fontsize=10)
    ax.legend(title="Conditions", fontsize=10)

    # Display grid for better visualization
    ax.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()
    save_plot(output_dir,"plot_bar")
    plt.show()