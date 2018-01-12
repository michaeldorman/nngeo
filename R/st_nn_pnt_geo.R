.st_nn_pnt_geo = function(x, y, k, maxdist) {

  x_features = length(sf::st_geometry(x))
  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)
  maxdist = units::set_units(maxdist, "m")

  ids = matrix(NA, nrow = x_features, ncol = k)
  dist_matrix = matrix(NA, nrow = x_features, ncol = k)

  for(i in 1:x_features) {
    dists = sf::st_distance(x[i, ], y)[1, ]
    ids1 = order(dists)[1:k]
    dists1 = dists[ids1]
    dists1 = units::set_units(dists1, "m")
    ids1[dists1 > maxdist] = NA
    dists1[dists1 > maxdist] = NA
    ids[i, ] = ids1
    dist_matrix[i, ] = dists1
  }

  return(list(ids, dist_matrix))

}

