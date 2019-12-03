.st_nn_poly = function(x, y, k, maxdist, progress) {

  x_features = length(x)
  y_features = length(y)
  maxdist = units::set_units(maxdist, "m")

  ids = matrix(NA, nrow = x_features, ncol = k)
  dists = matrix(NA, nrow = x_features, ncol = k)

  # Progress bar
  if(progress) pb = utils::txtProgressBar(min = 0, max = x_features, initial = 0, style = 3)

  for(i in 1:x_features) {

    # Calculate distances
    dists1 = sf::st_distance(x[i], y)[1, ]

    # Select nearest
    ids1 = order(dists1)[1:k]
    dists1 = dists1[ids1]
    dists1 = units::set_units(dists1, "m")
    ids1[dists1 > maxdist] = NA
    dists1[dists1 > maxdist] = NA
    ids[i, ] = ids1
    dists[i, ] = dists1

    # Progress
    if(progress) utils::setTxtProgressBar(pb, i)

  }

  # Progress bar
  if(progress) cat("\n")

  # From n*k 'matrix' to sparse 'list'
  ids = split(ids, 1:nrow(ids))
  ids = lapply(ids, function(x) c(x[!is.na(x)]))
  names(ids) = NULL
  dists = split(dists, 1:nrow(dists))
  dists = lapply(dists, function(x) c(x[!is.na(x)]))
  names(dists) = NULL

  # Return sparse lists
  return(list(ids, dists))

}
