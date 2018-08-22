test_that("copy_plugins_configs", {
  destdir = tempdir()
  x <- copy_plugins(destdir)
  expect_that(all(x), equals(TRUE))
  x <- copy_configs(destdir)
  expect_that(all(x), equals(TRUE))
})
