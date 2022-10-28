#' get conversion table
#'
#' @param data input data from sql query
#' @param curve_duration numeric specifying number of days
#'
#' @return tbl_df
#'
get_conversion_tbl <- function(data, curve_duration) {

  number_of_installs <- dplyr::count(data) %$% n

  message(paste0(number_of_installs, " installs between ", min(data$install_time), " and ", max(data$install_time)))

  grouped_counts_tbl <- data %>%
    dplyr::count(campaign_source, type, time_to_convert, name = "number_conversions") %>%
    dplyr::rename(days_to_convert = time_to_convert) %>%
    tidyr::drop_na(type) %>%
    dplyr::filter(days_to_convert <= curve_duration) %>%
    dplyr::ungroup()

  output_tbl <- grouped_counts_tbl %>%
    dplyr::mutate(conversion_rate = number_conversions / number_of_installs * 100) %>%  # turn counts into rates
    dplyr::group_by(campaign_source, type) %>%
    dplyr::arrange(campaign_source, type, days_to_convert) %>%
    dplyr::mutate(cum_conversion_rate = cumsum(conversion_rate)) %>% # get cumulative rate
    dplyr::ungroup()

  output_tbl

}
