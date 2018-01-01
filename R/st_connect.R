#' Create lines between features of two layers
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param ids A sparse list representation of features to connect, such as returned by function \code{\link{st_nn}}
#' @param ... Other arguments passed to \code{st_nn} such as \code{k} and \code{maxdist}
#'
#' @return Object of class \code{sfc} with geometry type \code{LINESTRING}
#' @export
#'
#' @examples
#' # Nearest 'city' per 'town'
#' l = st_connect(towns, cities)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_geometry(cities), col = "red", add = TRUE)
#'
#' # Ten nearest 'towns' per 'city'
#' l = st_connect(cities, towns, k = 10)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_geometry(cities), col = "red", add = TRUE)



st_connect = function(x, y, ids = st_nn(x, y, ...), ...) {

  x_features = length(st_geometry(x))
  x = st_centroid(x)
  y = st_centroid(y)

  result = st_sfc()

  for(i in 1:x_features) {

    for(j in ids[[i]]) {

      start = st_geometry(x[i, ])
      end = st_geometry(y[j, ])
      l = c(start, end)
      l = st_combine(l)
      l = st_cast(l, "LINESTRING")
      result = c(result, l)

    }

  }

  return(result)

}
