if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
db <- sprintf('%s/.BioInstaller', tempdir())
set.biosoftwares.db(db)

test_that("install.github", {
  x <- tryCatch(RCurl::getURL("https://github.com"), error = function(e){message("Connect Github failed. Please check the network.");NULL})
  if (!is.null(x)) {
    destdir <- sprintf('%s/github_demo0', tempdir())
    destdir <- normalizePath(destdir, "/", FALSE)
    x <- install.github(name = "github_demo", destdir = destdir, 
                      download.dir = destdir, verbose = F)
    expect_that(x, equals(TRUE))
    unlink(destdir, recursive = T, TRUE)
    destdir <- sprintf('%s/github_demo1', tempdir())
    destdir <- normalizePath(destdir, "/", FALSE)
    x <- suppressWarnings(install.github(show.all.versions = T, verbose = F))
    expect_that(x, equals(FALSE))
    destdir <- sprintf('%s/bwa', tempdir())
    destdir <- normalizePath(destdir, "/", FALSE)
    x <- install.github(name = "bwa", show.all.versions = T, verbose = F)
    expect_that(is.character(x), equals(TRUE))
    unlink(destdir, recursive = T, TRUE)
    x <- tryCatch(install.github(name = list(), show.all.versions = T, verbose = F), error = function(e) {return(FALSE)})
    expect_that(is.character(x), equals(FALSE))
    unlink(destdir, recursive = T, TRUE)
    destdir <- sprintf('%s/github_demo2', tempdir())
    destdir <- normalizePath(destdir, "/", FALSE)
    x <- install.github(name = "github_demo", destdir = destdir, 
                        download.dir = destdir, verbose = F, download.only = TRUE)
    expect_that(x, equals(TRUE))
    unlink(destdir, recursive = T, TRUE)
  } else {
    message("Please check RCurl::getURL('https://github.com')")
  }
})

test_that("install.nongithub", {
  destdir <- sprintf('%s/demo0', tempdir())
  destdir <- normalizePath(destdir, "/", FALSE)
  x <- tryCatch(install.nongithub('demo', destdir = destdir, verbose = F), 
           warning = function(w) {NULL})
  if (!is.null(x) && is.logical(x) && x) {
    expect_that(x, equals(TRUE))
    expect_that(is.list(get.info('demo')), equals(TRUE))
    unlink(destdir, recursive = T, TRUE)
    x <- install.nongithub('demo', destdir = destdir, verbose = F, download.only = T)
    expect_that(as.logical(x), equals(TRUE))
    unlink(destdir, recursive = T, TRUE)
  } else {
    message("Please check install.nongithub('demo', destdir = destdir, verbose = F)")
    expect_that(is.null(x) || is.logical(x), equals(TRUE))
  }
})

test_that("install.bioinfo", {
  destdir <- sprintf('%s/demo1', tempdir())
  destdir <- normalizePath(destdir, "/", FALSE)
  x <- tryCatch(install.bioinfo('demo', destdir = destdir, verbose = F),
                error = function(e) {message(e); NULL})
  if (!is.null(x) && is.list(x) && "demo" %in% x$success.list) {
    expect_that("demo" %in% x$success.list, equals(TRUE))
    expect_that(is.list(get.info('demo')), equals(TRUE))
    unlink(destdir, recursive = T, TRUE)

    destdir <- sprintf('%s/github_demo3', tempdir())
    destdir <- normalizePath(destdir, "/", FALSE)
    unlink(destdir, recursive = T, TRUE)
  } else {
    message("Please check install.bioinfo('demo', destdir = destdir, verbose = F)")
    expect_that(is.null(x) || is.list(x), equals(TRUE))
    expect_that("demo" %in% x$fail.list, equals(TRUE))
  }
  x <- tryCatch(install.bioinfo(name = "github_demo", destdir = destdir, 
                      download.dir = destdir, verbose = F), 
         error = function(e) {
                   message("Connecting Github website failed (SSL possible)."); NULL
                })
  if (!is.null(x)) expect_that("github_demo" %in% x$success.list, equals(TRUE))
  unlink(destdir, recursive = T, TRUE)
})

unlink(db)
temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)
