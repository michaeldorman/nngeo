.st_nn_pnt_geo = function(x, y, k, maxdist) {

  x_features = length(sf::st_geometry(x))
  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)
  maxdist = units::set_units(maxdist, "m")
  maxdist = as.numeric(maxdist)

  ids = matrix(NA, nrow = x_features, ncol = k)
  dist_matrix = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)

  for(i in 1:x_features) {

    # dists = sf::st_distance(x[i, ], y)[1, ]
    dists = mapply(
      getDistance,
        x_coord[i, 1],
        x_coord[i, 2],
        y_coord[, 1],
        y_coord[, 2]
      )
    ids1 = order(dists)[1:k]
    dists1 = dists[ids1]
    # dists1 = units::set_units(dists1, "m")
    ids1[dists1 > maxdist] = NA
    dists1[dists1 > maxdist] = NA
    ids[i, ] = ids1
    dist_matrix[i, ] = dists1

    # Progress
    utils::setTxtProgressBar(pb, i)

  }

  return(list(ids, dist_matrix))

}

