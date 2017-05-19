test_that("is.biosoftwares.db.active",{ 
  db <- sprintf('%s/test', tempdir())
  x <- is.biosoftwares.db.active(db)
  expect_that(x, equals(FALSE))
  set.biosoftwares.db(db)
  x <- is.biosoftwares.db.active(db)
  expect_that(x, equals(TRUE))
})
