## I recommend at least a 3 month lag between the end date of the window in the query, and the current date
## Note that curves will be biased by date ranges where the full cohort of installs has not had at least x months to convert
## For example, if today is 30 June, looking at installs between 1 Jan and 30 March will allow for a 3 month conversion curve i.e.
## all installs have had at least 3 months to convert.

sql_script_path <- './inst/extdata/ftp_conversions_script.sql'
start_dt <- '2022-03-01'
end_dt <- '2022-05-31'
platform <- 'ios'
curve_duration <- 120 # number of days

source("./R/read_sql.R")
source("./R/table_funcs.R")
source("./R/plot_funcs.R")

# --------------------------------------------------------------------------------------------------

# Get data from BQ
ftp_conv_tbl <- read_sql(sql_script_path, start_dt, end_dt, platform)

ftp_conv_data <- ftp_conv_tbl$data[[1]]

# Create table counting number of conversions by day, by group
rate_tbl_combined <- get_conversion_tbl(ftp_conv_data, curve_duration)

# Incremental overall conversion plot - rate per day
plot_ttl_inc <- paste0(platform, " FTP ", start_dt, " to ", end_dt)
incremental_plot <- plotly::ggplotly(p = get_conversion_plot(rate_tbl_combined, plot_type = "incremental", plot_ttl_inc))

# Cumulative overall plot - aggregated rate until that day
plot_ttl_cum <- paste0(platform, " FTP ", start_dt, " to ", end_dt)
cumulative_plot <- plotly::ggplotly(p = get_conversion_plot(rate_tbl_combined, plot_type = "cumulative", plot_ttl_cum))

# Write plots to HTML file
combined_plots <- manipulateWidget::combineWidgets(incremental_plot, cumulative_plot)

htmlwidgets::saveWidget(
  widget = combined_plots,
  file = "ftp_conversions.html",
  selfcontained = TRUE
)
