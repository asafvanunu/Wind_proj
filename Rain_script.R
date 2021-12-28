
Rain_dir <- "C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\Rain"
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

#create function which makes mean for months 1,2,3 in each year
mean_rain <- function(stn_name){
  stn_name%>%
  filter(month(Date) <=3 & month(Date)>=1)%>%
  group_by(Date = floor_date(Date, "year"))%>%
  summarize(mean_rain = mean(Month_precipitation_mm, na.rm=T))
}
#mean calc
Gat_mean <- mean_rain(rain_station_data_list[[2]])
Galon_mean <- mean_rain(rain_station_data_list[[1]])
Jamal_mean <- mean_rain(rain_station_data_list[[3]])
Jovrin_mean <- mean_rain(rain_station_data_list[[4]])
Nativ_mean <- mean_rain(rain_station_data_list[[5]])

fit = fevd(Gat_mean$mean_rain, data=Gat_mean, type = "GEV")
return_level = return.level(fit, return.period = c(10,20,50))
return_level
plot(fit, main = "Gat", rperiods = c(10,20,50))

fit = fevd(Jovrin_mean$mean_rain, data=Jovrin_mean, type = "GEV")
return_level = return.level(fit, return.period = c(10,20,50))
return_level
plot(fit, main = "Jovrin", rperiods = c(10,20,50))

fit = fevd(Galon_mean$mean_rain, data=Galon_mean, type = "GEV")
return_level = return.level(fit, return.period = c(10,20,50))
return_level
plot(fit, main = "Galon", rperiods = c(10,20,50))

fit = fevd(Nativ_mean$mean_rain, data=Nativ_mean, type = "GEV")
return_level = return.level(fit, return.period = c(10,20,30))
return_level
plot(fit, main = "Nativ", rperiods = c(10,20,30))

fit = fevd(Jamal_mean$mean_rain, data=Jamal_mean, type = "GEV")
return_level = return.level(fit, return.period = c(10,20,50))
return_level
plot(fit, main = "Jamal", rperiods = c(10,20,50))


mean_rain_feb_mar <- function(stn_name){
  stn_name%>%
    filter(month(Date) <=3 & month(Date)>=2)%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(mean_rain = mean(Month_precipitation_mm, na.rm=T))
}

max_rain <- function(stn_name){
  stn_name%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(max_rain = max(Month_precipitation_mm, na.rm=T))
}


