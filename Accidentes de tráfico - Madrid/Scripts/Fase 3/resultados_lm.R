# EXPERIMENTO FINAL CON LA REGRESIÓN LINEAL

load("../Accidentes de tráfico - Madrid/Cleaned_data/crash_traffic.RData")

library(data.table)

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

crash_traffic[,c(4:12)] <- as.data.table(lapply(crash_traffic[,c(4:12)], normalize))
crash_traffic$`DIA SEMANA` <- weekdays(crash_traffic$FECHA)

# Datos de entrenamiento 
n <- 931672
train <- crash_traffic[1:n, ]
test  <- crash_traffic[((n+1):(n+655)), ]

# Entrenamiento
modelo_lm <- lm(`Número de accidentes` ~ (`DIA SEMANA` + `RANGO HORARIO` + BARRIO)^2 + . ,
                data = train[, -c("FECHA")])

# Calculamos el error para cada modelo, y el resultado final. Seguimos por ahora
# la idea de la STNN. Se calcula el error para acada timestep como la media de errores
# de cada barrio. El error total es la media de errores para todos los timesteps.
rmse = function(pred, obs){
  sqrt(mean((pred - obs)^2))
}

mae = function(pred, obs){
  mean(abs(pred-obs))
}

bias = function(pred, obs){
  mean(pred-obs)
}

lmpred <- predict(modelo_lm, newdata = test[, -c("Número de accidentes", "FECHA")])


rmse <- c(rmse(lmpred[1:131], test$`Número de accidentes`[1:131]), 
          rmse(lmpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
          rmse(lmpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
          rmse(lmpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
          rmse(lmpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))

mae <- c(mae(lmpred[1:131], test$`Número de accidentes`[1:131]),
         mae(lmpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
         mae(lmpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
         mae(lmpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
         mae(lmpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))

bias <- c(bias(lmpred[1:131], test$`Número de accidentes`[1:131]),
          bias(lmpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
          bias(lmpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
          bias(lmpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
          bias(lmpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))


cal_rmse = function(x){
  sqrt(mean(x^2))
}