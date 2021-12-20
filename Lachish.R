LoadIMSData_lac <- function(data_path, station_name) {
  #' Read all CSV files in a directory,
  #' Parse date and time (LST time zone)
  #' Convert to UTC time zone
  #' Return merged data frame from a single station
  
  ims_file_list = list.files(data_path, pattern=".csv$", full.names = TRUE)
  ims_data_list = lapply(ims_file_list, function(f) {
    ims_wind = fread(file=f, na.string=c("-",""),)
    # Read in with hour as LST where GMT is 2 hours behind
    ims_wind$date_time = as_datetime(ims_wind$Date,
                                     format = "%H:%M %d/%m/%Y",
                                     tz = "Etc/GMT-2")
    # Convert to UTC ("Greenwich Mean Time")
    ims_wind$date_time = as_datetime(ims_wind$date_time, tz = "UTC") 
    # Some columns input as character because of '-' or other non-numeric
    # Force all to be numeric (Some will become NA)
    # ims_wind[,3:13] = apply(ims_wind[3:13], 2,
    #                         function(x) as.numeric(as.character(x)))
    ims_wind <- filter(ims_wind, year(date_time) >= 2000)
    ims_wind$WD_UpperGust_degrees[ims_wind$WD_UpperGust_degrees <0] <- NA
    ims_wind$WD_UpperGust_degrees[ims_wind$WD_UpperGust_degrees  == 360] <- 0
    ims_wind$compass <- as.integer(ims_wind$WD_UpperGust_degrees/90)+1
    
    ims_wind$station = station_name
    return(ims_wind[,2:ncol(ims_wind)])
  })
  ims_data <- do.call(rbind, ims_data_list)
  ims_data <- ims_data[!is.na(ims_data$WS_UpperGust_ms),]
  ims_data_zoo <- zoo(ims_data$WS_UpperGust_ms, ims_data$date_time)
  ims_data$Gust_ma <- rollmean(ims_data_zoo,3, fill = NA)
  return(ims_data)
}