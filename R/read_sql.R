#' read sql file for the ftp conversions
#'
#' @param path path to script
#' @param start_dt min date as string Y-m-d
#' @param end_dt max date as string Y-m-d
#' @param platform string specifying ios or android
#'
#' @return tbl_df containing query name, query string and required bq data
#'
read_sql <- function(path, start_dt, end_dt, platform = c('ios', 'android')) {

  sql_script <- readr::read_file(path)

  session_source <- dplyr::case_when(
    platform == 'ios' ~ '`over-data.users.sessions_ios`',
    platform == 'android' ~ '`over-data.users.sessions_android`'
  )

  sub_providor <- dplyr::case_when(
    platform == 'ios' ~ "'APPLE'",
    platform == 'android' ~ "'PLAY_STORE'"
  )

  reqd_string <- sql_script %>%
    stringr::str_replace_all(
      c("SQL_SESSION_SOURCE" = session_source,
        "SQL_START_DATE" = paste0("'", start_dt, "'"),
        "SQL_END_DATE" = paste0("'", end_dt, "'"),
        "SQL_SUB_PROVIDOR" = sub_providor))

  results_table <- bigrquery::bq_project_query('over-data', query = reqd_string)
  query_results <- bigrquery::bq_table_download(results_table)

  result_tbl <- tibble::tibble(name = basename(path),
                               query = reqd_string,
                               data = list(query_results))

  result_tbl
}
