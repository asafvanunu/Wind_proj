#' Required packages
#' Check for installed packages, and install if needed
pkg_list <- c("tidyverse", "data.table", "readr", # fast reading of CSV
              "lubridate",                        # date processing
              "clifro",
              "extRemes", "zoo")                           # wind rose
installed_packages <- pkg_list %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkg_list[!installed_packages])
}
#' Now Load Packages
lapply(pkg_list, function(p) {require(p,
                                      character.only = TRUE,
                                      quietly=TRUE)})

#' Load functions
source("functions.R")

# Set Directory of raw data files
# Data_dir <- "C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\stations\\IMS"
base_dir <- "C:\\Users\\asaf_rs\\Desktop\\projects\\wind\\Wind_proj"
Data_dir <- file.path(base_dir,"\\stations\\IMS")
stations <- dir(Data_dir)

if (file.exists(file.path(Data_dir,"station_data.rds"))) {
  station_data <- readRDS(file.path(Data_dir,"station_data.rds"))
} else {
  # Work on each IMS station separately
  station_data_list <- lapply(stations, function(stn){
    # Now read all years of data from one station, and merge
    IMS_merged <- LoadIMSData(file.path(Data_dir, stn), stn)
    # Further analyses, wrapped in functions ...
    
  })
  station_data <- do.call(rbind, station_data_list)
  ## save all the stations data as one table
  saveRDS(station_data, file.path(base_dir,"station_data.rds"))
} # end else
station_data_list <- lapply(stations, function(stn){
  station_df <- station_data[station==stn,]
  extreme_value(station_df, stn)
  extreme_value_month(station_df, stn)
})
PlotWindrose(station_data)









