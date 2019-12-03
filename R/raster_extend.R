#' Wrapper for \code{raster::extend} on \code{stars} objects
#'
#' This is a wrapper around \code{raster::extend}, to apply the function on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @param	y An \code{sf} object from which an extent can be extracted, or any other object accepted by \code{raster::extend}
#' @return	An extended \code{stars} object
#'
#' @examples
#' library(stars)
#' data(dem)
#' e = st_as_sf(dem)
#' e = st_union(e)
#' e = st_buffer(e, 1000)
#' dem_extend = raster_extend(dem, st_sf(e))
#' dem_extend[is.na(dem_extend)] = -1
#' plot(dem)
#' plot(dem_extend)
#'
#' @export

raster_extend = function(x, y) {
  x = as(x, "Raster")
  x = raster::extend(x = x, y = y)
  stars::st_as_stars(x)
}










