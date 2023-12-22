.st_nn_pnt_proj = function(x, y, k, maxdist) {

  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)

  if(maxdist == Inf) {
    nn = nabor::knn(
      query = x_coord,
      data = y_coord,
      k = k
      )
  } else {
    nn = nabor::knn(
      query = x_coord,
      data = y_coord,
      k = k,
      radius = maxdist
    )
  }

  # Extract ids and indices
  ids = nn$nn.idx
  ids[ids == 0] = NA
  dists = nn$nn.dists
  dists[is.na(ids)] = NA

  # From n*k 'matrix' to sparse 'list'
  ids = split(ids, 1:nrow(ids))
  ids = lapply(ids, function(x) c(x[!is.na(x)]))
  names(ids) = NULL
  dists = split(dists, 1:nrow(dists))
  dists = lapply(dists, function(x) c(x[!is.na(x)]))
  crs_units = st_crs(x)$ud_unit

  # Convert to meters
  if(!is.null(crs_units) && !is.na(crs_units)) {
    dists = lapply(dists, units::set_units, "m", mode = "standard")
    dists = lapply(dists, as.numeric)
  }

  # Remove names
  names(dists) = NULL

  # Return sparse lists
  return(list(ids, dists))

}
