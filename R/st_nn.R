#' Nearest Neighbor Search for Simple Features
#'
#' Returns the indices of layer \code{y} which are nearest neighbors of each feature of layer \code{x}. The number of nearest neighbors \code{k} and the search radius \code{maxdist} can be modified.\cr\cr
#' The function has three modes of operation:
#' \itemize{
#' \item{lon-lat points—Calculation using C code from \code{GeographicLib}, similar to \code{sf::st_distance}}
#' \item{projected points—Calculation using \code{nabor::knn}, a fast search method based on the \code{libnabo} C++ library}
#' \item{lines or polygons, either lon-lat or projected—Calculation based on \code{sf::st_distance}}
#' }
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param sparse \code{logical}; should a sparse index list be returned (\code{TRUE}, the default) or a dense logical matrix? See "Value" section below.
#' @param k The maximum number of nearest neighbors to compute. Default is \code{1}, meaning that only a single point (nearest neighbor) is returned.
#' @param maxdist Search radius (\strong{in meters}). Points farther than search radius are not considered. Default is \code{Inf}, meaning that search is unconstrained.
#' @param returnDist \code{logical}; whether to return a second \code{list} with the distances between detected neighbors.
#' @param progress Display progress bar? The default is \code{TRUE}. When using \code{parallel>1} or when input is projected points, a progress bar is not displayed regardless of \code{progress} argument.
#' @param parallel Number of parallel processes. The default \code{parallel=1} implies ordinary non-parallel processing. Parallel processing is not applicable for projected points, where calculation is already highly optimized through the use of \code{nabor::knn}. Parallel processing is done with the \code{parallel} package.
#' @return  \itemize{
#' \item{If \code{sparse=TRUE} (the default), a sparse \code{list} with list element \code{i} being a numeric vector with the indices \code{j} of neighboring features from \code{y} for the feature \code{x[i,]}, or an empty vector (\code{integer(0)}) in case there are no neighbors.}
#' \item{If \code{sparse=FALSE}, a \code{logical} matrix with element \code{[i,j]} being \code{TRUE} when \code{y[j,]} is a neighbor of \code{x[i]}.}
#' \item{If \code{returnDists=TRUE} the function returns a \code{list}, with the first element as specified above, and the second element a sparse \code{list} with the distances (as \code{units} vectors, \strong{in meters}) between each pair of detected neighbors corresponding to the sparse \code{list} of indices.}
#' }
#' @references C. F. F. Karney, GeographicLib, Version 1.49 (2017-mm-dd), \url{https://geographiclib.sourceforge.io/1.49/}
#' @export
#' @import sf
#'
#' @examples
#' data(cities)
#' data(towns)
#'
#' cities = st_transform(cities, 32636)
#' towns = st_transform(towns, 32636)
#' water = st_transform(water, 32636)
#'
#' # Nearest town
#' st_nn(cities, towns, progress = FALSE)
#'
#' # Using 'sfc' objects
#' st_nn(st_geometry(cities), st_geometry(towns), progress = FALSE)
#' st_nn(cities, st_geometry(towns), progress = FALSE)
#' st_nn(st_geometry(cities), towns, progress = FALSE)
#'
#' # With distances
#' st_nn(cities, towns, returnDist = TRUE, progress = FALSE)
#'
#' \dontrun{
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
#' # Polygons to polygons
#' st_nn(water, towns, k = 4)
#'
#' # Large example - Geo points
#' n = 1000
#' x = data.frame(
#'   lon = (runif(n) * 2 - 1) * 70,
#'   lat = (runif(n) * 2 - 1) * 70
#' )
#' x = st_as_sf(x, coords = c("lon", "lat"), crs = 4326)
#' start = Sys.time()
#' result1 = st_nn(x, x, k = 3)
#' end = Sys.time()
#' end - start
#'
#' # Large example - Geo points - Parallel processing
#' start = Sys.time()
#' result2 = st_nn(x, x, k = 3, parallel = 4)
#' end = Sys.time()
#' end - start
#' all.equal(result1, result2)
#'
#' # Large example - Proj points
#' n = 1000
#' x = data.frame(
#'   x = (runif(n) * 2 - 1) * 70,
#'   y = (runif(n) * 2 - 1) * 70
#' )
#' x = st_as_sf(x, coords = c("x", "y"), crs = 4326)
#' x = st_transform(x, 32630)
#' start = Sys.time()
#' result = st_nn(x, x, k = 3)
#' end = Sys.time()
#' end - start
#'
#' # Large example - Polygons
#' set.seed(1)
#' n = 150
#' x = data.frame(
#'   lon = (runif(n) * 2 - 1) * 70,
#'   lat = (runif(n) * 2 - 1) * 70
#' )
#' x = st_as_sf(x, coords = c("lon", "lat"), crs = 4326)
#' x = st_transform(x, 32630)
#' x = st_buffer(x, 1000000)
#' start = Sys.time()
#' result1 = st_nn(x, x, k = 3)
#' end = Sys.time()
#' end - start
#'
#' # Large example - Polygons - Parallel processing
#' start = Sys.time()
#' result2 = st_nn(x, x, k = 3, parallel = 4)
#' end = Sys.time()
#' end - start
#' all.equal(result1, result2)
#'
#' }

st_nn = function(x, y, sparse = TRUE, k = 1, maxdist = Inf, returnDist = FALSE, progress = TRUE, parallel = 1) {

  # To geometry
  x = sf::st_geometry(x)
  y = sf::st_geometry(y)

  # Check that 'k' does not exceed number of features in 'y'
  if(k > length(y))
    stop("'k' cannot exceed number of features in 'y'")

  # Check that 'maxdist' has length 1
  if(!is.numeric(k) | length(k) != 1)
    stop("'k' must be 'numeric' of length 1")

  # Check that CRS is the same
  if(!is.na(sf::st_crs(x)) & !is.na(sf::st_crs(y)) & sf::st_crs(x) != sf::st_crs(y))
    stop("'x' and 'y' need to be in the same CRS")

  # Check that geometries are non-empty
  if(any(st_is_empty(x))) stop("'x' contains empty geometries")
  if(any(st_is_empty(y))) stop("'y' contains empty geometries")

  # Determine geometry type and projection & calculate IDs+dists
  # Single thread
  if(parallel == 1) {
    if(!class(x)[1] == "sfc_POINT" | !class(y)[1] == "sfc_POINT") {
      message("lines or polygons")
      result = .st_nn_poly(x, y, k, maxdist, progress)
    } else {
      if(!is.na(sf::st_crs(x)) & !is.na(sf::st_crs(y)) & sf::st_is_longlat(x) & sf::st_is_longlat(y)) {
        message("lon-lat points")
        result = .st_nn_pnt_geo(x, y, k, maxdist, progress)
      } else {
        message("projected points")
        result = .st_nn_pnt_proj(x, y, k, maxdist)
      }
    }
    # Returned sparse lists
    ids = result[[1]]
    dists = result[[2]]
  }
  # Parallel
  if(parallel > 1) {
    if(!class(x)[1] == "sfc_POINT" | !class(y)[1] == "sfc_POINT") {
      message("lines or polygons")
      if(.Platform$OS.type == "unix") {
        result = parallel::mclapply(
          split(x, 1:length(x)),
          function(i) .st_nn_poly(i, y, k, maxdist, progress = FALSE),
          mc.cores = parallel
        )
      } else {
        result = parallel::parLapply(
          parallel::makeCluster(parallel),
          split(x, 1:length(x)),
          function(i) .st_nn_poly(i, y, k, maxdist, progress = FALSE)
        )
      }
    } else {
      if(!is.na(sf::st_crs(x)) & !is.na(sf::st_crs(y)) & sf::st_is_longlat(x) & sf::st_is_longlat(y)) {
        message("lon-lat points")
        if(.Platform$OS.type == "unix") {
          result = parallel::mclapply(
            split(x, 1:length(x)),
            function(i) .st_nn_pnt_geo(i, y, k, maxdist, progress = FALSE),
            mc.cores = parallel
          )
        } else {
          result = parallel::parLapply(
            parallel::makeCluster(parallel),
            split(x, 1:length(x)),
            function(i) .st_nn_pnt_geo(i, y, k, maxdist, progress = FALSE)
          )
        }
      } else {
        message("projected points")
        warning("argument 'parallel' ignored")
        result = .st_nn_pnt_proj(x, y, k, maxdist)
      }
    }
    ids = lapply(result, function(i) i[[1]])
    ids = do.call(c, ids)
    names(ids) = NULL
    dists = lapply(result, function(i) i[[2]])
    dists = do.call(c, dists)
    names(dists) = NULL
  }

  # To dense matrix?
  if(!sparse) {
    # ids
    m = matrix(
      FALSE,
      nrow = length(x),
      ncol = length(y)
      )
    for(i in 1:nrow(m)) m[i, ids[[i]]] = TRUE
    ids = m
  }

  # Attach distances?
  if(returnDist) {
    result = list(nn = ids, dist = dists)
  } else {
    result = ids
  }

  return(result)

}

