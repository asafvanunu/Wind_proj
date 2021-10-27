install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)

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

library(lubridate)

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

write.csv(Nativ, file = "Nativ.csv")




