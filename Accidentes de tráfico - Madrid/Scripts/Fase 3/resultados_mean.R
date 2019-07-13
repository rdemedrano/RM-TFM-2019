# EXPERIMENTO FINAL DEL MODELO MEAN
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

medias1 <- number_crash[1:141480]
medias1[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias1 <- unique(medias1[, c(3,5)])

gr_truth1 <- number_crash[(141480 + 1):(141480 + 655)]
gr_truth1 <- dcast(gr_truth1, BARRIO ~ `RANGO HORARIO`)
gr_truth1 <- gr_truth1[, c("BARRIO") := NULL]



medias2 <- number_crash[1:240254]
medias2[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias2 <- unique(medias2[, c(3,5)])

gr_truth2 <- number_crash[(240254 + 1):(240254 + 655)]
gr_truth2 <- dcast(gr_truth2, BARRIO ~ `RANGO HORARIO`)
gr_truth2 <- gr_truth2[, c("BARRIO") := NULL]



medias3 <- number_crash[1:339028]
medias3[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias3 <- unique(medias3[, c(3,5)])

gr_truth3 <- number_crash[(339028 + 1):(339028 + 655)]
gr_truth3 <- dcast(gr_truth3, BARRIO ~ `RANGO HORARIO`)
gr_truth3 <- gr_truth3[, c("BARRIO") := NULL]



medias4 <- number_crash[1:437802]
medias4[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias4 <- unique(medias4[, c(3,5)])

gr_truth4 <- number_crash[(437802 + 1):(437802 + 655)]
gr_truth4 <- dcast(gr_truth4, BARRIO ~ `RANGO HORARIO`)
gr_truth4 <- gr_truth4[, c("BARRIO") := NULL]



medias5 <- number_crash[1:536576]
medias5[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias5 <- unique(medias5[, c(3,5)])

gr_truth5 <- number_crash[(536576 + 1):(536576 + 655)]
gr_truth5 <- dcast(gr_truth5, BARRIO ~ `RANGO HORARIO`)
gr_truth5 <- gr_truth5[, c("BARRIO") := NULL]



medias6 <- number_crash[1:635350]
medias6[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias6 <- unique(medias6[, c(3,5)])

gr_truth6 <- number_crash[(635350 + 1):(635350 + 655)]
gr_truth6 <- dcast(gr_truth6, BARRIO ~ `RANGO HORARIO`)
gr_truth6 <- gr_truth6[, c("BARRIO") := NULL]



medias7 <- number_crash[1:734124]
medias7[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias7 <- unique(medias7[, c(3,5)])

gr_truth7 <- number_crash[(734124 + 1):(734124 + 655)]
gr_truth7 <- dcast(gr_truth7, BARRIO ~ `RANGO HORARIO`)
gr_truth7 <- gr_truth7[, c("BARRIO") := NULL]



medias8 <- number_crash[1:832898]
medias8[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias8 <- unique(medias8[, c(3,5)])

gr_truth8 <- number_crash[(832898 + 1):(832898 + 655)]
gr_truth8 <- dcast(gr_truth8, BARRIO ~ `RANGO HORARIO`)
gr_truth8 <- gr_truth8[, c("BARRIO") := NULL]



medias9 <- number_crash[1:931672]
medias9[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias9 <- unique(medias9[, c(3,5)])

gr_truth9 <- number_crash[(931672 + 1):(931672 + 655)]
gr_truth9 <- dcast(gr_truth9, BARRIO ~ `RANGO HORARIO`)
gr_truth9 <- gr_truth9[, c("BARRIO") := NULL]



medias10 <- number_crash[1:1146905]
medias10[, media_acc := mean(`Número de accidentes`), by = BARRIO]
medias10 <- unique(medias10[, c(3,5)])

gr_truth10 <- number_crash[(1146905 + 1):(1146905 + 655)]
gr_truth10 <- dcast(gr_truth10, BARRIO ~ `RANGO HORARIO`)
gr_truth10 <- gr_truth10[, c("BARRIO") := NULL]



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

rmse1 <- vector()
mae1 <- vector()
bias1 <- vector()
j <- 1
for(i in gr_truth1){
  rmse1[j] <- rmse(medias1$media_acc, i)
  mae1[j] <- mae(medias1$media_acc, i)
  bias1[j] <- bias(medias1$media_acc, i)
  j <- j+1
}


rmse2 <- vector()
mae2 <- vector()
bias2 <- vector()
j <- 1
for(i in gr_truth2){
  rmse2[j] <- rmse(medias2$media_acc, i)
  mae2[j] <- mae(medias2$media_acc, i)
  bias2[j] <- bias(medias2$media_acc, i)
  j <- j+1
}


rmse3 <- vector()
mae3 <- vector()
bias3 <- vector()
j <- 1
for(i in gr_truth3){
  rmse3[j] <- rmse(medias3$media_acc, i)
  mae3[j] <- mae(medias3$media_acc, i)
  bias3[j] <- bias(medias3$media_acc, i)
  j <- j+1
}


rmse4 <- vector()
mae4 <- vector()
bias4 <- vector()
j <- 1
for(i in gr_truth4){
  rmse4[j] <- rmse(medias4$media_acc, i)
  mae4[j] <- mae(medias4$media_acc, i)
  bias4[j] <- bias(medias4$media_acc, i)
  j <- j+1
}


rmse5 <- vector()
mae5 <- vector()
bias5 <- vector()
j <- 1
for(i in gr_truth5){
  rmse5[j] <- rmse(medias5$media_acc, i)
  mae5[j] <- mae(medias5$media_acc, i)
  bias5[j] <- bias(medias5$media_acc, i)
  j <- j+1
}


rmse6 <- vector()
mae6 <- vector()
bias6 <- vector()
j <- 1
for(i in gr_truth6){
  rmse6[j] <- rmse(medias6$media_acc, i)
  mae6[j] <- mae(medias6$media_acc, i)
  bias6[j] <- bias(medias6$media_acc, i)
  j <- j+1
}


rmse7 <- vector()
mae7 <- vector()
bias7 <- vector()
j <- 1
for(i in gr_truth7){
  rmse7[j] <- rmse(medias7$media_acc, i)
  mae7[j] <- mae(medias1$media_acc, i)
  bias7[j] <- bias(medias7$media_acc, i)
  j <- j+1
}

rmse8 <- vector()
mae8 <- vector()
bias8 <- vector()
j <- 1
for(i in gr_truth8){
  rmse8[j] <- rmse(medias8$media_acc, i)
  mae8[j] <- mae(medias8$media_acc, i)
  bias8[j] <- bias(medias8$media_acc, i)
  j <- j+1
}

rmse9 <- vector()
mae9 <- vector()
bias9 <- vector()
j <- 1
for(i in gr_truth9){
  rmse9[j] <- rmse(medias9$media_acc, i)
  mae9[j] <- mae(medias9$media_acc, i)
  bias9[j] <- bias(medias9$media_acc, i)
  j <- j+1
}


rmse10 <- vector()
mae10 <- vector()
bias10 <- vector()
j <- 1
for(i in gr_truth10){
  rmse10[j] <- rmse(medias10$media_acc, i)
  mae10[j] <- mae(medias10$media_acc, i)
  bias10[j] <- bias(medias10$media_acc, i)
  j <- j+1
}


cal_rmse = function(x){
  sqrt(mean(x^2))
}

rmse_mean <- data.table(rmse1,rmse2, rmse3, rmse4, rmse5, rmse6, rmse7, rmse8, rmse9, rmse10)
rmse_total <- apply(rmse_mean, 2, cal_rmse)
rmse_timestep <- apply(rmse_mean, 1, cal_rmse)

mae_mean <- data.table(mae1, mae2, mae3, mae4, mae5, mae6, mae7, mae8, mae9, mae10)
mae_total <- apply(mae_mean, 2, mean)
mae_timestep <- apply(mae_mean, 1, mean)

bias_mean <- data.table(bias1,bias2, bias3, bias4, bias5, bias6, bias7, bias8, bias9, bias10)
bias_total <- apply(bias_mean, 2, mean)
bias_timestep <- apply(bias_mean, 1, mean)
# mean(c(rmse1, rmse2, rmse3, rmse4, rmse5, rmse6, rmse7, rmse8, rmse9, rmse10))
# sd(c(rmse1, rmse2, rmse3, rmse4, rmse5, rmse6, rmse7, rmse8, rmse9, rmse10))
