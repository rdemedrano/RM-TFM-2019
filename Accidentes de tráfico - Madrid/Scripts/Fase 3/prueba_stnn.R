# PREPARACIÓN DE DATOS PARA LA LA STNN PERO CON BARRIOS Y RANGO HORARIO. 
# SIMULACRO DE EXPERIMENTO REAL

library(data.table); library(lubridate); library(plyr); library(tidyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/BarriosAccidentalidad.RData")

car_crash <- BarriosAccidentalidad[ , .N, by = list(FECHA, `RANGO HORARIO`, BARRIO,lon, lat)]
car_crash <- na.omit(car_crash)

car_crash[,FECHA := dmy(FECHA)]
car_crash[, N := NULL]
car_crash <- car_crash[year(FECHA) == 2018]
car_crash$`RANGO HORARIO` <- extract_numeric(substr(car_crash$`RANGO HORARIO`, start = 1, stop = 5))

car_crash <- car_crash[, .N, by = list(FECHA, `RANGO HORARIO`, BARRIO)]
colnames(car_crash)[4] <- "Número de accidentes"

num_dias = 45
num_zonas = 131
num_horas = num_zonas*24
fechas_horas_y_zonas <- data.table(FECHA = sort(rep(seq(ymd('2018-01-01'), ymd('2018-02-14'), by = '1 day'), num_horas)),
                                   "RANGO HORARIO" = sort(rep(seq(0,23), num_zonas)),
                                   BARRIO = rep(sort(unique(car_crash$BARRIO)), times = num_dias))

# 9_ Ahora se hace el join con car_crash y se da 0 a todas aquellas zonas sin accidentes
number_crash <- join(fechas_horas_y_zonas, car_crash)
number_crash[is.na(number_crash)] <- 0

crash <- dcast(number_crash, FECHA + `RANGO HORARIO` ~ BARRIO)
crash <- crash[, c("FECHA", "RANGO HORARIO") := NULL]

write.table(crash, file = "Raw_data/crash.csv", row.names = FALSE, col.names = FALSE)
