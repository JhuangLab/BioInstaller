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

test_that("dependence",{
  db <- sprintf('%s/.BioInstaller', tempdir())
  unlink(db)
  set.biosoftwares.db(db)
  x <- change.info(name = "demo", installed = "yes", debug = TRUE, verbose = F, version = '1.0')
  x <- check.need.install('demo', '1.0', db)
  expect_that(x, equals(TRUE))
  config.cfg <- system.file("extdata", "github.toml", package = "BioInstaller")
  x <- get.need.install(eval.config(config = "bcftools", file = config.cfg), db)
  expect_that(is.list(x), equals(TRUE))
  expect_that(x[[1]][1], equals('htslib'))
  destdir <- sprintf('%s/denpendence', tempdir())
  x <- install.dependence('github_demo', 'master', destdir, destdir, F)
  expect_that(x, equals(TRUE))
  unlink(destdir, recursive=TRUE)
  x <- process.dependence(eval.config(config = "github_demo", file = config.cfg), db, destdir, destdir, FALSE)
  expect_that(x, equals(TRUE))
  unlink(destdir, recursive=TRUE)
})


test_that("git.download",{
  destdir <- sprintf('%s/denpendence', tempdir())
  url <-  "https://github.com/Miachol/github_demo"
  x <- git.download("github_demo", destdir, "master", url, FALSE, TRUE, FALSE)
  expect_that(x, equals(TRUE))
  unlink(destdir, recursive=TRUE)
})
