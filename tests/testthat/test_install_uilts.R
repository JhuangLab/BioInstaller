test_that("db.check", {
  db <- sprintf('%s/config.db', tempdir())
  x <- db.check(db)
  expect_that(x, equals(TRUE))
  unlink(db)
})
test_that("config.and.name.initial", {
  config.cfg <- system.file("extdata", "github.toml", package = "BioInstaller")
  x <- config.and.name.initial(config.cfg, "bwa")
  expect_that(x, equals(TRUE))
  expect_that(Sys.getenv('R_CONFIGFILE_ACTIVE'), equals(config.cfg))
  expect_that(Sys.getenv('R_CONFIG_ACTIVE'), equals("bwa"))
  x <- check.configfile.validate(config.cfg)
  expect_that(x, equals(TRUE))
  config.cfg <- system.file("extdata", "config.error.toml", package = "configr") 
  x <- tryCatch({
    x <- check.configfile.validate(config.cfg)
  }, warning = function(w) {
    return(FALSE)
  })
  expect_that(x, equals(FALSE))
})


test_that("initial",{
  config.cfg <- system.file("extdata", "github.toml", package = "BioInstaller")
  x <- NULL
  tryCatch({
    x <- check.install.name(NULL, config.cfg)
  }, warning = function(w) {
    x <- FALSE
  })
  expect_that(x, equals(NULL))
  config.cfg <- system.file("extdata", "github.toml", package = "BioInstaller")
  x <- config.and.name.initial(config.cfg, "bwa")
  config <- eval.config()
  x <- version.initial('bwa', config = config)
  expect_that(x, equals(config$version_newest))
  x <- version.initial('bwa', "v0.7.15",  config = config)
  expect_that(x, equals("v0.7.15"))
  x <- tryCatch({
    x <- check.configfile.validate(config.cfg)
  }, warning = function(w) {}, error = function(e){
    x <- TRUE
    return(x)
  })
  expect_that(x, equals(TRUE))
})

test_that("set.makedir", {
  old.workdir <- getwd()
  makedir.1 <- sprintf("%s/setmakedir/test_makedir1", tempdir())
  makedir.2 <- sprintf("%s/setmakedir/test_makedir2", tempdir())
  destdir <- sprintf("%s/setmakedir", tempdir())
  set.makedir(makedir.1, destdir)
  expect_that(getwd(), equals(destdir))
  dir.create(makedir.1)
  set.makedir(makedir.1, destdir)
  expect_that(getwd(), equals(makedir.1))
  set.makedir(makedir.2, destdir)
  expect_that(getwd(), equals(destdir))
  setwd(old.workdir)
  unlink(destdir, recursive=TRUE)
})
