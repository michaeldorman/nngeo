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

  # Check that CRS is the same
  if(!is.na(sf::st_crs(x)) & !is.na(sf::st_crs(y)) & sf::st_crs(x) != sf::st_crs(y))
    stop("'x' and 'y' needs to be in the same CRS")

  # Get nearest IDs
  if(progress) cat("Calculating nearest IDs\n")
  if(is.null(ids)) ids = st_nn(x, y, progress = progress, ...)

  # Draw lines
  if(progress) cat("Calculating lines\n")
  x = x[rep(1:length(ids), times = lengths(ids))]
  y = y[unlist(ids)]
  result = st_nearest_points(x, y, pairwise = TRUE)

  # Return
  return(result)

}
