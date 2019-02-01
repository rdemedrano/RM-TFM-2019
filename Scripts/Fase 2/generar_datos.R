# Script para la generación de datos en un formato trabajable. Es decir, para realizar la primera limpieza
# que consistirá en simplemente generar un conjunto unido.
# Solo es necesario correrlo una vez para generar el conjunto sobre el cual se trabajará.

library(data.table)

directorio = "../Accidentes de tráfico - Madrid/Raw_data"

# dt1 = fread("../Accidentes de tráfico - Madrid/Raw_data/2010_Accidentalidad.csv")
# dt2 = fread("../Accidentes de tráfico - Madrid/Raw_data/2011_Accidentalidad.csv")
# dt3 = fread("../Accidentes de tráfico - Madrid/Raw_data/2012_Accidentalidad.csv")
# dt4 = fread("../Accidentes de tráfico - Madrid/Raw_data/2013_Accidentalidad.csv")
# dt5 = fread("../Accidentes de tráfico - Madrid/Raw_data/2014_Accidentalidad.csv")
# dt6 = fread("../Accidentes de tráfico - Madrid/Raw_data/2015_Accidentalidad.csv")
# dt7 = fread("../Accidentes de tráfico - Madrid/Raw_data/2016_Accidentalidad.csv")
# dt8 = fread("../Accidentes de tráfico - Madrid/Raw_data/2017_Accidentalidad.csv")
# dt9 = fread("../Accidentes de tráfico - Madrid/Raw_data/2018_Accidentalidad.csv")

dt1 = fread(paste(directorio, "2010_Accidentalidad.csv", sep = "/"))
dt2 = fread(paste(directorio, "2011_Accidentalidad.csv", sep = "/"))
dt3 = fread(paste(directorio, "2012_Accidentalidad.csv", sep = "/"))
dt4 = fread(paste(directorio, "2013_Accidentalidad.csv", sep = "/"))
dt5 = fread(paste(directorio, "2014_Accidentalidad.csv", sep = "/"))
dt6 = fread(paste(directorio, "2015_Accidentalidad.csv", sep = "/"))
dt7 = fread(paste(directorio, "2016_Accidentalidad.csv", sep = "/"))
dt8 = fread(paste(directorio, "2017_Accidentalidad.csv", sep = "/"))
dt9 = fread(paste(directorio, "2018_Accidentalidad.csv", sep = "/"))

# Se normaliza el nombre de las columnas, que por algún motivo en 2018 se cambió.
colnames(dt9)[20] <- "Nº VICTIMAS *"

Accidentalidad = rbind(dt1, dt2, dt3, dt4, dt5, dt6, dt7, dt8, dt9)

# Como apenas existen valores no existentes (NA), se hace su tratamiento aquí mismo.
# Se puede comprobar si existen valores así mediante el comando apply(dt, 2, function(x) any(is.na(x)))
# Este nos muestra que solo existen en la casilla del número de calle, pues algunas intersecciones las
# toma como que tienen el número 0 y otras no se añade número. Yo veo más lógico asignarles 0 y tenerlo
# en cuenta. 

Accidentalidad[is.na(Accidentalidad)] <- 0

# Lo guardamos como RData porque pesan menos y son más rapidos de cargar.
save(Accidentalidad, file = "../Accidentes de tráfico - Madrid/Cleaned_data/Accidentalidad.RData")
