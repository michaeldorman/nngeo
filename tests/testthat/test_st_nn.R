library(nngeo)

context("st_nn")

test_that("'st_nn' lon/lat points", {
  expect_equal({
    st_nn(cities, towns, k = 10)
  },
    list(
      c(29L, 40L, 87L, 2L, 49L, 43L, 9L, 11L, 63L, 36L),
      c(18L, 19L, 39L, 32L, 28L, 44L, 25L, 10L, 64L, 46L),
      c(69L, 80L, 61L, 68L, 60L, 58L, 30L, 57L, 89L, 56L)
    )
  )
  }
)
