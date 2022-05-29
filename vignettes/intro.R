## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(nngeo)


## ---- eval=FALSE--------------------------------------------------------------
## install.packages("remotes")
## remotes::install_github("michaeldorman/nngeo")


## ---- eval=FALSE--------------------------------------------------------------
## install.packages("nngeo")


## ---- include=FALSE-----------------------------------------------------------
data(cities)
data(towns)
data(water)


## -----------------------------------------------------------------------------
cities


## -----------------------------------------------------------------------------
towns


## -----------------------------------------------------------------------------
water


## ---- eval=FALSE--------------------------------------------------------------
## plot(st_geometry(water), col = "lightblue")
## plot(st_geometry(towns), col = "grey", pch = 1, add = TRUE)
## plot(st_geometry(cities), col = "red", pch = 1, add = TRUE)


## ----layers, echo=FALSE, fig.align='center', fig.width=4, fig.height=8, out.width="50%", fig.cap='Visualization of the \\texttt{water}, \\texttt{towns} and \\texttt{cities} layers'----
opar = par(mar = rep(0, 4))
plot(st_geometry(water), col = "lightblue")
plot(st_geometry(towns), col = "grey", pch = 1, add = TRUE)
plot(st_geometry(cities), col = "red", pch = 1, add = TRUE)
par(opar)


## -----------------------------------------------------------------------------
nn = st_nn(cities, towns, progress = FALSE)
nn


## -----------------------------------------------------------------------------
l = st_connect(cities, towns, ids = nn)
l


## ---- eval=FALSE--------------------------------------------------------------
## plot(st_geometry(l))
## plot(st_geometry(towns), col = "darkgrey", add = TRUE)
## plot(st_geometry(cities), col = "red", add = TRUE)
## text(st_coordinates(cities)[, 1], st_coordinates(cities)[, 2], 1:3, col = "red", pos = 4)


## ----st_connect, echo=FALSE, fig.align='center', fig.width=4, fig.height=8, out.width="50%", fig.cap="Nearest neighbor match between \\texttt{cities} (in red) and \\texttt{towns} (in grey)"----
opar = par(mar = rep(0.5, 4))
plot(st_geometry(l))
plot(st_geometry(towns), col = "darkgrey", add = TRUE)
plot(st_geometry(cities), col = "red", add = TRUE)
text(st_coordinates(cities)[, 1], st_coordinates(cities)[, 2], 1:3, col = "red", pos = 4)
par(opar)


## -----------------------------------------------------------------------------
nn = st_nn(cities, towns[1:5, ], sparse = FALSE, progress = FALSE)
nn


## -----------------------------------------------------------------------------
nn = st_nn(cities, towns, k = 2, progress = FALSE)
nn


## ---- results='hide', warning=FALSE-------------------------------------------
x = st_nn(cities, towns, k = 10)
l = st_connect(cities, towns, ids = x)


## ---- eval=FALSE--------------------------------------------------------------
## plot(st_geometry(l))
## plot(st_geometry(cities), col = "red", add = TRUE)
## plot(st_geometry(towns), col = "darkgrey", add = TRUE)


## ----cities_towns, echo=FALSE, fig.align='center', fig.width=4, fig.height=8, out.width="50%", warning=FALSE, fig.cap="Nearest 10 \\texttt{towns} features from each \\texttt{cities} feature"----
opar = par(mar = rep(1, 4))
plot(st_geometry(l))
plot(st_geometry(cities), col = "red", add = TRUE)
plot(st_geometry(towns), col = "darkgrey", add = TRUE)
par(opar)


## -----------------------------------------------------------------------------
nn = st_nn(cities, towns, k = 1, returnDist = TRUE, progress = FALSE)
nn


## -----------------------------------------------------------------------------
nn = st_nn(cities, towns, k = 1, maxdist = 2000, progress = FALSE)
nn


## -----------------------------------------------------------------------------
st_join(cities, towns, join = st_nn, k = 2, maxdist = 5000, progress = FALSE)


## -----------------------------------------------------------------------------
cities1 = st_join(cities, towns, join = st_nn, k = 1, progress = FALSE)
cities1


## -----------------------------------------------------------------------------
# Calculate distances
n = st_nn(cities, towns, k = 1, returnDist = TRUE, progress = FALSE)
dists = sapply(n[[2]], "[", 1)
dists

# Bind distances
cities1$dist = dists
cities1


## -----------------------------------------------------------------------------
# Get indices & distances
n = st_nn(cities, towns, k = 1, returnDist = TRUE, progress = FALSE)
ids = sapply(n[[1]], "[", 1)
dists = sapply(n[[2]], "[", 1)

# Join
cities1 = data.frame(cities, st_drop_geometry(towns)[ids, , drop = FALSE])
cities1 = st_sf(cities1)

# Add distances
cities1$dist = dists
cities1


## -----------------------------------------------------------------------------
nn = st_nn(water[-1, ], towns, k = 20, progress = FALSE)


## ---- warning=FALSE-----------------------------------------------------------
l = st_connect(water[-1, ], towns, ids = nn, dist = 100)


## ---- eval=FALSE--------------------------------------------------------------
## plot(st_geometry(water[-1, ]), col = "lightblue", border = "grey")
## plot(st_geometry(towns), col = "darkgrey", add = TRUE)
## plot(st_geometry(l), col = "red", add = TRUE)


## ----water_towns, echo=FALSE, fig.align='center', fig.width=4, fig.height=8, out.width="50%", warning=FALSE, fig.cap="Nearest 20 \\texttt{towns} features from each \\texttt{water} polygon"----
opar = par(mar = rep(0, 4))
plot(st_geometry(water[-1, ]), col = "lightblue", border = "grey")
plot(st_geometry(towns), col = "darkgrey", add = TRUE)
plot(st_geometry(l), col = "red", add = TRUE)
par(opar)

