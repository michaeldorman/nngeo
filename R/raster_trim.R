#' Wrapper for \code{raster::trim} on \code{stars} objects
#'
#' This is a wrapper around \code{raster::trim}, to apply the function on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @return	A \code{stars} object with the trimmed result
#'
#' @examples
#' library(stars)
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' r = read_stars(tif)
#' r[[1]][1:50, , 1:6] = NA
#' r[[1]][, 1:100, 1:6] = NA
#' plot(r)
#' r = raster_trim(r)
#' plot(r)
#'
#' @export

raster_trim = function(x) {
  x = as(x, "Raster")
  x = raster::trim(x)
  stars::st_as_stars(x)
}










