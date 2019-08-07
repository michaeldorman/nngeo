#' Wrapper for \code{raster::terrain} for calculating aspect on \code{stars} objects
#'
#' This is a wrapper around \code{raster::terrain} with \code{opt="aspect"}, to calculate topographic aspect on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @return	A \code{stars} object with the aspect values, in decimal degrees
#'
#' @examples
#' library(stars)
#' data(dem)
#' aspect = raster_aspect(dem)
#' plot(dem)
#' plot(aspect)
#'
#' @export

raster_aspect = function(x) {
  x = as(x, "Raster")
  x = raster::stack(x)
  n = raster::nlayers(x)
  for(i in 1:n) {
    x[[i]] = raster::terrain(x = x[[i]], opt = "aspect", unit = "degrees")
  }
  stars::st_as_stars(x)
}











