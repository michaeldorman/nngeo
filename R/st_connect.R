#' Create lines between features of two layers
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param ids A sparse list representation of features to connect, such as returned by function \code{\link{st_nn}}
#' @param progress Display progress bar? (default `TRUE`)
#' @param ... Other arguments passed to \code{st_nn} such as \code{k} and \code{maxdist}
#'
#' @return Object of class \code{sfc} with geometry type \code{LINESTRING}
#'
#' @importFrom methods as
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
#' # Nearest 'city' per 'town', search radius of 30 km
#' cities = st_transform(cities, 32636)
#' towns = st_transform(towns, 32636)
#' l = st_connect(cities, towns, k = nrow(towns), maxdist = 30000)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_buffer(st_geometry(cities), units::set_units(30, km)), border = "red", add = TRUE)
#'
#' # The 20-nearest towns for each water body
#' water = st_transform(water, 32636)
#' l = st_connect(water[-1, ], towns, k = 20)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#' \dontrun{
#'
#' # The 2-nearest water bodies for each town
#' l = st_connect(towns, water[-1, ], k = 2)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#' # The 2-nearest water bodies for each water body
#' l = st_connect(water, water, k = 2)
#' plot(st_geometry(water), col = "lightblue")
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#' }

st_connect = function(x, y, ids = st_nn(x, y, ...), progress = TRUE, ...) {

  # To geometry
  x = sf::st_geometry(x)
  y = sf::st_geometry(y)

  # Numer of 'x' features
  x_features = length(x)

  # Final line layer
  result = st_sfc()

  # # If line or polygon - use nearest point on shape outline
  if(class(x)[1] %in% c("sfc_POLYGON", "sfc_MULTIPOLYGON")) {
    x = st_cast(x, "MULTILINESTRING")
  }
  if(class(y)[1] %in% c("sfc_POLYGON", "sfc_MULTIPOLYGON")) {
    y = st_cast(y, "MULTILINESTRING")
  }

    # Progress bar
    if(progress) {
      pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)
    }

    # Draw lines
    for(i in 1:x_features) {

      if(class(x)[1] == "sfc_MULTILINESTRING") {
        x_sp = as(x[i], "Spatial")
        start_pool = sp::spsample(x_sp, type = "regular", n = 1000)
        start_pool = st_as_sfc(start_pool)
      } else {
        start = x[i]
      }

      for(j in ids[[i]]) {

        if(class(x)[1] == "sfc_MULTILINESTRING") {
          nearest_id = st_nn(y[j], start_pool, k = 1, progress = FALSE)[[1]]
          start = start_pool[nearest_id]
        }

        if(class(y)[1] == "sfc_MULTILINESTRING") {
          y_sp = as(y[j], "Spatial")
          end_pool = sp::spsample(y_sp, type = "regular", n = 1000)
          end_pool = st_as_sfc(end_pool)
          nearest_id = st_nn(x[i], end_pool, k = 1, progress = FALSE)[[1]]
          end = end_pool[nearest_id]
        } else {
          end = y[j]
        }

        l = c(start, end)
        l = sf::st_combine(l)
        l = sf::st_cast(l, "LINESTRING")
        result = c(result, l)
      }

      # Progress
      if(progress) {
        utils::setTxtProgressBar(pb, i)
      }

    }

  cat("\n")

  return(result)

}
