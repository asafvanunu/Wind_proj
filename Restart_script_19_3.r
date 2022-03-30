
## load rain & wind data sets
rain_data <- readRDS("D:\\Project_data\\wind\\Rain\\Rain_data.rds") 
station_data <- readRDS("C:\\Users\\asaf_rs\\Desktop\\projects\\wind\\Wind_proj\\station_data.rds")
## wind after filtering jan, feb and mar
winter_wind <- readRDS("D:\\Project_data\\wind\\wind\\winter_wind.rds")

## mean rain value for each winter by year
mean_winter_rain <- rain_data%>%
  filter(month(Date) <=3 & month(Date)>=1)%>%
  group_by(Date = floor_date(Date, "year"))%>%
  summarize(high_rain = mean(Month_precipitation_mm, na.rm=T))

## takes 3 quantile as a reference for rainy year
rainy_value <- as.integer(quantile(mean_winter_rain$high_rain)[4]) 
dry_value <- as.integer(quantile(mean_winter_rain$high_rain)[2])

## create dry and rainy years
dry_years <- mean_winter_rain%>%
  filter(high_rain<rainy_value)

  rainy_years <- mean_winter_rain%>%
    filter(high_rain>=rainy_value)
  

 ##write_rds(rain_data, "D:\\Project_data\\wind\\Rain\\Rain_data.rds")
  
  ## wind part
 
   #winter_wind <- station_data%>%
    #filter(month(Date) <=3 & month(Date)>=1)
   
   ##write_rds(winter_wind, "D:\\Project_data\\wind\\wind\\winter_wind.rds") 
   
  ## filter out wind in rainy and dry years
   wind_rainy_years <- winter_wind%>%
     filter(year(date_time) %in% year(rainy_years$Date))
   
   wind_dry_years <- winter_wind%>%
     filter(year(date_time) %in% year(dry_years$Date))
   
    par(mfrow = c(2,2))
   
   hist(wind_rainy_years$WS_UpperGust_ms, breaks = 30, main = "gust in rainy years",
        freq = F)
   
   hist(wind_dry_years$WS_UpperGust_ms, breaks = 30, main = "gust in dry years",
        freq = F)
   
   hist(wind_rainy_years$WS_UpperGust_ms, breaks = 30, main = "gust in rainy years",
        ylim = c(0,0.002), xlim = c(20,30), freq = F)
   
   
   hist(wind_dry_years$WS_UpperGust_ms, main = "gust in dry years",
        ylim = c(0,0.002), xlim = c(20,30), freq = F)
  
    ## create CDF and density functions & plots
  density_rainy <- density(wind_rainy_years$WS_UpperGust_ms) 
  density_dry <- density(wind_dry_years$WS_UpperGust_ms) 
  
  rainy_cdf <- ecdf(wind_rainy_years$WS_UpperGust_ms)
  dry_cdf <- ecdf(wind_dry_years$WS_UpperGust_ms)
  
  plot(density_rainy)
  
  plot(density_dry)
  
  plot(rainy_cdf, verticals = T, do.points = F, col="red",
  main = "CDF gust m/s", xlab = "gust m/s", xlim = c(20, 30), ylim = c(0.995,1))
  
  plot(dry_cdf, verticals = T, do.points = F, add=T)
  legend("topright", legend = c("dry years", "rainy years"), lty = 1, col = c(1, 2))
  
###################################################################
  #################################################################
  ## script 30.3 after golan meeting - subset by daily max
  
  mean_winter_rain <- rain_data%>%
    filter(month(Date) <=3 & month(Date)>=1)%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(high_rain = mean(Month_precipitation_mm, na.rm=T))

  ##daily max speed from all stations
  daily_winter_wind <- winter_wind%>%
    mutate(day = day(date_time), month = month(date_time), year = year(date_time))%>%
    group_by(day, month, year)%>%
    summarize(daily_max_gust = max(WS_UpperGust_ms))
  
  ## takes 3 quantile as a reference for rainy year
  rainy_value <- as.integer(quantile(mean_winter_rain$high_rain)[4])  
  dry_value <- as.integer(quantile(mean_winter_rain$high_rain)[2])
  ## create dry and rainy years
  dry_years <- mean_winter_rain%>%
    filter(high_rain<dry_value)
  
  rainy_years <- mean_winter_rain%>%
    filter(high_rain>=rainy_value)
  
  
  
  ## filter out wind in rainy and dry years
  wind_rainy_years <- daily_winter_wind%>%
    filter(year %in% year(rainy_years$Date))
  
  wind_dry_years <- daily_winter_wind%>%
    filter(year %in% year(dry_years$Date))
  
  par(mfrow = c(2,2))
  
  hist(wind_rainy_years$WS_UpperGust_ms, breaks = 30, main = "gust in rainy years",
       freq = F)
  
  hist(wind_dry_years$WS_UpperGust_ms, breaks = 30, main = "gust in dry years",
       freq = F)
  
  hist(wind_rainy_years$WS_UpperGust_ms, breaks = 30, main = "gust in rainy years",
       ylim = c(0,0.002), xlim = c(20,30), freq = F)
  
  
  hist(wind_dry_years$WS_UpperGust_ms, main = "gust in dry years",
       ylim = c(0,0.002), xlim = c(20,30), freq = F)
  
  ## create CDF and density functions & plots
  density_rainy <- density(wind_rainy_years$WS_UpperGust_ms) 
  density_dry <- density(wind_dry_years$WS_UpperGust_ms) 
  
  rainy_cdf <- ecdf(wind_rainy_years$daily_max_gust)
  dry_cdf <- ecdf(wind_dry_years$daily_max_gust)
  
  plot(density_rainy)
  
  plot(density_dry)
  
  plot(rainy_cdf, verticals = T, do.points = F, col="red",
       main = "CDF gust m/s", xlab = "gust m/s",xlim = c(15, 30), ylim = c(0.8,1))
  
  plot(dry_cdf, verticals = T, do.points = F, add=T)
  legend("topright", legend = c("dry years", "rainy years"), lty = 1, col = c(1, 2))
  