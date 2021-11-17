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



Data_dir <- "C:\\Users\\asaf_rs\\Desktop\\wind\\Wind_proj\\stations\\IMS\\Dorot"

IMS_merged <- LoadIMSData(Data_dir)


str(IMS_merged)


write.csv(ims_wind, file = "Dorot_station.csv")




