.st_nn_pnt_geo = function(x, y, k, maxdist, progress) {

  x_features = length(sf::st_geometry(x))
  y_features = length(sf::st_geometry(y))
  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)
  maxdist = units::set_units(maxdist, "m")
  maxdist = as.numeric(maxdist)

  ids = matrix(NA, nrow = x_features, ncol = k)
  dist_matrix = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  if(progress) {
    pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)
  }

  for(i in 1:x_features) {

    dists = rep(NA, y_features)

    for(j in 1:y_features) {

      dists[j] = .Call(addr_dist_one, c(x_coord[i, ], y_coord[j, ]))

    }

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

