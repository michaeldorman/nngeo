#' Calculate the azimuth between pairs of points
#'
#' Calculates the (planar!) azimuth between pairs in two sequences of points \code{x} and \code{y}. When point sequence length doesn't match, the shorter one is recycled.
#' @param x Object of class \code{sf}, \code{sfc} or \code{sfg}, of type \code{"POINT"}
#' @param y Object of class \code{sf}, \code{sfc} or \code{sfg}, of type \code{"POINT"}
#' @return A \code{numeric} vector, of the same length as (the longer of) \code{x} and \code{y}, with the azimuth values from \code{x} to \code{y} (in decimal degrees, ranging between 0 and 360 clockwise from north). For identical points, an azimuth of \code{NA} is returned.
#' @note
#' The function currently calculates planar azimuth, ignoring CRS information. For bearing on a sphere, given points in lon-lat, see function \code{geosphere::bearing}.
#' @references
#' \url{https://en.wikipedia.org/wiki/Azimuth#Cartographical_azimuth}
#' @export
#'
#' @examples
#' # Two points
#' x = st_point(c(0, 0))
#' y = st_point(c(1, 1))
#' st_azimuth(x, y)
#'
#' # Center and all other points on a 5*5 grid
#' library(stars)
#' m = matrix(1, ncol = 5, nrow = 5)
#' m[(nrow(m)+1)/2, (ncol(m)+1)/2] = 0
#' s = st_as_stars(m)
#' s = st_set_dimensions(s, 2, offset = ncol(m), delta = -1)
#' names(s) = "value"
#' pnt = st_as_sf(s, as_points = TRUE)
#' ctr = pnt[pnt$value == 0, ]
#' az = st_azimuth(ctr, pnt)
#' plot(st_geometry(pnt), col = NA)
#' plot(st_connect(ctr, pnt, k = nrow(pnt)), col = "grey", add = TRUE)
#' plot(st_geometry(pnt), col = "grey", add = TRUE)
#' text(st_coordinates(pnt), as.character(round(az)), col = "red")

st_azimuth = function(x, y) {

  # Checks
  stopifnot(all(st_is(x, "POINT")))
  stopifnot(all(st_is(y, "POINT")))

  # Extract geometry
  x = st_geometry(x)
  y = st_geometry(y)

  # Recycle 'x' or 'y' if necessary
  if(length(x) < length(y)) {
    ids = rep(1:length(x), length.out = length(y))
    x = x[ids]
  }
  if(length(y) < length(x)) {
    ids = rep(1:length(y), length.out = length(x))
    y = y[ids]
  }

  # Get coordinate matrices
  x_coords = st_coordinates(x)
  y_coords = st_coordinates(y)

  # Calculate azimuths
  x1 = x_coords[, 1]
  y1 = x_coords[, 2]
  x2 = y_coords[, 1]
  y2 = y_coords[, 2]
  az = (180 / pi) * atan2(x2 - x1, y2 - y1)
  names(az) = NULL
  az[az < 0] = az[az < 0] + 360

  # Replace with 'NA' for identical points
  az[x1 == x2 & y1 == y2] = NA

  # Return
  return(az)

}










