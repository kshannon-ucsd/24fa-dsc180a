import matplotlib.pyplot as plt
import seaborn as sns
import utils.modeling as modeling

def plot_subgroup_characteristics(df, bubble_size_scale=10, save_plots=False, output_dir="plots"):
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
        import os
        os.makedirs(output_dir, exist_ok=True)
        plt.savefig(f"{output_dir}/subgroup_characteristics_plots.png")
    plt.show()



def plot_roc_curves(df, feature_columns, colors, cv_splits=10):
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
    
    plt.show()
