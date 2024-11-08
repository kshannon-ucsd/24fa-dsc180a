from sklearn.cluster import KMeans
import pandas as pd


def kmeans_w_age(patients_age_at_admission,
                 include_gender=False,
                 clusters_count=6,
                 bin_age=False):
    """
    Perform KMeans clustering on patient age at admission data.

    This function applies KMeans clustering to a dataset containing ages at
    admission and elixhauser indicators.

    Parameters:
    - patients_age_at_admission (DataFrame): DataFrame containing ages at
      admission and elixhauser indicators.
    - clusters_count (int): Number of clusters to use in the KMeans algorithm.
      Default is 6.

    Returns:
    - tuple: A tuple containing the KMeans model instance and the DataFrame
      with an additional 'cluster' column indicating the cluster assignment.
    """
    patients_age_at_admission['gender'] = (
      (patients_age_at_admission['gender'] == 'M').astype(float)
      )
    drop_cols = ['hadm_id', 'gender'] if not include_gender else 'hadm_id'
    df = patients_age_at_admission.drop(columns=drop_cols, errors='ignore')
    kmeans = KMeans(n_clusters=clusters_count, random_state=0)
    df['cluster'] = kmeans.fit_predict(df)
    if bin_age:
        bins = [16, 25, 45, 65, 85, 96]
        labels = ['16-24', '25-44', '45-64', '65-84', '85-95']
        df['age_group'] = pd.cut(df['age_at_admission'],
                                 bins=bins,
                                 labels=labels,
                                 right=False)

    return kmeans, df
