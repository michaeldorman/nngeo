#' Nearest Neighbor Search for Simple Features
#'
#' The function returns the indices of layer \code{y} which are nearest neighbors of each feature of layer \code{x}. The number of nearest neighbors \code{k} and the search radius \code{maxdist} can be modified.\cr\cr
#' The function has three modes of operation -
#' \itemize{
#' \item{lon-lat points - Calculation using C implementation (see references) of the Vincenty distance, which is identical to \code{geosphere::distVincentyEllipsoid} and \code{sf::st_distance}}
#' \item{projected points - Calculation using \code{RANN::nn2}, a fast search method based on the ANN C++ library}
#' \item{lines or polygons, either lon-lat or projected - Calculation based on \code{sf::st_distance}, which internally uses \code{geosphere::distGeo}}
#' }
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param sparse logical; should a sparse index list be returned (TRUE) or a dense logical matrix? See below.
#' @param k The maximum number of nearest neighbors to compute. Default is \code{1}, meaning that only a single point (nearest neighbor) is returned
#' @param maxdist Search radius (in meters). Points farther than search radius are not considered. Default is \code{Inf} meaning that search is unconstrained
#' @param returnDist logical; whether to return a matrix with the distances between detected neighbors
#' @return If \code{sparse=FALSE}, returned object is a logical matrix with element \code{[i,j]} being \code{TRUE} when \code{y[j, ]} is a neighbor of \code{x[i]}; if \code{sparse=TRUE} (the default), a sparse list representation of the same matrix is returned, with list element \code{i} a numeric vector with the indices \code{j} of neighboring features from \code{y} for the feature \code{x[i, ]}, or \code{integer(0)} in case there are no neighbors. If \code{returnDists=TRUE} the function returns a \code{list}, with the first element as specified above, and the second element the matrix of distances (in meters) between each pair of detected neighbors.
#' @references C code for Vincenty distance by Jan Antala (\url{https://github.com/janantala/GPS-distance/blob/master/c/distance.c})
#' @export
#'
#' @import sf
#'
#' @examples
#' data(cities)
#' data(towns)
#'
#' cities = st_transform(cities, 32636)
#' towns = st_transform(towns, 32636)
#'
#' # Nearest town
#' st_nn(cities, towns)
#'
#' # Using 'sfc' objects
#' st_nn(st_geometry(cities), st_geometry(towns))
#' st_nn(cities, st_geometry(towns))
#' st_nn(st_geometry(cities), towns)
#'
#' # With distances
#' st_nn(cities, towns, returnDist = TRUE)
#'
#' # Distance limit
#' st_nn(cities, towns, maxdist = 7200)
#' st_nn(cities, towns, k = 3, maxdist = 12000)
#' st_nn(cities, towns, k = 3, maxdist = 12000, returnDist = TRUE)
#'
#' # 3 nearest towns
#' st_nn(cities, towns, k = 3)
#'
#' # Spatial join
#' st_join(cities, towns, st_nn, k = 1)
#' st_join(cities, towns, st_nn, k = 2)
#' st_join(cities, towns, st_nn, k = 1, maxdist = 7200)
#' st_join(towns, cities, st_nn, k = 1)
#'
#' \dontrun{
#' # Large example
#' n = 1000
#' x = data.frame(
#'   lon = (runif(n) * 2 - 1) * 70,
#'   lat = (runif(n) * 2 - 1) * 70
#' )
#' x = st_as_sf(x, coords = c("lon", "lat"), crs = 4326)
#' start = Sys.time()
#' result = st_nn(x, x, k = 3)
#' end = Sys.time()
#' end - start
#' }

st_nn = function(x, y, sparse = TRUE, k = 1, maxdist = Inf, returnDist = FALSE) {

  # Check that 'k' does not exceed number of features in 'y'
  if(k > length(sf::st_geometry(y)))
    stop("'k' cannot exceed number of features in 'y'")

  # Check that 'maxdist' has length 1
  if(!is.numeric(k) | length(k) != 1)
    stop("'k' must be 'numeric' of length 1")

  # Check that CRS is the same
  if(sf::st_crs(x) != sf::st_crs(y))
    stop("'x' and 'y' needs to be in the same CRS")

  # Determine geometry type and projection

  # Check that 'x' and 'y' are 'POINT'
  if(!class(sf::st_geometry(x))[1] == "sfc_POINT" | !class(sf::st_geometry(y))[1] == "sfc_POINT") {
    result = .st_nn_poly(x, y, k, maxdist)
  } else {
    if(sf::st_is_longlat(x) & sf::st_is_longlat(y)) {
      result = .st_nn_pnt_geo(x, y, k, maxdist)
    } else {
      result = .st_nn_pnt_proj(x, y, k, maxdist)
    }
  }

  ids = result[[1]]
  dist_matrix = result[[2]]

  # To sparse
  ids = split(ids, 1:nrow(ids))
  ids = lapply(ids, function(x) c(x[!is.na(x)]))
  names(ids) = NULL
  result = ids

  # To dense matrix
  if(!sparse) {
    m = matrix(
      FALSE,
      nrow = length(sf::st_geometry(x)),
      ncol = length(sf::st_geometry(y))
      )
    for(i in 1:nrow(m)) m[i, ids[[i]]] = TRUE
    ids = m
  }

  if(returnDist) {
    result = list(nn = ids, dist = dist_matrix)
  } else {
    result = ids
  }

  return(result)

}











