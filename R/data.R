#' Point layer of towns in Israel
#'
#' A \code{sf} POINT layer of towns in Israel, based on a subset from the \code{maps::world.cities} dataset.
#'
#' @format A \code{sf} POINT layer with 193 features and 4 attributes:
#' \describe{
#'   \item{name}{Town name}
#'   \item{country.etc}{Country name}
#'   \item{pop}{Population size}
#'   \item{capital}{Is it a capital?}
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

#' Sample network dataset: lines
#'
#' An \code{sf} object based on the \code{edge_table} sample dataset from pgRouting 2.6 tutorial
#'
#' @format An \code{sf} object
#' @references
#' \url{https://docs.pgrouting.org/2.6/en/sampledata.html}

"line"

#' Sample network dataset: points
#'
#' An \code{sf} object based on the \code{pointsOfInterest} sample dataset from pgRouting 2.6 tutorial
#'
#' @format An \code{sf} object
#' @references
#' \url{https://docs.pgrouting.org/2.6/en/sampledata.html}

"pnt"





