context("knn")

set.seed(42)
d=matrix(rnorm(100*3), ncol=3)
q=matrix(rnorm(100*3), ncol=3)

test_that('knn gives appropriate result structure',{
  expect_is(r<-knn(d, d, k=5), 'list')
  expect_is(r$nn.idx, 'matrix')
  expect_equal(dim(r$nn.idx), c(nrow(d), 5))
  expect_equal(dim(r$nn.dists), c(nrow(d), 5))
  expect_is(r$nn.dists, 'matrix')
  
  expect_is(r2<-knn(d, q, k=5), 'list')
  expect_equal(dim(r$nn.idx), c(nrow(q), 5))
  expect_equal(dim(r$nn.dists), c(nrow(q), 5))
})

test_that('different knn search types agree',{
  expect_equal(knn(d, q, k=5), knn(d, q, k=5, searchtype='brute'))
  expect_equal(knn(d, q, k=5), knn(d, q, k=5, searchtype='kd_tree_heap'))
})


test_that('knn and RANN:nn2 agree',{
  if(require('RANN')){
    expect_equal(knn(d, q, k=5), nn2(data=d, query=q, k=5))
    expect_equal(knn(d, k=5), nn2(data=d, k=5))
  }
})


test_that("knn with different input types",{
  m=matrix(rnorm(200), ncol = 2)
  df=data.frame(m)
  expect_equal(knn(df, df, k=1), nn2(m, m, k=1))
  # matrix vs vector input for 1d case
  expect_equal(knn(m[,1, drop=FALSE], m[,2, drop=FALSE], k=1), knn(m[,1], m[,2], k=1))
  
  # integer data and query
  expect_is(knn(matrix(1:24,ncol=3), matrix(1:6,ncol=3), k=1), "list")
  # numeric data and integer query
  expect_is(knn(matrix(as.numeric(1:24),ncol=3), matrix(1:6, ncol=3), k=1), "list")
})

test_that("nn2 with bad data", {
  m=matrix(NA_real_, ncol=2, nrow=3)
  expect_is(knn(m, m, k=1), 'list')
})
