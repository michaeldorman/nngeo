context("WKNND")

test_that("constructing WKNN and getting points", {
  data(kcpoints)
  expect_is(w1<-WKNND(kcpoints[[1]]),"WKNND")
  expect_equivalent(w1$getPoints(), kcpoints[[1]])
  w1_notree=WKNND(kcpoints[[1]], FALSE)
})

library(RANN)

test_that("Basic queries", {
  p1=kcpoints[[1]]
  w1<-WKNND(p1)
  p2=kcpoints[[2]]
  expect_equal(w1$query(p2, 1, 0, 0), nn2(p1, p2, k=1))
  w1.notree<-WKNND(p1,FALSE)
  expect_equal(w1.notree$query(p2, 1, 0, 0), w1$query(p2, 1, 0, 0))
  
  # queries with radius limit
  res1=w1$query(p2, 1, 0, 15.0)
  res2=nn2(p1, p2, k=1, radius=15.0, searchtype = 'radius')
  res1f=res1$nn.idx!=0
  res2f=res2$nn.idx!=0
  
  expect_equal(res1f, res2f)
  expect_equal(res1$nn.dists[res1f], res2$nn.dists[res2f])
  expect_equal(res1$nn.idx[res1f], res2$nn.idx[res2f])
})

test_that("Queries using WKNND objects", {
  p1=kcpoints[[1]]
  w1=WKNND(p1)
  p2=kcpoints[[2]]
  w2=WKNND(p2)
  expect_equal(w1$queryWKNN(w2$.CppObject, 1, 0, 0), nn2(p1, p2, k=1))
})

test_that("equivalence of WKNND and knn, nn2 queries", {
  p1=kcpoints[[1]]
  w1=WKNND(p1)
  p2=kcpoints[[2]]
  w2=WKNND(p2)
  knnq12<-knn(p1, p2, k=5)
  knnq11<-knn(p1, p1, k=5)
  knnq22<-knn(p2, p2, k=5)
  knnq21<-knn(p2, p1, k=5)
  
  expect_equal(w1$query(p2, 5, 0, 0), knnq12)
  expect_equal(w1$query(p2, 5, 0, 0), nn2(p1, p2, k=5, eps=0))
  expect_equal(w1$queryWKNN(w2$.CppObject, 5, 0, 0), nn2(p1, p2, k=5, eps=0))
  
  expect_equal(w1$query(p1, 5, 0, 0), knnq11)
  expect_equal(w1$query(p1, 5, 0, 0), nn2(p1, p1, k=5, eps=0))
  expect_equal(w1$queryWKNN(w1$.CppObject, 5, 0, 0), nn2(p1, p1, k=5, eps=0))
  
  expect_equal(w2$query(p2, 5, 0, 0), knnq22)
  expect_equal(w2$query(p2, 5, 0, 0), nn2(p2, p2, k=5, eps=0))
  expect_equal(w2$queryWKNN(w2$.CppObject, 5, 0, 0), nn2(p2, p2, k=5, eps=0))

  expect_equal(w2$query(p1, 5, 0, 0), knnq21)
  expect_equal(w2$query(p1, 5, 0, 0), nn2(p2, p1, k=5, eps=0))
  expect_equal(w2$queryWKNN(w1$.CppObject, 5, 0, 0), nn2(p2, p1, k=5, eps=0))
  
  set.seed(42)
  d=matrix(rnorm(100*3), ncol=3)
  q=matrix(rnorm(100*3), ncol=3)
  wd=WKNND(d)
  wq=WKNND(q)
  expect_equal(wd$query(q, 5, 0, 0), nn2(d, q, k=5))
  expect_equal(wd$query(d, 5, 0, 0), nn2(d, d, k=5))
  expect_equal(wq$query(q, 5, 0, 0), nn2(q, q, k=5))
  expect_equal(wq$query(d, 5, 0, 0), nn2(q, d, k=5))
  
})
