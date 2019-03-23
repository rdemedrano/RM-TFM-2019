# Script en el que se preparan los datos meteorológicos, previa limpieza.

library(data.table); library(lubridate)

meteo_2013 <- fread("../../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2013.csv", sep = ";", fill = TRUE)
meteo_2014 <- fread("../../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2014.csv", sep = ";", fill = TRUE)
load("Raw_data/red_meteo_municipal_2015.RData")
meteo_2016 <- fread("Raw_data/red_meteo_municipal_2016.csv", fill = TRUE)
meteo_2017 <- fread("Raw_data/red_meteo_municipal_2017.csv", fill = TRUE)
meteo_2018 <- fread("Raw_data/red_meteo_municipal_2018.csv", fill = TRUE)

# 1_ Todos tienen dos filas sobrantes, y necesitan remodificar los nombres de sus columnas. Lo haremos de forma que cuadre
# lo mejor posible con los datos de accidentalidad.
colnames(meteo_2013) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia") 
meteo_2013 <- meteo_2013[grepl("\\d", FECHA)]

colnames(meteo_2014) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia") 
meteo_2014 <- meteo_2014[grepl("\\d", FECHA)]

colnames(meteo_2016) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia")
meteo_2016 <- meteo_2016[grepl("\\d", FECHA)]

colnames(meteo_2017) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia")
meteo_2017 <- meteo_2017[grepl("\\d", FECHA)]

colnames(meteo_2018) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia")
meteo_2018 <- meteo_2018[grepl("\\d", FECHA)]


# 2_ Se hace la media para cada día y hora de las 5 estaciones. Antes hay que pasar todas las columnas a numéricas.
cols.names <- c('Velocidad viento','Direccion viento','Temperatura', 'Humedad relativa', 'Presion', 'Radiacion solar', 'Lluvia')

meteo_2013[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2013[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2013 <- unique(meteo_2013)

meteo_2014[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2014[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2014 <- unique(meteo_2014)

meteo_2016[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2016[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2016 <- unique(meteo_2016)

meteo_2017[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2017[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2017 <- unique(meteo_2017)

meteo_2018[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2018[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2018 <- unique(meteo_2018)

# 3_ Es conveniente utilizar las mismas unidades de tiempo (en el rango horario) que en el resto de datasets
meteo_2013$`RANGO HORARIO` <- ifelse(meteo_2013$`RANGO HORARIO` == "24:00", 0, hour(hm(meteo_2013$`RANGO HORARIO`)))
meteo_2014$`RANGO HORARIO` <- ifelse(meteo_2014$`RANGO HORARIO` == "24:00", 0, hour(hm(meteo_2014$`RANGO HORARIO`)))
meteo_2016$`RANGO HORARIO` <- ifelse(meteo_2016$`RANGO HORARIO` == "24:00:00", 0, hour(hm(meteo_2016$`RANGO HORARIO`)))
meteo_2017$`RANGO HORARIO` <- ifelse(meteo_2017$`RANGO HORARIO` == "24:00:00", 0, hour(hm(meteo_2017$`RANGO HORARIO`)))
meteo_2018$`RANGO HORARIO` <- ifelse(meteo_2018$`RANGO HORARIO` == "24:00:00", 0, hour(hm(meteo_2018$`RANGO HORARIO`)))

# 4_ Se ordenan los datasets, para que el 0 sea la primera hora del día.
meteo_2013 <- meteo_2013[order(dmy(FECHA),`RANGO HORARIO`)]
meteo_2014 <- meteo_2014[order(dmy(FECHA),`RANGO HORARIO`)]
meteo_2016 <- meteo_2016[order(dmy(FECHA),`RANGO HORARIO`)]
meteo_2017 <- meteo_2017[order(dmy(FECHA),`RANGO HORARIO`)]
meteo_2018 <- meteo_2018[order(dmy(FECHA),`RANGO HORARIO`)]

colnames(red_meteo_municipal_2015) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Direccion viento", "Temperatura", "Humedad relativa", "Presion", "Radiacion solar", "Lluvia") 


# 5_ Finalmente se genera el nuevo conjunto de datos y se guarda
meteo <- rbind(meteo_2013, meteo_2014, red_meteo_municipal_2015, meteo_2016, meteo_2017, meteo_2018)
save(meteo, file = "Cleaned_data/meteo.RData", compress = "xz")