library(tidygraph)
library(dplyr)
library(reshape2)

#' Create a Condition Network from Cooccurrence Matrix
#'
#' This function takes a cooccurrence matrix as input and converts it into a network graph 
#' using the tidygraph package. It processes the matrix to establish connections (edges) 
#' between different conditions based on their cooccurrences and represents each condition 
#' as a node in the graph. The resulting graph is undirected, highlighting the bidirectional 
#' relationships between conditions without any implied directionality.
#'
#' @param cooccurrence_matrix A square matrix where both the rows and columns represent 
#' conditions, and the entries represent the frequency of cooccurrences between conditions.
#' @return A tbl_graph object representing the condition network, with nodes representing 
#' conditions and edges representing the cooccurrences.
#' @examples
#' # Assuming cooccurrence_matrix is predefined:
#' condition_network <- create_condition_network(cooccurrence_matrix)
#' plot(condition_network)
create_condition_network <- function(cooccurrence_matrix) {

  # Convert the cooccurrence matrix to long format suitable for graph creation.
  # Filters out self-links and entries with zero cooccurrences.
  edges <- cooccurrence_matrix %>%
    as.matrix() %>%
    melt() %>%
    filter(Var1 != Var2, value > 0) %>%
    rename(from = Var1, to = Var2, weight = value)
  

  nodes <- data.frame(
    name = colnames(cooccurrence_matrix),
    total_cooccurrences = rowSums(cooccurrence_matrix)
  )
  

  condition_network <- tbl_graph(
    nodes = nodes,
    edges = edges,
    directed = FALSE
  )
  
  return(condition_network)
}