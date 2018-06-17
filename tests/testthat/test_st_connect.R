library(nngeo)

context("st_connect")

test_that("'st_connect' points", {

  city_geoms <- st_geometry(cities)
  town_geoms <- st_geometry(towns)

  lines <- st_connect(cities, towns, k = 2)

  expect_equivalent(
    lines,
    c(
      st_cast(
        st_combine(
          c(
            city_geoms[1],
            town_geoms[29]
          )
        ),
        "LINESTRING"
      ),
      st_cast(
        st_combine(
          c(
            city_geoms[1],
            town_geoms[40]
          )
        ),
        "LINESTRING"
      ),
      st_cast(
        st_combine(
          c(
            city_geoms[2],
            town_geoms[18]
          )
        ),
        "LINESTRING"
      ),
      st_cast(
        st_combine(
          c(
            city_geoms[2],
            town_geoms[19]
          )
        ),
        "LINESTRING"
      ),
      st_cast(
        st_combine(
          c(
            city_geoms[3],
            town_geoms[69]
          )
        ),
        "LINESTRING"
      ),
      st_cast(
        st_combine(
          c(
            city_geoms[3],
            town_geoms[80]
          )
        ),
        "LINESTRING"
      )
    )
  )

})
