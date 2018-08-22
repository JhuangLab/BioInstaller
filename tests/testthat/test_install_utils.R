if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("db.check", {
  db <- sprintf('%s/config.db', tempdir())
  db <- normalizePath(db, "/", FALSE)
  x <- db.check(db)
  expect_that(x, equals(TRUE))
  unlink(db)
})
test_that("config.and.name.initial", {
  config.cfg <- system.file("extdata", "config/github/github.toml", package = "BioInstaller")
  x <- config.and.name.initial(config.cfg, "bwa")
  expect_that(x, equals(TRUE))
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
  config.cfg <- system.file("extdata", "config/github/github.toml", package = "BioInstaller")
  x <- NULL
  tryCatch({
    x <- check.install.name(NULL, config.cfg)
  }, warning = function(w) {
    x <- FALSE
  })
  expect_that(x, equals(NULL))
  config.cfg <- system.file("extdata", "config/github/github.toml", package = "BioInstaller")
  x <- config.and.name.initial(config.cfg, "bwa")
  config <- eval.config(config = "bwa", file = config.cfg)
  versions <- tryCatch(show.avaliable.versions(config), 
              error = function(e) {message("Featch bwa version failed."); NULL})
  if (!is.null(versions)) {
    params <- list(name = "bwa", version = "v0.7.15", versions = versions, config = config)
    x <- do.call(version.initial, params)
    expect_that(x, equals("v0.7.15"))
  }
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
  tmp.dir <- normalizePath(tempdir(), "/")
  makedir.1 <- sprintf("%s/setmakedir/test_makedir1", tmp.dir)
  makedir.2 <- sprintf("%s/setmakedir/test_makedir2", tmp.dir)
  destdir <- sprintf("%s/setmakedir", tmp.dir)
  destdir <- normalizePath(destdir, "/", FALSE)
  makedir.1 <- normalizePath(makedir.1, "/", FALSE)
  makedir.2 <- normalizePath(makedir.2, "/", FALSE)
  params <- list(make.dir = makedir.1, destdir = destdir)
  do.call(set.makedir, params)
  expect_that(getwd(), equals(destdir))
  dir.create(makedir.1)
  params <- list(make.dir = makedir.1, destdir = destdir)
  do.call(set.makedir, params)
  expect_that(getwd(), equals(makedir.1))
  params <- list(make.dir = makedir.2, destdir = destdir)
  do.call(set.makedir, params)
  expect_that(getwd(), equals(destdir))
  setwd(old.workdir)
  unlink(destdir, recursive = T, TRUE)
})

test_that("dependence",{
  db <- sprintf('%s/.BioInstaller', tempdir())
  unlink(db)
  set.biosoftwares.db(db)
  x <- change.info(name = "demo", installed = "yes", debug = TRUE, verbose = F, version = '1.0')
  x <- check.need.install('demo', '1.0', db)
  expect_that(x, equals(TRUE))
  config.cfg <- system.file("extdata", "config/github/github.toml", package = "BioInstaller")
  x <- get.need.install(eval.config(config = "bcftools", file = config.cfg), db)
  expect_that(is.list(x), equals(TRUE))
  expect_that(x[[1]][1], equals('htslib'))
  destdir <- sprintf('%s/', tempdir())
  destdir <- normalizePath(destdir, "/", FALSE)
  x <- tryCatch(install.dependence('github_demo', 'master', destdir, destdir, F), 
           error = function(e) {message("Connecting Github website failed."); NULL})
  if (!is.null(x)) {
    expect_that(x, equals(TRUE))
    unlink(destdir, recursive=TRUE, TRUE)
    x <- process.dependence(eval.config(config = "github_demo", file = config.cfg), db, destdir, destdir, FALSE)
    expect_that(x, equals(TRUE))
    unlink(destdir, recursive=TRUE, TRUE)
  }
})


test_that("git.download",{
  destdir <- sprintf('%s/denpendence1', tempdir())
  destdir <- normalizePath(destdir, "/", FALSE)
  unlink(destdir, recursive = TRUE, TRUE)
  url <-  "https://github.com/Miachol/github_demo"
  x <- tryCatch(git.download("github_demo", destdir, "master", 
                             url, TRUE, FALSE, FALSE),
                error = function(e) {NULL})
  expect_that(is.null(x) || x, equals(TRUE))
  unlink(destdir, recursive=TRUE, TRUE)
})

temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)
