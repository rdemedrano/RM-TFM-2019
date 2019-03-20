# ===== RANGO DIARIO =====

# Script en el cual se van a preparar los datos para introducirlos en la xSTNN. En primer lugar, se va
# a realizar un dataset sencillo. Para ello:
# 1_ Cargar datos y paquetes
library(data.table); library(lubridate); library(sp); library(plyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
load("../Accidentes de tráfico - Madrid/Cleaned_data/trafico_2017.RData")


# 2_ Nos interesan solo día (fecha), dirección y número de accidentes (no lo saca todavía, ahora mismo solo podemos 
# saber número de afectados por accidente). Hay que tener en cuenta que los accidentes
# están repetidos, pero esto ya lo tiene en cuenta el by. Es decir, reune todos aquellos elementos con la misma fecha,
# rango y posición, por lo que la columna de las Ns sobra (pues nos dice precisamente el número de veces que se repite
# cierto accidente, el número de personas involucradas). Las autovías (NAs) hay que quitarlas,
car_crash <- GeoAccidentalidad[ , .N, by = list(FECHA, `RANGO HORARIO`, lon, lat)]
car_crash <- na.omit(car_crash)

# 3_ Vamos a aplicar el algoritmo en solo una serie de datos, por lo que cogeremos solo una muestra. Por ejemplo, aquellos
# cuyo año sea 2017.
car_crash[,FECHA := dmy(FECHA)]
car_crash[, N := NULL]
car_crash <- car_crash[year(FECHA) == 2017]

# 4_ Ahora es cuando hay que hacer el grid espacial, porque si juntamos primero por días u horas perdemos el número de accidentes
# por zona. Primero pasamos nuestros datos a coordenadas del paquete sp para poder tratarlos correctamente
sd <- data.frame(car_crash$lon, car_crash$lat) #Esto es porque se repite cada accidente por persona 
colnames(sd) <- c("lon", "lat")
coordinates(sd) <- ~ lon + lat
proj4string(sd) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

# Hacemos lo mismo para los puntos de medida
pmed_ubicacion <- fread("Raw_data/pmed_ubicacion_10_2018.csv")
colnames(pmed_ubicacion)[c(8,9)] <- c("lon", "lat")
sd_traf <- na.omit(data.frame(pmed_ubicacion$lon, pmed_ubicacion$lat)) #Esto es porque se repite cada accidente por persona 
colnames(sd_traf) <- c("lon", "lat")
coordinates(sd_traf) <- ~ lon + lat
proj4string(sd_traf) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")


# 5_ Para hacer el grid vamos a mirar el mínimo y máximo de lon y lat, y hacer un cuadrado a partir de eso. Eso se hace
# manualmente. Se va a utilizar un rectangulo de 7x7 que aproximadamente contiene a Madrid dentro de la M30.
grid  <- GridTopology(cellcentre.offset= c(-3.720591,40.403850), cellsize = c(6.54e-3,8.572e-3), cells.dim = c(7,7)) # Centro, distancia de cada celda, y número de celdas en cada dimensión
sg    <- SpatialGrid(grid)
poly  <- as.SpatialPolygons.GridTopology(grid)
proj4string(poly) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
plot(poly)
plot(sd, color = "red", add = TRUE)

# 6_ Se crean unos data.frame donde se puede ver a que zona corresponde cada uno de los puntos si caen dentro de aquellos que vamos
# a estudiar
zonas <- data.frame(sd, zona = over(sd, poly))
zonas_pmed <- data.frame(sd_traf, zona = over(sd_traf, poly))

# 7_ Se hace un merge de ambas tablas, zonas y car_crash/p_med
car_crash <- unique(join(car_crash, zonas))
car_crash <- na.omit(car_crash)
car_crash <- car_crash[, .N, by = list(FECHA, zona)]
colnames(car_crash)[3] <- "Número de accidentes"

pmed_ubicacion <- join(pmed_ubicacion, zonas_pmed)
pmed_ubicacion <- na.omit(pmed_ubicacion[,c("id", "lon", "lat", "zona")]) # Dejo la lon y lat para comprobar, pero realmente no haría falta
# Ahora en el caso del tráfico hay que hacer un merge por id con tráfico, para establecer a cada uno una zona.
traffic_int <- join(trafico_2017, pmed_ubicacion[, c("id", "zona")])
traffic_int <- na.omit(traffic_int)

# 8_ Se obtiene la intensidad media por día y zona
traffic_int[, "int_med" := mean(int_med), by= list(FECHA, zona)]
traffic_int_med <- unique(traffic_int[, c("FECHA", "zona", "int_med")])

# 9_ Se hace el conteo de accidentes por día y zona. SI no sale alguna zona algún día, hay que ponerlo como 0 accidentes,
# pero lo importante es que al final tiene que haber 365 días, con 49 zonas cada día y el número de accidentes para estos.
num_zonas = 7*7
fechas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2017-01-01'), ymd('2017-12-31'), by = '1 day'), num_zonas)),
                             zona = rep(1:num_zonas, times = 365))

# 10_ Ahora se hace el join con car_crash y se da 0 a todas aquellas zonas sin accidentes. Igual para intensidad
number_crash <- join(fechas_y_zonas, car_crash)
number_crash[is.na(number_crash)] <- 0

traffic <- join(fechas_y_zonas, traffic_int_med)
traffic[is.na(traffic)] <- 300

# 11_ Ahora hay que general el dataset final con el string en vez de número de accidentes y eso.
# Recuerda que primero va la variable de la serie temporal, y luego las exógenas
crash_traffic <- join(number_crash, traffic)
crash_traffic <- within(crash_traffic, variables <- paste(`Número de accidentes`, int_med))
crash_traffic[, c(3,4) := NULL]

# 12_ Ahora simplemente se pone en forma de matriz para la entrada en la STNN mediante dcast de data.table
crash_ex <- dcast(crash_traffic, FECHA~zona)
crash_ex <- crash_ex[, FECHA := NULL]
fwrite(crash_ex, file = "Raw_data/crash_ex.csv", sep = "\t", row.names = FALSE, col.names = FALSE)

# 13_ A continuación se construye la matriz de adjacencia en matlab


# ===== RANGO HORARIO =====

# Script en el cual se van a preparar los datos para introducirlos en la xSTNN. En primer lugar, se va
# a realizar un dataset sencillo. Para ello:
# 1_ Cargar datos y paquetes
library(data.table); library(lubridate); library(sp); library(plyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
load("../Accidentes de tráfico - Madrid/Cleaned_data/trafico_2014.RData")


# 2_ Nos interesan solo día (fecha), dirección y número de accidentes (no lo saca todavía, ahora mismo solo podemos 
# saber número de afectados por accidente). Hay que tener en cuenta que los accidentes
# están repetidos, pero esto ya lo tiene en cuenta el by. Es decir, reune todos aquellos elementos con la misma fecha,
# rango y posición, por lo que la columna de las Ns sobra (pues nos dice precisamente el número de veces que se repite
# cierto accidente, el número de personas involucradas). Las autovías (NAs) hay que quitarlas,
car_crash <- GeoAccidentalidad[ , .N, by = list(FECHA, `RANGO HORARIO`, lon, lat)]
car_crash <- na.omit(car_crash)

# 3_ Vamos a aplicar el algoritmo en solo una serie de datos, por lo que cogeremos solo una muestra. Por ejemplo, aquellos
# cuyo año sea 2017.
car_crash[,FECHA := dmy(FECHA)]
car_crash[, N := NULL]
car_crash <- car_crash[year(FECHA) == 2014]
car_crash$`RANGO HORARIO` <- extract_numeric(substr(car_crash$`RANGO HORARIO`, start = 1, stop = 5))

# 4_ Ahora es cuando hay que hacer el grid espacial, porque si juntamos primero por días u horas perdemos el número de accidentes
# por zona. Primero pasamos nuestros datos a coordenadas del paquete sp para poder tratarlos correctamente
sd <- data.frame(car_crash$lon, car_crash$lat) #Esto es porque se repite cada accidente por persona 
colnames(sd) <- c("lon", "lat")
coordinates(sd) <- ~ lon + lat
proj4string(sd) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

# Hacemos lo mismo para los puntos de medida
pmed_ubicacion <- fread("Raw_data/pmed_ubicacion_10_2018.csv")
colnames(pmed_ubicacion)[c(8,9)] <- c("lon", "lat")
sd_traf <- na.omit(data.frame(pmed_ubicacion$lon, pmed_ubicacion$lat)) #Esto es porque se repite cada accidente por persona 
colnames(sd_traf) <- c("lon", "lat")
coordinates(sd_traf) <- ~ lon + lat
proj4string(sd_traf) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")


# 5_ Para hacer el grid vamos a mirar el mínimo y máximo de lon y lat, y hacer un cuadrado a partir de eso. Eso se hace
# manualmente. Se va a utilizar un rectangulo de 7x7 que aproximadamente contiene a Madrid dentro de la M30.
grid  <- GridTopology(cellcentre.offset= c(-3.720591,40.403850), cellsize = c(6.54e-3,8.572e-3), cells.dim = c(7,7)) # Centro, distancia de cada celda, y número de celdas en cada dimensión
sg    <- SpatialGrid(grid)
poly  <- as.SpatialPolygons.GridTopology(grid)
proj4string(poly) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
plot(poly)
plot(sd, color = "red", add = TRUE)

# 6_ Se crean unos data.frame donde se puede ver a que zona corresponde cada uno de los puntos si caen dentro de aquellos que vamos
# a estudiar
zonas <- data.frame(sd, zona = over(sd, poly))
zonas_pmed <- data.frame(sd_traf, zona = over(sd_traf, poly))

# 7_ Se hace un merge de ambas tablas, zonas y car_crash/p_med
car_crash <- unique(join(car_crash, zonas))
car_crash <- na.omit(car_crash)
car_crash <- car_crash[, .N, by = list(FECHA, zona, `RANGO HORARIO`)]
colnames(car_crash)[4] <- "Número de accidentes"

pmed_ubicacion <- join(pmed_ubicacion, zonas_pmed)
pmed_ubicacion <- na.omit(pmed_ubicacion[,c("id", "lon", "lat", "zona")]) # Dejo la lon y lat para comprobar, pero realmente no haría falta
# Ahora en el caso del tráfico hay que hacer un merge por id con tráfico, para establecer a cada uno una zona. Se omiten aquellos
# puntos que no entran dentro de ninguna zona.
traffic_int <- join(trafico_2014, pmed_ubicacion[, c("id", "zona")])
traffic_int <- na.omit(traffic_int)

# 8_ Se obtiene la intensidad media por hora y zona
traffic_int[, "int_med" := mean(int_med), by= list(FECHA, `RANGO HORARIO`, zona)]
traffic_int_med <- unique(traffic_int[, c("FECHA", "RANGO HORARIO", "zona", "int_med")])

# 9_ Se hace el conteo de accidentes por día y zona. SI no sale alguna zona algún día, hay que ponerlo como 0 accidentes,
# pero lo importante es que al final tiene que haber 365 días, con 49 zonas cada día y el número de accidentes para estos.
num_dias = 45
num_zonas = 7*7
num_horas = num_zonas*24
fechas_horas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2014-01-01'), ymd('2014-02-16'), by = '1 day'), num_horas)),
                                   "RANGO HORARIO" = sort(rep(seq(0,23), num_zonas)),
                                   zona = rep(1:num_zonas, times = num_dias))

# 10_ Ahora se hace el join con car_crash y se da 0 a todas aquellas zonas sin accidentes. Igual para intensidad
number_crash <- join(fechas_horas_y_zonas, car_crash)
number_crash[is.na(number_crash)] <- 0

traffic <- join(fechas_horas_y_zonas, traffic_int_med)
traffic[is.na(traffic)] <- 300

# 11_ Ahora hay que general el dataset final con el string en vez de número de accidentes y eso.
# Recuerda que primero va la variable de la serie temporal, y luego las exógenas
crash_traffic <- join(number_crash, traffic)
crash_traffic <- within(crash_traffic, variables <- paste(`Número de accidentes`, int_med))
crash_traffic[, c(4,5) := NULL]

# 12_ Ahora simplemente se pone en forma de matriz para la entrada en la STNN mediante dcast de data.table
crash_ex <- dcast(crash_traffic, FECHA + `RANGO HORARIO` ~ zona)
crash_ex <- crash_ex[, c("FECHA", "RANGO HORARIO") := NULL]
fwrite(crash_ex, file = "Raw_data/crash_ex.csv", sep = "\t", row.names = FALSE, col.names = FALSE)

# 13_ A continuación se construye la matriz de adjacencia en matlab
