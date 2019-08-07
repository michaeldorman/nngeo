#' Wrapper for \code{raster::terrain} for calculating slope on \code{stars} objects
#'
#' This is a wrapper around \code{raster::terrain} with \code{opt="slope"}, to calculate topographic slope on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @return	A \code{stars} object with the slope values, in decimal degrees
#'
#' @examples
#' library(stars)
#' data(dem)
#' slope = raster_slope(dem)
#' plot(dem)
#' plot(slope)
#'
#' @export

raster_slope = function(x) {
  x = as(x, "Raster")
  x = raster::stack(x)
  n = raster::nlayers(x)
  for(i in 1:n) {
    x[[i]] = raster::terrain(x = x[[i]], opt = "slope", unit = "degrees")
  }
  stars::st_as_stars(x)
}











