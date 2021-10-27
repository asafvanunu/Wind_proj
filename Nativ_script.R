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

