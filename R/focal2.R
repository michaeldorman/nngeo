#' Apply a 3x3 focal filter on a raster
#'
#' Applies a 3x3 focal filter on a raster (class \code{stars}).
#'
#' @param	r	A raster (class \code{stars}) with two dimensions: \code{x} and \code{y}, i.e., a single-band raster
#' @param fun A function to be applied on each 3x3 neighborhood. The function needs to accepts a vector of length 9 and return a vector of length 1
#' @param ... Further arguments passed to \code{fun}
#' @return The filtered \code{stars} raster
#'
#' @note The raster is "padded" with one more row/column of \code{NA} values on all sides, so that the neigborhood of the outermost rows and columns is still a complete 3x3 neighborhood. Those rows and columns are removed from the filtered result before returning it.
#'
#' This function provides a subset of the functionality that \code{focal} (package \code{raster}) has.
#'
#' @examples
#' library(stars)
#' dem1 = focal2(dem, mean, na.rm = TRUE)
#' dem2 = focal2(dem, min, na.rm = TRUE)
#' dem3 = focal2(dem, max, na.rm = TRUE)
#' r = c(dem, round(dem1, 1), dem2, dem3, along = 3)
#' r = st_set_dimensions(r, 3, values = c("input", "mean", "min", "max"))
#' plot(r, text_values = TRUE, breaks = "equal", col = terrain.colors(10))
#'
#' @export

# Apply focal filter
focal2 = function(r, fun, ...) {
  template = r
  input = template[[1]]
  input = matrix(NA, nrow = nrow(input)+2, ncol = ncol(input)+2)
  input[2:(nrow(input)-1), 2:(ncol(input)-1)] = template[[1]]
  output = matrix(NA, nrow = nrow(input), ncol = ncol(input))
  for(i in 2:(nrow(input) - 1)) {
    for(j in 2:(ncol(input) - 1)) {
      v = get_neighbors(input, c(i, j))
      output[i, j] = fun(v, ...)
    }
  }
  template[[1]] = output[2:(nrow(output)-1), 2:(ncol(output)-1)]
  return(template)
}

# Helper function to get 3x3 neighborhood as vector (by rows), given a matrix, row and column
get_neighbors = function(m, pos) {
  i = (pos[1]-1):(pos[1]+1)
  j = (pos[2]-1):(pos[2]+1)
  as.vector(t(m[i, j]))
}







