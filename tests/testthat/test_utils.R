if (!dir.exists(tempdir())) {
  dir.create(tempdir())
}
test_that("extract.file with decompress", {
  workdir <- tempdir()
  dir.create(sprintf("%s/tmp/", workdir))
  dir.create(sprintf("%s/tmp1/", workdir))
  test.file <- sprintf("%s/tmp1/test", workdir)
  file.create(test.file)
  gzip(test.file)
  x <- extract.file(sprintf("%s.gz", test.file), paste0(workdir, "/tmp"))
  expect_that(x, equals(TRUE))
  unlink(sprintf('%s/tmp', workdir), recursive=TRUE, TRUE)
  unlink(sprintf('%s/tmp1', workdir), recursive=TRUE, TRUE)
})

test_that("extract.file with decompress", {
  workdir <- tempdir()
  dir.create(sprintf("%s/tmp/", workdir))
  dir.create(sprintf("%s/tmp1/", workdir))
  test.file <- sprintf("%s/tmp1/test", workdir)
  file.create(test.file)
  gzip(test.file)
  x <- extract.file(sprintf("%s.gz", test.file), paste0(workdir, "/tmp"), decompress = FALSE)
  expect_that(x, equals(TRUE))
  unlink(sprintf('%s/tmp', workdir), recursive=TRUE, TRUE)
  unlink(sprintf('%s/tmp1', workdir), recursive=TRUE, TRUE)
})

test_that("drop_redundance_dir", {
  test.dir <- sprintf("%s/test_drop", tempdir())
  dir.create(test.dir)
  dir.create(sprintf("%s/a", test.dir))
  file.create(sprintf("%s/a/b1", test.dir))
  dir.create(sprintf("%s/a/b", test.dir))
  dir.create(sprintf("%s/a/c", test.dir))
  x <- drop_redundance_dir(test.dir)
  expect_that(x, equals(TRUE))
  expect_that(file.exists(sprintf("%s/b1", test.dir)), equals(TRUE))
  expect_that(dir.exists(sprintf("%s/b", test.dir)), equals(TRUE))
  expect_that(dir.exists(sprintf("%s/c", test.dir)), equals(TRUE))
  unlink(test.dir, recursive=TRUE, TRUE)
})

test_that("is.file.empty", {
  test.file <- sprintf("%s/1", tempdir())
  file.create(test.file)
  x <- is.file.empty(test.file)
  expect_that(x, equals(TRUE))
  unlink(test.file)
})

test_that("get.os", {
  x <- get.os()
  x <- x %in% c('centos', 'ubuntu', 'arch', 'other', 'windows', 'mac')
  expect_that(x, equals(TRUE))
})

test_that("runcmd & for_runcmd", {
  cmd <- ""
  x <- runcmd(cmd, verbose = FALSE)
  expect_that(x, equals(0))
  destdir <- normalizePath(tempdir(), "/", FALSE)
  cmd <- sprintf("echo 123 > %s/123", destdir)
  x <- runcmd(cmd, verbose = FALSE)
  expect_that(x, equals(0))
  cmd <- rep("", 3)
  x <- for_runcmd(cmd, verbose = FALSE)
  expect_that(x, equals(rep(0,3)))
  cmd <- rep(sprintf("echo 123 > %s/123", destdir), 3)
  x <- for_runcmd(cmd, verbose = FALSE)
  expect_that(x, equals(rep(0,3)))
  unlink(sprintf('%s/123', destdir), TRUE)
  cmd <- "#R#Sys.setenv(R_TEST= 'rtest')#R#"
  runcmd(cmd, verbose = FALSE)
  expect_that(Sys.getenv("R_TEST") == "rtest", equals(TRUE))
})

test_that("get.subconfig", {
  config.1 <- list()
  x <- get.subconfig(config.1, "empty")
  expect_that(x, equals(""))
  config.1 <- list(debug=TRUE)
  x <- get.subconfig(config.1, "debug")
  expect_that(x, equals(TRUE))
  config.1 <- list(install = list(windows = "w", mac = "m", linux = "l"))
  x <- get.subconfig(config.1, "install")
  expect_that(x %in% c("w", "m", "l"), equals(TRUE))
  expect_that(sum(x %in% c("w", "m", "l")), equals(1))
})

test_that("get.file.type", {
  filetype.lib <- c("tgz", "tar.xz", "tar.bz2", "tar.gz", "tar", "gz", "zip", 
    "bz2", "xz")
  filenames <- sprintf("test.%s", filetype.lib)
  x <- sapply(filenames, function(x) {get.file.type(x)})
  x <- unname(x)
  expect_that(x, equals(filetype.lib))
})

test_that("download.file.custom", {
  url <- "http://bioinfo.rjh.com.cn/download/annovarR/humandb/GRCh37_MT_ensGene.txt"
  destfile <- sprintf("%s/GRCh37", tempdir())
  x <- download.file.custom(url, destfile, quiet = T)
  expect_that(x, equals(0))
  unlink(destfile)
})


test_that("destdir.initial",{
  test.dir <- sprintf('%s/destdir.initial', tempdir())
  x <- destdir.initial(test.dir, FALSE, TRUE)
  expect_that(x, equals(TRUE))
  unlink(test.dir, recursive = T, TRUE)
})

test_that("is.null.na",{
  x <- is.null.na(NULL)
  expect_that(x, equals(TRUE))
  x <- is.null.na(NA)
  expect_that(x, equals(TRUE))
})

test_that("destdir.initial", {
  test.dir <- sprintf('%s/destdir.initial', tempdir())
  dir.create(test.dir)
  x <- destdir.initial(test.dir, TRUE, FALSE)
  expect_that(x, equals(TRUE))
  file.create(sprintf('%s/1', test.dir))
  x <- destdir.initial(test.dir, TRUE, FALSE)
  expect_that(x, equals(FALSE))
  x <- destdir.initial(test.dir, FALSE, FALSE)
  expect_that(x, equals(FALSE))
})

test_that("download.file.custom is.dir", {
 url <- "ftp://ftp.sjtu.edu.cn/pub/CPAN/clpa/"
 x <- download.file.custom(url, tempdir(), TRUE)
 expect_that(x, equals(0))
 x <- file.exists(sprintf('%s/%s', tempdir(), c('README', 'index.html')))
 expect_that(all(x), equals(TRUE))
})
temps <- list.files(tempdir(), ".*")
unlink(sprintf("%s/%s", tempdir(), temps), recursive = TRUE, TRUE)


