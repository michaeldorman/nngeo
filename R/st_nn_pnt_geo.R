.st_nn_pnt_geo = function(x, y, k, maxdist, progress) {

  x_features = length(sf::st_geometry(x))
  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)
  maxdist = units::set_units(maxdist, "m")
  maxdist = as.numeric(maxdist)

  # result = getIdsDists(x_coord, y_coord, k, maxdist)
  # ids = result[[1]]
  # dist_matrix = result[[2]]

  ids = matrix(NA, nrow = x_features, ncol = k)
  dist_matrix = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  if(progress) {
    pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)
  }

  for(i in 1:x_features) {

    dists = getDistancesN(x_coord[i, ], y_coord)
    ids1 = order(dists)[1:k]
    ids[i, ] = ids1
    dist_matrix[i, ] = dists[ids1]

    # Progress
    if(progress) {
      utils::setTxtProgressBar(pb, i)
    }

  }

  ids[dist_matrix > maxdist] = NA
  dist_matrix[is.na(ids)] = NA

  if(progress) {
    cat("\n")
  }
  return(list(ids, dist_matrix))

}

