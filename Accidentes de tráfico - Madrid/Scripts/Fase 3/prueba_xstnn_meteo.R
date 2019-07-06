# PREPARACIÓN DE DATOS PARA LA LA STNN PERO CON BARRIOS Y RANGO HORARIO. 
# SIMULACRO DE EXPERIMENTO REAL CON METEOROLOGÍA Y TRÁFICO


# Cargamos paquetes y dataset
library(data.table); library(lubridate); library(plyr); library(sp)
load("../Accidentes de tráfico - Madrid/Cleaned_data/BarriosAccidentalidad.RData")
load("../Accidentes de tráfico - Madrid/Cleaned_data/trafico_2018.RData")
# load("../Accidentes de tráfico - Madrid/Cleaned_data/trafico.RData")


car_crash <- BarriosAccidentalidad[ , .N, by = list(FECHA, `RANGO HORARIO`, BARRIO,lon, lat)]
car_crash <- na.omit(car_crash)

car_crash[,FECHA := dmy(FECHA)]
car_crash[, N := NULL]
car_crash <- car_crash[year(FECHA) == 2018]
# car_crash <- car_crash[year(FECHA) >= 2018]
car_crash$`RANGO HORARIO` <- extract_numeric(substr(car_crash$`RANGO HORARIO`, start = 1, stop = 5))

car_crash <- car_crash[, .N, by = list(FECHA, `RANGO HORARIO`, BARRIO)]
colnames(car_crash)[4] <- "Número de accidentes"

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
# traffic_int <- join(trafico, pmed_ubicacion[, c("id", "BARRIO")])
traffic_int <- na.omit(traffic_int)

# Se obtiene la intensidad media por hora y zona
traffic_int[, "int_med" := mean(int_med), by= list(FECHA, `RANGO HORARIO`, BARRIO)]
traffic_int_med <- unique(traffic_int[, c("FECHA", "RANGO HORARIO", "BARRIO", "int_med")])


num_dias = 365 
num_zonas = 131
num_horas = num_zonas*24
fechas_horas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2018-01-01'), ymd('2018-12-31'), by = '1 day'), num_horas)),
                                   "RANGO HORARIO" = sort(rep(seq(0,23), num_zonas)),
                                   BARRIO = rep(sort(unique(car_crash$BARRIO)), times = num_dias))

# Ahora se hace el join con car_crash y se da 0 a todas aquellas zonas sin accidentes. A la intensidad se le da 300
number_crash <- join(fechas_horas_y_zonas, car_crash)
number_crash[is.na(number_crash)] <- 0

traffic <- join(fechas_horas_y_zonas, traffic_int_med)
traffic[is.na(traffic)] <- 300


# METEOROLOGÍA
load("../Accidentes de tráfico - Madrid/Cleaned_data/meteo.RData")
meteo[,FECHA := dmy(FECHA)]
meteo <- meteo[year(FECHA) == 2018]
library(zoo)
# Hay NaN, creo que lo mejor es darle el valor que tuviese la casilla anterior (por proximidad)
meteo <- na.locf(meteo)
meteo[, c(2:9)] <- data.table(sapply(meteo[, c(2:9)], as.numeric))

meteo_crash <- join(number_crash, meteo)


# Ahora hay que general el dataset final con el string en vez de número de accidentes y eso.
# Recuerda que primero va la variable de la serie temporal, y luego las exógenas
crash_traffic <- join(meteo_crash, traffic)
# Si quieres normalizar - estandarizar...
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
crash_traffic[,c(4:12)] <- as.data.table(lapply(crash_traffic[,c(4:12)], normalize))

crash_traffic <- within(crash_traffic, variables <- paste(`Número de accidentes`, int_med, `Velocidad viento`, `Direccion viento`,
                                                          `Temperatura`, `Humedad relativa`, `Presion`, `Radiacion solar`, `Lluvia`))
crash_traffic[, c(4:12) := NULL]

# Ahora simplemente se pone en forma de matriz para la entrada en la STNN mediante dcast de data.table
xcrash <- dcast(crash_traffic, FECHA + `RANGO HORARIO` ~ BARRIO)
xcrash <- xcrash[, c("FECHA", "RANGO HORARIO") := NULL]
# fwrite(xcrash, file = "Raw_data/xcrash_10.csv", sep = "\t", row.names = FALSE, col.names = FALSE)
