#' Create lines between features of two layers
#'
#' Returns a line layer with line segments which connect the nearest feature(s) from \code{y} for each feature in \code{x}. This is mostly useful for graphical purposes (see Note and Examples below).
#'
#' @param x Object of class \code{sf} or \code{sfc}
#' @param y Object of class \code{sf} or \code{sfc}
#' @param ids A sparse list representation of features to connect such as returned by function \code{\link{st_nn}}. If \code{NULL} the function automatically calculates \code{ids} using \code{\link{st_nn}}
#' @param progress Display progress bar? (default \code{TRUE})
#' @param ... Other arguments passed to \code{st_nn} when calculating \code{ids}, such as \code{k} and \code{maxdist}
#'
#' @return Object of class \code{sfc} with geometry type \code{LINESTRING}
#' @note The segments are straight lines, i.e., they correspond to shortest path assuming planar geometry regardless of CRS. Therefore, the lines should serve as a graphical indication of features that are nearest to each other; the exact shortest path between features should be calculated by other means, such as \code{geosphere::greatCircle}.
#'
#' @importFrom methods as
#' @export
#'
#' @examples
#' # Nearest 'city' per 'town'
#' l = st_connect(towns, cities, progress = FALSE)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_geometry(cities), col = "red", add = TRUE)
#'
#' # Ten nearest 'towns' per 'city'
#' l = st_connect(cities, towns, k = 10, progress = FALSE)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_geometry(cities), col = "red", add = TRUE)
#'
#' \dontrun{
#'
#' # Nearest 'city' per 'town', search radius of 30 km
#' cities = st_transform(cities, 32636)
#' towns = st_transform(towns, 32636)
#' l = st_connect(cities, towns, k = nrow(towns), maxdist = 30000, progress = FALSE)
#' plot(st_geometry(towns), col = "darkgrey")
#' plot(st_geometry(l), add = TRUE)
#' plot(st_buffer(st_geometry(cities), units::set_units(30, km)), border = "red", add = TRUE)
#'
#' # The 20-nearest towns for each water body, search radius of 100 km
#' water = st_transform(water, 32636)
#' l = st_connect(water[-1, ], towns, k = 20, maxdist = 100000, progress = FALSE)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#'
#' # The 2-nearest water bodies for each town, search radius of 100 km
#' l = st_connect(towns, water[-1, ], k = 2, maxdist = 100000)
#' plot(st_geometry(water[-1, ]), col = "lightblue", border = NA, extent = l)
#' plot(st_geometry(towns), col = "darkgrey", add = TRUE)
#' plot(st_geometry(l), col = "red", add = TRUE)
#'
#' }

st_connect = function(x, y, ids = NULL, progress = TRUE, ...) {

  # To geometry
  x = sf::st_geometry(x)
  y = sf::st_geometry(y)

  # Check that CRS is the same
  if(!is.na(sf::st_crs(x)) & !is.na(sf::st_crs(y)) & sf::st_crs(x) != sf::st_crs(y))
    stop("'x' and 'y' need to be in the same CRS")

  # Get nearest IDs
  if(progress) cat("Calculating nearest IDs\n")
  if(is.null(ids)) ids = st_nn(x, y, progress = progress, ...)

  # Draw lines
  if(progress) cat("Calculating lines\n")
  x = x[rep(1:length(ids), times = lengths(ids))]
  y = y[unlist(ids)]
  crs = st_crs(x)
  result = sf::st_nearest_points(st_set_crs(x, NA), st_set_crs(y, NA), pairwise = TRUE)
  result = st_set_crs(result, crs)

  # Return
  return(result)

}
