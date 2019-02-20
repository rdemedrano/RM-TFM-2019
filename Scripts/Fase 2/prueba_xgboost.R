# Script en el que se hacen pruebas con el método xgboost

library(data.table); library(xgboost); library(tidyr); library(plyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
load("../Accidentes de tráfico - Madrid/Cleaned_data/meteo_parcial.RData")

# 1_ En primer lugar vamos a probar solo los años 2013 y 2014, con meteo y accidentes únicamente
# (por no introducir variables espaciales todavía - intensidades de tráfico). 
# Aunque utilizaremos los distritos también
# Nos aseguramos de coger solo accidentes individuales, y no tantos como personas implicadas.
acc <- GeoAccidentalidad[, .N, by = list(FECHA, `RANGO HORARIO`, `DIA SEMANA`, DISTRITO, lat, lon)]
acc <- acc[,c("N", "lat", "lon") := NULL]
# También de que ambos tengan el mismo formato en las columnas que juntar: fecha y hora
acc$`RANGO HORARIO` <- substr(acc$`RANGO HORARIO`, 1, 5)
acc$`RANGO HORARIO` <- extract_numeric(acc$`RANGO HORARIO`)
acc[, FECHA := dmy(FECHA)]
meteo_parcial[, FECHA := dmy(FECHA)]
acc <- acc[year(FECHA) == 2013 | year(FECHA) == 2014]
# acc <- join(acc[year(FECHA) == 2013 | year(FECHA) == 2014], meteo_parcial)

# 2_ Ahora hay que obtener para cada día de la semana, hora, distrito y condiciones meteorológicas el número de accidentes. Esto es
# un acercamiento distinto al de tener una serie de puntos temporales como pasaba en la STNN. Antes hay que crear otro conjunto 
# que nos servirá en nuestro proposito de asignar un número de accidentes a cada una de estas posibilidades: todas las posibles
# combinaciones de días de la semena, distritos y horas.
num_distritos <- 21
num_horas <- 24*num_distritos
dias_horas_zonas <- data.table(FECHA = sort(rep(seq(ymd('2013-01-01'), ymd('2014-12-31'), by = '1 day'), num_horas)),
                           "RANGO HORARIO" = sort(rep(seq(0,23), num_distritos)),
                            DISTRITO = unique(acc$DISTRITO))

dias_horas_zonas$`DIA SEMANA` <- toupper(weekdays(dias_horas_zonas$FECHA))

# 3_ Ahora si que podemos crear el dataset sobre el que hacer la regresión.
# Primero obtenemos el número de accidentes que ha habido en función de las variables relevantes,
# para a continuación hacer el merge con todos los rangos posibles y asignar a 0 todas aquellas
# posibilidades para las cuales no hubo accidente.
num_acc_sm <- acc[,.N, by = list(FECHA, `RANGO HORARIO`, `DIA SEMANA`, DISTRITO)]
num_acc_sm <- join(dias_horas_zonas, num_acc_sm)
num_acc_sm[is.na(num_acc_sm)] <- 0

num_acc <- join(num_acc_sm, meteo_parcial)
num_acc <- na.omit(num_acc)

# 4_ Ya se está preparado para utilizar el xgboost
library(xgboost)

# La fecha ya no nos interesa
num_acc[, FECHA := NULL]

# Dividimos el dataset en dos: uno para el entrenamiento, otro para la validación.
sample <- seq(1, floor(.98*nrow(num_acc)))
train <- num_acc[sample, ]
test  <- num_acc[-sample, ]

# Ahora hay que pasar a numérico las variables que no lo son. Así, para las que son strings de esta manera
# puedes crear una variable dummy, es decir, estas nuevas matrices tienen tantas columnas como variables y posibles
# valores de las variables que no son numéricas, de forma que en cada fila se asigna 0 o 1 en cada columna según pertenezca
# a esa clase o no.
labels <- train$N 
ts_label <- test$N
# new_tr <- model.matrix(~.+0,data = train[,-c("N"),with=F])
# new_ts <- model.matrix(~.+0,data = test[,-c("N"),with=F])

# Otra posibilidad es:
train$DISTRITO = as.numeric(factor(train$`DISTRITO`,unique(train$`DISTRITO`)))
train$`DIA SEMANA` = as.numeric(factor(train$`DIA SEMANA`,unique(train$`DIA SEMANA`)))

test$DISTRITO = as.numeric(factor(test$`DISTRITO`,unique(test$`DISTRITO`)))
test$`DIA SEMANA` = as.numeric(factor(test$`DIA SEMANA`,unique(test$`DIA SEMANA`)))

new_tr <- model.matrix(~.+0, data = train[,-c("N"), with=F])
new_ts <- model.matrix(~.+0, data = test[,-c("N"), with=F])

# Creamos las matrices con las que el xgb es capaz de trabajar
dtrain <- xgb.DMatrix(data = new_tr , label=labels) 
dtest <- xgb.DMatrix(data = new_ts , label=ts_label)

params <- list(booster = "gbtree", objective = "reg:linear",
               eta=0.3, gamma=0, max_depth=16, min_child_weight=1, subsample=1, colsample_bytree=1)

xgb1 <- xgb.train (params = params, data = dtrain, nrounds = 80,
                   watchlist = list(val=dtest,train=dtrain), verbose = 1, print_every_n = 10, early_stop_round = 10, 
                   maximize = F , eval_metric = "rmse") # Aunque esto del error lo hace automático al poner regresión creo

xgbpred <- predict (xgb1,dtest)
comparar <- data.table(test$N, xgbpred)
rmse <- sqrt(1/nrow(test)*sum((xgbpred - test$N)^2))

mat <- xgb.importance (feature_names = colnames(new_tr),model = xgb1)
xgb.plot.importance (importance_matrix = mat[1:10])
