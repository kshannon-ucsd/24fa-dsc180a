library(ggraph)
library(igraph)

#' Visualize Condition Network
#'
#' This function visualizes a network graph of medical conditions based on their co-occurrences.
#' It adjusts node sizes and edge widths to reflect the proportion of total and maximum co-occurrences,
#' respectively, providing a clear visual representation of the relationships between conditions.
#' The visualization is created using the ggraph library, and the layout is automatically determined.
#' If the save parameter is set to TRUE, the plot will be saved to the current working directory as 'condition_network_plot.png'.
#'
#' @param condition_graph An igraph or tbl_graph object representing the condition network.
#' @param save A logical value; if TRUE, the plot will be saved to the plots directory.
#' @return A ggplot object representing the visualized network, which can be displayed using
#' the plot function or further customized.
#' @examples
#' # Assuming condition_graph is predefined:
#' plot(visualize_condition_network(condition_graph))
#' visualize_condition_network(condition_graph, save = TRUE)
visualize_condition_network <- function(condition_graph,
                                        edge_alpha = 0.1,
                                        sub_group = 0,
                                        edge_color= 'black',
                                        node_fill_color = 'red',
                                        node_stroke = 0.8,
                                        node_border_color = 'black',
                                        text_color = 'blue',
                                        text_size = 4.5,
                                        save = FALSE) {

  # Calculate the percentage of total co-occurrences for each node to determine node size
  # Nodes are capped at 60% to prevent any single node from dominating the visualization.
  V(condition_graph)$total_pct <- 
    (V(condition_graph)$total_cooccurrences / sum(V(condition_graph)$total_cooccurrences)) * 100
  V(condition_graph)$node_size <- pmin(V(condition_graph)$total_pct, 60)
  
  # Calculate edge weight as a percentage of the maximum weight to normalize edge width
  # This makes the relative importance of connections easier to interpret visually.
  E(condition_graph)$weight_pct <- 
    (E(condition_graph)$weight / max(E(condition_graph)$weight))
  
  set.seed(123)
  if (sub_group == 1) {
      graph_layout <- 'auto'
  } else if (sub_group == 2) {
      graph_layout <- 'auto'
  } else if (sub_group == 3) {
      graph_layout <- 'fr'
  } else if (sub_group == 4) {
      graph_layout <- 'auto'
  } else if (sub_group == 5) {
      graph_layout <- 'auto'
  } else if (sub_group == 6) {
      graph_layout <- 'auto'
  } else {
      graph_layout <- 'fr'
  }
  
  plot <- ggraph(condition_graph, layout = graph_layout) +
    geom_edge_link(
      aes(edge_width = weight_pct / 10),
      edge_alpha = edge_alpha,
      color = edge_color
    ) +
    geom_node_point(
      aes(size = node_size),
      shape = 21,
      color = node_border_color, 
      alpha = 1,
      fill = node_fill_color,
      stroke = node_stroke
    ) +
    geom_node_text(
      aes(label = name),
      repel = TRUE,
      size = text_size,
      color = text_color
    ) +
    scale_size_continuous(range = c(1, 12)) +
    theme_graph() +
    labs(
      title = 'Medical Condition Co-occurrence Network',
      subtitle = 'Node size: % of total co-occurrences (capped at 60%)\nEdge width: Relative co-occurrence frequency'
    )
  
  if (sub_group == 0) {
    image_name <- paste("/workspaces/network_visualization/plots/condition_network_plot.png")
  } else {
    image_name <- paste("/workspaces/network_visualization/plots/condition_network_plot_subgroup_", sub_group, ".png")
  }
  if (save) {
    ggsave(image_name, plot, width = 11, height = 8, dpi = 300)
  }
  
  return(plot)
}