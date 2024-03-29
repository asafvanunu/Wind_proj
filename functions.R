LoadIMSData <- function(data_path, station_name) {
  #' Read all CSV files in a directory,
  #' Parse date and time (LST time zone)
  #' Convert to UTC time zone
  #' Return merged data frame from a single station

  ims_file_list = list.files(data_path, pattern=".csv$", full.names = TRUE)
  ims_data_list = lapply(ims_file_list, function(f) {
    ims_wind = fread(file=f, na.string=c("-",""),)
    # Read in with hour as LST where GMT is 2 hours behind
    ims_wind$Date = gsub('-','/',ims_wind$Date)
    ims_wind$date_time = as_datetime(paste(ims_wind$Date, ims_wind$Hour_LST),
                                     format = "%d/%m/%Y %H:%M",
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


PlotWindrose <- function (station_data) {
  #Input data.table of stations
  # Select only gust speed, and direction columns
  # Rename those columns
  wind_df <- select(station_data, station, WS_UpperGust_ms, WD_UpperGust_degrees)
  names(wind_df) <- c("station_name", "wind_speed", "wind_direction")
  # What to do with wind direction < 0 ??
  wind_df$wind_direction[which(wind_df$wind_direction<0)] <- NA
  rose_plot = clifro::windrose(speed = wind_df$wind_speed,
                             direction = wind_df$wind_direction,
                             facet = wind_df$station_name, 
                             col_pal = "YlOrRd", n_col = 3,
                             n_speeds = 7,
                             legend_title = "Wind speed m/s",
                             strip.text = element_text(size=12, face="bold"),
                             plot.title = element_text(size=14, face="bold", hjust = 0.5))
  
  print(rose_plot)
}

extreme_value = function (IMS_merged,stn) {
    max_gust_per_year = IMS_merged %>%
      group_by(date_time = floor_date(date_time, "year")) %>%
      summarize(mean_WS_ms = mean(WS_ms, na.rm=T),
              max_WS_ms=max(WS_ms,na.rm=T),
              mean_Gust_ms = mean(WS_UpperGust_ms,na.rm=T),
              max_gust_ms=max(WS_UpperGust_ms,na.rm=T))
    
    yrs <- unique(year(max_gust_per_year$date_time))
    max_gust_list <- lapply(yrs, function(y) {
      IMS_merged_yr <- IMS_merged[year(IMS_merged$date_time) == y,]
      max_gust_value <- max_gust_per_year$max_gust_ms[
        year(max_gust_per_year$date_time) == y]
      IMS_merged_max <- IMS_merged_yr[
        IMS_merged_yr$WS_UpperGust_ms == max_gust_value,]
      if(nrow(IMS_merged_max) == 1) {
        max_yearly <- data.frame(
          "date_time" = IMS_merged_max$date_time,
          "compass" = IMS_merged_max$compass,
          "max_gust" = IMS_merged_max$WS_UpperGust_ms) 
      } else {
        # What if there is more than one date_time with same max value?
        print(paste("Number of rows:", 
                    nrow(IMS_merged_max), "in year:", y))
        IMS_merged_max <- IMS_merged_max[which.max(IMS_merged_max$Gust_ma),]
        max_yearly <- data.frame(
         "date_time" = IMS_merged_max$date_time,
         "compass" = IMS_merged_max$compass,
         "max_gust" = IMS_merged_max$WS_UpperGust_ms) 
      }
      return(max_yearly)
    })
    
    max_gust_year <- do.call(rbind, max_gust_list)
    
    fit = fevd(max_gust_year$max_gust, data=max_gust_year, type = "GEV",
               location.fun = ~max_gust_year$compass)
    v_year <- make.qcov(fit, vals = list(mu1 = c(1:4)))
    return_level = return.level(fit, return.period = c(10,20,50), qcov = v_year)
    return_level
    plot(fit, main = stn, rperiods = c(10,20,50))
    
}

## max gust and compass for each month

extreme_value_month = function (IMS_merged,stn) {
  max_gust_per_month <- IMS_merged %>%
    group_by(date_time = floor_date(date_time, "month"))%>%
    summarize(mean_WS_ms = mean(WS_ms, na.rm=T),
              max_WS_ms=max(WS_ms,na.rm=T),
              mean_Gust_ms = mean(WS_UpperGust_ms,na.rm=T),
              max_gust_ms=max(WS_UpperGust_ms,na.rm=T))
  
  unique(format_ISO8601(max_gust_per_month$date_time, precision = "ym"))
  
  yrs_months <- unique(format_ISO8601(max_gust_per_month$date_time, precision = "ym"))
  max_gust_year_month_list <- lapply(yrs_months, function(ym) {
    IMS_merged_yr_mo <- 
      IMS_merged[format_ISO8601(IMS_merged$date_time, precision = "ym") == ym,]
    max_gust_value_yr_mo <- max_gust_per_month$max_gust_ms[
      format_ISO8601(max_gust_per_month$date_time, precision = "ym") == ym]
    IMS_merged_max_yr_mo <- IMS_merged_yr_mo[
      IMS_merged_yr_mo$WS_UpperGust_ms == max_gust_value_yr_mo,]
    if(nrow(IMS_merged_max_yr_mo) == 1) {
      max_yearly_month <- data.frame(
        "date_time" = IMS_merged_max_yr_mo$date_time,
        "compass" = IMS_merged_max_yr_mo$compass,
        "max_gust" = IMS_merged_max_yr_mo$WS_UpperGust_ms) 
    } else {
      # What if there is more than one date_time with same max value?
      print(paste("Number of rows:", 
                  nrow(IMS_merged_max_yr_mo), "in year and month:", ym))
      IMS_merged_max_yr_mo <- 
        IMS_merged_max_yr_mo[which.max(IMS_merged_max_yr_mo$Gust_ma),]
      max_yearly_month <- data.frame(
        "date_time" = IMS_merged_max_yr_mo$date_time,
        "compass" = IMS_merged_max_yr_mo$compass,
        "max_gust" = IMS_merged_max_yr_mo$WS_UpperGust_ms) 
    }
    return(max_yearly_month)
  })
  
  max_gust_year_month <- do.call(rbind, max_gust_year_month_list)
  
  fit_month <- 
    fevd(max_gust_year_month$max_gust, data=max_gust_year_month, type = "GEV",
             location.fun = ~max_gust_year_month$compass)
  v_year <- make.qcov(fit_month, vals = list(mu1 = c(1:4)))
  return_level_months = return.level(fit_month, return.period = c(10,20,50),
  qcov = v)
  return_level_months
  plot(fit_month, main = stn, rperiods = c(10,20,50))
  
}
