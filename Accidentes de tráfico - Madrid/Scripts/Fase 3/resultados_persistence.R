# EXPERIMENTO FINAL DEL MODELO PERSISTENCE
# Script en el que se calcula el modelo media para los accidentes de tráfico

load("../Accidentes de tráfico - Madrid/Cleaned_data/number_crash.RData")

library(data.table)

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

number_crash$`Número de accidentes` <- normalize(number_crash$`Número de accidentes`)

# Habrá que hacerlo modelo a modelo, porque para poder evaluar en distintos horarios, no son intervalos temporales iguales
# o proporcionales. A su vez, se calcula la realidad de aquel espacio sobre el cual se va a testear. Son 5 timesteps más allá
# del intervalo entrenado.

pers1 <- number_crash[1:141480]
pers1 <- tail(pers1, 131)
pers1 <- data.table(pers1,i=rep(1:5,ea=NROW(pers1)))
pers1 <- dcast(pers1, BARRIO ~ i, value.var = "Número de accidentes")
pers1 <- pers1[, c("BARRIO") := NULL]

gr_truth1 <- number_crash[(141480 + 1):(141480 + 655)]
gr_truth1 <- dcast(gr_truth1, BARRIO ~ `RANGO HORARIO`)
gr_truth1 <- gr_truth1[, c("BARRIO") := NULL]
colnames(gr_truth1)[1:5] <- colnames(pers1)



pers2 <- number_crash[1:240254]
pers2 <- tail(pers2, 131)
pers2 <- data.table(pers2,i=rep(1:5,ea=NROW(pers2)))
pers2 <- dcast(pers2, BARRIO ~ i, value.var = "Número de accidentes")
pers2 <- pers2[, c("BARRIO") := NULL]

gr_truth2 <- number_crash[(240254 + 1):(240254 + 655)]
gr_truth2 <- dcast(gr_truth2, BARRIO ~ `RANGO HORARIO`)
gr_truth2 <- gr_truth2[, c("BARRIO") := NULL]
colnames(gr_truth2)[1:5] <- colnames(pers2)



pers3 <- number_crash[1:339028]
pers3 <- tail(pers3, 131)
pers3 <- data.table(pers3,i=rep(1:5,ea=NROW(pers3)))
pers3 <- dcast(pers3, BARRIO ~ i, value.var = "Número de accidentes")
pers3 <- pers3[, c("BARRIO") := NULL]

gr_truth3 <- number_crash[(339028 + 1):(339028 + 655)]
gr_truth3 <- dcast(gr_truth3, BARRIO ~ `RANGO HORARIO`)
gr_truth3 <- gr_truth3[, c("BARRIO") := NULL]
colnames(gr_truth3)[1:5] <- colnames(pers3)



pers4 <- number_crash[1:437802]
pers4 <- tail(pers4, 131)
pers4 <- data.table(pers4,i=rep(1:5,ea=NROW(pers4)))
pers4 <- dcast(pers4, BARRIO ~ i, value.var = "Número de accidentes")
pers4 <- pers4[, c("BARRIO") := NULL]

gr_truth4 <- number_crash[(437802 + 1):(437802 + 655)]
gr_truth4 <- dcast(gr_truth4, BARRIO ~ `RANGO HORARIO`)
gr_truth4 <- gr_truth4[, c("BARRIO") := NULL]
colnames(gr_truth4)[1:5] <- colnames(pers4)



pers5 <- number_crash[1:536576]
pers5 <- tail(pers5, 131)
pers5 <- data.table(pers5,i=rep(1:5,ea=NROW(pers5)))
pers5 <- dcast(pers5, BARRIO ~ i, value.var = "Número de accidentes")
pers5 <- pers5[, c("BARRIO") := NULL]

gr_truth5 <- number_crash[(536576 + 1):(536576 + 655)]
gr_truth5 <- dcast(gr_truth5, BARRIO ~ `RANGO HORARIO`)
gr_truth5 <- gr_truth5[, c("BARRIO") := NULL]
colnames(gr_truth5)[1:5] <- colnames(pers5)



pers6 <- number_crash[1:635350]
pers6 <- tail(pers6, 131)
pers6 <- data.table(pers6,i=rep(1:5,ea=NROW(pers6)))
pers6 <- dcast(pers6, BARRIO ~ i, value.var = "Número de accidentes")
pers6 <- pers6[, c("BARRIO") := NULL]

gr_truth6 <- number_crash[(635350 + 1):(635350 + 655)]
gr_truth6 <- dcast(gr_truth6, BARRIO ~ `RANGO HORARIO`)
gr_truth6 <- gr_truth6[, c("BARRIO") := NULL]
colnames(gr_truth6)[1:5] <- colnames(pers6)



pers7 <- number_crash[1:734124]
pers7 <- tail(pers7, 131)
pers7 <- data.table(pers7,i=rep(1:5,ea=NROW(pers7)))
pers7 <- dcast(pers7, BARRIO ~ i, value.var = "Número de accidentes")
pers7 <- pers7[, c("BARRIO") := NULL]

gr_truth7 <- number_crash[(734124 + 1):(734124 + 655)]
gr_truth7 <- dcast(gr_truth7, BARRIO ~ `RANGO HORARIO`)
gr_truth7 <- gr_truth7[, c("BARRIO") := NULL]
colnames(gr_truth7)[1:5] <- colnames(pers7)



pers8 <- number_crash[1:832898]
pers8 <- tail(pers8, 131)
pers8 <- data.table(pers8,i=rep(1:5,ea=NROW(pers8)))
pers8 <- dcast(pers8, BARRIO ~ i, value.var = "Número de accidentes")
pers8 <- pers8[, c("BARRIO") := NULL]

gr_truth8 <- number_crash[(832898 + 1):(832898 + 655)]
gr_truth8 <- dcast(gr_truth8, BARRIO ~ `RANGO HORARIO`)
gr_truth8 <- gr_truth8[, c("BARRIO") := NULL]
colnames(gr_truth8)[1:5] <- colnames(pers8)



pers9 <- number_crash[1:931672]
pers9 <- tail(pers9, 131)
pers9 <- data.table(pers9,i=rep(1:5,ea=NROW(pers9)))
pers9 <- dcast(pers9, BARRIO ~ i, value.var = "Número de accidentes")
pers9 <- pers9[, c("BARRIO") := NULL]

gr_truth9 <- number_crash[(931672 + 1):(931672 + 655)]
gr_truth9 <- dcast(gr_truth9, BARRIO ~ `RANGO HORARIO`)
gr_truth9 <- gr_truth9[, c("BARRIO") := NULL]
colnames(gr_truth9)[1:5] <- colnames(pers9)



pers10 <- number_crash[1:1146905]
pers10 <- tail(pers10, 131)
pers10 <- data.table(pers10,i=rep(1:5,ea=NROW(pers10)))
pers10 <- dcast(pers10, BARRIO ~ i, value.var = "Número de accidentes")
pers10 <- pers10[, c("BARRIO") := NULL]

gr_truth10 <- number_crash[(1146905 + 1):(1146905 + 655)]
gr_truth10 <- dcast(gr_truth10, BARRIO ~ `RANGO HORARIO`)
gr_truth10 <- gr_truth10[, c("BARRIO") := NULL]
colnames(gr_truth10)[1:5] <- colnames(pers10)



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

rmse1 <- mapply(rmse, pers1, gr_truth1)
mae1 <- mapply(mae, pers1, gr_truth1)
bias1 <- mapply(bias, pers1, gr_truth1)

rmse2 <- mapply(rmse, pers2, gr_truth2)
mae2 <- mapply(mae, pers2, gr_truth2)
bias2 <- mapply(bias, pers2, gr_truth2)

rmse3 <- mapply(rmse, pers3, gr_truth3)
mae3 <- mapply(mae, pers3, gr_truth3)
bias3 <- mapply(bias, pers3, gr_truth3)

rmse4 <- mapply(rmse, pers4, gr_truth4)
mae4 <- mapply(mae, pers4, gr_truth4)
bias4 <- mapply(bias, pers4, gr_truth4)

rmse5 <- mapply(rmse, pers5, gr_truth5)
mae5 <- mapply(mae, pers5, gr_truth5)
bias5 <- mapply(bias, pers5, gr_truth5)

rmse6 <- mapply(rmse, pers6, gr_truth6)
mae6 <- mapply(mae, pers6, gr_truth6)
bias6 <- mapply(bias, pers6, gr_truth6)

rmse7 <- mapply(rmse, pers7, gr_truth7)
mae7 <- mapply(mae, pers7, gr_truth7)
bias7 <- mapply(bias, pers7, gr_truth7)

rmse8 <- mapply(rmse, pers8, gr_truth8)
mae8 <- mapply(mae, pers8, gr_truth8)
bias8 <- mapply(bias, pers8, gr_truth8)

rmse9 <- mapply(rmse, pers9, gr_truth9)
mae9 <- mapply(mae, pers9, gr_truth9)
bias9 <- mapply(bias, pers9, gr_truth9)

rmse10 <- mapply(rmse, pers10, gr_truth10)
mae10 <- mapply(mae, pers10, gr_truth10)
bias10 <- mapply(bias, pers10, gr_truth10)

cal_rmse = function(x){
  sqrt(mean(x^2))
}

rmse_pers <- data.table(rmse1,rmse2, rmse3, rmse4, rmse5, rmse6, rmse7, rmse8, rmse9, rmse10)
rmse_total <- apply(rmse_pers, 2, cal_rmse)
rmse_timestep <- apply(rmse_pers, 1, cal_rmse)

mae_pers <- data.table(mae1, mae2, mae3, mae4, mae5, mae6, mae7, mae8, mae9, mae10)
mae_total <- apply(mae_pers, 2, mean)
mae_timestep <- apply(mae_pers, 1, mean)

bias_pers <- data.table(bias1,bias2, bias3, bias4, bias5, bias6, bias7, bias8, bias9, bias10)
bias_total <- apply(bias_pers, 2, mean)
bias_timestep <- apply(bias_pers, 1, mean)