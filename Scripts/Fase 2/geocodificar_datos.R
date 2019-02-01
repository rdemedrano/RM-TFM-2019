
# Script en el cual se realiza el geocoding de las calles. Por ahora será unicamente de aquellas
# vías que no sean autovías, pues no entiendo muy bien cual es el criterio para clasificarlas.

library(data.table); library(ggmap); library(beepr); library(plyr)
load("../Accidentes de tráfico - Madrid/Cleaned_data/Accidentalidad.RData")

register_google(key = "AIzaSyBo4vW2UT8J5SjT88n3kqHN3e9t76ZUkmg")

# La idea es quedarse con aquellas direcciones (que son LUGAR ACCIDENTE + Nº) tales que no contengan la palabra
# autovía (grepl devuelve TRUE si sí está contenida). Por supuesto, no queremos repetidas (unique).
# Para que no haya ninguna duda, se añade al final de cada dirección MADRID.
# EN LOS CRUCES NO SE DEBE PONEREL NUMERO, O SI NO GEOLOCALIZARÁ MAL. 
dir1 <- data.table("Direcciones" = unique(Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº != 0 , paste(`LUGAR ACCIDENTE`, Nº, "MADRID")]))
dir2 <- data.table("Direcciones" = unique(Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº == 0 , paste(`LUGAR ACCIDENTE`, "MADRID")]))
# direcciones <- data.table("Direcciones" = unique(Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) , paste(`LUGAR ACCIDENTE`, Nº, "MADRID")]))
direcciones <- rbind(dir1, dir2)

# ==== COMO LO HE HECHO =====

# Esto sería directo, sin tener en cuenta lo del número.
# direcciones <- data.table("Direcciones" = unique(Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) , paste(`LUGAR ACCIDENTE`, Nº, "MADRID")]))

# ptm <- proc.time()
# geocoded31 <- geocode(direcciones$Direcciones[30001:31074])
# write.csv(geocoded31, file = "geocoded31.csv")
# proc.time() - ptm
# beep()

# Algunos datos no han salido bien (muy pocos). Hacer una búsqueda de aquellas coordenadas que se salen de lo normal o con NA.

# Ahora se cargan todos los datos en un mismo data table, teniendo en cuenta que en su momento tenía todos los archivos csv
# en el directorio principal. Se hace lo siguiente:

# # 1. Lista de archivos a juntar.
# filenames = c("geocoded1.csv","geocoded2.csv","geocoded3.csv","geocoded4.csv","geocoded5.csv","geocoded6.csv","geocoded7.csv","geocoded8.csv","geocoded9.csv","geocoded10.csv",
#               "geocoded11.csv","geocoded12.csv","geocoded13.csv","geocoded14.csv","geocoded15.csv","geocoded16.csv","geocoded17.csv","geocoded18.csv","geocoded19.csv","geocoded20.csv",
#               "geocoded21.csv","geocoded22.csv","geocoded23.csv","geocoded24.csv","geocoded25.csv","geocoded26.csv","geocoded27.csv","geocoded28.csv","geocoded29.csv","geocoded30.csv",
#               "geocoded31.csv")
# # 2. Se crea el data.table que se crearía al hacer la geocodificación de una. Es un rbind pero cargando a la vez los archivos.
# geocoded <- rbindlist(lapply(filenames, fread))
# # 3. Se elimina una columna rara que se autogenera
# geocoded <- geocoded[,-1]
# # 4. Se cambia el orden de las columnas, porque lo habitual es tener primero longitud y luego latitud. Guardamos por si acaso.
# geocoded <- setcolorder(geocoded,order(c(2,1)))
# # 5. Se supone que están ordenados, así que se juntan con direcciones.
# geocoded <- cbind(direcciones, geocoded)
# 6. Una vez que se comprueba que están ordenados, no veo otra que aquellas direcciones que no salen o estan mal, meterlas
# a mano. Para ello te recomiendo cambiar la forma de ordenar el data.table por lon y lat, de forma que automáticamente salen
# en primeras posiciones valores anómalos.
# write.csv(geocoded, file = "../Accidentes de tráfico - Madrid/Raw_data/geocoded.csv")

# De aquí se tira a en LIMPIO.

# ===== A LIMPIO =====

# # 1. Se realiza la geocodificiación
# Geocoded <- geocode(direcciones$Direcciones)
# 
# # 2. Se cambia el orden de las columnas, porque lo habitual es tener primero longitud y luego latitud.
# Geocoded <- setcolorder(geocoded,order(c(2,1)))
# 
# # 3. Se supone que están ordenados, así que se juntan con direcciones.
# Geocoded <- cbind(direcciones, Geocoded)
# 
# # 4. Una vez que se comprueba que están ordenados, no veo otra que aquellas direcciones que no salen o estan mal, meterlas
# # a mano. Para ello te recomiendo cambiar la forma de ordenar el data.table por lon y lat, de forma que automáticamente salen
# # en primeras posiciones valores anómalos.
# 
# # 5. Se guarda este dataset.
# save(Geocoded, file = "../Accidentes de tráfico - Madrid/Cleaned_data/Geocoded.RData")

# 6. Ahora hay que unir ambos datasets, Geocoded y Accidentalidad. Para eso vamos a proceder de la siguiente manera:
#  - Se construyen un dataset auxiliar que contenga las mismas columnas que Accidentalidad en cuanto a LUGAR DE ACCIDENTE
#    y Nº, y que esté ordenado exactamente igual que direcciones, es decir, que Geocode. Luego se juntan ambos datasets,
#    este auxiliar y Geocode, que ya tendrá la latitud y longitud para cada ubicación que en el mismo formato que Accidentalidad.
#    Por último se hace un join (paquete plyr) de este nuevo dataset y de Accidentalidad.

aux1 <- data.table(unique(cbind("LUGAR ACCIDENTE" = Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº != 0]$`LUGAR ACCIDENTE`, 
                                   "Nº" = Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº != 0]$Nº)))
aux2 <- data.table(unique(cbind("LUGAR ACCIDENTE" = Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº == 0]$`LUGAR ACCIDENTE`, 
                                "Nº" = Accidentalidad[!grepl("AUTOVIA", `LUGAR ACCIDENTE`) & Nº == 0]$Nº)))
aux <- rbind(aux1, aux2)
dirGeolocalizadas <- cbind(aux, "lat" = Geocoded$lat, "lon" = Geocoded$lon)

GeoAccidentalidad <- join(Accidentalidad, dirGeolocalizadas)
save(GeoAccidentalidad, file = "../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")

# Para comprobar que dos columnas son enteras iguales (por ejemplo GeoAccidentalidad y Accidentalidad), se puede hacer
# identical(Accidentalidad$`LUGAR ACCIDENTE`, GeoAccidentalidad$`LUGAR ACCIDENTE`) 


