#' Point layer of towns in Israel
#'
#' A \code{sf} POINT layer of all towns in Israel whose name starts with the letter "A".
#'
#' @format A \code{sf} POINT layer with 93 features and 1 attribute:
#' \describe{
#'   \item{name}{Town name}
#' }

"towns"

#' Point layer of the three largest cities in Israel
#'
#' A \code{sf} POINT layer of the three largest cities in Israel: Jerusalem, Tel-Aviv and Haifa.
#'
#' @format A \code{sf} POINT layer with 3 features and 1 attribute:
#' \describe{
#'   \item{name}{Town name}
#' }

"cities"

#' Polygonal layer of water bodies in Israel
#'
#' A \code{sf} POLYGON layer of the four large water bodies in Israel:
#' \itemize{
#' \item{Mediterranean Sea}
#' \item{Red Sea}
#' \item{Sea of Galilee}
#' \item{Dead Sea}
#' }
#'
#' @format A \code{sf} POLYGON layer with 4 features and 1 attribute:
#' \describe{
#'   \item{name}{Water body name}
#' }

"water"

#' Small Digital Elevation Model
#'
#' A \code{stars} object representing a 13*11 Digital Elevation Model (DEM)
#'
#' @format A \code{stars} object with 1 attribute:
#' \describe{
#'   \item{elevation}{Elevation above sea level, in meters}
#' }

"dem"





