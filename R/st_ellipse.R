#' Calculate ellipse polygon
#'
#' The function calculates ellipse polygons, given centroid locations and sizing on the x and y axes.
#' @param pnt Object of class \code{sf} or \code{sfc} (type \code{"POINT"}) representing centroid locations
#' @param ex Size along x-axis, in CRS units
#' @param ey Size along y-axis, in CRS units
#' @param res Number of points the ellipse polygon consists of (default \code{30})
#' @return Object of class \code{sfc} (type \code{"POLYGON"}) containing ellipse polygons
#' @references Based on StackOverflow answer by user 'fdetsch' -
#'
#' \url{https://stackoverflow.com/questions/35841685/add-an-ellipse-on-raster-plot-in-r}
#' @export
#'
#' @examples
#' # Sample data
#' dat = data.frame(
#'   x = c(1, 1, -1, 3, 3),
#'   y = c(0, -3, 2, -2, 0),
#'   ex = c(0.5, 2, 2, 0.3, 0.6),
#'   ey = c(0.5, 0.2, 1, 1, 0.3),
#'   stringsAsFactors = FALSE
#' )
#' dat = st_as_sf(dat, coords = c("x", "y"))
#' dat
#'
#' # Plot 1
#' plot(dat %>% st_geometry, graticule = TRUE, axes = TRUE, main = "Input")
#' text(dat %>% st_coordinates, as.character(1:nrow(dat)), pos = 2)
#'
#' # Calculate ellipses
#' el = st_ellipse(pnt = dat, ex = dat$ex, ey = dat$ey)
#'
#' # Plot 2
#' plot(el, graticule = TRUE, axes = TRUE, main = "Output")
#' plot(dat %>% st_geometry, pch = 3, add = TRUE)
#' text(dat %>% st_coordinates, as.character(1:nrow(dat)), pos = 2)

st_ellipse = function(pnt, ex, ey, res = 30) {

  # Checks
  stopifnot(length(st_geometry(pnt)) == length(ex))
  stopifnot(length(ex) == length(ey))
  stopifnot(class(ex) == "numeric")
  stopifnot(class(ey) == "numeric")
  stopifnot(all(!st_is_empty(pnt)))
  stopifnot(all(!is.na(ex)))
  stopifnot(all(!is.na(ey)))
  stopifnot(class(st_geometry(pnt))[1] == "sfc_POINT")

  # Point coordinates
  coords = st_coordinates(pnt)

  # Create ellipses
  result = list()
  for(i in 1:nrow(coords)) {
    theta = seq(0, 2 * pi, length = res)
    x = coords[i, 1] - ex[i] * cos(theta)
    y = coords[i, 2] - ey[i] * sin(theta)
    elp = cbind(x[!is.na(x)], y[!is.na(y)])
    pnt = st_multipoint(elp)
    pol = st_cast(pnt, "POLYGON")
    result[[i]] = pol
  }

  # Combine
  result = st_sfc(result)

  # Return result
  return(result)

}










