import pandas as pd
from .data_preprocessing import (
    get_morbidity_columns_and_distribution,
)

LCA_ADD_ONE = 1
CLASS_ASSIGNMENT_INDEX = -1
MAX_MORBIDITY_NUM = 8


def reassign_classes(df, df_prob, num_classes=6):
    """
    Reassigns class assignments based on the most popular classes.

    Parameters:
    - df (pd.DataFrame): The DataFrame containing the original
     class assignments in a column named "class_assignment".
    - df_prob (pd.DataFrame): The DataFrame containing the
     posterior probabilities for each class.
    - num_classes (int): The number of most popular classes to
      retain. Default is 6.

    Returns:
    - pd.DataFrame: A modified version of `df` with an updated
    "class_assignment" column based on the most popular classes.
    """
    keep_classes = (
        df["class_assignment"]
        .value_counts(normalize=True)
        .index[:num_classes]
    )
    target_prob_class = keep_classes - 1  # Adjust to 0-based indexing

    # Rename probability columns, if needed
    classes_mapping = {col: col[1:] for col in df_prob.columns}
    df_prob = df_prob.rename(columns=classes_mapping)

    # Select columns corresponding to the most popular classes
    df_prob = df_prob.iloc[:, target_prob_class]

    # Find the most probable class for each row
    df_prob["class_assignment"] = df_prob.idxmax(axis=1)

    # Update the class assignments
    df = df.drop(columns=["class_assignment"])
    df["class_assignment"] = df_prob["class_assignment"]

    classes_distribution = (
        df["class_assignment"].value_counts(normalize=True)
    )
    return df, classes_distribution


def adjust_elixhauser_index(df):
    """
    Adjusts the Elixhauser index columns by subtracting
    1 and calculates morbidity count.

    Parameters:
    - df (pd.DataFrame): DataFrame containing Elixhauser index columns.

    Returns:
    - pd.DataFrame: Updated DataFrame with adjusted
    Elixhauser columns and morbidity count.
    """
    target_columns, _ = get_morbidity_columns_and_distribution(
        df, display_distribution=False
    )

    # Adjust indices and calculate morbidity count
    df.loc[:, target_columns] = df.loc[:, target_columns] - LCA_ADD_ONE
    df["count_morbidity"] = df.loc[:, target_columns].sum(axis=1)
    df = df.dropna(subset=["count_morbidity"])
    df["count_morbidity"] = df["count_morbidity"].apply(
        lambda x: ">=8" if x >= MAX_MORBIDITY_NUM else str(x)
    )
    return df


def calculate_percentage_within_subgroup(df):
    """
    Calculates the percentage of each count_morbidity
    within each class_assignment group.

    Parameters:
    - df (pd.DataFrame): DataFrame with 'class_assignment',
    'count_morbidity', and 'subject_id'.

    Returns:
    - pd.DataFrame: DataFrame with a new column 'percent'
    for within-group percentages.
    """
    df["percent"] = (
        df.groupby(["class_assignment", "count_morbidity"])["subject_id"]
        .transform("count")
        / df.groupby("class_assignment")["subject_id"].transform("count")
        * 100
    )
    return df


def reassign_class_assignment(df):
    """
    Reassigns unique values in 'class_assignment'
    to a sequential integer order.

    Parameters:
    - df (pd.DataFrame): DataFrame with a 'class_assignment' column.

    Returns:
    - pd.DataFrame: Updated DataFrame with reassigned
    'class_assignment' values.
    """
    unique_values = sorted(df["class_assignment"].unique())
    value_map = {
        original_value: new_value
        for new_value, original_value in enumerate(unique_values, start=1)
    }
    df["class_assignment"] = df["class_assignment"].map(value_map)
    return df


def process_morbidity_data(df, classes_map=None):
    """
    Processes morbidity data by adjusting indices, calculating percentages, and
    reassigning class assignments.

    Parameters:
    - df (pd.DataFrame): DataFrame with class
    assignments and morbidity columns.

    Returns:
    - pd.DataFrame: Fully processed DataFrame.
    """
    df = adjust_elixhauser_index(df)
    df = calculate_percentage_within_subgroup(df)
    df = reassign_class_assignment(df)

    # Final sorting for easier viewing
    if classes_map is not None:
        df["class_assignment"] = df["class_assignment"].map(classes_map)
    df = df.sort_values(by="count_morbidity", ascending=True)
    return df


def calculate_prevalence(
    df, condition_columns, subgroup_column="class_assignment"
):
    """
    Calculate percentages for conditions by subgroups.

    Parameters:
    - df (pd.DataFrame): DataFrame with condition columns
    and subgroup assignments.
    - condition_columns (list): List of condition columns
    to calculate percentages for.
    - subgroup_column (str): Column name for subgroups.

    Returns:
    - pd.DataFrame: DataFrame with prevalence percentages
    for each condition by subgroup.
    """
    percentages = {
        condition: df.groupby(subgroup_column)[condition].mean() * 100
        for condition in condition_columns
    }
    return pd.DataFrame(percentages)
