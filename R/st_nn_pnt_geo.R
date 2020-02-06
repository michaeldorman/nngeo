.st_nn_pnt_geo = function(x, y, k, maxdist, progress) {

  x_features = length(sf::st_geometry(x))
  y_features = length(sf::st_geometry(y))
  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)
  maxdist = units::set_units(maxdist, "m")
  maxdist = as.numeric(maxdist)

  ids = matrix(NA, nrow = x_features, ncol = k)
  dists = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  if(progress) pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)

  for(i in 1:x_features) {

    dists1 = rep(NA, y_features)

    for(j in 1:y_features) {
      dists1[j] = .Call(addr_dist_one, c(x_coord[i, ], y_coord[j, ]))
    }

    ids1 = order(dists1)[1:k]
    ids[i, ] = ids1
    dists[i, ] = dists1[ids1]

    # Progress
    if(progress) utils::setTxtProgressBar(pb, i)

  }

  ids[dists > maxdist] = NA
  dists[is.na(ids)] = NA

  # From n*k 'matrix' to sparse 'list'
  ids = split(ids, 1:nrow(ids))
  ids = lapply(ids, function(x) c(x[!is.na(x)]))
  names(ids) = NULL
  dists = split(dists, 1:nrow(dists))
  dists = lapply(dists, function(x) c(x[!is.na(x)]))
  names(dists) = NULL

  if(progress) cat("\n")

  # Return sparse lists
  return(list(ids, dists))

}

