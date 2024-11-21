import pandas as pd

LCA_ADD_ONE = 1
CLASS_ASSIGNMENT_INDEX = -1
MAX_MORBIDITY_NUM = 8


def get_morbidity_columns_and_distribution(
    df, exclude_columns=None, display_distribution=True
):
    """
    Identifies morbidity columns and calculates the multi-morbidity
    distribution.

    Parameters:
    - df (pd.DataFrame): The DataFrame containing morbidity and other columns.
    - exclude_columns (list): List of columns to exclude when identifying
    morbidity columns. Default is ["subject_id", "hadm_id", "admission_type",
    "gender", "age_bucket", "age_at_admission"].
    - display_distribution (bool): Whether to display the morbidity
    distribution. Default is True.

    Returns:
    - tuple: A tuple containing the list of target morbidity columns and the
      distribution (as a Series).
    """
    if exclude_columns is None:
        exclude_columns = [
            "subject_id",
            "hadm_id",
            "icustay_id",
            "deathtime",
            "gender",
            "age_at_admission",
            "admission_type",
            "los_icu_days",
            "los_hospital_days",
            "class_assignment",
            "count_morbidity",
        ]

    # List target columns for multi-morbidity count
    target_columns = [
        col for col in df.columns if col not in exclude_columns
    ]

    # Calculate multi-morbidity count distribution
    morbidity_distribution = (
        df[target_columns]
        .apply(lambda row: sum(row), axis=1)
        .value_counts()
    )

    if display_distribution:
        print("Multi-morbidity count distribution:", morbidity_distribution)

    return target_columns, morbidity_distribution


def preprocess_lca_data(
    input_path="data/raw_data/poLCA_35128.csv",
    output_path="data/processed_data/LCA_prep_data.csv",
):
    """
    Preprocesses the data for LCA analysis by performing the following steps:
    - Changes all non-elective admissions (EMERGENCY, URGENT, etc.)
    to 'Non-elective'.
    - Drops rows with any null values, including those
    with age > 95 and null elixhauser index.
    - Checks multi-morbidity count distribution for alignment
    with paper's settings.
    - Adds 1 to all elixhauser indices, changing values from 0/1
    to 1/2 to prevent errors in poLCA.

    Parameters:
    - input_path (str): Path to the input CSV file.
    - output_path (str): Path to save the processed CSV file.

    Returns:
    - DataFrame: The processed DataFrame.
    """
    df = pd.read_csv(input_path)

    # Modify admission type to make all non-elective
    # admissions as 'Non-elective'
    df["admission_type"] = df["admission_type"].apply(
        lambda x: "Non-elective" if x != "ELECTIVE" else "Elective"
    )

    df["admission_type"] = df["admission_type"].map(
        {"Non-elective": 0, "Elective": 1}
    )
    df["gender"] = df["gender"].map({"M": 0, "F": 1})

    # Print multi-morbidity count distribution
    target_columns, morbidity_distribution = (
        get_morbidity_columns_and_distribution(df)
    )
    print("Multi-morbidity count distribution:", morbidity_distribution)

    # Drop rows that have NaN for disease columns to prevent
    # mismatch when assigning back
    df = df.dropna(how="any", subset=target_columns)

    # Add 1 to elixhauser index columns to prevent poLCA errors
    df[target_columns] = df[target_columns] + LCA_ADD_ONE

    df = df.reset_index(drop=True)
    df.to_csv(output_path, index=True)

    return {"df": df, "morbidity_distribution": morbidity_distribution}
