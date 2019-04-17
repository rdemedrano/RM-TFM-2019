# SCRIPT EN EL QUE SE GENERA EL DATASET PARA LA STNN CON LA INTENSIDAD DE TRÁFICO

library(data.table); library(lubridate); library(plyr); library(sp); library(tidyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/trafico_2018.RData")

# Puntos de medida espaciales
pmed_ubicacion <- fread("Raw_data/pmed_ubicacion_10_2018.csv")
colnames(pmed_ubicacion)[c(8,9)] <- c("lon", "lat")
sd_traf <- na.omit(data.frame(pmed_ubicacion$lon, pmed_ubicacion$lat)) #Esto es porque se repite cada accidente por persona 
colnames(sd_traf) <- c("lon", "lat")
coordinates(sd_traf) <- ~ lon + lat
proj4string(sd_traf) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

library(rgdal)
barrios <- rgdal::readOGR("Raw_data/BARRIOS.shp")
barrios <- spTransform(barrios, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
zonas_pmed <- data.frame(sd_traf, zona = over(sd_traf, barrios))
zonas_pmed <- zonas_pmed[,c(1,2,7)]
colnames(zonas_pmed)[3] <- "BARRIO"

# Ahora vamos con la intensida de tráfico.
pmed_ubicacion <- join(pmed_ubicacion, zonas_pmed)
pmed_ubicacion <- na.omit(pmed_ubicacion[,c("id", "lon", "lat", "BARRIO")]) # Dejo la lon y lat para comprobar, pero realmente no haría falta
# Ahora en el caso del tráfico hay que hacer un merge por id con tráfico, para establecer a cada uno una zona. Se omiten aquellos
# puntos que no entran dentro de ninguna zona.
traffic_int <- join(trafico_2018, pmed_ubicacion[, c("id", "BARRIO")])
traffic_int <- na.omit(traffic_int)

# Se obtiene la intensidad media por hora y zona
traffic_int[, "int_med" := mean(int_med), by= list(FECHA, `RANGO HORARIO`, BARRIO)]
traffic_int_med <- unique(traffic_int[, c("FECHA", "RANGO HORARIO", "BARRIO", "int_med")])
# CUidado porque utiliza el barrio como un factor, no como númerico. Mientras que en el resto
# de datasets es numérico.
traffic_int_med$BARRIO <- as.numeric(as.character(traffic_int_med$BARRIO))


num_dias = 45
# Parece ser que hay algunos barrios sin puntos de medida, pero por facilitar las cosas 
# los ponemos igual y ya se les dará el valor de NA
num_zonas = 131
num_horas = num_zonas*24
fechas_horas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2018-01-01'), ymd('2018-02-14'), by = '1 day'), num_horas)),
                                   "RANGO HORARIO" = sort(rep(seq(0,23), num_zonas)),
                                   BARRIO = rep(sort(as.numeric(as.character(barrios$CODBAR))), times = num_dias))

# Ahora se hace el join con la intensidad, y si es NA se le da 300 que es más o menos la media.
traffic <- join(fechas_horas_y_zonas, traffic_int_med)
traffic[is.na(traffic)] <- 300

# Si quieres normalizar - estandarizar...
traffic$int_med <- (traffic$int_med-min(traffic$int_med))/(max(traffic$int_med) - min(traffic$int_med))

# Ahora simplemente se pone en forma de matriz para la entrada en la STNN mediante dcast de data.table
traffic_stnn <- dcast(traffic, FECHA + `RANGO HORARIO` ~ BARRIO)
traffic_stnn <- traffic_stnn[, c("FECHA", "RANGO HORARIO") := NULL]
# fwrite(traffic_stnn, file = "Raw_data/traffic.csv", sep = "\t", row.names = FALSE, col.names = FALSE)
