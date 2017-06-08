if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("is.biosoftwares.db.active",{ 
  db <- sprintf('%s/test', tempdir())
  db <- normalizePath(db, "/", mustWork = FALSE)
  x <- is.biosoftwares.db.active(db)
  expect_that(x, equals(FALSE))
  set.biosoftwares.db(db)
  x <- do.call(is.biosoftwares.db.active, list(db))
  expect_that(x, equals(TRUE))
  unlink(db, recursive = TRUE, TRUE)
})
