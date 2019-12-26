.st_nn_pnt_proj = function(x, y, k, maxdist, progress) {

  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)

  # Progress bar
  if(progress) pb = utils::txtProgressBar(min = 0, max = 1, initial = 0, style = 3)

  if(maxdist == Inf) {
    nn = RANN::nn2(
      query = x_coord,
      data = y_coord,
      k = k
      )
  } else {
    nn = RANN::nn2(
      query = x_coord,
      data = y_coord,
      k = k,
      searchtype = "radius",
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
  crs_units = st_crs(x)$units
  dists = lapply(dists, units::set_units, crs_units, mode = "standard")
  dists = lapply(dists, units::set_units, "m", mode = "standard")
  dists = lapply(dists, as.numeric)
  names(dists) = NULL

  # Progress
  if(progress) utils::setTxtProgressBar(pb, 1)
  if(progress) cat("\n")

  # Return sparse lists
  return(list(ids, dists))

}
