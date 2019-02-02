#' Split polygons or lines to segments
#'
#' Split lines or polygons to separate segments.
#'
#' @param	x	An object of class \code{sfg}, \code{sfc} or \code{sf}, with geometry type \code{LINESTRING}, \code{MULTILINESTRING}, \code{POLYGON} or \code{MULTIPOLYGON}
#' @return	An \code{sf} layer of type \code{LINESTRING} where each segment is represented by a separate feature
#'
#' @examples
#'
#' # Sample geometries
#' s1 = rbind(c(0,3),c(0,4),c(1,5),c(2,5))
#' ls = st_linestring(s1)
#' s2 = rbind(c(0.2,3), c(0.2,4), c(1,4.8), c(2,4.8))
#' s3 = rbind(c(0,4.4), c(0.6,5))
#' mls = st_multilinestring(list(s1,s2,s3))
#' p1 = rbind(c(0,0), c(1,0), c(3,2), c(2,4), c(1,4), c(0,0))
#' p2 = rbind(c(1,1), c(1,2), c(2,2), c(1,1))
#' pol = st_polygon(list(p1,p2))
#' p3 = rbind(c(3,0), c(4,0), c(4,1), c(3,1), c(3,0))
#' p4 = rbind(c(3.3,0.3), c(3.8,0.3), c(3.8,0.8), c(3.3,0.8), c(3.3,0.3))[5:1,]
#' p5 = rbind(c(3,3), c(4,2), c(4,3), c(3,3))
#' mpol = st_multipolygon(list(list(p1,p2), list(p3,p4), list(p5)))
#'
#' # Geometries ('sfg')
#' opar = par(mfrow = c(1, 2))
#'
#' plot(ls)
#' seg = st_segments(ls)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' plot(mls)
#' seg = st_segments(mls)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' plot(pol)
#' seg = st_segments(pol)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' plot(mpol)
#' seg = st_segments(mpol)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' par(opar)
#'
#' # Columns ('sfc')
#' opar = par(mfrow = c(1, 2))
#'
#' ls = st_sfc(ls)
#' plot(ls)
#' seg = st_segments(ls)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' ls2 = st_sfc(c(ls, ls + c(1, -1), ls + c(-3, -1)))
#' plot(ls2)
#' seg = st_segments(ls2)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' mls = st_sfc(mls)
#' plot(mls)
#' seg = st_segments(mls)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' mls2 = st_sfc(c(mls, mls + c(1, -2)))
#' plot(mls2)
#' seg = st_segments(mls2)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' pol = st_sfc(pol)
#' plot(pol)
#' seg = st_segments(pol)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' mpol = st_sfc(mpol)
#' plot(mpol)
#' seg = st_segments(mpol)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' mpol2 = st_sfc(c(mpol, mpol + c(5, 2)))
#' plot(mpol2)
#' seg = st_segments(mpol2)
#' plot(seg, col = rainbow(length(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:length(seg)))
#'
#' par(opar)
#'
#' # Layers ('sf')
#' opar = par(mfrow = c(1, 2))
#'
#' mpol_sf = st_sf(id = 1:2, type = c("a", "b"), geom = st_sfc(c(mpol, mpol + c(5, 2))))
#' plot(st_geometry(mpol_sf))
#' seg = st_segments(mpol_sf)
#' plot(st_geometry(seg), col = rainbow(nrow(seg)))
#' text(st_coordinates(st_centroid(seg)), as.character(1:nrow(seg)))
#'
#' par(opar)
#'
#' @export

st_segments = function(x) {

  # Get or transform to geometry
  geom = st_geometry(x)

  # Get attributes
  if(class(x)[1] == "sf") dat = st_set_geometry(x, NULL) else dat = NULL

  # For each feature...
  final = list()
  for(i in 1:length(geom)) {

    # Current geometry
    geom1 = geom[i]

    # Cast LINESTRING
    if(st_is(geom1, "MULTIPOLYGON")) geom1 = st_cast(geom1, "POLYGON")
    line = st_cast(geom1, "LINESTRING")

    result = list()
    # For each LINESTRING...
    for(j in 1:length(line)) {

      # Split to segments
      pnt = st_cast(line[j], "POINT")

      # For each segment...
      tmp = list()
      for(k in 1:(length(pnt)-1)) {
        tmp[[k]] = pnt[c(k, k+1)]
      }
      tmp = lapply(tmp, st_combine)
      tmp = lapply(tmp, st_cast, "LINESTRING")
      tmp = do.call(c, tmp)
      result[[j]] = tmp

    }

    # Combine
    result = do.call(c, result)

    # Add attributes
    if(!is.null(dat)) result = st_sf(result, dat[i, , drop = FALSE])

    # Add to 'final'
    final[[i]] = result

  }

  # Combine
  if(!is.null(dat)) final = do.call(rbind, final) else final = do.call(c, final)

  # Return result
  return(final)

}










