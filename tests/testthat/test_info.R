if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
db <- sprintf('%s/.BioInstaller', tempdir())
unlink(db)
set.biosoftwares.db(db)
test_that("info", {
 x <- change.info(name = "demo", installed = "yes", debug = TRUE, verbose = F)
 expect_that(x, equals(TRUE))
 x <- get.info(name = "demo")
 expect_that(is.list(x), equals(TRUE))
 x <- del.info(name = "demo")
 expect_that(x, equals(TRUE))
 x <- NULL
 x <- tryCatch({
   get.info(name = "demo")
 }, warning = function(w){
   x <- FALSE
   return(x)
 })
 expect_that(x, equals(FALSE))
 x <- change.info(name = "demo", installed = "yes", debug = TRUE, verbose = F)
 x <- change.info(name = "demo1", installed = "no", debug = TRUE, verbose = F)
 x <- show.installed()
 expect_that(as.character(x), equals('demo'))
})

temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)
