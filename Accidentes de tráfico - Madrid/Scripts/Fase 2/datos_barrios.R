# EJEMPLO DE TRATAMIENTO DE LOS BARRIOS DE MADRID

library(rgdal); library(sp)

barrios <- rgdal::readOGR("Raw_data/BARRIOS.shp")

# df <- data.frame(x = c(434753,424754), y=  c(4473567,4462567))
# coordinates(df) <- ~ x + y
# proj4string(df) <- CRS("+proj=utm +zone=30 +ellps=GRS80 +units=m +no_defs")

df <- data.frame(x = c(-3.888964,-3.758963), y =  c(40.312066, 40.4155065))
coordinates(df) <- ~ x + y
proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

barrios <- spTransform(barrios, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

zonas <- over(df, barrios)

plot(barrios)
plot(df, add = TRUE)