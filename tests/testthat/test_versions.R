if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("nongithub.versions",{ 
  x <- nongithub2versions("gmap")
  expect_that(length(x) > 1, equals(TRUE))
})
temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)
