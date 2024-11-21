#' Create Cooccurrence Matrix from Data Frame
#'
#' This function converts a data frame into a cooccurrence matrix. Each element of the matrix 
#' represents the frequency of cooccurrences of corresponding disease/elixhauser index across 
#' different rows of the data frame. The input data frame is first transformed into a binary 
#' format, where each non-zero value is considered as the presence (1) of a disease/elixhauser
#' index, and zeros are treated as the absence (0) of the disease/elixhauser index
#'
#' @param df A data frame with numeric entries where rows represent samples and columns represent 
#' diseases/elixhauser indecies
#' @return A data frame representing the cooccurrence matrix, with rows and columns labeled by 
#' diseases/elixhauser indecies names. Each entry in the matrix counts the cooccurrences of
#' the respective disease/elixhauser index across all samples.
#' @examples
#' # Assuming df is predefined:
#' cooccurrence_matrix <- create_cooccurrence_matrix(df)
#' print(cooccurrence_matrix)
create_cooccurrence_matrix <- function(df) {

  # Ensures input data frame is a binary matrix, treating any non-zero value as 1
  binary_df <- ifelse(df != 0, 1, 0)
  
  n_cols <- ncol(binary_df)
  
  cooccurrence_matrix <- matrix(0, nrow = n_cols, ncol = n_cols)
  
  for (i in 1:n_cols) {
    for (j in 1:n_cols) {
      cooccurrence_matrix[i, j] <- sum(binary_df[,i] == 1 & binary_df[,j] == 1)
    }
  }
  
  cooccurrence_matrix <- as.data.frame(cooccurrence_matrix)
  
  colnames(cooccurrence_matrix) <- colnames(df)
  rownames(cooccurrence_matrix) <- colnames(df)
  
  return(cooccurrence_matrix)
}