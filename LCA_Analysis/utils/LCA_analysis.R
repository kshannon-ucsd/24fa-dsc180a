#' Convert Specified Columns to Factors
#'
#' This function converts specified columns in a data frame to factors.
#'
#' @param df A data frame containing the data to modify.
#' @param columns A character vector of column names to convert to factors.
#'
#' @return A data frame with the specified columns converted to factors.
convert_to_factors <- function(df, columns) {
  for (col in columns) {
    if (col %in% names(df)) {
      df[[col]] <- as.factor(df[[col]])
    } else {
      warning(paste("Column", col, "not found in dataframe"))
    }
  }
  return(df)
}




#' Run LCA and Track Best Models Based on AIC and BIC
#'
#' This function performs latent class analysis (LCA) on a given formula and data frame.
#' It iterates over a specified range of classes, fits LCA models, and tracks the models with
#' the lowest AIC, BIC, and combined AIC+BIC.
#'
#' @param df A data frame containing the data to fit the LCA model.
#' @param formula An LCA formula defining the variables to use in the model.
#' @param class_range A numeric vector specifying the range of classes to evaluate (e.g., 8:9).
#' @param seed An integer seed for reproducibility. Default is 1.
#' @param max_iter The maximum number of iterations for the LCA algorithm. Default is 7000.
#' @param n_rep The number of repetitions for each LCA model fitting to avoid local optima. Default is 7.
#'
#' @return A list containing the best models based on BIC, AIC, and combined AIC+BIC.
#' @examples
#' df <- your_dataframe  # Make sure to replace with your data
#' formula <- as.formula(cbind(admission_type, gender, age_at_admission) ~ 1)
#' best_models <- find_best_lca_model(df, formula, 8:9)
find_best_lca_model <- function(df, formula, class_range, seed = 1, max_iter = 7000, n_rep = 5, tol = 1e-5, plot_dir = "plots") {
  # Set seed for reproducibility
  set.seed(seed)
  
  # Initialize minimum AIC, BIC, and combined AIC+BIC
  min_aic <- Inf
  min_bic <- Inf
  min_aic_bic_combined <- Inf
  
  # Initialize placeholders for the best models
  LCA_best_model_aic <- NULL
  LCA_best_model_bic <- NULL
  LCA_best_model_aic_bic_combined <- NULL
  
  # Iterate over the range of classes
  for (i in class_range) {
    # Fit LCA model
    lc <- poLCA(formula, df, nclass = i, maxiter = max_iter, tol = tol, 
                na.rm = TRUE, nrep = n_rep, calc.se = FALSE)
    
    # Check if this model has the lowest combined AIC+BIC
    combined_aic_bic <- lc$bic + lc$aic

    # Check if this model has the lowest combined AIC+BIC
    if (combined_aic_bic < min_aic_bic_combined) {
      min_aic_bic_combined <- combined_aic_bic
      LCA_best_model_aic_bic_combined <- lc
      
      save_lca_plot(LCA_best_model_aic_bic_combined, plot_dir)
    }
    
    # Update best BIC model
    if (lc$bic < min_bic) {
      min_bic <- lc$bic
      LCA_best_model_bic <- lc
    }
    
    # Update best AIC model
    if (lc$aic < min_aic) {
      min_aic <- lc$aic
      LCA_best_model_aic <- lc
    }
  }

  
  # Return the best models
  return(list(
    best_model_bic = LCA_best_model_bic,
    best_model_aic = LCA_best_model_aic,
    best_model_aic_bic_combined = LCA_best_model_aic_bic_combined
  ))
}

#' Save LCA Model Plot
#'
#' This function saves a plot of a latent class analysis (LCA) model to a specified file.
#'
#' @param model An LCA model object (e.g., result from poLCA).
#' @param filename A string specifying the file path to save the plot (e.g., "output/lca_plot.png").
#'
#' @return None (the plot is saved to a file).
#' @examples
#' save_lca_plot(best_models$best_model_aic_bic_combined, "output_plots/lca_best_model_plot.png")
save_lca_plot <- function(model, plot_dir) {
  dir.create(plot_dir, showWarnings = FALSE)
  filename <- file.path(plot_dir, "best_model_aic_bic_combined.png")
  png(filename)               # Open a PNG device
  plot(model)                 # Plot the model
  dev.off()                   # Close the device
}
