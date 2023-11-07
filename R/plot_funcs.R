#' get conversion plot
#'
#' @param data tbl_df with cols conversion_rate, cum_conversion_rate, type, campaign_source, days_to_convert
#' @param plot_type string
#' @param plot_ttl optional string indicating the name of your plot
#'
#' @return ggplot
#'
get_conversion_plot <- function(data, plot_type = c("incremental", "cumulative"), plot_ttl = NULL) {

  y_var <- switch(plot_type,
                  incremental = "conversion_rate",
                  cumulative = "cum_conversion_rate")
  col_var <- switch(plot_type,
                    incremental = "type",
                    cumulative = "campaign_source")

  p <- ggplot2::ggplot(data,
                       ggplot2::aes_string(x = "days_to_convert",
                                           y = y_var,
                                           colour = col_var)
                       )

  p <- p + ggplot2::geom_line()
  p <- p + ggplot2::labs(title = plot_ttl)
  p <- p + ggplot2::theme_minimal()
  p <- p + ggplot2::theme(text = ggplot2::element_text(size = 10))

  if(plot_type == "incremental") {
    p <- p + ggplot2::facet_grid(type ~ campaign_source)
    p <- p + ggplot2::scale_y_log10()
  }

  if(plot_type == "cumulative") {
    p <- p + ggplot2::facet_wrap(dplyr::vars(type))
    p <- p + ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1))
  }

  p
}

