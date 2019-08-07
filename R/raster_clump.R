#' Wrapper for \code{raster::clump} on \code{stars} objects
#'
#' This is a wrapper around \code{raster::clump}, to apply the function on \code{stars} objects without needing to convert to and from a \code{Raster*} object. (The function uses the \code{gaps=FALSE} setting.)
#'
#' @param	x A \code{stars} object
#' @return	A \code{stars} object with the unique IDs for patches of connected cells that are not \code{0} or \code{NA}
#'
#' @examples
#' library(stars)
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' r = read_stars(tif)
#' r = r > 100
#' r_clump = raster_clump(r)
#' plot(r)
#' plot(r_clump)
#'
#' @export

raster_clump = function(x) {
  x = as(x, "Raster")
  x = raster::stack(x)
  n = raster::nlayers(x)
  for(i in 1:n) {
    x[[i]] = raster::clump(x = x[[i]], gaps = FALSE)
  }
  stars::st_as_stars(x)
}










