install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)
library(lubridate)

setwd("C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\stations\\IMS\\Negba")


## merging multiyear data
my_files <- list.files(pattern = "*.csv")


ims_wind = lapply(my_files, function(i){
  x = read.csv(i)
  x})

ims_wind = do.call("rbind.data.frame", ims_wind)

## delete station name
ims_wind = ims_wind[,-1]

ims_wind = as_tibble(ims_wind)

##set the date column into date class
ims_wind$Date = as.Date(ims_wind$Date, "%d/%m/%Y")
##set the time column
ims_wind$Hour_LST = as.ITime(ims_wind$Hour_LST)
## set numeric columns
ims_wind[,3:13] = apply(ims_wind[3:13],2,function(x) as.numeric(as.character(x)))


##Micha part
# Read in with hour as LST where GMT is 2 hours behind
ims_wind$date_time = as_datetime(paste(ims_wind$Date, ims_wind$Hour_LST),
                                 tz = "Etc/GMT-2")
# Convert to UTC ("Greenwich Mean Time")
ims_wind$date_time = as_datetime(ims_wind$date_time, tz = "UTC")
# Check conversion:
head(ims_wind[,c("Date", "Hour_LST", "date_time")])
tail(ims_wind[,c("Date", "Hour_LST", "date_time")])


#change column order

ims_wind <- ims_wind[, c(1,2,14,3,4,5,6,7,8,9,10,11,12,13)]

# Data structure

str(ims_wind)

write.csv(ims_wind, file = "Negba_station.csv")




