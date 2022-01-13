library(nngeo)

city_geoms = st_geometry(cities)
town_geoms = st_geometry(towns)
lines = st_connect(cities, towns, k = 2)

expect_equal(
  st_coordinates(lines),
  structure(c(35.21371, 35.22, 35.21371, 35.15, 34.7817676, 34.8, 
34.7817676, 34.77, 34.989571, 34.99, 34.989571, 34.99, 31.768319, 
31.78, 31.768319, 31.8, 32.0852999, 32.08, 32.0852999, 32.07, 
32.7940463, 32.82, 32.7940463, 32.75, 1, 1, 2, 2, 3, 3, 4, 4, 
5, 5, 6, 6), .Dim = c(12L, 3L), .Dimnames = list(NULL, c("X", 
"Y", "L1")))
)
