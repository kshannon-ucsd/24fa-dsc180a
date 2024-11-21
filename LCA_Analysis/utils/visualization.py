import matplotlib.pyplot as plt
import seaborn as sns
import LCA_Analysis.utils.evaluation as evaluation
import numpy as np
import os


def save_plot(output_dir, name):
    """
    Save plots created from visualization to the 'output_dir/name'.

    Parameters:
    - output_dir: Output directory that would be used with name to
      create the save path of the plot.
    - name: Name of the plot that would be used with output_dir to
      create the save path of the plot.

    Returns:
    - None
    """
    os.makedirs(output_dir, exist_ok=True)
    plt.savefig(f"{output_dir}/{name}.png")


def plot_subgroup_characteristics(
    df, bubble_size_scale=10, save_plots=False, output_dir="../output/plots"
):
    """
    Creates a bubble plot of subgroup characteristics by multimorbidity count
    and a box plot of age distribution within subgroups.

    Parameters:
    - df (pd.DataFrame): DataFrame containing 'class_assignment',
      'count_morbidity', 'percent', and 'age_at_admission' columns.
    - bubble_size_scale (float): Scaling factor for bubble sizes in
      the bubble plot. Default is 10.
    - save_plots (bool): Whether to save the plots as images.
      Default is False.
    - output_dir (str): Directory to save the plots if save_plots=True.
      Default is "plots".

    Returns:
    - None (displays the plots and optionally saves them to
      the specified directory).
    """
    plt.figure(figsize=(15, 8))

    # Bubble Plot
    plt.subplot(1, 2, 1)
    plt.scatter(
        x=df['class_assignment'],
        y=df['count_morbidity'],
        s=df['percent'] * bubble_size_scale,
        alpha=1,
        c=df['class_assignment'],
        cmap='Set1'
    )
    plt.xlabel("Subgroup")
    plt.ylabel("Multimorbidity count")
    plt.title("Subgroup Characteristic by Multimorbidity Count and Percentage")

    for size in [10, 20, 30]:
        plt.scatter(
            [], [], s=size * bubble_size_scale,
            color='gray', alpha=0.5, label=f"{size}%"
        )
    plt.legend(
        title="Percent", loc="upper left", bbox_to_anchor=(1.05, 1),
        scatterpoints=1, frameon=True, labelspacing=1.2, borderpad=1.2
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

    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "subgroup_characteristics_plots")

    plt.show()


def plot_roc_curves(
    df, feature_columns, colors,
    save_plots=False, output_dir="../output/plots", cv_splits=10
):
    """
    Plots ROC curves for each unique class in 'class_assignment'
    with one-vs-all AUC-ROC evaluation.

    Parameters:
    - df (pd.DataFrame): DataFrame with data and class assignments.
    - feature_columns (list): Feature columns for logistic regression.
    - colors (list): Colors for each class's ROC curve.
    - cv_splits (int): Number of splits for cross-validation. Default is 10.

    Returns:
    - None
    """
    plt.figure(figsize=(10, 8))

    for i, class_label in enumerate(sorted(df["class_assignment"].unique())):
        print(f"Processing class {class_label} vs. all")

        fpr, tpr, auc_score = evaluation.calculate_auc_for_class(
            df, class_label, feature_columns, cv_splits
        )
        print(
            f"Cross-validated AUC-ROC for class {class_label} vs. all: "
            f"{auc_score:.3f}"
        )

        plt.plot(
            fpr, tpr, color=colors[i % len(colors)], lw=2, linestyle='--',
            label=f"CV - Class {class_label} (AUC = {auc_score:.2f})"
        )

    plt.plot([0, 1], [0, 1], color='gray', linestyle='--', lw=2)

    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('1 - Specificity (False Positive Rate)')
    plt.ylabel('Sensitivity (True Positive Rate)')
    plt.title('ROC Curves for Each Subgroup')
    plt.legend(loc="lower right")
    plt.grid()
    if save_plots:
        save_plot(output_dir, "roc_curves_plots")
    plt.show()


def plot_subgroup_bar_plot(df, save_plots=False, output_dir="../output/plots"):
    """
    Creates bar plots for subgroup characteristics.

    Parameters:
    - df (pd.DataFrame): DataFrame containing subgroup data.
    - output_dir (str): Directory to save the plots if save_plots=True.
      Default is "plots".

    Returns:
    - None
    """
    cmap = plt.cm.get_cmap('tab10')

    fig, axes = plt.subplots(2, 3, figsize=(18, 10), sharey=True)
    axes = axes.flatten()

    for i, (class_id, row) in enumerate(df.iterrows()):
        ax = axes[i]
        colors = [cmap(j / len(row)) for j in range(len(row))]
        row.plot(kind='bar', ax=ax, color=colors, edgecolor='black')
        ax.set_title(f'Subgroup {class_id}')
        ax.set_ylabel('Prevalence')
        ax.set_xlabel('Condition')
        ax.set_xticklabels(row.index, rotation=45, ha='right')

    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "subgroup_bar_plot")
    plt.show()


def plot_polar_subgroup(df, save_plots=False, output_dir="../output/plots"):
    """
    Generate polar bar plots for each subgroup (e.g., class assignments),
    showing condition prevalence.

    Parameters:
    - df (pd.DataFrame): A DataFrame where each row corresponds to a subgroup
      (class) and columns are conditions.

    Returns:
    - None
    """
    cmap = plt.cm.get_cmap('tab10')

    fig, axes = plt.subplots(
        2, 3, subplot_kw={'projection': 'polar'}, figsize=(18, 10)
    )
    axes = axes.flatten()

    for i, (class_id, row) in enumerate(df.iterrows()):
        ax = axes[i]
        num_conditions = len(row)
        angles = np.linspace(0, 2 * np.pi, num_conditions, endpoint=False)
        heights = row.values
        colors = [cmap(j / num_conditions) for j in range(num_conditions)]

        # Create the bars
        ax.bar(
            angles,
            heights,
            color=colors,
            edgecolor='black',
            width=2 * np.pi / num_conditions
        )

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
        ax.set_title(f'Subgroup {class_id}', va='bottom', fontsize=10)
        ax.set_theta_zero_location("N")
        ax.set_theta_direction(-1)
        ax.set_yticks([])
        ax.set_xticks([])

    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "plot_polar_subgroup")
    plt.show()


def plot_polar_all(
    mean_prevalence, save_plots=False, output_dir="../output/plots"
):
    """
    Generate a polar bar plot normalized to 50% prevalence.

    Parameters:
    - mean_prevalence (pd.Series): A pandas Series containing the mean
      prevalence of conditions.

    Returns:
    - None
    """
    num_conditions = len(mean_prevalence)
    angles = np.linspace(0, 2 * np.pi, num_conditions, endpoint=False)
    heights = mean_prevalence.values

    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw={'projection': 'polar'})

    ax.bar(
        angles, heights, color='gray', edgecolor='black',
        width=2 * np.pi / num_conditions
    )

    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.set_xticks(angles)
    ax.set_xticklabels(
        mean_prevalence.index, fontsize=8, rotation=45, ha='right'
    )

    ax.set_title(
        'Polar Bar Plot (Capped at 50% Prevalence)',
        va='bottom', fontsize=14
    )

    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "plot_polar_all")
    plt.show()


def plot_bar(data, y_label="Percent prevalence", colors=("red", "blue"),
             save_plots=False, output_dir="../output/plots"):
    """
    Create bar plots with distinct colors for each attribute.

    Parameters:
    - data (pd.DataFrame): DataFrame containing prevalence
    data for each subgroup.
    - y_label (str): Label for the y-axis. Default is "Percent prevalence".
    - colors (tuple): Tuple of colors for bar plots.
    - output_dir (str): Directory to save plots if save_plots=True.

    Returns:
    - None
    """
    x = np.arange(len(data.index))
    bar_width = 0.35
    fig, ax = plt.subplots(figsize=(8, 6))

    for i, column in enumerate(data.columns):
        offsets = x + (i * bar_width)
        ax.bar(
            offsets, data[column], width=bar_width, label=column,
            color=colors[i % len(colors)], edgecolor="black"
        )

    ax.set_ylabel(y_label, fontsize=12)
    ax.set_xlabel("Subgroup", fontsize=12)
    ax.set_xticks(x + bar_width / 2)
    ax.set_xticklabels(data.index, fontsize=10)
    ax.legend(title="Conditions", fontsize=10)

    ax.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "plot_bar")
    plt.show()


def plot_boxplot_by_subgroup(
    df, score_column, save_plots=False, output_dir="../output/plots"
):
    """
    Plot a boxplot for a given score column grouped by subgroups.

    Parameters:
    - df (DataFrame): The DataFrame containing the data.
    - score_column (str): The name of the column to plot
      (e.g., 'SOFA score' or 'OASIS score').
    - output_dir (str): Directory to save the plot if save_plots=True.
      Default is "plots".

    Returns:
    - None
    """
    # Ensure 'class_assignment' column is renamed to 'Subgroup'
    df.rename(columns={'class_assignment': 'Subgroup'}, inplace=True)

    # Create the boxplot
    plt.figure(figsize=(8, 6))
    sns.boxplot(
        data=df, x='Subgroup', y=score_column, palette='tab10',
        order=sorted(df['Subgroup'].unique())
    )

    plt.ylabel(f"{score_column} score")
    plt.xlabel('Subgroup')
    plt.tight_layout()
    if save_plots:
        save_plot(output_dir, "plot_boxplot_by_subgroup")
    plt.show()
