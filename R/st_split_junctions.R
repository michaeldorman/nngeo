#' Split line layer at intersections (junctions)
#'
#' Split \code{sf} line layer at intersections (junctions). For example, this can be a preliminary step before using the line layer in routing applications, where all junctions need to be routable.
#' @param x Object of class \code{sf}
#' @param progress Display progress bar? (default \code{TRUE})
#' @return Normalized \code{sf} line layer
#' @export
#'
#' @examples
#' data(line)
#'
#' # Line layer with single feature
#' line = st_sf(st_union(line))
#'
#' # Line layer split at intersections
#' line1 = st_split_junctions(line)
#'
#' # Plot
#' opar = par(mfrow = c(1, 2))
#' plot(st_geometry(line), col = sample(hcl.colors(nrow(line), "Set 2")), lwd = 5, main = "before")
#' text(st_coordinates(st_centroid(line)), as.character(1:nrow(line)))
#' plot(st_geometry(line1), col = sample(hcl.colors(nrow(line1), "Set 2")), lwd = 5, main = "after")
#' text(st_coordinates(st_centroid(line1)), as.character(1:nrow(line1)))
#' par(opar)

st_split_junctions = function(x, progress = TRUE) {

  # To 'LINESTRING'
  x = st_cast(x, "LINESTRING")

  # Count features
  x_features = length(st_geometry(x))

  # Object to collect normalized features
  result = NULL

  # Progress bar
  if(progress) pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)

  # Split lines at intersections
  for(i in 1:nrow(x)) {

    # Progress
    if(progress) utils::setTxtProgressBar(pb, i)

    # Current line vs. the rest
    current = x[i, ]
    rest = x[-i, ]
    rest = rest[current, ]

    # Union
    rest = st_union(rest)

    # Get intersections
    rest = st_intersection(rest, current)

    # Split
    if(length(rest) > 0) {

      # Cast intersections to points
      rest = st_cast(rest)
      rest = st_cast(rest, "MULTIPOINT")
      rest = st_cast(rest, "POINT")

      # Split by "rest"
      current = lwgeom::st_split(current, rest)

      # Separate lines
      current = st_cast(current, warn = FALSE)

    }

    # Collect
    result[[i]] = current

  }

  # Progress
  if(progress) cat("\n")

  # Combine results
  result = do.call(rbind, result)


  # Return result
  return(result)

}










