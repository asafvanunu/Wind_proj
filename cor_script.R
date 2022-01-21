##Mean function for rain <- only during winter periods grouping for each year
mean_rain <- function(stn_name){
  stn_name%>%
    filter(month(Date) ==3 | month(Date)==2 | month(Date)==1 | month(Date)==11 | 
    month(Date)==12)%>%
    group_by(Date = floor_date(Date, "year"))%>%
    summarize(mean_rain = mean(Month_precipitation_mm, na.rm=T))
}
## max function for wind <-  only during winter periods grouping for each year
max_wind <- function(stn_name){
  stn_name%>%
    filter(month(date_time) ==3 | month(date_time)==2 | 
    month(date_time)==1 | month(date_time)==11 | 
    month(date_time)==12)%>%
    group_by(Date = floor_date(date_time, "year"))%>%
    summarize(max_gust = max(WS_UpperGust_ms, na.rm=T))
}

## I took "Besor" station as an example,
## here i calculated the mean rain for each winter by year
mean_besor_rain <- mean_rain(rain_station_data_list[[1]])

## rainy year is considered above the mean of all winters 
besor_rainy <- mean_besor[mean_besor$mean_rain>mean(mean_besor$mean_rain),]

## max rain for each winter period by year
max_besor_wind <- max_wind(station_data_list[[1]])

## see which dates are matching for rainy years and max gust data
##(there is a lot more rain data by years)
besor_rainy_match <- besor_rainy[which(besor_rainy$Date%in%max_besor_wind$Date),]

## matching gust years to rainy years
besor_max_wind_match <- 
max_besor_wind[which(max_besor_wind$Date%in%besor_rainy_match$Date),]

## testing correlation
cor(besor_max_wind_match$max_gust, besor_rainy_match$mean_rain)

## i tried to create a genreal fuction for this correlation
correlation <- function(wind_stn, rain_stn){
  
  mean_rain_stn <- mean_rain(rain_stn)
  
  rainy_years <- mean_rain_stn[mean_rain_stn$mean_rain>mean(mean_rain_stn$mean_rain),]
  
  max_stn_wind <- max_wind(wind_stn)
  
  rainy_match <- rainy_years[which(rainy_years$Date%in%max_stn_wind$Date),]
  
  ## matching gust years to rainy years
  max_wind_match <- 
    max_stn_wind[which(max_stn_wind$Date%in%rainy_match$Date),]
  
  ## testing correlation
  cor_rain_wind <- cor(max_wind_match$max_gust, rainy_match$mean_rain)
 
  return(cor_rain_wind)
  }

##try
correlation(station_data_list[[1]], rain_station_data_list[[1]])
