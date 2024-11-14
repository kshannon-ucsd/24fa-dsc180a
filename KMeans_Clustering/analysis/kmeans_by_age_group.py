from sklearn.cluster import KMeans
import warnings

warnings.filterwarnings("ignore")


def kmeans_by_age_group(patients, clusters_count=3, group_by_gender=True):
    """
    Apply KMeans clustering to patient data grouped by age & optionally gender.

    This function groups the patients by 'age_group' and optionally 'gender',
    then applies KMeans clustering to the grouped data, calculating the mean
    of the elixhauser indicator columns.

    Parameters:
    - patients (DataFrame): DataFrame with patient data including 'hadm_id',
                            'age_group', and 'gender'.
    - clusters_count (int): Number of clusters for KMeans. Default is 3.
    - group_by_gender (bool): If True, groups by 'age_group' and 'gender'.
                              Default is True.

    Returns:
    - tuple: Containing fitted KMeans model and DataFrame with cluster labels.
    """
    group_cols = ['age_group', 'gender'] if group_by_gender else ['age_group']

    df = (patients.drop(columns='hadm_id', errors='ignore')
          .groupby(group_cols)
          .mean()
          )

    kmeans = KMeans(n_clusters=clusters_count, random_state=0).fit(df)

    df['cluster'] = kmeans.labels_

    return kmeans, df
