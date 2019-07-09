# SCRIPT EN EL QUE SE GENERAN LOS PLOTS RELATIVOS AL ANÁLISIS DE DATOS
library(data.table); library(ggplot2); library(lubridate)
load("../Accidentes de tráfico - Madrid/Cleaned_data/number_crash.RData")
load("../Accidentes de tráfico - Madrid/Cleaned_data/crash_traffic.RData")


# 1_ Serie temporal sola. 
acc <- number_crash
acc <- acc[ ,acc := sum(`Número de accidentes`), by = list(FECHA, `RANGO HORARIO`)]
acc$BARRIO <- NULL
acc$`Número de accidentes` <- NULL
acc <- unique(acc)

ggplot(data = acc[1:672], aes(x = FECHA, y = acc)) +
  geom_line() +
  labs(x = "Timestep", y = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))
  






# 2_ Serie temporal por periodos temporales.
acc <- number_crash
acc <- acc[ ,acc := sum(`Número de accidentes`), by = list(FECHA, `RANGO HORARIO`)]
acc$BARRIO <- NULL
acc$`Número de accidentes` <- NULL
acc <- unique(acc)
acc$weekday <- weekdays(acc$FECHA)

ggplot(data = acc, aes(x = `RANGO HORARIO`, y = acc, group = `RANGO HORARIO`)) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = seq(0,23,1)) +
  scale_y_continuous(limits = c(0,11), breaks = c(1,2,3,4,5,6,7,8,9,10,11)) +
  labs(x = "Hour", y = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))

ggplot(data = acc, aes(x = weekday, y = acc, group = weekday)) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = c("Monday", "Tuesday", "Wednesday", "Thursday",
                              "Friday", "Saturday", "Sunday")) +
  scale_y_continuous(limits = c(0,11), breaks = c(1,2,3,4,5,6,7,8,9,10,11)) +
  labs(x = "Weekday", y = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14),
        axis.text.x = element_text(angle=45, hjust=1))

ggplot(data = acc, aes(x = month(FECHA), y = acc, group = month(FECHA))) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = c("January", "February", "March", "April",
                              "May", "June", "July", "August",
                              "September", "October", "November", "December")) +
  scale_y_continuous(limits = c(0,11), breaks = c(1,2,3,4,5,6,7,8,9,10,11)) +
  labs(x = "Month", y = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14),
        axis.text.x = element_text(angle=45, hjust=1))







# 3_ Dependencia espacial por distritos
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
GeoAccidentalidad$FECHA <- dmy(GeoAccidentalidad$FECHA)
acc <- GeoAccidentalidad[year(FECHA) == 2018, .N, by = list(FECHA, `RANGO HORARIO`, `DIA SEMANA`, DISTRITO, lat, lon)]
acc <- acc[,c("N", "lat", "lon") := NULL]

ggplot(acc, aes(x = DISTRITO)) + 
  geom_histogram(stat = "count", color = "black" , fill = "lightblue") + 
  labs(x = "District", y = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=10),
        text = element_text(size=14),
        axis.text.x = element_text(angle=60, hjust=1))






# 4_ Dependencia espacial por barrios
library(rgdal); library(sp); library(data.table); library(plyr)
barrios <- rgdal::readOGR("Raw_data/BARRIOS.shp")
barrios <- spTransform(barrios, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

acc <- number_crash
acc <- acc[ ,acc := sum(`Número de accidentes`), by = list(BARRIO)]
acc$FECHA <- NULL
acc$`Número de accidentes` <- NULL
acc$`RANGO HORARIO` <- NULL
acc <- unique(acc)
colnames(acc)[1] <- "CODBAR"

# Jugamos con la idea del que el id del fortify se ordena igual que como
# salen los barrios de forma natural
barrios@data$CODBAR <- as.numeric(as.character(barrios@data$CODBAR))
barrios@data <- join(barrios@data, acc)
barrios@data$id <- seq(0,130,1)

barrios_for <- fortify(barrios)
barrios_for <- join(barrios_for, barrios@data[,10:11])

ggplot() +
  geom_polygon(data = barrios_for, aes(x = long, y = lat, group = id, fill = acc)) +
  scale_fill_gradient2(low = "green", mid = "red", high = "black", midpoint = 125) +
  labs(x = "Longitude", y = "Latitude", fill = "Number of accidents") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))




# 5_ Serie temporal del tráfico: no recuerdo como solucione lo de las
# medidas a 300.
acc <- crash_traffic
acc <- acc[ ,int := mean(int_med), by = list(FECHA, `RANGO HORARIO`)]
acc[, c(3,4,5,6,7,8,9,10,11,12) := NULL]
acc <- unique(acc)
acc$weekday <- weekdays(acc$FECHA)

ggplot(data = acc, aes(x = `RANGO HORARIO`, y = int, group = `RANGO HORARIO`)) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = seq(0,23,1)) +
  labs(x = "Hour", y = "Traffic intensity") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))

ggplot(data = acc, aes(x = weekday, y = int, group = weekday)) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = c("Monday", "Tuesday", "Wednesday", "Thursday",
                              "Friday", "Saturday", "Sunday")) +
  labs(x = "Weekday", y = "Traffic intensity") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14),
        axis.text.x = element_text(angle=45, hjust=1))

ggplot(data = acc, aes(x = month(FECHA), y = int, group = month(FECHA))) +
  geom_boxplot(fill = "lightgrey") +
  scale_x_discrete(limits = c("January", "February", "March", "April",
                              "May", "June", "July", "August",
                              "September", "October", "November", "December")) +
  labs(x = "Month", y = "Traffic intensity") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14),
        axis.text.x = element_text(angle=45, hjust=1))



# 6_ Correlación entre las variables
library(corrplot)
acc <- crash_traffic
acc <- acc[ ,c("int", "acc") := list(mean(int_med), sum(`Número de accidentes`)), by = list(FECHA, `RANGO HORARIO`)]
acc[, c("BARRIO", "int_med", "Número de accidentes") := NULL]
acc <- unique(acc)
colnames(acc)[3:11] <- c("Wind speed","Wind direction", "Temperature",
                         "Humidity", "Pressure", "Solar radiation", 
                         "Rainfall", "Traffic intensity", "Number of accidents") 


M <- cor(acc[,3:11])
p.mat <- cor.mtest(acc[,3:11])$p
corrplot(M[9,-9, drop = FALSE])
