#' Wrapper for \code{raster::focal} on \code{stars} objects
#'
#' This is a wrapper around \code{raster::focal}, to apply the function on \code{stars} objects without needing to convert to and from a \code{Raster*} object.
#'
#' @param	x A \code{stars} object
#' @param w A matrix of weights (the moving window), e.g. a 3 by 3 matrix with values 1
#' @param fun A function. The function fun should take multiple numbers, and return a single number
#' @param na.rm If \code{TRUE}, \code{NA} will be removed from focal computation. Default is \code{FALSE}
#' @return	A \code{stars} object with the filtered output
#'
#' @examples
#' library(stars)
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' r = read_stars(tif)
#' r = r[, , , 1:2]
#' w = matrix(1, ncol = 7, nrow = 7)
#' r_focalmean7 = raster_focal(r, w, mean)
#' plot(r)
#' plot(r_focalmean7)
#'
#' @export

raster_focal = function(x, w, fun, na.rm = FALSE) {
  x = as(x, "Raster")
  x = raster::stack(x)
  n = raster::nlayers(x)
  for(i in 1:n) {
    x[[i]] = raster::focal(x = x[[i]], w = w, fun = fun, na.rm = na.rm)
  }
  stars::st_as_stars(x)
}










