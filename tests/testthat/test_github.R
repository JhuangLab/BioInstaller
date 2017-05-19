db <- sprintf('%s/.BioInstaller', tempdir())
set.biosoftwares.db(db)

test_that("install.github", {
  x <- install.github(name = "lofreq", destdir = sprintf("%s/lofreq", tempdir()), 
                      download.dir = sprintf("%s/lofreq", tempdir()), verbose = F)
  expect_that(x, equals(TRUE))
  x <- suppressWarnings(install.github(show.all.versions = T, verbose = F))
  expect_that(x, equals(FALSE))
  x <- install.github(name = "bwa", show.all.versions = T, verbose = F)
  expect_that(is.character(x), equals(TRUE))
  x <- tryCatch(install.github(name = list(), show.all.versions = T, verbose = F), error = function(e) {return(FALSE)})
  expect_that(is.character(x), equals(FALSE))
})
unlink(db)




