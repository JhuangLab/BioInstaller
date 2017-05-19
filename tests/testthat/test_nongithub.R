test_that("install.nongithub", {
  destdir <- sprintf('%s/blat', tempdir())
  x <- install.nongithub('blat', destdir = destdir, verbose = F)
  expect_that(x, equals(TRUE))
  expect_that(is.list(get.info('blat')), equals(TRUE))
  unlink(destdir, recursive = T)
})
