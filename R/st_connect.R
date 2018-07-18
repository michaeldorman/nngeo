#' Create lines between features of two layers
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param ids A sparse list representation of features to connect such as returned by function \code{\link{st_nn}}. If \code{NULL} the function automatically calculates \code{ids} using \code{\link{st_nn}}
#' @param dist Sampling distance interval for generating outline points to choose from. Required when at least one of \code{x} or \code{y} is a line or polygon layer. Should be given in CRS units for projected layers, or in meters for layers in lon/lat
#' @param progress Display progress bar? (default \code{TRUE})
#' @param ... Other arguments passed to \code{st_nn} when calculating \code{ids}, such as \code{k} and \code{maxdist}
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
#' \dontrun{
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
#' l = st_connect(water[-1, ], towns, k = 20, dist = 100)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#'
#' # The 2-nearest water bodies for each town
#' l = st_connect(towns, water[-1, ], k = 2, dist = 100)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#' }

st_connect = function(x, y, ids = NULL, dist, progress = TRUE, ...) {

  # To geometry
  x = sf::st_geometry(x)
  y = sf::st_geometry(y)

  # Check projection match
  stopifnot(st_crs(x) == st_crs(y))

  # Get nearest IDs
  if(progress) cat("Calculating nearest IDs\n")
  if(is.null(ids)) ids = st_nn(x, y, progress = progress, ...)

  # Numer of 'x' features
  x_features = length(x)

  # If 'x' or 'y' are polygons - convert to lines
  if(class(x)[1] %in% c("sfc_POLYGON", "sfc_MULTIPOLYGON")) {
    x = st_cast(x, "MULTILINESTRING")
  }
  if(class(y)[1] %in% c("sfc_POLYGON", "sfc_MULTIPOLYGON")) {
    y = st_cast(y, "MULTILINESTRING")
  }

  # Calculate line lengths
  if(class(x)[1] %in% c("sfc_LINESTRING", "sfc_MULTILINESTRING")) {
    x_lengths = st_length(x)
    x_lengths = as.numeric(x_lengths)
    n_x = ceiling(x_lengths / dist)
  }
  if(class(y)[1] %in% c("sfc_LINESTRING", "sfc_MULTILINESTRING")) {
    y_lengths = st_length(y)
    y_lengths = as.numeric(y_lengths)
    n_y = ceiling(y_lengths / dist)
  }

  # Progress bar
  if(progress) {
    cat("Calculating lines\n")
    pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)
  }

  # Draw lines
  result <- lapply(1:x_features, function(i) {

    if(class(x)[1] %in% c("sfc_LINESTRING", "sfc_MULTILINESTRING")) {
      x_sp = as(x[i], "Spatial")
      start_pool = sp::spsample(x_sp, type = "regular", n = n_x[i])
      start_pool = st_as_sfc(start_pool)
    } else {
      start = x[i]
    }

    lines <- lapply(ids[[i]], function(j) {

      if(class(x)[1] %in% c("sfc_LINESTRING", "sfc_MULTILINESTRING")) {
        nearest_id = st_nn(y[j], start_pool, k = 1, progress = FALSE)[[1]]
        start = start_pool[nearest_id]
      }

      if(class(y)[1] %in% c("sfc_LINESTRING", "sfc_MULTILINESTRING")) {
        y_sp = as(y[j], "Spatial")
        end_pool = sp::spsample(y_sp, type = "regular", n = n_y[j])
        end_pool = st_as_sfc(end_pool)
        nearest_id = st_nn(x[i], end_pool, k = 1, progress = FALSE)[[1]]
        end = end_pool[nearest_id]
      } else {
        end = y[j]
      }

      l = c(start, end)
      l = sf::st_combine(l)
      l = sf::st_cast(l, "LINESTRING")
      l

    })

    # Progress
    if(progress) {
      utils::setTxtProgressBar(pb, i)
    }

    do.call(c, lines)

  })

  result <- do.call(c, result)

  if(progress) cat("\nDone.\n")

  return(result)

}
