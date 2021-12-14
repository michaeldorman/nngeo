# Based on 'sf:::udunits_from_proj'
udunits_from_proj = list(
	`km` =     units::as_units("km"),
	`m` =      units::as_units("m"),
	`dm` =     units::as_units("dm"),
	`cm` =     units::as_units("cm"),
	`mm` =     units::as_units("mm"),
	`kmi` =    units::as_units("nautical_mile"),
	`in` =     units::as_units("in"),
	`ft` =     units::as_units("ft"),
	`yd` =     units::as_units("yd"),
	`mi` =     units::as_units("mi"),
	`fath` =   units::as_units("fathom"),
	`ch` =     units::as_units("chain"),
	`link` =   units::as_units("link", check_is_valid = FALSE), 
  `us-in` =  units::as_units("us_in", check_is_valid = FALSE),
	`us-ft` =  units::as_units("US_survey_foot"),
	`us-yd` =  units::as_units("US_survey_yard"),
	`us-ch` =  units::as_units("chain"),
	`us-mi` =  units::as_units("US_survey_mile"),
	`ind-yd` = units::as_units("ind_yd", check_is_valid = FALSE),
	`ind-ft` = units::as_units("ind_ft", check_is_valid = FALSE),
	`ind-ch` = units::as_units("ind_ch", check_is_valid = FALSE)
)

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
  crs_units = st_crs(x)$units

  # Convert to meters
  if(!is.na(crs_units) & crs_units != "m") {
    dists = lapply(dists, units::set_units, udunits_from_proj[[st_crs(x)$units]], mode = "standard")
    dists = lapply(dists, units::set_units, "m", mode = "standard")
    dists = lapply(dists, as.numeric)
  }

  # Remove names
  names(dists) = NULL

  # Return sparse lists
  return(list(ids, dists))

}
