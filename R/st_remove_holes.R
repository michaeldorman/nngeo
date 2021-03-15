#' Remove polygon holes
#'
#' The function removes all polygon holes and return the modified layer
#' @param x Object of class \code{sf}, \code{sfc} or \code{sfg}, of type \code{"POLYGON"} or \code{"MULTIPOLYGON"}
#' @param max_area Maximum area of holes to be removed (\code{numeric} or \code{units}) in the units
#'  of \code{x}). Default value (\code{0}) causes removing all holes.
#' @return Object of same class as \code{x}, with holes removed
#' @references Following the StackOverflow answer by user \code{lbusett}:
#'
#' \url{https://stackoverflow.com/questions/52654701/removing-holes-from-polygons-in-r-sf}
#' @note
#'
#' See function \code{sfheaders::st_remove_holes} for highly-optimized faster alternative:
#'
#' \url{https://github.com/dcooley/sfheaders}
#'
#' @export
#'
#' @examples
#' opar = par(mfrow = c(1, 2))
#'
#' # Example with 'sfg' - POLYGON
#' p1 = rbind(c(0,0), c(1,0), c(3,2), c(2,4), c(1,4), c(0,0))
#' p2 = rbind(c(1,1), c(1,2), c(2,2), c(1,1))
#' pol = st_polygon(list(p1, p2))
#' pol
#' result = st_remove_holes(pol)
#' result
#' plot(pol, col = "#FF000033", main = "Before")
#' plot(result, col = "#FF000033", main = "After")
#'
#' # Example with 'sfg' - MULTIPOLYGON
#' p3 = rbind(c(3,0), c(4,0), c(4,1), c(3,1), c(3,0))
#' p4 = rbind(c(3.3,0.3), c(3.8,0.3), c(3.8,0.8), c(3.3,0.8), c(3.3,0.3))[5:1,]
#' p5 = rbind(c(3,3), c(4,2), c(4,3), c(3,3))
#' mpol = st_multipolygon(list(list(p1,p2), list(p3,p4), list(p5)))
#' mpol
#' result = st_remove_holes(mpol)
#' result
#' plot(mpol, col = "#FF000033", main = "Before")
#' plot(result, col = "#FF000033", main = "After")
#'
#' # Example with 'sfc' - POLYGON
#' x = st_sfc(pol, pol * 0.75 + c(3.5, 2))
#' x
#' result = st_remove_holes(x)
#' result
#' plot(x, col = "#FF000033", main = "Before")
#' plot(result, col = "#FF000033", main = "After")
#'
#' # Example with 'sfc' - MULTIPOLYGON
#' x = st_sfc(pol, mpol * 0.75 + c(3.5, 2))
#' x
#' result = st_remove_holes(x)
#' result
#' plot(x, col = "#FF000033", main = "Before")
#' plot(result, col = "#FF000033", main = "After")
#'
#' par(opar)
#'
#' # Example with 'sf'
#' x = st_sfc(pol, mpol * 0.75 + c(3.5, 2))
#' x = st_sf(geom = x, data.frame(id = 1:length(x)))
#' result = st_remove_holes(x)
#' result
#' plot(x, main = "Before")
#' plot(result, main = "After")
#' 
#' # Example with 'sf' using argument 'max_area'
#' x = st_sfc(pol, mpol * 0.75 + c(3.5, 2))
#' x = st_sf(geom = x, data.frame(id = 1:length(x)))
#' result = st_remove_holes(x, max_area = 0.4)
#' result
#' plot(x, main = "Before")
#' plot(result, main = "After")

st_remove_holes = function(x, max_area = 0) {

  # Checks
  stopifnot(all(st_is(x, "POLYGON") | st_is(x, "MULTIPOLYGON")))

  # Metadata
  geometry_is_polygon = all(st_is(x, "POLYGON"))
  type_is_sfg = any(class(x) == "sfg")
  type_is_sf = any(class(x) == "sf")

  # Split to 'sfc' + data
  geom = st_geometry(x)
  if(type_is_sf) dat = st_set_geometry(x, NULL)

  # Remove holes
  for(i in 1:length(geom)) {
    if(st_is(geom[i], "POLYGON")) {
      if(length(geom[i][[1]]) > 1){
        if (max_area > 0) {
          holes = lapply(geom[i][[1]], function(x) {st_polygon(list(x))})[-1]
          areas = c(Inf,sapply(holes, st_area))
          geom[i] = st_polygon(geom[i][[1]][which(areas > max_area)])
        } else {
          geom[i] = st_polygon(geom[i][[1]][1])
        }
      }
    }
    if(st_is(geom[i], "MULTIPOLYGON")) {
      tmp = st_cast(geom[i], "POLYGON")
      for(j in 1:length(tmp)) {
        if(length(tmp[j][[1]]) > 1){
          if (max_area > 0) {
            holes = lapply(tmp[j][[1]], function(x) {st_polygon(list(x))})[-1]
            areas = c(Inf,sapply(holes, st_area))
            tmp[j] = st_polygon(tmp[j][[1]][which(areas > max_area)])
          } else {
            tmp[j] = st_polygon(tmp[j][[1]][1])
          }
        }
      }
      geom[i] = st_combine(tmp)
    }
  }

  # To POLYGON
  if(geometry_is_polygon) geom = st_cast(geom, "POLYGON")

  # To 'sfg'
  if(type_is_sfg) geom = geom[[1]]

  # To 'sf'
  if(type_is_sf) geom = st_sf(dat, geom)

  # Return result
  return(geom)

}










