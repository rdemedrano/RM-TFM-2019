# Script en el que se preparan los datos meteorológicos, previa limpieza.

library(data.table); library(lubridate)

meteo_2013 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2013.csv", sep = ";", fill = TRUE)
meteo_2014 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2014.csv", sep = ";", fill = TRUE)
# meteo_2015 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2015.csv", sep = ";", fill = TRUE)
# meteo_2016 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2016.csv", sep = ";", fill = TRUE)
# meteo_2017 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2017.csv", sep = ";", fill = TRUE)
# meteo_2018 <- fread("../data/raw/AytoMadrid/meteo/redMunicipal/red_meteo_municipal_2018.csv", sep = ";", fill = TRUE)

# 1_ Todos tienen dos filas sobrantes, y necesitan remodificar los nombres de sus columnas. Lo haremos de forma que cuadre
# lo mejor posible con los datos de accidentalidad.
colnames(meteo_2013) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
meteo_2013 <- meteo_2013[grepl("\\d", FECHA)]

colnames(meteo_2014) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
meteo_2014 <- meteo_2014[grepl("\\d", FECHA)]

# colnames(meteo_2015) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
# meteo_2015 <- meteo_2015[grepl("\\d", FECHA)]
# 
# colnames(meteo_2016) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
# meteo_2016 <- meteo_2016[grepl("\\d", FECHA)]
# 
# colnames(meteo_2017) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
# meteo_2017 <- meteo_2017[grepl("\\d", FECHA)]
# 
# colnames(meteo_2018) <- c("FECHA", "RANGO HORARIO", "Velocidad viento", "Dirección viento", "Temperatura", "Humedad relativa", "Presión", "Radiación solar", "Lluvia") 
# meteo_2018 <- meteo_2018[grepl("\\d", FECHA)]


# 2_ Se hace la media para cada día y hora de las 5 estaciones. Antes hay que pasar todas las columnas a numéricas.
cols.names <- c('Velocidad viento','Dirección viento','Temperatura', 'Humedad relativa', 'Presión', 'Radiación solar', 'Lluvia')

meteo_2013[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2013[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2013 <- unique(meteo_2013)

meteo_2014[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
meteo_2014[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
meteo_2014 <- unique(meteo_2014)

# meteo_2015[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
# meteo_2015[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
# meteo_2015 <- unique(meteo_2015)
# 
# meteo_2016[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
# meteo_2016[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
# meteo_2016 <- unique(meteo_2016)
# 
# meteo_2017[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
# meteo_2017[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
# meteo_2017 <- unique(meteo_2017)
# 
# meteo_2018[, (cols.names) := lapply(.SD, as.numeric), .SDcols = cols.names]
# meteo_2018[, (cols.names) := lapply(.SD, mean, na.rm = TRUE), by = list(FECHA, `RANGO HORARIO`), .SDcols = cols.names]
# meteo_2018 <- unique(meteo_2018)

# 3_ Es conveniente utilizar las mismas unidades de tiempo (en el rango horario) que en el resto de datasets
meteo_2013$`RANGO HORARIO` <- hour(hm(meteo_2013$`RANGO HORARIO`) - hm("01:00"))
meteo_2014$`RANGO HORARIO` <- hour(hm(meteo_2014$`RANGO HORARIO`) - hm("01:00"))
# meteo_2015$`RANGO HORARIO` <- hour(hm(meteo_2015$`RANGO HORARIO`) - hm("01:00"))
# meteo_2016$`RANGO HORARIO` <- hour(hm(meteo_2016$`RANGO HORARIO`) - hm("01:00"))
# meteo_2017$`RANGO HORARIO` <- hour(hm(meteo_2017$`RANGO HORARIO`) - hm("01:00"))
# meteo_2018$`RANGO HORARIO` <- hour(hm(meteo_2018$`RANGO HORARIO`) - hm("01:00"))

# 4_ Finalmente se genera el nuevo conjunto de datos y se guarda
# meteo <- rbind(meteo_2013, meteo_2014, meteo_2015, meteo_2016, meteo_2017, meteo_2018)
# save(meteo, file = "Cleaned_data/meteo.RData", compress = "xz")