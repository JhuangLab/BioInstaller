#' Download and install biology software or database
#'
#' @param name Software name
#' @param destdir A string, point the install path
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like 'GATK-3.7'
#' @param github.cfg Configuration file of installed by github url,
#' default is system.file('extdata', 'github.toml', package='BioInstaller')
#' @param nongithub.cfg Configuration file of installed by non github url,
#' default is system.file('extdata', 'nongithub.toml', package='BioInstaller')
#' @param version Software version
#' @param show.all.versions Logical wheather show all avaliable versions can be install
#' @param show.all.names Logical wheather show all avaliable names can be install
#' @param db File of saving softwares infomation, default is Sys.getenv('BIO_SOFTWARES_DB_ACTIVE',
#' system.file('extdata', 'softwares_db_demo.yaml', package = 'BioInstaller'))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param decompress Logicol indicating wheather need to decompress the downloaded file, default is TRUE
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose TRUE is debug mode
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @export
#' @return Bool Value or a list
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' install.bioinfo('bwa', sprintf('%s/bwa', tempdir()), verbose = TRUE)
install.bioinfo <- function(name = c(), destdir = c(), name.saved = NULL, github.cfg = system.file("extdata", 
  "github.toml", package = "BioInstaller"), nongithub.cfg = system.file("extdata", 
  "nongithub.toml", package = "BioInstaller"), version = c(), show.all.versions = FALSE, 
  show.all.names = FALSE, db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", 
    "softwares_db_demo.yaml", package = "BioInstaller")), download.only = FALSE, 
  decompress = TRUE, showWarnings = FALSE, verbose = FALSE, ...) {
  db.check(db)
  if (verbose) {
    flog.info("Debug:Now run install.bioinfo function.")
    flog.info(sprintf("Debug:name:%s", paste0(name, collapse = ", ")))
    flog.info(sprintf("Debug:destdir:%s", paste0(destdir, collapse = ", ")))
    flog.info(sprintf("Debug:version:%s", paste0(version, collapse = ", ")))
    flog.info(sprintf("Debug:show.all.versions:%s", show.all.versions))
    flog.info(sprintf("Debug:db:%s", db))
    flog.info(sprintf("Debug:github.cfg:%s", github.cfg))
    flog.info(sprintf("Debug:nongithub.cfg:%s", nongithub.cfg))
  }
  github.names <- eval.config.groups(file = github.cfg)
  nongithub.names <- eval.config.groups(file = nongithub.cfg)
  all.names <- c(github.names, nongithub.names)
  all.names <- all.names[!(all.names %in% c("title", "debug", "demo"))]
  if (show.all.names) {
    return(all.names)
  }
  install.success <- c()
  install.fail <- c()
  name <- name[!duplicated(name)]
  count <- 1
  bygithub <- NULL
  bynongithub <- NULL
  for (i in name) {
    i <- tolower(i)
    if (!show.all.versions) {
      destdir[count] <- normalizePath(destdir[count], mustWork = FALSE)
    }
    if (i %in% eval.config.groups(file = github.cfg)) {
      status <- install.github(name = i, destdir = destdir[count], github.cfg = github.cfg, 
        name.saved = name.saved, version = version[count], show.all.versions = show.all.versions, 
        db = db, download.only = download.only, verbose = verbose, showWarnings = showWarnings, 
        ...)
      bygithub <- c(bygithub, i)
    } else if (i %in% eval.config.groups(file = nongithub.cfg)) {
      status <- install.nongithub(name = i, destdir = destdir[count], name.saved = name.saved, 
        nongithub.cfg = nongithub.cfg, version = version, show.all.versions = show.all.versions, 
        db = db, download.only = download.only, showWarnings = showWarnings, 
        decompress = decompress, verbose = verbose, ...)
      bynongithub <- c(bynongithub, i)
    } else {
      warning(sprintf("%s not existed in install database, so can not be installed by BioInstaller package.", 
        i))
      next
    }
    if (is.logical(status) && download.only && status && !verbose) {
      flog.info(sprintf("%s be downloaded in %s successful", name, destdir))
      return(TRUE)
    } else if (is.logical(status) && download.only && !status && !verbose) {
      flog.info(sprintf("%s downloaded fail!", name))
      return(FALSE)
    } else if (is.logical(status) && download.only && verbose) {
      return(TRUE)
    }
    if (show.all.versions) {
      return(status)
    }
    if (status == TRUE && (i %in% show.installed(db))) {
      install.success <- c(install.success, i)
    } else {
      install.fail <- c(install.fail, i)
    }
    count <- count + 1
  }
  if (verbose) {
    flog.info(sprintf("Debug:Install by Github configuration file: %s", paste0(bygithub, 
      collapse = ", ")))
    flog.info(sprintf("Debug:Install by Non Github configuration file: %s", paste0(bynongithub, 
      collapse = ", ")))
    fail.list <- ""
    success.list <- ""
  } else {
    success.list <- paste(install.success, collapse = ",")
    if (success.list != "") {
      msg <- sprintf("Installed successful list: %s", success.list)
      flog.info(msg)
    }
    fail.list <- paste(install.fail, collapse = ",")
    if (fail.list != "") {
      msg <- sprintf("Installed fail list: %s", fail.list)
      flog.info(msg)
    }
  }
  return(list(fail.list = fail.list, success.list = success.list))
}

#' Install from Github
#'
#' @param name Software name
#' @param destdir A string, point the install path
#' @param version Software version
#' @param show.all.versions Logical wheather show all avaliable version can be install
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like 'GATK-3.7'
#' @param github.cfg Configuration file of installed by github url,
#' default is system.file('extdata', 'github.toml', package='BioInstaller')
#' @param db File of saving softwares infomation, default is Sys.getenv('BIO_SOFTWARES_DB_ACTIVE',
#' system.file('extdata', 'softwares_db_demo.yaml', package = 'BioInstaller'))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose TRUE is debug mode
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @return Bool Value
#' @export
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' install.github('bwa', destdir = sprintf('%s/bwa_example', tempdir()), verbose = TRUE)
install.github <- function(name = "", destdir = "./", version = NULL, show.all.versions = FALSE, 
  name.saved = NULL, github.cfg = system.file("extdata", "github.toml", package = "BioInstaller"), 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
    package = "BioInstaller")), download.only = FALSE, showWarnings = FALSE, 
  verbose = FALSE, ...) {
  old.work.dir <- getwd()
  config.cfg <- github.cfg
  name <- tolower(name)
  
  status <- config.and.name.initial(config.cfg, name)
  if (!status) {
    return(FALSE)
  }
  
  config <- eval.config()
  if (show.all.versions) {
    all.versions <- show.avaliable.versions(config)
    return(all.versions)
  }
  version <- version.initial(name, version, config)
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all$os.version <- get.os()
  args.all <- args.all[names(args.all) != ""]
  config <- configr::parse.extra(config = config, extra.list = args.all)
  config <- configr::parse.extra(config = config, other.config = db)
  config <- configr::parse.extra(config = config, rcmd.parse = T)
  
  
  destdir <- normalizePath(destdir, mustWork = FALSE)
  status <- destdir.initial(destdir, strict = FALSE, download.only)
  if (status == FALSE) {
    return(FALSE)
  }
  
  github_url <- config$github_url
  use_git2r <- config$use_git2r
  recursive_clone <- config$recursive_clone
  if (is.null(github_url) || github_url == "") {
    need.download = FALSE
  } else {
    need.download = TRUE
  }
  make.dir <- config$make_dir
  
  if (need.download && download.only && !verbose) {
    status <- git.download(name, destdir, version, github_url, use_git2r, recursive_clone)
    return(status)
  } else if (need.download && download.only && verbose) {
    msg <- sprintf("Debug:Now need to download %s in %s.", name, destdir)
    flog.info(msg)
    return(TRUE)
  }
  
  process.dependence(config, db, destdir, verbose)
  config <- configr::parse.extra(config = config, other.config = db)
  
  if (!is.null(name.saved)) {
    msg <- sprintf("Now start to install %s in %s.", name, destdir)
  } else {
    msg <- sprintf("Now start to install %s in %s.", name.saved, destdir)
  }
  flog.info(msg)
  flog.info("Running before install steps.")
  if (!verbose) {
    if (need.download) {
      status <- git.download(name, destdir, version, github_url, use_git2r, 
        recursive_clone)
    } else {
      dir.create(destdir, recursive = T)
    }
  } else {
    flog.info("Gebug:Git clone and checkout to point version.")
    flog.info(sprintf("Debug:github_url:%s", github_url))
    flog.info(sprintf("Debug:destdir:%s", destdir))
    flog.info(sprintf("Debug:version:%s", version))
  }
  if (!verbose) {
    set.makedir(make.dir, destdir)
  } else {
    flog.info("Debug:Now is step of set workdir of make")
  }
  
  before.cmd <- get.subconfig(config, "before_install")
  status <- for_runcmd(before.cmd)
  if (any(status == 0)) {
    flog.info("Running install steps.")
    install.cmd <- get.subconfig(config, "install")
    status <- for_runcmd(install.cmd, verbose)
    if (any(status == 0)) {
      flog.info("Running after install successful steps.")
      after_success.cmd <- get.subconfig(config, "after_success")
      status <- for_runcmd(after_success.cmd, verbose)
      if (all(status != 0)) {
        return(FALSE)
      } else {
        status <- TRUE
      }
      bin.dir <- get.subconfig(config, "bin_dir")
      if (is.null(bin.dir)) {
        bin.dir <- getwd()
      }
      if (verbose) {
        flog.info("Debug:Update Biosoftwares database step.")
      } else {
        last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        if (!is.null(name.saved)) {
          name <- tolower(name.saved)
        }
        change.info(name = name, installed = TRUE, source.dir = destdir, 
          bin.dir = bin.dir, version = version, last.update.time = last.update.time, 
          db = db, ...)
      }
    }
  } else {
    flog.info("Running after install fail steps.")
    after_failure.cmd <- get.subconfig(config, "after_failure")
    status <- for_runcmd(after_failure.cmd, verbose)
    if (all(status != 0)) {
      return(FALSE)
    } else {
      status <- TRUE
    }
  }
  return((is.logical(status)) || status == 0)
}

#' Download and Install Software(Non-Github) in SIMut
#'
#' @param name Software name
#' @param destdir A string, point the install path
#' @param version Software version
#' @param show.all.versions Logical wheather show all avaliable version can be install
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like 'GATK-3.7'
#' @param nongithub.cfg Configuration file of installed by non github url,
#' default is system.file('extdata', 'nongithub.toml', package='BioInstaller')
#' @param db File of saving softwares infomation, default is Sys.getenv('BIO_SOFTWARES_DB_ACTIVE',
#' system.file('extdata', 'softwares_db_demo.yaml', package = 'BioInstaller'))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param decompress Logicol indicating wheather need to decompress the downloaded file, default is TRUE
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose TRUE is debug mode
#' @return Bool Value
#' @export
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' install.nongithub('gmap', sprintf('%s/gmap_example', tempdir()), verbose = TRUE)
install.nongithub <- function(name = "", destdir = "./", version = NULL, show.all.versions = FALSE, 
  name.saved = NULL, nongithub.cfg = system.file("extdata", "nongithub.toml", package = "BioInstaller"), 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
    package = "BioInstaller")), download.only = FALSE, decompress = TRUE, showWarnings = FALSE, 
  verbose = FALSE, ...) {
  old.work.dir <- getwd()
  config.cfg <- nongithub.cfg
  name <- tolower(name)
  
  status <- config.and.name.initial(config.cfg, name)
  if (!status) {
    return(FALSE)
  }
  config <- eval.config()
  if (show.all.versions) {
    all.versions <- show.avaliable.versions(config)
    return(all.versions)
  }
  version <- version.initial(name, version, config)
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all$os.version <- get.os()
  args.all <- args.all[names(args.all) != ""]
  config <- configr::parse.extra(config = config, extra.list = args.all)
  config <- configr::parse.extra(config, other.config = db)
  config <- configr::parse.extra(config = config, rcmd.parse = T)
  
  destdir <- normalizePath(destdir, mustWork = FALSE)
  status <- destdir.initial(destdir, strict = FALSE, download.only)
  if (status == FALSE) {
    return(FALSE)
  }
  
  source_url <- source.url.initial(config)
  if (is.null(source_url)) {
    need.download <- FALSE
  } else {
    need.download <- TRUE
  }
  filename <- url2filename(source_url)
  url.all.download <- config$url_all_download
  if (is.null(url.all.download)) {
    url.all.download <- TRUE
  }
  if (need.download && download.only && !verbose) {
    msg <- sprintf("Now start to download %s in %s.", name, destdir)
    flog.info(msg)
    destfile <- sprintf(sprintf("%s/%s", destdir, filename))
    status <- download.dir.files(config, source_url, destfile, showWarnings, 
      url.all.download)
    if (all(!status)) {
      return(FALSE)
    }
    return(status)
  } else if (need.download && download.only && verbose) {
    msg <- sprintf("Debug:Now need to download %s in %s.", name, destdir)
    flog.info(msg)
    return(TRUE)
  }
  
  process.dependence(config, db, destdir, verbose)
  config <- configr::parse.extra(config, other.config = db)
  extract_dir <- sprintf("%s/install_tmp/", tempdir())
  dir.create(extract_dir, showWarnings = FALSE)
  destfile <- sprintf("%s/%s", extract_dir, filename)
  
  if (!is.null(name.saved)) {
    msg <- sprintf("Now start to install %s in %s.", name, destdir)
  } else {
    msg <- sprintf("Now start to install %s in %s.", name.saved, destdir)
  }
  flog.info(msg)
  flog.info("Running before install steps.")
  if (verbose) {
    flog.info("Debug:Source download and decompression step.")
    flog.info(sprintf("Debug:source_url:%s.", source_url))
    flog.info(sprintf("Debug:extract_dir:%s.", extract_dir))
    flog.info(sprintf("Debug:destfile:%s", destfile))
    flog.info(sprintf("Debug:destdir:%s", destdir))
  } else {
    if (need.download) {
      status <- download.dir.files(config, source_url, destfile, showWarnings, 
        url.all.download)
      if (all(!status)) {
        return(FALSE)
      }
      destfile <- attributes(status)$success
      if (!is.null(config$decompress)) {
        decompress <- unlist(config$decompress)
      }
      if (length(decompress) < length(destfile)) {
        len <- length(destfile) - length(decompress)
        decompress <- c(decompress, rep(FALSE, len))
      } else if (length(decompress) > length(destfile)) {
        decompress <- decompress[1:length(destfile)]
      }
      count <- 1
      for (fn in destfile) {
        status <- extract.file(fn, destdir, decompress[count])
        count <- count + 1
      }
      if (!all(status)) {
        return(FALSE)
      }
    } else {
      status <- TRUE
    }
  }
  make.dir <- config$make_dir
  files <- list.files(destdir)
  if (!verbose) {
    set.makedir(make.dir, destdir)
  } else {
    flog.info("Debug:Now is step of set workdir of make")
  }
  if (!verbose) {
    if ((length(files) == 1) && (length(list.files(files)) != 0)) {
      file.copy(sprintf("%s/%s", files, list.files(files)), "./", recursive = T, 
        copy.mode = TRUE)
      unlink(files, recursive = TRUE, force = TRUE)
    }
  } else {
    flog.info("Debug:Now is step of move the files that if only a directorie be generated.")
  }
  before.cmd <- get.subconfig(config, "before_install")
  status <- for_runcmd(before.cmd)
  if (any(status == 0)) {
    flog.info("Running install steps.")
    install.cmd <- get.subconfig(config, "install")
    status <- for_runcmd(install.cmd, verbose)
    if (any(status == 0)) {
      flog.info("Running after install successful steps.")
      after_success.cmd <- get.subconfig(config, "after_success")
      status <- for_runcmd(after_success.cmd, verbose)
      if (all(status != 0)) {
        return(FALSE)
      } else {
        status <- TRUE
      }
      bin.dir <- get.subconfig(config, "bin_dir")
      if (is.null(bin.dir)) {
        bin.dir <- getwd()
      }
      if (verbose) {
        flog.info("Update Biosoftwares database step.")
      } else {
        last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        if (!is.null(name.saved)) {
          name <- tolower(name.saved)
        }
        change.info(name = name, installed = TRUE, source.dir = destdir, 
          bin.dir = bin.dir, version = version, last.update.time = last.update.time, 
          db = db, ...)
      }
    }
  } else {
    flog.info("Running after install fail steps.")
    after_failure.cmd <- get.subconfig(config, "after_failure")
    status <- for_runcmd(after_failure.cmd, verbose)
    if (all(status != 0)) {
      return(FALSE)
    } else {
      status <- TRUE
    }
  }
  return(status)
}
