#' Send 'sf' layer to a PostGIS query
#'
#' The function sends a query plus an \code{sf} layer to PostGIS, saving the trouble of manually importing the layer and exporting the result
#' @param x Object of class \code{sf}
#' @param con Connection to PostgreSQL database with PostGIS extension enabled. Can be created using function \code{RPostgreSQL::dbConnect}
#' @param query SQL query, which may refer to layer \code{x} as \code{x} and to the geometry column of the \code{x} layer as \code{geom} (see examples)
#' @param prefix Prefix for storage of temporarily layer in the database
#' @return Returned result from the database: an \code{sf} layer in case the result includes a geometry column, otherwise a \code{data.frame}
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Database connection and 'sf' layer
#' source("~/Dropbox/postgis_159.R")  ## Creates connection object 'con'
#' x = towns
#'
#' # Query 1: Buffer
#' query = "SELECT ST_Buffer(geom, 0.1, 'quad_segs=2') AS geom FROM x LIMIT 5;"
#' st_postgis(x, con, query)
#'
#' # Query 2: Extrusion
#' query = "SELECT ST_Extrude(geom, 0, 0, 30) AS geom FROM x LIMIT 5;"
#' st_postgis(x, con, query)
#' }

st_postgis = function(x, con, query, prefix = "temporary_nngeo_layer_") {

  # Rename geometry column to "geom"
  geom_column = attr(x, "sf_column")
  names(x)[names(x) == geom_column] = "geom"
  st_geometry(x) = "geom"

  # Set temporary table name
  x_table = paste0(prefix, "x")

  # Write temporary table to database
  st_write(x, con, x_table, overwrite = TRUE)

  # Execute query
  query = gsub(" x;", paste0(" ", x_table, ";"), query)
  query = gsub(" x ", paste0(" ", x_table, " "), query)
  result = st_read(con, query = query)

  # Remove temporary table
  DBI::dbSendQuery(con, paste0("DROP TABLE ", x_table, ";"))

  # Return result
  return(result)

}










