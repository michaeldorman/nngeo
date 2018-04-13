.st_nn_poly = function(x, y, k, maxdist, progress) {

  x_features = length(sf::st_geometry(x))
  maxdist = units::set_units(maxdist, "m")

  ids = matrix(NA, nrow = x_features, ncol = k)
  dist_matrix = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  if(progress) {
    pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)
  }

  for(i in 1:x_features) {

    dists = sf::st_distance(x[i], y)[1, ]
    ids1 = order(dists)[1:k]
    dists1 = dists[ids1]
    dists1 = units::set_units(dists1, "m")
    ids1[dists1 > maxdist] = NA
    dists1[dists1 > maxdist] = NA
    ids[i, ] = ids1
    dist_matrix[i, ] = dists1

    # Progress
    if(progress) {
      utils::setTxtProgressBar(pb, i)
    }

  }

  if(progress) {
    cat("\n")
  }

  return(list(ids, dist_matrix))

}
