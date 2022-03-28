
Rain_dir <- "C:\\Users\\asaf_rs\\Desktop\\projects\\wind\\Wind_proj\\Rain"
rain_stations <- dir(Rain_dir)

##Create function which load all the station rain data
LoadIMSRain <- function(data_path, station_name) {
rain_file_list = list.files(data_path, pattern=".csv$", full.names = TRUE)
rain_data_list = lapply(rain_file_list, function(f) {
  ims_rain = fread(file=f, na.string=c("-",""),)
  # Read in with hour as LST where GMT is 2 hours behind
  ims_rain$Date = as_datetime((ims_rain$Date), format = "%d/%m/%Y")
  # Convert to UTC ("Greenwich Mean Time")
  ims_rain$Date = as_datetime(ims_rain$Date, tz = "UTC") 
  ims_rain$Station_Name = station_name
  return(ims_rain)
})
rain_data <- do.call(rbind, rain_data_list)
return(rain_data)
}

##create rain stations list 
rain_station_data_list <- lapply(rain_stations, function(stn){
  # Now read all years of data from one station, and merge
  IMS_rain_merged <- LoadIMSRain(file.path(Rain_dir, stn), stn)
})

## Merge all of the rain list

rain_data <- do.call(rbind, rain_station_data_list)

#create function which makes mean for months 1,2,3 in each year
mean_rain <- function(stn_name){
  stn_name%>%
  filter(month(Date) <=3 & month(Date)>=1)%>%
  group_by(Date = floor_date(Date, "year"))%>%
  summarize(mean_rain = mean(Month_precipitation_mm, na.rm=T))
}


## Mean rain for feb and mar
mean_rain_feb_mar <- function(stn_name){
  stn_name%>%
    filter(month(Date) <=3 & month(Date)>=2)%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(mean_rain = mean(Month_precipitation_mm, na.rm=T))
}

## max rain for each year
max_rain <- function(stn_name){
  stn_name%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(max_rain = max(Month_precipitation_mm, na.rm=T))
}

jan_rain <- function(stn_name){
  stn_name%>%
    filter(month(Date) ==1)
}

feb_rain <- function(stn_name){
  stn_name%>%
    filter(month(Date) ==2)
}

mar_rain <- function(stn_name){
  stn_name%>%
    filter(month(Date) ==3)
}

#max calc
Gat_max <- max_rain(rain_station_data_list[[2]])
Galon_max <- max_rain(rain_station_data_list[[1]])
Jamal_max <- max_rain(rain_station_data_list[[3]])
Jovrin_max <- max_rain(rain_station_data_list[[4]])
Nativ_max <- max_rain(rain_station_data_list[[5]])

##jan rain for each year
Gat_jan <- jan_rain(rain_station_data_list[[2]])
Galon_jan <- jan_rain(rain_station_data_list[[1]])
Jamal_jan <- jan_rain(rain_station_data_list[[3]])
Jovrin_jan <- jan_rain(rain_station_data_list[[4]])
Nativ_jan <- jan_rain(rain_station_data_list[[5]])
##feb rain for each year
Gat_feb <- feb_rain(rain_station_data_list[[2]])
Galon_feb <- feb_rain(rain_station_data_list[[1]])
Jamal_feb <- feb_rain(rain_station_data_list[[3]])
Jovrin_feb <- feb_rain(rain_station_data_list[[4]])
Nativ_feb <- feb_rain(rain_station_data_list[[5]])
##mar rain for each year
Gat_mar <- mar_rain(rain_station_data_list[[2]])
Galon_mar <- mar_rain(rain_station_data_list[[1]])
Jamal_mar <- mar_rain(rain_station_data_list[[3]])
Jovrin_mar <- mar_rain(rain_station_data_list[[4]])
Nativ_mar <- mar_rain(rain_station_data_list[[5]])

## extreme model for each station
fit = fevd(Gat_max$max_rain, data=Gat_max, type = "GEV")
return_level = return.level(fit, return.period = c(15,20,30))
return_level
plot(fit, main = "Gat", rperiods = c(15,20,30))


fit = fevd(Jovrin_max$max_rain, data=Jovrin_max, type = "GEV")
return_level = return.level(fit, return.period = c(15,20,30))
return_level
plot(fit, main = "Jovrin", rperiods = c(15,20,30))

fit = fevd(Galon_max$max_rain, data=Galon_max, type = "GEV")
return_level = return.level(fit, return.period = c(15,20,30))
return_level
plot(fit, main = "Galon", rperiods = c(15,20,30))

fit = fevd(Nativ_max$max_rain, data=Nativ_max, type = "GEV")
return_level = return.level(fit, return.period = c(15,20,30))
return_level
plot(fit, main = "Nativ", rperiods = c(15,20,30))

fit = fevd(Jamal_max$max_rain, data=Jamal_max, type = "GEV")
return_level = return.level(fit, return.period = c(15,20,30))
return_level
plot(fit, main = "Jamal", rperiods = c(15,20,30))



#save data_function - left join for getting the exact month of event
save_rain <- data <- function(stn_x,stn_y){
  j <- left_join(stn_x, stn_y,
                   by = c("max_rain"="Month_precipitation_mm"))
  j <- j[,c(2,3,5)]
  j <- j[,c(2,3,1)]
  j <- j[order(-j$max_rain),]
  write.csv(j,
paste("C:\\Users\\asaf_rs\\Desktop\\wind\\output\\max_rain\\"
,as.character(j[1,1]),".csv"))
        
   }

##save the data
save_rain(Gat_max, rain_station_data_list[[2]])
save_rain(Galon_max,rain_station_data_list[[1]])
save_rain(Jovrin_max,rain_station_data_list[[4]])
save_rain(Nativ_max,rain_station_data_list[[5]])




