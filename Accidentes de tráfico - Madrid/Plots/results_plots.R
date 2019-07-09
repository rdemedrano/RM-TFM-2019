# SCRIPT EN EL QUE SE GENERAN LOS PLOTS RELATIVOS A LOS RESULTADOS
library(data.table); library(ggplot2); require(reshape2); library(gridExtra)


# 1_ Gráficas de RMSE, MAE y BIAS completos.
rmse_stnn <- c(0.00429, 0.0045, 0.00413, 0.0043, 0.00645, 
               0.00221, 0.00465, 0.00356, 0.00464, 0.00408)
rmse_xstnn <- c(0.00239, 0.00369, 0.00327, 0.00412, 0.00804,
                0.00398, 0.00459, 0.00397, 0.00261, 0.00366)
rmse_mean <- c(0.004811045, 0.004859302, 0.004765978, 0.004261287, 0.007279863,
               0.003807245, 0.006168168, 0.005649511, 0.005213137, 0.004706289)

rmse <- data.table("STNN" = rmse_stnn, "XSTNN" = rmse_xstnn, "Mean" = rmse_mean)
rmse <- melt(rmse)
colnames(rmse)[1] <- "model"

# Simplemente boxplot(rmse) funcionaría.
p1_box <- ggplot(data = rmse, aes(x = model, y = value, group = model, color = model)) +
  geom_boxplot() +
  labs(x = "Model", y = "RMSE") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))



# 1_ Gráficas de RMSE, MAE y BIAS por ventana temporal.
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
rmse_mean <- c(0.004256072,0.005758882,0.004494138,0.004992509,0.005762263)

rmse <- data.table("STNN" = rmse_stnn, "XSTNN" = rmse_xstnn, "Mean" = rmse_mean)
rmse <- melt(rmse)
colnames(rmse)[1] <- "model"
rmse$timestep <- rep(seq(1,5,1), 3)

p1_line <- ggplot(data = rmse, aes(x = timestep, y = value, group = model, color = model)) +
  geom_line() +
  labs(x = "Timestep", y = "RMSE") +
  theme_bw() +
  theme(axis.text = element_text(size=12),
        text = element_text(size=14))

grid.arrange(p1_line, p1_box, nrow = 1)
