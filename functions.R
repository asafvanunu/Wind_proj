LoadIMSData <- function(data_path, station_name) {
  #' Read all CSV files in a directory,
  #' Parse date and time (LST time zone)
  #' Convert to UTC time zone
  #' Return merged data frame
  ims_file_list = list.files(data_path, pattern=".csv$", full.names = TRUE)
  ims_data_list = lapply(ims_file_list, function(f) {
    ims_wind = read.csv(f)
    # Read in with hour as LST where GMT is 2 hours behind
    ims_wind$date_time = as_datetime(paste(ims_wind$Date, ims_wind$Hour_LST),
                                     format = "%d/%m/%Y %H:%M",
                                     tz = "Etc/GMT-2")
    # Convert to UTC ("Greenwich Mean Time")
    ims_wind$date_time = as_datetime(ims_wind$date_time, tz = "UTC") 
    # Some columns input as character because of '-' or other non-numeric
    # Force all to be numeric (Some will become NA)
    ims_wind[,3:13] = apply(ims_wind[3:13], 2,
                            function(x) as.numeric(as.character(x)))
    ims_wind$station = station_name
    return(ims_wind[,2:ncol(ims_wind)])
  })
  ims_data <- do.call(rbind, ims_data_list)
  return(ims_data)
}
