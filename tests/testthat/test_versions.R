if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("nongithub.versions",{ 
  x <- tryCatch(nongithub2versions("gmap"), error = function(e) {
    message("Connecting Gmap website failed. Please try it later.")
    NULL
  })
  if (!is.null(x)) expect_that(length(x) > 1, equals(TRUE)) else {
    expect_that(x, equals(NULL))
  }
})
temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)
