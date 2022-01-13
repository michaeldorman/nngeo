context("WKNNF")

test_that("constructing WKNNF and getting points", {
  data(kcpoints)
  expect_is(w1<-WKNNF(kcpoints[[1]]),"WKNNF")
  expect_equivalent(w1$getPoints(), kcpoints[[1]])
  w1_notree=WKNNF(kcpoints[[1]], FALSE)
})

library(RANN)

test_that("Basic queries", {
  p1=kcpoints[[1]]
  w1<-WKNNF(p1)
  p2=kcpoints[[2]]
  expect_equal(w1$query(p2, 1, 0, 0), nn2(p1, p2, k=1), tolerance=1e-6)
  w1.notree<-WKNNF(p1,FALSE)
  expect_equal(w1.notree$query(p2, 1, 0, 0), w1$query(p2, 1, 0, 0))
})

test_that("Queries using WKNNF objects", {
  p1=kcpoints[[1]]
  w1=WKNNF(p1)
  p2=kcpoints[[2]]
  w2=WKNNF(p2)
  expect_equal(w1$queryWKNN(w2$.CppObject, 1, 0, 0), nn2(p1, p2, k=1), tolerance=1e-6)
})

test_that("equivalence of WKNNF and knn, nn2 queries", {
  p1=kcpoints[[1]]
  w1=WKNNF(p1)
  p2=kcpoints[[2]]
  w2=WKNNF(p2)
  knnq12<-knn(p1, p2, k=5)
  knnq11<-knn(p1, p1, k=5)
  knnq22<-knn(p2, p2, k=5)
  knnq21<-knn(p2, p1, k=5)
  
  expect_equal(w1$query(p2, 5, 0, 0), knnq12, tolerance=1e-6)
  expect_equal(w1$query(p2, 5, 0, 0), nn2(p1, p2, k=5, eps=0), tolerance=1e-6)
  expect_equal(w1$queryWKNN(w2$.CppObject, 5, 0, 0), nn2(p1, p2, k=5, eps=0), tolerance=1e-6)
  
  expect_equal(w1$query(p1, 5, 0, 0), knnq11, tolerance=1e-6)
  expect_equal(w1$query(p1, 5, 0, 0), nn2(p1, p1, k=5, eps=0), tolerance=1e-6)
  expect_equal(w1$queryWKNN(w1$.CppObject, 5, 0, 0), nn2(p1, p1, k=5, eps=0), tolerance=1e-6)
  
  expect_equal(w2$query(p2, 5, 0, 0), knnq22, tolerance=1e-6)
  expect_equal(w2$query(p2, 5, 0, 0), nn2(p2, p2, k=5, eps=0), tolerance=1e-6)
  expect_equal(w2$queryWKNN(w2$.CppObject, 5, 0, 0), nn2(p2, p2, k=5, eps=0), tolerance=1e-6)

  expect_equal(w2$query(p1, 5, 0, 0), knnq21, tolerance=1e-6)
  expect_equal(w2$query(p1, 5, 0, 0), nn2(p2, p1, k=5, eps=0), tolerance=1e-6)
  expect_equal(w2$queryWKNN(w1$.CppObject, 5, 0, 0), nn2(p2, p1, k=5, eps=0), tolerance=1e-6)
  
  set.seed(42)
  d=matrix(rnorm(100*3), ncol=3)
  q=matrix(rnorm(100*3), ncol=3)
  wd=WKNNF(d)
  wq=WKNNF(q)
  expect_equal(wd$query(q, 5, 0, 0), nn2(d, q, k=5), tolerance=1e-6)
  expect_equal(wd$query(d, 5, 0, 0), nn2(d, d, k=5), tolerance=1e-6)
  expect_equal(wq$query(q, 5, 0, 0), nn2(q, q, k=5), tolerance=1e-6)
  expect_equal(wq$query(d, 5, 0, 0), nn2(q, d, k=5), tolerance=1e-6)
  
})
