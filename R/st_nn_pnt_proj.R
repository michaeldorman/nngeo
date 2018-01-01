.st_nn_pnt_proj = function(x, y, k, maxdist) {

  x_coord = sf::st_coordinates(x)
  y_coord = sf::st_coordinates(y)

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

  ids = nn$nn.idx
  ids[ids == 0] = NA
  dist_matrix = nn$nn.dists
  dist_matrix[is.na(ids)] = NA

  return(list(ids, dist_matrix))

}
