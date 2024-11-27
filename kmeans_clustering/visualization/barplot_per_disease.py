import matplotlib.pyplot as plt
import warnings

warnings.filterwarnings("ignore")


def barplot_per_disease(patients,
                        figsize=(15, 20),
                        num_plots_per_row=6,
                        num_plots_per_column=5,
                        save=False):
    """
    Generate bar plots for each disease prevalence across different age groups.

    This function takes a dataframe containing patient information and
    generates bar plots for each disease, filtering out non-binary diseases
    and non-numeric data. Plots are displayed in a grid defined by
    num_plots_per_row and num_plots_per_column.

    Parameters:
    - patients (DataFrame): A pandas DataFrame containing patient data,
        expected to include 'age_group' and various diseases as columns.
    - figsize (tuple of int): A tuple with the figure size (width, height).
    - num_plots_per_row (int): Number of plots to display per row.
    - num_plots_per_column (int): Number of plots to display per column.
    - save (bool): If True, saves the figure to PDF file named 'barplots.pdf'.

    Returns:
    - None: Plots are displayed and optionally saved to a file.
    """
    fig, axes = plt.subplots(num_plots_per_row,
                             num_plots_per_column,
                             figsize=figsize)
    axes = axes.flatten()

    df = patients.drop(columns=['hadm_id', 'gender'], errors='ignore')

    for i, column in enumerate(df.columns):
        if (len(df[column].unique()) != 2) or (df[column].dtype == object):
            continue

        pivot = df.pivot_table(index='age_group',
                               values=column,
                               aggfunc='mean')
        pivot.plot(kind='bar', ax=axes[i], title=column, legend=False)
        axes[i].set_ylabel('Prevalence')
        axes[i].set_xlabel('Age Group')

    plt.tight_layout()
    plt.show()

    if save:
        fig.savefig('barplots.pdf')
