#' Required packages
#' Check for installed packages, and install if needed
pkg_list <- c("tidyverse", "data.table", "readr", # fast reading of CSV
              "lubridate",                        # date processing
              "clifro")                           # wind rose
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
Data_dir <- "/media/micha/Storage_8TB/Data/IMS/Wind_proj/stations/IMS"
stations <- dir(Data_dir)

# Work on each IMS station separately
station_data_list <- lapply(stations, function(stn){
  # Now read all years of data from one station, and merge
  IMS_merged <- LoadIMSData(file.path(Data_dir, stn), stn)
  # Further analyses, wrapped in functions ...
  
})
station_data <- do.call(rbind, station_data_list)

PlotWindrose(station_data)

# Nativ = lapply(my_files, function(i){
# x = read.csv(i)
# x})
# 
# Nativ = do.call("rbind.data.frame", Nativ)
# 
# ## delete station name
# Nativ = Nativ[,-1]
# 
# Nativ = as_tibble(Nativ)
# 
# ##set the date column into date class
# Nativ$Date = as.Date(Nativ$Date, "%d/%m/%Y")
# ##set the time column
# Nativ$Hour_LST = as.ITime(Nativ$Hour_LST)
# ## set numeric columns
# Nativ[,3:13] = apply(Nativ[3:13],2,function(x) as.numeric(as.character(x)))
# 
