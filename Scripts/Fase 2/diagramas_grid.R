# DIAGRAMAS DE VORONOI: En este script se muestra una función para generar
# diagramas de Voronoi como un objeto SpatialPolygonsDataFrame.
# Para ello deben entrar una serie de puntos SpatialPoints, es decir,
# vp <- voronoipolygons(df-con-coordenadas)

library(sp)

voronoipolygons = function(layer) {
  require(deldir)
  crds = layer@coords
  z = deldir(crds[,1], crds[,2])
  w = tile.list(z)
  polys = vector(mode='list', length=length(w))
  require(sp)
  for (i in seq(along=polys)) {
    pcrds = cbind(w[[i]]$x, w[[i]]$y)
    pcrds = rbind(pcrds, pcrds[1,])
    polys[[i]] = Polygons(list(Polygon(pcrds)), ID=as.character(i))
  }
  SP = SpatialPolygons(polys)
  voronoi = SpatialPolygonsDataFrame(SP, data=data.frame(dummy = seq(length(SP)), row.names=sapply(slot(SP, 'polygons'), 
                                                                                                   function(x) slot(x, 'ID'))))
}

# Estas coordenadas se construyen a partir de un data.table-frame que tiene dos columnas: lon y lat
# Se hace mediante coordinates(df) <- ~ lon + lat (si se llaman asi el data y las columnas), y a continuación
# hay que darle el CRS: proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
# ATENCIÓN: PARA PODER USAR over(vp, df) TIENEN QUE TENER EL MISMO CRS. ASÍ QUE SI NO SE LE PONE SOLO
# A VP AL CREARLO, HACERLO MANUALMENTE.

# Comandos rápdidos para general el ejemplo:
load("../Accidentes de tráfico - Madrid/Cleaned_data/GeoAccidentalidad.RData")
GeoAccidentalidad <- na.omit(GeoAccidentalidad)
df <- data.frame(GeoAccidentalidad$lon, GeoAccidentalidad$lat)
df <- unique(df[1:500,]) #Esto es porque se repite cada accidente por persona creo 
colnames(df) <- c("lon", "lat")
coordinates(df) <- ~ lon + lat
proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
randomCenters <- spsample(df, 10, type = "random")
vp <- voronoipolygons(randomCenters)
proj4string(vp) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
plot(vp)

df <- randomCenters
# GRID CUADRADO:
# Si lo que buscamos es un grid normal y corriente, se puede crear así:
grid  <- GridTopology(cellcentre.offset= c(-3.7,40.39), cellsize = c(0.03,0.03), cells.dim = c(5,5)) # Centro, distancia de cada celda, y número de celdas en cada dimensión
sg    <- SpatialGrid(grid)
poly  <- as.SpatialPolygons.GridTopology(grid)
# NO OLVIDES ESTO SI QUIERES JUNTAR TODO EN LA MISMA GRÁFICA Y HACER OVER. Quizás vale con CRS("+proj=longlat") (en todos claro)
proj4string(poly) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
plot(poly)
plot(df, color = "red", add = TRUE)
# Esto hace un data.frame con el grid al que pertenece cada coordenada
data.frame(df, grid = over(df, poly))