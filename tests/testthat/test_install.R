db <- sprintf('%s/.BioInstaller', tempdir())
set.biosoftwares.db(db)

test_that("install.github", {
  destdir <- sprintf('%s/github_demo', tempdir())
  x <- install.github(name = "github_demo", destdir = destdir, 
                      download.dir = destdir, verbose = F)
  expect_that(x, equals(TRUE))
  x <- suppressWarnings(install.github(show.all.versions = T, verbose = F))
  expect_that(x, equals(FALSE))
  x <- install.github(name = "bwa", show.all.versions = T, verbose = F)
  expect_that(is.character(x), equals(TRUE))
  x <- tryCatch(install.github(name = list(), show.all.versions = T, verbose = F), error = function(e) {return(FALSE)})
  expect_that(is.character(x), equals(FALSE))
  unlink(destdir, recursive = T)
  x <- install.github(name = "github_demo", destdir = destdir, 
                      download.dir = destdir, verbose = F, download.only = TRUE)
  expect_that(x, equals(TRUE))
  unlink(destdir, recursive = T)
})

test_that("install.nongithub", {
  destdir <- sprintf('%s/demo', tempdir())
  x <- install.nongithub('demo', destdir = destdir, verbose = F)
  expect_that(x, equals(TRUE))
  expect_that(is.list(get.info('demo')), equals(TRUE))
  unlink(destdir, recursive = T)
  x <- install.nongithub('demo', destdir = destdir, verbose = F, download.only = T)
  expect_that(as.logical(x), equals(TRUE))
  unlink(destdir, recursive = T)
})

test_that("install.bioinfo", {
  oldwd <- getwd()
  destdir <- sprintf('%s/demo', tempdir())
  x <- install.bioinfo('demo', destdir = destdir, verbose = F)
  expect_that("demo" %in% x$success.list, equals(TRUE))
  expect_that(is.list(get.info('demo')), equals(TRUE))
  unlink(destdir, recursive = T)

  destdir <- sprintf('%s/github_demo', tempdir())
  x <- install.bioinfo(name = "github_demo", destdir = sprintf("%s/github_demo", tempdir()), 
                      download.dir = sprintf("%s/github_demo", tempdir()), verbose = F)
  expect_that("github_demo" %in% x$success.list, equals(TRUE))
  unlink(destdir, recursive = T)
})

unlink(db)
