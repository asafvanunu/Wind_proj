<<<<<<< HEAD
install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)
library(lubridate)

setwd("C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\stations\\IMS\\Nativ\\try")

my_files <- list.files(pattern = "*.csv")


Nativ = lapply(my_files, function(i){
x = read.csv(i)
x})

Nativ = do.call("rbind.data.frame", Nativ)

## delete station name
Nativ = Nativ[,-1]

Nativ = as_tibble(Nativ)

##set the date column into date class
Nativ$Date = as.Date(Nativ$Date, "%d/%m/%Y")
##set the time column
Nativ$Hour_LST = as.ITime(Nativ$Hour_LST)
## set numeric columns
Nativ[,3:13] = apply(Nativ[3:13],2,function(x) as.numeric(as.character(x)))


##Micha part
ims_wind_csv = "Nativ.csv"
ims_wind = read.csv(ims_wind_csv, row.names = 1)
# Read in with hour as LST where GMT is 2 hours behind
ims_wind$date_time = as_datetime(paste(ims_wind$Date, ims_wind$Hour_LST),
                                 tz = "Etc/GMT-2")
# Convert to UTC ("Greenwich Mean Time")
ims_wind$date_time = as_datetime(ims_wind$date_time, tz = "UTC")
# Check conversion:
head(ims_wind[,c("Date", "Hour_LST", "date_time")])
tail(ims_wind[,c("Date", "Hour_LST", "date_time")])


# Data structure

str(ims_wind)

#change column order

ims_wind <- ims_wind[, c(1,2,14,3,4,5,6,7,8,9,10,11,12,13)]

write.csv(ims_wind, file = "Nativ_station.csv")



=======
#' Required packages
#' Check for installed packages, and install if needed
pkg_list <- c("tidyverse", "data.table", "lubridate")
installed_packages <- pkg_list %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(pkg_list[!installed_packages])
}
#' Now Load Packages
lapply(pkg_list, function(p) {require(p,
                                      character.only = TRUE,
                                      quietly=TRUE)})


Data_dir <- "C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\stations\\IMS\\Nativ\\try"

IMS_merged <- LoadIMSData(Data_dir)

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
str(IMS_merged)
# write.csv(Nativ, file = "Nativ.csv")
# 
>>>>>>> 72441b9ba0c8444ba89e64afa356db83b507e0c7

