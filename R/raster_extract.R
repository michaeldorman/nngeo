#' Wrapper for \code{raster::extract} on \code{stars} objects
#'
#' This is a wrapper around \code{raster::extract}, to apply the function on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @param y An \code{sf} object
#' @param fun A function to summarize raster values, default is \code{NULL}
#' @param na.rm If \code{TRUE}, \code{NA} will be removed before passing raster cells to function. Default is \code{FALSE}
#' @return	A vector, \code{matrix}, or \code{list}
#'
#' @examples
#' library(stars)
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' r = read_stars(tif)
#' pol = st_sfc(st_buffer(st_point(c(293749.5, 9115745)), 400), crs = st_crs(r))
#' plot(r[,,,1], reset = FALSE)
#' plot(pol, add = TRUE, border = "red")
#' raster_extract(r, pol)
#' raster_extract(r, pol, fun = mean)
#'
#' @export

raster_extract = function(x, y, fun = NULL, na.rm = FALSE) {
  x = as(x, "Raster")
  y = as(y, "Spatial")
  raster::extract(x = x, y = y, fun = fun, na.rm = na.rm)
}










