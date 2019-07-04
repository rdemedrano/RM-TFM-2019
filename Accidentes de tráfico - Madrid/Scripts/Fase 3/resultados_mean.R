# Script en el que se calcula el modelo media para los accidentes de tráfico

load("../Accidentes de tráfico - Madrid/Cleaned_data/number_crash.RData")

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

number_crash$`Número de accidentes` <- normalize(number_crash$`Número de accidentes`)

# Habrá que hacerlo modelo a modelo, porque para poder evaluar en distintos horarios, no son intervalos temporales iguales
# o proporcionales.

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



# Calculamos el error
rmse = function(pred, obs){
  sqrt(mean((pred - obs)^2))
}

res1 <- 0
for(i in gr_truth1){
  res1 <- res1 + rmse(medias1$media_acc, i)
}
res1 <- res1/5


res2 <- 0
for(i in gr_truth2){
  res2 <- res2 + rmse(medias2$media_acc, i)
}
res2 <- res2/5


res3 <- 0
for(i in gr_truth3){
  res3 <- res3 + rmse(medias3$media_acc, i)
}
res3 <- res3/5


res4 <- 0
for(i in gr_truth4){
  res4 <- res4 + rmse(medias4$media_acc, i)
}
res4 <- res4/5


res5 <- 0
for(i in gr_truth5){
  res5 <- res5 + rmse(medias5$media_acc, i)
}
res5 <- res5/5


res6 <- 0
for(i in gr_truth6){
  res6 <- res6 + rmse(medias6$media_acc, i)
}
res6 <- res6/5


res7 <- 0
for(i in gr_truth7){
  res7 <- res7 + rmse(medias7$media_acc, i)
}
res7 <- res7/5


res8 <- 0
for(i in gr_truth8){
  res8 <- res8 + rmse(medias8$media_acc, i)
}
res8 <- res8/5


res9 <- 0
for(i in gr_truth9){
  res9 <- res9 + rmse(medias9$media_acc, i)
}
res9 <- res9/5

res10 <- 0
for(i in gr_truth10){
  res10 <- res10 + rmse(medias10$media_acc, i)
}
res10 <- res10/5


mean(res1, res2, res3, res4, res5, res6, res7, res8, res9, res10)
sd(c(res1, res2, res3, res4, res5, res6, res7, res8, res9, res10))
