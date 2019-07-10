# SCRIPT EN EL QUE SE GENERAN LOS PLOTS RELATIVOS A LOS RESULTADOS
library(data.table); library(ggplot2); require(reshape2); library(gridExtra)

# ==== RELACIONES ESPACIALES ====
# library(readr)
# crash_relations <- read_table2("Raw_data/crash_relations.csv", 
#                                col_names = FALSE)
# 
# levelplot(as.matrix(crash_relations), cuts = 50) 
# Pero me gusta más la de python, así que me quedo con esa


# ==== RMSE ====
# 1_ Gráficas de RMSE completa.
rmse_stnn <- c(0.00429, 0.0045, 0.00413, 0.0043, 0.00645, 
               0.00221, 0.00465, 0.00356, 0.00464, 0.00408)
rmse_xstnn <- c(0.00239, 0.00369, 0.00327, 0.00412, 0.00706,
                0.00398, 0.00459, 0.00397, 0.00261, 0.00366)
rmse_mean <- c(0.004811045, 0.004859302, 0.004765978, 0.004261287, 0.007279863,
               0.003807245, 0.006168168, 0.005649511, 0.005213137, 0.004706289)
rmse_xgboost <- c(0.00486,0.00491, 0.00479, 0.00424, 0.0073,
                  0.00379, 0.00619, 0.00543, 0.00551, 0.00501)

rmse <- data.table("STNN" = rmse_stnn, "XSTNN" = rmse_xstnn, "XGBosst" = rmse_xgboost,"Mean" = rmse_mean)
rmse <- data.table("STNN" = rmse_stnn, "XSTNN" = rmse_xstnn, "Mean" = rmse_mean)

rmse <- melt(rmse)
colnames(rmse)[1] <- "model"

# Simplemente boxplot(rmse) funcionaría.
p1_box <- ggplot(data = rmse, aes(x = model, y = value, group = model, color = model)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0.002, 0.008)) +
  labs(x = "Model", y = "RMSE") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16),
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x = element_blank(),
        legend.position = "none")



# 2_ Gráfica de RMSE por ventana temporal.
rmse_stnn <- c(mean(c(0.0052,0.0051,0.01,0.0023,0.0012,0.0036,0.0036)), 
               mean(c(0.0052,0.00219,0.0019,0.0023,0.0073,0.0036,0.0087)),
               mean(c(0.0019,0.0051,0.0047,0.0023,0.01,0.001,0.0036)),
               mean(c(0.0052,0.00219,0.0019,0.0057,0.0072,0.001,0.0036)),
               mean(c(0.0052,0.0083,0.0019,0.0088,0.0072,0.001,0.0036)))
rmse_xstnn <- c(mean(c(0.0026,0.0035,0.008,0.0005,0.003,0.0039,0.005)), 
               mean(c(0.00237,0.0015,0.0016,0.0005,0.0075,0.0039,0.002)),
               mean(c(0.00175,0.0045,0.0036,0.0005,0.01,0.0012,0.0002)),
               mean(c(0.0026,0.0025,0.0014,0.0033,0.0075,0.0011,0.0002)),
               mean(c(0.0025,0.007,0.0012,0.006,0.007,0.0012,0.003)))
rmse_mean <- c(0.004505069,0.006006934,0.004494138,0.004992509,0.005762263)

rmse <- data.table("STNN" = rmse_stnn, "XSTNN" = rmse_xstnn, "Mean" = rmse_mean)
rmse <- melt(rmse)
colnames(rmse)[1] <- "model"
rmse$timestep <- rep(seq(1,5,1), 3)

p1_line <- ggplot(data = rmse, aes(x = timestep, y = value, group = model, color = model)) +
  geom_line() +
  scale_y_continuous(limits = c(0.002, 0.008)) +
  labs(x = "Timestep", y = "RMSE") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16), 
        legend.position="none",
        axis.title.x=element_blank(),
        axis.text.x = element_blank())



# ==== MAE ====
# 3_ Gráficas de MAE completa.
mae_stnn <- c(0.003061829, 0.003391697, 0.003099099, 0.003268382, 0.004616502, 
              0.001683993, 0.003215719, 0.002576380, 0.003228670, 0.002765318)
mae_xstnn <- c(0.001685565, 0.002313136, 0.002427736, 0.003020570, 0.005126657,
               0.002813938, 0.003251009, 0.002632017, 0.001767151, 0.002574710)
mae_mean <- c(0.003451829, 0.003536639, 0.003539958, 0.003050302, 0.004979732,
              0.002744015, 0.004254299, 0.003945015, 0.003716587, 0.003270475)
mae_xgboost <- c(0.003604776, 0.003429927, 0.003301771, 0.003126313, 0.005213118,
                 0.002871114, 0.004392486, 0.003924828, 0.003922161, 0.003477557)

mae <- data.table("STNN" = mae_stnn, "XSTNN" = mae_xstnn, "XGBosst" = mae_xgboost,"Mean" = mae_mean)
mae <- data.table("STNN" = mae_stnn, "XSTNN" = mae_xstnn, "Mean" = mae_mean)

mae <- melt(mae)
colnames(mae)[1] <- "model"

# Simplemente boxplot(mae) funcionaría.
p2_box <- ggplot(data = mae, aes(x = model, y = value, group = model, color = model)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0.001, 0.005)) +
  labs(x = "Model", y = "MAE", legend = "Model") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16),
        axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.text.x = element_blank(),
        legend.position = "none")



# 4_ Gráfica de MAE por ventana temporal.
mae_stnn <- c(0.003151477, 0.003270318, 0.002998494, 0.002895234, 0.003675015)
mae_xstnn <- c(0.002633113, 0.002000482, 0.002440098, 0.001757051, 0.002806670)
mae_mean <- c(0.002988944, 0.004353516, 0.003455615, 0.003529027, 0.004165893)

mae <- data.table("STNN" = mae_stnn, "XSTNN" = mae_xstnn, "Mean" = mae_mean)
mae <- melt(mae)
colnames(mae)[1] <- "model"
mae$timestep <- rep(seq(1,5,1), 3)

p2_line <- ggplot(data = mae, aes(x = timestep, y = value, group = model, color = model)) +
  geom_line() +
  scale_y_continuous(limits = c(0.001, 0.005)) +
  labs(x = "Timestep", y = "MAE") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16), 
        legend.position="none",
        axis.title.x=element_blank(),
        axis.text.x = element_blank())




# ==== BIAS ====
# 5_ Gráficas de BIAS completa.
bias_stnn <- c(0.00053,0.00055,0.00012,
               0.00129, -0.00265, 8.5e-6)
bias_xstnn <- c(-0.0017,-0.000138,-0.00078,
                -0.0012,-0.00203,0.00027)
bias_mean <- c(0.0007963434, 0.0008446616, 0.0007458578, 0.0012386117, -0.0017914828,
               0.0017953359, -0.0008666111, -0.0003936456, 0.0001788899, 0.0006978201)

# bias <- data.table("STNN" = bias_stnn, "XSTNN" = bias_xstnn, "XGBoost" = bias_xgboost, "Mean" = bias_mean)
bias <- data.table("STNN" = bias_stnn, "XSTNN" = bias_xstnn, "Mean" = bias_mean)
bias <- melt(bias)
colnames(bias)[1] <- "model"

# Simplemente boxplot(bias) funcionaría.
p3_box <- ggplot(data = bias, aes(x = model, y = value, group = model, color = model)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(-0.003, 0.002)) +
  labs(x = "Model", y = "Bias") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16),
        axis.title.y=element_blank(),
        legend.position = "none")



# 6_ Gráfica de BIAS por ventana temporal.
bias_stnn <- c(mean(c(3.7e-5,3.4e-5,-0.0054,0.0028,0.002,-0.0015)), 
               mean(c(1.8e-5,2.58e-3,0.0022,0.0028,-0.0032,-0.0015)),
               mean(c(2.56e-3,3.92e-5,-0.0004,0.0028,-0.0057,0.001)),
               mean(c(1.73e-5,2.58e-3,0.0022,0.0003,-0.0032,0.001)),
               mean(c(1.72e-5,-2.5e-3,0.0022,-0.0023,-0.0032,0.001)))
bias_xstnn <- c(mean(c(-0.0022,-0.0014,-0.006,-0.0004,0.0029,-0.0012)), 
                mean(c(-0.0022,0.0015,0.0013,-0.0001,-0.0025,-0.0012)),
                mean(c(0.0004,-0.0006,-0.0013,0.0004,-0.0051,0.0013)),
                mean(c(-0.0022,0.0023,0.0011,-0.0019,-0.0025,0.0012)),
                mean(c(-0.0022,-0.0025,0.001,-0.0041,-0.003,0.0013)))
bias_mean <- c(0.0009861557, -0.0005405619, 0.0009861557, 0.0004772498, -0.0002861089)

# bias <- data.table("STNN" = bias_stnn, "XSTNN" = bias_xstnn, "XGBoost" = bias_xgboost, "Mean" = bias_mean)
bias <- data.table("STNN" = bias_stnn, "XSTNN" = bias_xstnn, "Mean" = bias_mean)
bias <- melt(bias)
colnames(bias)[1] <- "model"
bias$timestep <- rep(seq(1,5,1), 3)

p3_line <- ggplot(data = bias, aes(x = timestep, y = value, group = model, color = model)) +
  geom_line() +
  scale_y_continuous(limits = c(-0.003, 0.002)) +
  labs(x = "Timestep", y = "Bias") +
  theme_bw() +
  theme(axis.text = element_text(size=14),
        text = element_text(size=16), 
        legend.position="none")

grid.arrange(p1_line, p1_box, p2_line, p2_box, p3_line, p3_box, nrow = 3, widths=c(2,1))
