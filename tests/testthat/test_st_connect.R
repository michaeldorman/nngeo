library(nngeo)

context("st_connect")

test_that("'st_connect' points", {

  city_geoms = st_geometry(cities)
  town_geoms = st_geometry(towns)

  lines = st_connect(cities, towns, k = 2)

  expect_equivalent(
    lines,
    structure(
      list(
        structure(
          c(35.21371, 35.22, 31.768319, 31.78),
          .Dim = c(2L,
                   2L),
          class = c("XY", "LINESTRING", "sfg")
        ),
        structure(
          c(35.21371,
            35.15, 31.768319, 31.8),
          .Dim = c(2L, 2L),
          class = c("XY", "LINESTRING",
                    "sfg")
        ),
        structure(
          c(34.7817676, 34.8, 32.0852999, 32.08),
          .Dim = c(2L,
                   2L),
          class = c("XY", "LINESTRING", "sfg")
        ),
        structure(
          c(34.7817676,
            34.77, 32.0852999, 32.07),
          .Dim = c(2L, 2L),
          class = c("XY",
                    "LINESTRING", "sfg")
        ),
        structure(
          c(34.989571, 34.99, 32.7940463,
            32.82),
          .Dim = c(2L, 2L),
          class = c("XY", "LINESTRING", "sfg")
        ),
        structure(
          c(34.989571, 34.99, 32.7940463, 32.75),
          .Dim = c(2L,
                   2L),
          class = c("XY", "LINESTRING", "sfg")
        )
      ),
      n_empty = 0L,
      precision = 0,
      crs = structure(
        list(epsg = 4326L, proj4string = "+proj=longlat +datum=WGS84 +no_defs"),
        class = "crs"
      ),
      class = c("sfc_LINESTRING",
                "sfc"),
      bbox = structure(c(
        xmin = 34.77,
        ymin = 31.768319,
        xmax = 35.22,
        ymax = 32.82
      ), class = "bbox")
    )
  )

})
