if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("get.meta",{ 
  x <- get.meta.files()
  expect_that(is.list(x), equals(TRUE))
  expect_that(x[[1]] != "", equals(TRUE))
  expect_that(x[[2]] != "", equals(TRUE))
  expect_that(x[[3]] != "", equals(TRUE))
  expect_that(x[[4]] != "", equals(TRUE))
  x <- get.meta()
  expect_that(is.list(x), equals(TRUE))
  x <- get.meta(config = "db", value = "cfg_meta")
  expect_that(is.list(x), equals(TRUE))
  x <- get.meta(config = "db_meta_file")
  expect_that(is.character(x), equals(TRUE))
})
