# Script para realizar el estudio de los cruces semaforizados
library(data.table); library(geosphere)

# 1_ Se cargan y general los datasets necesarios.
load("Cleaned_data/GeoAccidentalidad.RData")
cruces <- fread("Raw_data/cruces_semaforizados.csv")

# 2_ Se crea un nuevo data.table que contenga los accidentes que nos interesan
acc <- GeoAccidentalidad[, .N, by = list(FECHA, `RANGO HORARIO`, DISTRITO, `LUGAR ACCIDENTE`, Nº, lon, lat)]
acc <- na.omit(acc)
acc <- acc[year(dmy(FECHA)) > 2012]
acc <- acc[, N := NULL]

# 3_ Se calcula la distancia en metros de cada accidente a cada cruce semaforizado. Es decir, distancias es una matriz de 
# ncolumns(cruces) de filas y columns(acc) columnas. Nos interesan los cruces más cercanos de cada accidente.
distancias <- distm(cruces[, c(7,8)], acc[, c(6,7)])
acc[, `DIST CRUCE SEM` := apply(distancias, 2, min)]

# 4_ Se genera una variable auxiliar que nos dice si estamos en un cruce semaforizado o no. Hacemos 
acc$SEMAFORO <- ifelse(acc$`DIST CRUCE SEM` < 10, 1, 0)
acc_cruce <- acc[Nº == 0]
