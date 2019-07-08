# SCRIPT EN EL QUE SE GENERAN LOS PLOTS RELATIVOS AL ANÁLISIS DE DATOS
library(data.table); library(ggplot2); library(lubridate)
load("../Accidentes de tráfico - Madrid/Cleaned_data/number_crash.RData")


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

