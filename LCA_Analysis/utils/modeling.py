from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_predict, StratifiedKFold
from sklearn.metrics import roc_curve, auc

def calculate_auc_for_class(df, class_label, feature_columns, cv_splits=10):
    """
    Calculates cross-validated AUC-ROC for a specific class vs. all other classes.
    
    Parameters:
    - df (pd.DataFrame): DataFrame containing the data.
    - class_label (int or str): The class label for one-vs-all comparison.
    - feature_columns (list): List of feature columns for the logistic regression model.
    - cv_splits (int): Number of splits for cross-validation. Default is 10.
    
    Returns:
    - tuple: (fpr, tpr, auc_score) for the cross-validated ROC curve of the specified class.
    """
    # Create a binary target for the class vs. all others
    df["dichotomized_class"] = df["class_assignment"].apply(lambda x: 1 if x == class_label else 0)
    X = df[feature_columns]
    y = df["dichotomized_class"]
    
    # Initialize logistic regression model
    log_reg = LogisticRegression(max_iter=1000)
    cv = StratifiedKFold(n_splits=cv_splits)
    
    # Cross-validated predicted probabilities for the positive class
    y_pred_prob_cv = cross_val_predict(log_reg, X, y, cv=cv, method='predict_proba')[:, 1]
    
    # Calculate ROC curve and AUC score
    fpr, tpr, _ = roc_curve(y, y_pred_prob_cv)
    auc_score = auc(fpr, tpr)
    
    return fpr, tpr, auc_score
