import pandas as pd

LCA_ADD_ONE = 1
CLASS_ASSIGNMENT_INDEX = -1
MAX_MORBIDITY_NUM = 8

def get_morbidity_columns_and_distribution(df, exclude_columns=None, display_distribution=True):
    """
    Identifies morbidity columns and calculates the multi-morbidity distribution.
    
    Parameters:
    - df (pd.DataFrame): The DataFrame containing morbidity and other columns.
    - exclude_columns (list): List of columns to exclude when identifying morbidity columns.
      Default is ["subject_id", "hadm_id", "admission_type", "gender", "age_bucket", "age_at_admission"].
    - display_distribution (bool): Whether to display the morbidity distribution. Default is True.
    
    Returns:
    - tuple: A tuple containing the list of target morbidity columns and the distribution (as a Series).
    """
    if exclude_columns is None:
        exclude_columns = ["subject_id", "hadm_id", "admission_type", "gender", "age_bucket", "age_at_admission","class_assignment","count_morbidity"]
    
    # List target columns for multi-morbidity count
    target_columns = [col for col in df.columns if col not in exclude_columns]
    
    # Calculate multi-morbidity count distribution
    morbidity_distribution = df[target_columns].apply(lambda row: sum(row), axis=1).value_counts()
    
    # Optionally print the distribution
    if display_distribution:
        print("Multi-morbidity count distribution:", morbidity_distribution)
    
    return target_columns, morbidity_distribution


def preprocess_lca_data(input_path="data/raw_data/poLCA_35128.csv", output_path="data/processed_data/LCA_prep_data.csv"):
    """
    Preprocesses the data for LCA analysis by performing the following steps:
    - Changes all non-elective admissions (EMERGENCY, URGENT, etc.) to 'Non-elective'.
    - Drops rows with any null values, including those with age > 95 and null elixhauser index.
    - Checks multi-morbidity count distribution for alignment with paper's settings.
    - Adds 1 to all elixhauser indices, changing values from 0/1 to 1/2 to prevent errors in poLCA.

    Parameters:
    - input_path (str): Path to the input CSV file.
    - output_path (str): Path to save the processed CSV file.

    Returns:
    - DataFrame: The processed DataFrame.
    """
    
    # Load data
    df = pd.read_csv(input_path)
    
    # Modify admission type to make all non-elective admissions as 'Non-elective'
    df["admission_type"] = df["admission_type"].apply(lambda x: "Non-elective" if x != "ELECTIVE" else "Elective")
    
    df["admission_type"] = df["admission_type"].map({"Non-elective":0,"Elective":1})
    df["gender"] = df["gender"].map({"M":0,"F":1})
    # Drop rows with any null values
    df = df.dropna(how='any')
    
    # Print multi-morbidity count distribution
    target_columns, morbidity_distribution = get_morbidity_columns_and_distribution(df)
    print("Multi-morbidity count distribution:", morbidity_distribution)
    
    # Add 1 to elixhauser index columns to prevent poLCA errors
    df[target_columns] = df[target_columns] + LCA_ADD_ONE
    
    # Reset index and remove the old index column
    df = df.reset_index(drop=True)
    
    # Save the processed DataFrame to CSV
    df.to_csv(output_path, index=True)
    
    return {"df": df, "morbidity_distribution": morbidity_distribution}



def reassign_classes(df, df_prob, num_classes=6):
    """
    Reassigns class assignments based on the most popular classes.

    Parameters:
    - df (pd.DataFrame): The DataFrame containing the original class assignments in a column named "class_assignment".
    - df_prob (pd.DataFrame): The DataFrame containing the posterior probabilities for each class.
    - num_classes (int): The number of most popular classes to retain. Default is 6.
    
    Returns:
    - pd.DataFrame: A modified version of `df` with an updated "class_assignment" column based on the most popular classes.
    """
    
    # Find the most popular classes, adjusted for 0-based indexing in Python
    keep_classes = (df["class_assignment"].value_counts() / df["class_assignment"].count()).index[:num_classes]
    target_prob_class = keep_classes - 1  # Adjust to 0-based indexing

    # Rename the probability columns to remove any leading characters, if needed. Here we start from 1 since the
    # format is V1,V2...
    classes_mapping = {col: f"{col[1:]}" for col in df_prob.columns}
    df_prob = df_prob.rename(columns=classes_mapping)

    # Select only the columns corresponding to the most popular classes
    df_prob = df_prob.iloc[:, target_prob_class]

    # For each row, find the most probable class among the target classes
    df_prob["class_assignment"] = df_prob.idxmax(axis=1)

    # Drop the original "class_assignment" and add the reassigned one
    df = df.drop(columns=["class_assignment"])
    df["class_assignment"] = df_prob["class_assignment"]

    classes_distribution = df["class_assignment"].value_counts()/df["class_assignment"].value_counts().sum()
    return df,classes_distribution

def adjust_elixhauser_index(df):
    """
    Adjusts the Elixhauser index columns by subtracting 1 and calculates the morbidity count.
    
    Parameters:
    - df (pd.DataFrame): DataFrame containing Elixhauser index columns and the starting column.
    - start_column (str): Column name where Elixhauser index starts. Default is "congestive_heart_failure".
    
    Returns:
    - pd.DataFrame: Updated DataFrame with adjusted Elixhauser columns and morbidity count.
    """
    target_columns, _ = get_morbidity_columns_and_distribution(df,display_distribution=False)

    # Subtract 1 for all Elixhauser index columns
    df.loc[:, target_columns] = df.loc[:, target_columns] - LCA_ADD_ONE

    # Calculate morbidity count
    df["count_morbidity"] = df.loc[:,target_columns].apply(lambda row: sum(row), axis=1)
    df = df[~df["count_morbidity"].isna()]  # Remove rows with NaN morbidity count
    df["count_morbidity"] = df["count_morbidity"].apply(lambda x: '>=8' if x >= MAX_MORBIDITY_NUM else str(x)) # replicating paper's setting
    
    return df

def calculate_percentage_within_subgroup(df):
    """
    Calculates the percentage of each count_morbidity within each class_assignment group.
    
    Parameters:
    - df (pd.DataFrame): DataFrame with 'class_assignment', 'count_morbidity', and 'subject_id'.
    
    Returns:
    - pd.DataFrame: DataFrame with a new column 'percent' representing the within-group percentages.
    """
    # Calculate percentage within each group
    df['percent'] = df.groupby(["class_assignment", "count_morbidity"])["subject_id"].transform('count') / \
                    df.groupby("class_assignment")["subject_id"].transform('count') * 100
    
    return df

def reassign_class_assignment(df):
    """
    Reassigns unique values in 'class_assignment' to a sequential integer order.
    
    Parameters:
    - df (pd.DataFrame): DataFrame with a 'class_assignment' column.
    
    Returns:
    - pd.DataFrame: Updated DataFrame with reassigned 'class_assignment' values.
    """
    unique_values = sorted(df['class_assignment'].unique())
    value_map = {original_value: new_value for new_value, original_value in enumerate(unique_values, start=1)}
    df['class_assignment'] = df['class_assignment'].map(value_map)
    
    return df

# Main Function to Integrate All Processing Steps Before Visualization
def process_morbidity_data(df, classes_map,start_column="congestive_heart_failure"):
    """
    Processes morbidity data by adjusting Elixhauser indices, calculating percentages, 
    and reassigning class assignments.
    
    Parameters:
    - df (pd.DataFrame): DataFrame with class assignments, Elixhauser indices, and subject IDs.
    - start_column (str): Column name where Elixhauser index starts.
    
    Returns:
    - pd.DataFrame: Fully processed DataFrame.
    """

    df = adjust_elixhauser_index(df)
    df = calculate_percentage_within_subgroup(df)
    df = reassign_class_assignment(df)

    
    # Final sorting for easier viewing
    df = df.sort_values(by="count_morbidity", ascending=True)
    df["class_assignment"] = df["class_assignment"].map(classes_map)
    return df

def calculate_prevalence(df, condition_columns, subgroup_column="class_assignment"):
    """
    Calculate percentages for conditions by subgroups.
    """
    percentages = {}
    for condition in condition_columns:
        percentages[condition] = (
            df.groupby(subgroup_column)[condition].mean() * 100
        )
    return pd.DataFrame(percentages)
