% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/st_nn.R
\name{st_nn}
\alias{st_nn}
\title{Nearest Neighbor Search for Simple Features}
\usage{
st_nn(
  x,
  y,
  sparse = TRUE,
  k = 1,
  maxdist = Inf,
  returnDist = FALSE,
  progress = TRUE,
  parallel = 1
)
}
\arguments{
\item{x}{Object of class \code{sf} or \code{sfc}}

\item{y}{Object of class \code{sf} or \code{sfc}}

\item{sparse}{\code{logical}; should a sparse index list be returned (\code{TRUE}, the default) or a dense logical matrix? See "Value" section below.}

\item{k}{The maximum number of nearest neighbors to compute. Default is \code{1}, meaning that only a single point (nearest neighbor) is returned.}

\item{maxdist}{Search radius (\strong{in meters}). Points farther than search radius are not considered. Default is \code{Inf}, meaning that search is unconstrained.}

\item{returnDist}{\code{logical}; whether to return a second \code{list} with the distances between detected neighbors.}

\item{progress}{Display progress bar? The default is \code{TRUE}. When using \code{parallel>1} or when input is projected points, a progress bar is not displayed regardless of \code{progress} argument.}

\item{parallel}{Number of parallel processes. The default \code{parallel=1} implies ordinary non-parallel processing. Parallel processing is not applicable for projected points, where calculation is already highly optimized through the use of \code{nabor::knn}. Parallel processing is done with the \code{parallel} package.}
}
\value{
\itemize{
\item{If \code{sparse=TRUE} (the default), a sparse \code{list} with list element \code{i} being a numeric vector with the indices \code{j} of neighboring features from \code{y} for the feature \code{x[i,]}, or an empty vector (\code{integer(0)}) in case there are no neighbors.}
\item{If \code{sparse=FALSE}, a \code{logical} matrix with element \code{[i,j]} being \code{TRUE} when \code{y[j,]} is a neighbor of \code{x[i]}.}
\item{If \code{returnDists=TRUE} the function returns a \code{list}, with the first element as specified above, and the second element a sparse \code{list} with the distances (as \code{numeric} vectors, \strong{in meters}) between each pair of detected neighbors corresponding to the sparse \code{list} of indices.}
}
}
\description{
Returns the indices of layer \code{y} which are nearest neighbors of each feature of layer \code{x}. The number of nearest neighbors \code{k} and the search radius \code{maxdist} can be modified.\cr\cr
The function has three modes of operation:
\itemize{
\item{lon-lat points—Calculation using C code from \code{GeographicLib}, similar to \code{sf::st_distance}}
\item{projected points—Calculation using \code{nabor::knn}, a fast search method based on the \code{libnabo} C++ library}
\item{lines or polygons, either lon-lat or projected—Calculation based on \code{sf::st_distance}}
}
}
\examples{
data(cities)
data(towns)

cities = st_transform(cities, 32636)
towns = st_transform(towns, 32636)
water = st_transform(water, 32636)

# Nearest town
st_nn(cities, towns, progress = FALSE)

# Using 'sfc' objects
st_nn(st_geometry(cities), st_geometry(towns), progress = FALSE)
st_nn(cities, st_geometry(towns), progress = FALSE)
st_nn(st_geometry(cities), towns, progress = FALSE)

# With distances
st_nn(cities, towns, returnDist = TRUE, progress = FALSE)

\dontrun{

# Distance limit
st_nn(cities, towns, maxdist = 7200)
st_nn(cities, towns, k = 3, maxdist = 12000)
st_nn(cities, towns, k = 3, maxdist = 12000, returnDist = TRUE)

# 3 nearest towns
st_nn(cities, towns, k = 3)

# Spatial join
st_join(cities, towns, st_nn, k = 1)
st_join(cities, towns, st_nn, k = 2)
st_join(cities, towns, st_nn, k = 1, maxdist = 7200)
st_join(towns, cities, st_nn, k = 1)

# Polygons to polygons
st_nn(water, towns, k = 4)

# Large example - Geo points
n = 1000
x = data.frame(
  lon = (runif(n) * 2 - 1) * 70,
  lat = (runif(n) * 2 - 1) * 70
)
x = st_as_sf(x, coords = c("lon", "lat"), crs = 4326)
start = Sys.time()
result1 = st_nn(x, x, k = 3)
end = Sys.time()
end - start

# Large example - Geo points - Parallel processing
start = Sys.time()
result2 = st_nn(x, x, k = 3, parallel = 4)
end = Sys.time()
end - start
all.equal(result1, result2)

# Large example - Proj points
n = 1000
x = data.frame(
  x = (runif(n) * 2 - 1) * 70,
  y = (runif(n) * 2 - 1) * 70
)
x = st_as_sf(x, coords = c("x", "y"), crs = 4326)
x = st_transform(x, 32630)
start = Sys.time()
result = st_nn(x, x, k = 3)
end = Sys.time()
end - start

# Large example - Polygons
set.seed(1)
n = 150
x = data.frame(
  lon = (runif(n) * 2 - 1) * 70,
  lat = (runif(n) * 2 - 1) * 70
)
x = st_as_sf(x, coords = c("lon", "lat"), crs = 4326)
x = st_transform(x, 32630)
x = st_buffer(x, 1000000)
start = Sys.time()
result1 = st_nn(x, x, k = 3)
end = Sys.time()
end - start

# Large example - Polygons - Parallel processing
start = Sys.time()
result2 = st_nn(x, x, k = 3, parallel = 4)
end = Sys.time()
end - start
all.equal(result1, result2)

}
}
\references{
C. F. F. Karney, GeographicLib, Version 1.49 (2017-mm-dd), \url{https://geographiclib.sourceforge.io/1.49/}
}
