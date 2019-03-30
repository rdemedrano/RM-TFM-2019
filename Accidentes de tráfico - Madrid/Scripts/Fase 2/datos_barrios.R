# EJEMPLO DE TRATAMIENTO DE LOS BARRIOS DE MADRID

library(rgdal); library(sp); library(data.table); library(plyr)

barrios <- rgdal::readOGR("Raw_data/BARRIOS.shp")

# Si se trabaja en el sistema de coordenadas del archivo
# df <- data.frame(x = c(434753,424754), y=  c(4473567,4462567))
# coordinates(df) <- ~ x + y
# proj4string(df) <- CRS("+proj=utm +zone=30 +ellps=GRS80 +units=m +no_defs")

# Si se trabaja en el sistema de coordenadas mundial (accidentes)  
# df <- data.frame(x = c(-3.888964,-3.758963), y =  c(40.312066, 40.4155065))
# coordinates(df) <- ~ x + y
# proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
# barrios <- spTransform(barrios, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# Con el objeto leido se puede utilizar over y plot sin problemas
# zonas <- over(df, barrios)
# plot(barrios)
# plot(df, add = TRUE)

load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
GeoAccidentalidad <- na.omit(GeoAccidentalidad)

spatial_data <- data.frame(GeoAccidentalidad$lon, GeoAccidentalidad$lat) #Esto es porque se repite cada accidente por persona 
colnames(spatial_data) <- c("lon", "lat")
coordinates(spatial_data) <- ~ lon + lat
proj4string(spatial_data) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
barrios <- spTransform(barrios, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

plot(barrios)
plot(spatial_data, add = TRUE)


zonas <- data.frame(spatial_data, zona = over(spatial_data, barrios))
zonas <- zonas[,c(1,2,7)]
colnames(zonas)[3] <- "BARRIO"

BarriosAccidentalidad <- join(GeoAccidentalidad, unique(zonas))
BarriosAccidentalidad$BARRIO <- as.numeric(as.character(BarriosAccidentalidad$BARRIO))

save(BarriosAccidentalidad, file = "Cleaned_data/BarriosAccidentalidad.RData", compress = "xz")
