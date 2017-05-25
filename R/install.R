#' Download and install biology software or database
#'
#' @param name Software name
#' @param download.dir A string, point the source code download destdir
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
#' @param dependence.need Logical should the dependence should be installed
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose Ligical indicating wheather show the log message
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @export
#' @return Bool Value or a list
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' install.bioinfo('bwa', show.all.versions = TRUE)
#' unlink(db)
install.bioinfo <- function(name = c(), download.dir = c(), destdir = c(), name.saved = NULL, 
  github.cfg = system.file("extdata", "github.toml", package = "BioInstaller"), 
  nongithub.cfg = system.file("extdata", "nongithub.toml", package = "BioInstaller"), 
  version = c(), show.all.versions = FALSE, show.all.names = FALSE, db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
    system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller")), 
  download.only = FALSE, decompress = TRUE, dependence.need = TRUE, showWarnings = FALSE, 
  verbose = TRUE, ...) {
  db.check(db)
  github.names <- eval.config.sections(file = github.cfg)
  nongithub.names <- eval.config.sections(file = nongithub.cfg)
  all.names <- c(github.names, nongithub.names)
  all.names <- all.names[!(all.names %in% c("title", "debug", "demo"))]
  if (show.all.names) {
    return(all.names)
  }
  if (!show.all.versions) {
    info.msg(sprintf("Debug:name:%s", paste0(name, collapse = ", ")), verbose = verbose)
    info.msg(sprintf("Debug:destdir:%s", paste0(destdir, collapse = ", ")), verbose = verbose)
    info.msg(sprintf("Debug:version:%s", paste0(version, collapse = ", ")), verbose = verbose)
    info.msg(sprintf("Debug:show.all.versions:%s", show.all.versions), verbose = verbose)
    info.msg(sprintf("Debug:db:%s", db), verbose = verbose)
    info.msg(sprintf("Debug:github.cfg:%s", github.cfg), verbose = verbose)
    info.msg(sprintf("Debug:nongithub.cfg:%s", nongithub.cfg), verbose = verbose)
  }
  install.success <- c()
  install.fail <- c()
  name <- name[!duplicated(name)]
  count <- 1
  bygithub <- NULL
  bynongithub <- NULL
  for (i in name) {
    old_wd <- getwd()
    i <- tolower(i)
    if (!show.all.versions) {
      processed.dir.list <- pre.process.dir(i, destdir, download.dir, count)
      destdir[count] <- processed.dir.list[["des.dir"]]
      download.dir[count] <- processed.dir.list[["down.dir"]]
    }
    sf.name = str_split(i, "@")[[1]][1]
    sf.version = str_split(i, "@")[[1]][2]
    if (is.null(name.saved[count]) || is.na(name.saved[count])) {
      name.saved[count] <- str_replace(i, "@", "_")
    }
    if (i %in% github.names || (sf.name %in% github.names && (sf.name != i))) {
      if (sf.name %in% github.names && sf.name != i) {
        name.saved[count] <- str_replace(i, "@", "_")
        i <- sf.name
        version[count] <- sf.version
      }
      status <- install.github(name = i, destdir = destdir[count], download.dir = download.dir[count], 
        github.cfg = github.cfg, name.saved = name.saved[count], version = version[count], 
        show.all.versions = show.all.versions, db = db, download.only = download.only, 
        verbose = verbose, showWarnings = showWarnings, dependence.need = dependence.need, 
        ...)
      bygithub <- c(bygithub, i)
    } else if (i %in% nongithub.names || (sf.name %in% nongithub.names && sf.name != 
      i)) {
      if (sf.name %in% nongithub.names && sf.name != i) {
        name.saved[count] <- str_replace(i, "@", "_")
        i <- sf.name
        version[count] = sf.version
      }
      status <- install.nongithub(name = i, destdir = destdir[count], download.dir = download.dir[count], 
        name.saved = name.saved[count], nongithub.cfg = nongithub.cfg, version = version[count], 
        show.all.versions = show.all.versions, db = db, download.only = download.only, 
        showWarnings = showWarnings, decompress = decompress, dependence.need = dependence.need, 
        verbose = verbose, ...)
      bynongithub <- c(bynongithub, i)
    } else {
      warning(sprintf("%s not existed in install database, so can not be installed by BioInstaller package.", 
        i))
      next
    }
    status[is.null(status)] <- FALSE
    if (is.logical(status) && download.only && status) {
      info.msg(sprintf("%s be downloaded in %s successful", name, destdir), 
        verbose = verbose)
      return(TRUE)
    } else if (is.logical(status) && download.only && !status) {
      info.msg(sprintf("%s downloaded fail!", name), verbose = verbose)
      return(FALSE)
    }
    if (show.all.versions) {
      return(status)
    }
    if (status == TRUE && (name.saved[count] %in% show.installed(db))) {
      install.success <- c(install.success, name.saved[count])
    } else {
      install.fail <- c(install.fail, name.saved[count])
    }
    setwd(old_wd)
    count <- count + 1
  }
  info.msg(sprintf("Debug:Install by Github configuration file: %s", paste0(bygithub, 
    collapse = ", ")), verbose = verbose)
  info.msg(sprintf("Debug:Install by Non Github configuration file: %s", paste0(bynongithub, 
    collapse = ", ")), verbose = verbose)
  success.list <- paste(install.success, collapse = ",")
  if (success.list != "") {
    msg <- sprintf("Installed successful list: %s", success.list)
    info.msg(msg, verbose = verbose)
  }
  fail.list <- paste(install.fail, collapse = ",")
  if (fail.list != "") {
    msg <- sprintf("Installed fail list: %s", fail.list)
    info.msg(msg, verbose = verbose)
  }
  return(list(fail.list = fail.list, success.list = success.list))
}

#' Install from Github
#'
#' @param name Software name
#' @param download.dir A string, point the source code download destdir
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
#' @param dependence.need Logical should the dependence should be installed
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose Ligical indicating wheather show the log message
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @return Bool Value
#' @export
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' install.github('bwa', show.all.versions = TRUE)
#' unlink(db)
install.github <- function(name = "", download.dir = NULL, destdir = NULL, version = NULL, 
  show.all.versions = FALSE, name.saved = NULL, github.cfg = system.file("extdata", 
    "github.toml", package = "BioInstaller"), db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
    system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller")), 
  download.only = FALSE, showWarnings = FALSE, dependence.need = TRUE, verbose = TRUE, 
  ...) {
  old.work.dir <- getwd()
  config.cfg <- github.cfg
  name <- tolower(name)
  status <- config.and.name.initial(config.cfg, name)
  status[is.null(status)] <- FALSE
  if (!status) {
    return(FALSE)
  }
  
  config <- eval.config(config = name, file = config.cfg)
  info.msg("Fetching Versions....", verbose = verbose)
  all.versions <- show.avaliable.versions(config)
  if (show.all.versions) {
    return(all.versions)
  }
  info.msg(sprintf("Avaliable versions:%s", paste0(all.versions, collapse = ", ")), 
    verbose = verbose)
  version <- version.initial(name, version, all.versions, config)
  processed.dir.list <- pre.process.dir(name, destdir, download.dir, 1)
  destdir <- processed.dir.list[["des.dir"]]
  download.dir <- processed.dir.list[["down.dir"]]
  status <- destdir.initial(download.dir, strict = FALSE, download.only)
  if (status == FALSE) {
    return(FALSE)
  }
  
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all$download.dir <- download.dir
  args.all$os.version <- get.os()
  args.all <- args.all[names(args.all) != ""]
  config <- configr::parse.extra(config = config, extra.list = args.all)
  config <- configr::parse.extra(config = config, other.config = db)
  config <- configr::parse.extra(config = config, rcmd.parse = T)
  
  github_url <- config$github_url
  use_git2r <- config$use_git2r
  recursive_clone <- config$recursive_clone
  if (is.null(github_url) || github_url == "") {
    need.download = FALSE
  } else {
    need.download = TRUE
  }
  make.dir <- config$make_dir
  
  if (need.download && download.only) {
    status <- git.download(name, download.dir, version, github_url, use_git2r, 
      recursive_clone, verbose)
    return(status)
  }
  
  if (!is.null(name.saved)) {
    msg <- sprintf("Now start to install %s in %s.", name, destdir)
  } else {
    msg <- sprintf("Now start to install %s in %s.", name.saved, destdir)
  }
  info.msg(msg, verbose = verbose)
  info.msg("Running before install steps.", verbose = verbose)
  if (need.download) {
    status <- git.download(name, download.dir, version, github_url, use_git2r, 
      recursive_clone, verbose)
  } else {
    dir.create(download.dir, recursive = T)
  }
  if (dependence.need) {
    process.dependence(config, db, download.dir, destdir, verbose)
    config <- eval.config(config = name, file = config.cfg)
    config <- configr::parse.extra(config = config, extra.list = args.all)
    config <- configr::parse.extra(config, other.config = db)
    config <- configr::parse.extra(config = config, rcmd.parse = T)
  }
  set.makedir(make.dir, download.dir)
  before.cmd <- get.subconfig(config, "before_install")
  status <- for_runcmd(before.cmd)
  if (any(status == 0)) {
    info.msg("Running install steps.", verbose = verbose)
    install.cmd <- get.subconfig(config, "install")
    status <- for_runcmd(install.cmd, verbose)
    if (any(status == 0)) {
      info.msg("Running after install successful steps.", verbose = verbose)
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
      last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      if (!is.null(name.saved)) {
        name <- tolower(name.saved)
      }
      change.info(name = name, installed = TRUE, source.dir = download.dir, 
        install.dir = destdir, bin.dir = bin.dir, version = version, last.update.time = last.update.time, 
        db = db, verbose = verbose, ...)
    }
  } else {
    info.msg("Running after install fail steps.", verbose = verbose)
    after_failure.cmd <- get.subconfig(config, "after_failure")
    status <- for_runcmd(after_failure.cmd, verbose)
    if (all(status != 0)) {
      return(FALSE)
    } else {
      status <- TRUE
    }
  }
  setwd(old.work.dir)
  if (is.logical(status)) {
    return(status)
  } else {
    return(status == 0)
  }
}

#' Download and Install Software(Non-Github) in SIMut
#'
#' @param name Software name
#' @param download.dir A string, point the source code download destdir
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
#' @param dependence.need Logical should the dependence should be installed
#' @param showWarnings Logical should the warnings on failure be shown?
#' @param verbose Ligical indicating wheather show the log message
#' @return Bool Value
#' @export
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' install.nongithub('gmap', show.all.versions = TRUE)
#' unlink(db)
install.nongithub <- function(name = "", download.dir = NULL, destdir = NULL, version = NULL, 
  show.all.versions = FALSE, name.saved = NULL, nongithub.cfg = system.file("extdata", 
    "nongithub.toml", package = "BioInstaller"), db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
    system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller")), 
  download.only = FALSE, decompress = TRUE, dependence.need = TRUE, showWarnings = FALSE, 
  verbose = TRUE, ...) {
  old.work.dir <- getwd()
  config.cfg <- nongithub.cfg
  name <- tolower(name)
  
  status <- config.and.name.initial(config.cfg, name)
  status[is.null(status)] <- FALSE
  if (!status) {
    return(FALSE)
  }
  config <- eval.config(config = name, file = config.cfg)
  info.msg("Fetching Versions....", verbose = verbose)
  all.versions <- show.avaliable.versions(config)
  if (show.all.versions) {
    return(all.versions)
  }
  info.msg(sprintf("Avaliable versions:%s", paste0(all.versions, collapse = ", ")), 
    verbose = verbose)
  version <- version.initial(name, version, all.versions, config)
  processed.dir.list <- pre.process.dir(name, destdir, download.dir, 1)
  destdir <- processed.dir.list[["des.dir"]]
  download.dir <- processed.dir.list[["down.dir"]]
  status <- destdir.initial(download.dir, strict = FALSE, download.only)
  if (status == FALSE) {
    return(FALSE)
  }
  
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all$download.dir <- download.dir
  args.all$os.version <- get.os()
  args.all <- args.all[names(args.all) != ""]
  config <- configr::parse.extra(config = config, extra.list = args.all)
  config <- configr::parse.extra(config = config, other.config = db)
  config <- configr::parse.extra(config = config, rcmd.parse = T)
  
  source_url <- source.url.initial(config)
  if (all(is.null(source_url)) | all(source_url == "")) {
    need.download <- FALSE
  } else {
    need.download <- TRUE
  }
  filename <- url2filename(source_url)
  url.all.download <- config$url_all_download
  if (is.null(url.all.download)) {
    url.all.download <- TRUE
  }
  if (need.download && download.only) {
    msg <- sprintf("Now start to download %s in %s.", name, download.dir)
    info.msg(msg, verbose = verbose)
    destfile <- sprintf(sprintf("%s/%s", download.dir, filename))
    status <- download.dir.files(config, source_url, destfile, showWarnings, 
      url.all.download)
    status[is.null(status)] <- FALSE
    if (all(!status)) {
      return(FALSE)
    }
    return(status)
  }
  
  msg <- sprintf("Now start to install %s in %s.", name, destdir)
  info.msg(msg, verbose = verbose)
  info.msg("Running before install steps.", verbose = verbose)
  if (need.download && !is.download.dir(config)) {
    extract_dir <- sprintf("%s/install_tmp/", tempdir())
    dir.create(extract_dir, showWarnings = FALSE)
    destfile <- sprintf("%s/%s", extract_dir, filename)
    msg <- sprintf("Now start to download %s in %s.", name, download.dir)
    info.msg(msg, verbose = verbose)
    status <- download.dir.files(config, source_url, destfile, showWarnings, 
      url.all.download)
    status[is.null(status)] <- FALSE
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
      status <- extract.file(fn, download.dir, decompress[count])
      count <- count + 1
    }
    if (!all(status)) {
      return(FALSE)
    }
  } else if (need.download && is.download.dir(config)) {
    destfile <- sprintf(sprintf("%s/%s", download.dir, filename))
    status <- download.dir.files(config, source_url, destfile, showWarnings, 
      url.all.download)
    status[is.null(status)] <- FALSE
  } else {
    status <- TRUE
  }
  if (dependence.need) {
    process.dependence(config, db, download.dir, destdir, verbose)
    status <- config.and.name.initial(config.cfg, name)
    config <- eval.config(config = name, file = config.cfg)
    config <- configr::parse.extra(config = config, extra.list = args.all)
    config <- configr::parse.extra(config = config, other.config = db)
    config <- configr::parse.extra(config = config, rcmd.parse = T)
  }
  make.dir <- config$make_dir
  files <- list.files(download.dir)
  set.makedir(make.dir, download.dir)
  if ((length(files) == 1) && (length(list.files(files)) != 0)) {
    file.copy(sprintf("%s/%s", files, list.files(files)), "./", recursive = T, 
      copy.mode = TRUE)
    unlink(files, recursive = TRUE, force = TRUE)
  }
  before.cmd <- get.subconfig(config, "before_install")
  status <- for_runcmd(before.cmd, verbose = verbose)
  if (any(status == 0)) {
    info.msg("Running install steps.", verbose = verbose)
    install.cmd <- get.subconfig(config, "install")
    status <- for_runcmd(install.cmd, verbose = verbose)
    if (any(status == 0)) {
      info.msg("Running after install successful steps.", verbose = verbose)
      after_success.cmd <- get.subconfig(config, "after_success")
      status <- for_runcmd(after_success.cmd, verbose = verbose)
      if (all(status != 0)) {
        return(FALSE)
      } else {
        status <- TRUE
      }
      bin.dir <- get.subconfig(config, "bin_dir")
      if (is.null(bin.dir)) {
        bin.dir <- getwd()
      }
      last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      if (!is.null(name.saved)) {
        name <- tolower(name.saved)
      }
      change.info(name = name, installed = TRUE, source.dir = download.dir, 
        install.dir = destdir, bin.dir = bin.dir, version = version, last.update.time = last.update.time, 
        db = db, verbose = verbose, ...)
    }
  } else {
    info.msg("Running after install fail steps.", verbose = verbose)
    after_failure.cmd <- get.subconfig(config, "after_failure")
    status <- for_runcmd(after_failure.cmd, verbose = verbose)
    if (all(status != 0)) {
      return(FALSE)
    } else {
      status <- TRUE
    }
  }
  setwd(old.work.dir)
  if (is.logical(status)) {
    return(status)
  } else {
    return(status == 0)
  }
}
