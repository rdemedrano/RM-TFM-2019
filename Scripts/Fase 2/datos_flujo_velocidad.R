# Script para generar los datos de intensidad de tráfico y velocidad media. La idea es año a año
# cargarlos, y hacer el primer tratamiento: ponerlo en horas y eliminar aquellos que sean de la M-30 o autovías.

library(data.table); library(lubridate)


# ===== GENERACIÓN DE LOS MESES =====
directorio = "../Accidentes de tráfico - Madrid/Raw_data"
fecha = "01-2017.csv"

dt = fread(paste(directorio, fecha, sep = "/"))

# 1_ En primer lugar nos aseguramos de eliminar aquellos puntos de medida de la M-30, pues solo nos interesan
# accidentes urbanos.
dt <- dt[!grepl("M-30", tipo_elem) & !grepl("M30", tipo_elem)]
# 2_ Como vamos a querer unirlo al dataset principal, y por comodidad, se separa la fecha y hora y se ordena
#    también por comodidad.
dt[, c("FECHA", "RANGO HORARIO") := tstrsplit(fecha, " ", fixed=TRUE)]
dt[, fecha:=NULL]
dt <- dt[, c(1,9,10,2,3,4,5,6,7,8)]
# 4_ Para simplificar el proceso, se utilizan solo las horas de cada medición, pues los accidentes también van de
#    hora en hora (sin minutos).
#    Otra opción: substr("01:00:00", start = 1, stop = 2)
dt[, `RANGO HORARIO` := hms(`RANGO HORARIO`)]
dt[, `RANGO HORARIO` := hour(`RANGO HORARIO`)]
# 5_ Se calcula la velocidad e intensidad media para cada punto de medida en función del punto, la fecha y la hora.
#    Se utiliza .N en el nuevo dataset con las variables relevantes para poder comprobar, pero luego no es necesario.
dt[, c("int_med","v_med") := list(mean(intensidad), mean(vmed)), by= list(id, FECHA, `RANGO HORARIO`)]
dt <- dt[, .N, by = list(id, FECHA, `RANGO HORARIO`, int_med, v_med)]
dt[, N := NULL]

# 6_ Se guarda el nuevo dataset.
"01-2017" <- dt
save("01-2017", file = "../Accidentes de tráfico - Madrid/Raw_data/01-2017.RData")


# ===== GENERACIÓN DE UN AÑO =====
# directorio = "../Accidentes de tráfico - Madrid/Raw_data"
# año = "2017.RData"
# 
# load(paste(directorio, paste0("01-", año), sep = "/"))
# load(paste(directorio, paste0("02-", año), sep = "/"))
# load(paste(directorio, paste0("03-", año), sep = "/"))
# load(paste(directorio, paste0("04-", año), sep = "/"))
# load(paste(directorio, paste0("05-", año), sep = "/"))
# load(paste(directorio, paste0("06-", año), sep = "/"))
# load(paste(directorio, paste0("07-", año), sep = "/"))
# load(paste(directorio, paste0("08-", año), sep = "/"))
# load(paste(directorio, paste0("09-", año), sep = "/"))
# load(paste(directorio, paste0("10-", año), sep = "/"))
# load(paste(directorio, paste0("11-", año), sep = "/"))
# load(paste(directorio, paste0("12-", año), sep = "/"))
# 
# "2017_trafico" <- rbind(`01-2017`, `02-2017`, `03-2017`, `04-2017`, `05-2017`, `06-2017`,
#                         `07-2017`, `08-2017`, `09-2017`, `10-2017`, `11-2017`, `12-2017`) 
# save("2017_trafico", file = "../Accidentes de tráfico - Madrid/Raw_data/2017_trafico.RData")
