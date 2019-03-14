# Script en el cual se van a preparar los datos para introducirlos en la STNN. En primer lugar, se va
# a realizar un dataset sencillo. Para ello:
# 1_ Cargar datos y paquetes
library(data.table); library(lubridate); library(sp); library(plyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")

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

# 5_ Para hacer el grid vamos a mirar el mínimo y máximo de lon y lat, y hacer un cuadrado a partir de eso. Eso se hace
# manualmente. Se va a utilizar un rectangulo de 7x7 que aproximadamente contiene a Madrid dentro de la M30.
grid  <- GridTopology(cellcentre.offset= c(-3.720591,40.403850), cellsize = c(6.54e-3,8.572e-3), cells.dim = c(7,7)) # Centro, distancia de cada celda, y número de celdas en cada dimensión
sg    <- SpatialGrid(grid)
poly  <- as.SpatialPolygons.GridTopology(grid)
proj4string(poly) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
plot(poly)
plot(sd, color = "red", add = TRUE)
# 6_ Se crea un data.frame donde se puede ver a que zona corresponde cada uno de los puntos si caen dentro de aquellos que vamos
# a estudiar
zonas <- data.frame(sd, zona = over(sd, poly))

# 7_ Se hace un merge de ambas tablas, zonas y car_crash
# POr algún motivo el join se inventa casos repitiendo otros reales. Por eso unique
car_crash <- unique(join(car_crash, zonas))
car_crash <- na.omit(car_crash)
car_crash <- car_crash[, .N, by = list(FECHA, zona)]
colnames(car_crash)[3] <- "Número de accidentes"

# 8_ Se hace el conteo de accidentes por día y zona. SI no sale alguna zona algún día, hay que ponerlo como 0 accidentes,
# pero lo importante es que al final tiene que haber 365 días, con 49 zonas cada día y el número de accidentes para estos.
num_zonas = 7*7
fechas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2017-01-01'), ymd('2017-12-31'), by = '1 day'), num_zonas)),
                             zona = rep(1:num_zonas, times = 365))

# 9_ Ahora se hace el join con car_crash y se da 0 a todas aquellas zonas sin accidentes
number_crash <- join(fechas_y_zonas, car_crash)
number_crash[is.na(number_crash)] <- 0

# 10_ Ahora simplemente se pone en forma de matriz para la entrada en la STNN mediante dcast de data.table
crash <- dcast(number_crash, FECHA~zona)
crash <- crash[, FECHA := NULL]
write.table(crash, file = "Raw_data/crash.csv", row.names = FALSE, col.names = FALSE)

# 11_ A continuación se construye la matriz de adjacencia en matlab

