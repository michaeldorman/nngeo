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
#'
#' # Nearest 'city' per 'town', search radius of 50 km
#' cities = st_transform(cities, 32636)
#' towns = st_transform(towns, 32636)
#' l = st_connect(towns, cities, maxdist = 30000)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_buffer(st_geometry(cities), units::set_units(30, km)), border = "red", add = TRUE)

st_connect = function(x, y, ids = st_nn(x, y, ...), ...) {

  x_features = length(sf::st_geometry(x))
  x_ctr = sf::st_centroid(x)
  y_ctr = sf::st_centroid(y)

  result = st_sfc()

  # Progress bar
  pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)

  for(i in 1:x_features) {

    for(j in ids[[i]]) {

      start = sf::st_geometry(x_ctr[i, ])
      end = sf::st_geometry(y_ctr[j, ])
      l = c(start, end)
      l = sf::st_combine(l)
      l = sf::st_cast(l, "LINESTRING")
      result = c(result, l)

    }

    # Progress
    utils::setTxtProgressBar(pb, i)

  }

  cat("\n")

  return(result)

}
