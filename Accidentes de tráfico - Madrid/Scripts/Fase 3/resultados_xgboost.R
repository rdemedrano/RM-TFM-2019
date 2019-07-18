# EXPERIMENTO FINAL CON EL XGBOOST

load("../Accidentes de tráfico - Madrid/Cleaned_data/crash_traffic.RData")

library(data.table)

normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

crash_traffic[,c(4:12)] <- as.data.table(lapply(crash_traffic[,c(4:12)], normalize))
crash_traffic$`DIA SEMANA` <- weekdays(crash_traffic$FECHA)

library(xgboost); library(caret)

# La fecha ya no nos interesa
crash_traffic[, FECHA := NULL]
# num_acc <- num_acc[, -c(6,8,9,10)]

# Dividimos el dataset en dos: uno para el entrenamiento, otro para la validación.
n <- 1146905
train <- crash_traffic[1:n, ]
test  <- crash_traffic[((n+1):(n+655)), ]

# Ahora hay que pasar a numérico las variables que no lo son. Así, para las que son strings de esta manera
# puedes crear una variable dummy, es decir, estas nuevas matrices tienen tantas columnas como variables y posibles
# valores de las variables que no son numéricas, de forma que en cada fila se asigna 0 o 1 en cada columna según pertenezca
# a esa clase o no. ONE-HOT ENCODING
labels <- train$`Número de accidentes`
ts_label <- test$`Número de accidentes`
# new_tr <- model.matrix(~.+0,data = train[,-c("N"),with=F])
# new_ts <- model.matrix(~.+0,data = test[,-c("N"),with=F])

# Otra posibilidad es INTEGER ENCODING:
# train$BARRIO = as.numeric(factor(train$BARRIO,unique(train$BARRIO)))
train$`DIA SEMANA` = as.numeric(factor(train$`DIA SEMANA`,unique(train$`DIA SEMANA`)))

# test$DISTRITO = as.numeric(factor(test$BARRIO,unique(test$BARRIO)))
test$`DIA SEMANA` = as.numeric(factor(test$`DIA SEMANA`,unique(test$`DIA SEMANA`)))

new_tr <- model.matrix(~.+0, data = train[,-c("Número de accidentes"), with=F])
new_ts <- model.matrix(~.+0, data = test[,-c("Número de accidentes"), with=F])

# Creamos las matrices con las que el xgb es capaz de trabajar
dtrain <- xgb.DMatrix(data = new_tr , label=labels) 
dtest <- xgb.DMatrix(data = new_ts , label=ts_label)

# set up the cross-validated hyper-parameter search
# xgb_grid_1 = expand.grid(
#   nrounds = 20, 
#   max_depth = c(1, 5, 10, 15, 20),
#   eta = c(1, 0.1 ,0.01, 0.001, 0.0001), 
#   gamma = c(0, 1, 2, 3, 4), 
#   colsample_bytree = c(0.2, 0.4, 0.7, 1.0, 1.5), 
#   min_child_weight = c(0, 0.5, 1, 1.5, 2),
#   subsample = c(0.2, 0.5, 0.7, 1, 1.5)
# )
# 
# # pack the training control parameters
# xgb_trcontrol_1 = trainControl(
#   method = "cv",
#   number = 10,  
#   allowParallel = TRUE
# )
# 
# xgb_train_1 = train(`Número de accidentes` ~ .,
#   data = train,
#   trControl = xgb_trcontrol_1,
#   tuneGrid = xgb_grid_1,
#   method = "xgbTree"
# )

# Parámetros del algotitmo
params <- list(booster = "gbtree", objective = "reg:linear",
                eta=0.3, gamma=1, lambda = 1, max_depth=15, min_child_weight=1, subsample=0.7)

xgb1 <- xgb.train (data = dtrain, nrounds = 60,
                    params = params,
                    watchlist = list(val=dtest,train=dtrain), verbose = 1, print_every_n = 10, early_stop_round = 10,
                    maximize = F , eval_metric = "rmse") # Aunque esto del error lo hace automático al poner regresión creo

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

xgbpred <- predict (xgb1,dtest)


rmse <- c(rmse(xgbpred[1:131], test$`Número de accidentes`[1:131]), 
          rmse(xgbpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
          rmse(xgbpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
          rmse(xgbpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
          rmse(xgbpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))

mae <- c(mae(xgbpred[1:131], test$`Número de accidentes`[1:131]),
          mae(xgbpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
          mae(xgbpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
          mae(xgbpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
          mae(xgbpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))

bias <- c(bias(xgbpred[1:131], test$`Número de accidentes`[1:131]),
          bias(xgbpred[131:(2*131)], test$`Número de accidentes`[131:(2*131)]),
          bias(xgbpred[(2*131):(3*131)], test$`Número de accidentes`[(2*131):(3*131)]),
          bias(xgbpred[(3*131):(4*131)], test$`Número de accidentes`[(3*131):(4*131)]),
          bias(xgbpred[(4*131):(5*131)], test$`Número de accidentes`[(4*131):(5*131)]))


cal_rmse = function(x){
  sqrt(mean(x^2))
}

# mat <- xgb.importance(feature_names = colnames(new_tr),model = xgb1)
# xgb.plot.importance(importance_matrix = mat[1:10])
