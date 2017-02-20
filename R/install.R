#' Download and Install Software in SIMut 
#'
#' @param name Software name 
#' @param destdir A string, point the install path
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like "GATK-3.7"
#' @param github.cfg Configuration file of installed by github url,
#' default is system.file('extdata', 'github.toml', package='BioInstaller')
#' @param nongithub.cfg Configuration file of installed by non github url,
#' default is system.file('extdata', 'nongithub.toml', package='BioInstaller')
#' @param version Software version
#' @param show.list Logical wheather show all avaliable version can be install
#' @param db File of saving softwares infomation, default is Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
#' system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller"))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param decompress Logicol indicating wheather need to decompress the downloaded file, default is TRUE
#' @param verbose TRUE is debug mode
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @export
#' @return Bool Value or a list
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' install.bioinfo('bwa', sprintf('%s/bwa', tempdir()), TRUE)
install.bioinfo <- function(name = c(), destdir = c(), name.saved = NULL, github.cfg = system.file("extdata", 
  "github.toml", package = "BioInstaller"), nongithub.cfg = system.file("extdata", 
  "nongithub.toml", package = "BioInstaller"), version = c(), show.list = FALSE, 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
  package = "BioInstaller")), download.only = FALSE, decompress = TRUE, verbose = FALSE, ...) {
  db.check(db)
  if(verbose) {
    flog.info("Debug:Now run install.bioinfo function.")
    flog.info(sprintf("Debug:name:%s", paste0(name, collapse = ", ")))
    flog.info(sprintf("Debug:destdir:%s", paste0(destdir, collapse = ", ")))
    flog.info(sprintf("Debug:version:%s", paste0(version, collapse = ", ")))
    flog.info(sprintf("Debug:show.list:%s", show.list))
    flog.info(sprintf("Debug:db:%s", db))
    flog.info(sprintf("Debug:github.cfg:%s", github.cfg))
    flog.info(sprintf("Debug:nongithub.cfg:%s", nongithub.cfg))
  }
  install.success <- c()
  install.fail <- c()
  name <- name[!duplicated(name)]
  count <- 1
  bygithub <- NULL
  bynongithub <- NULL
  for (i in name) {
    i <- tolower(i)
    if (i %in% eval.config.groups(file = github.cfg)) {
      if(!show.list) {
        destdir[count] <- normalizePath(destdir[count], mustWork = FALSE)
      }
      status <- install.github(name = i, destdir = destdir[count], github.cfg = github.cfg, name.saved = name.saved,
        version = version[count], show.list = show.list, db = db, download.only = download.only, verbose = verbose, 
        ...)

      if(is.logical(status) && download.only && status && !verbose) {
        flog.info(sprintf("%s be downloaded in %s successful", name, destdir))
        return(TRUE)
      } else if(is.logical(status) && download.only && !status && !verbose) {
        flog.info(sprintf("%s downloaded fail!", name))
        return(FALSE)
      } else if (is.logical(status) && download.only && verbose) {
        return(TRUE)
      }

      if (status == TRUE && (i %in% show.installed(db))) {
        install.success <- c(install.success, i)
      } else {
        install.fail <- c(install.fail, i)
      }
      bygithub <- c(bygithub, i)

    } else if (i %in% eval.config.groups(file = nongithub.cfg)) {
      status <- install.nongithub(name = i, destdir = destdir[count], name.saved = name.saved, nongithub.cfg = nongithub.cfg, 
        version = version, show.list = show.list, db = db, download.only = download.only, 
        decompress = decompress, verbose = verbose, ...)

      if(is.logical(status) && download.only && status && !verbose) {
        flog.info(sprintf("%s be downloaded in %s successful", name, destdir))
        return(TRUE)
      } else if(is.logical(status) && download.only && !status && !verbose) {
        flog.info(sprintf("%s downloaded fail!", name))
        return(FALSE)
      } else if (is.logical(status) && download.only && verbose) {
        return(TRUE)
      }

      if (is.null(status)) {
        return(TRUE)
      }
      if (status == TRUE && (i %in% show.installed(db))) {
        install.success <- c(install.success, i)
      } else {
        install.fail <- c(install.fail, i)
      }
      bynongithub <- c(bynongithub, i)
    }
    count <- count + 1
  }
  if(verbose) {
     flog.info(sprintf("Debug:Install by Github configuration file: %s", paste0(bygithub, collapse = ", ")))
     flog.info(sprintf("Debug:Install by Non Github configuration file: %s", paste0(bynongithub, collapse = ", ")))
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
#' @param version Software version
#' @param show.list Logical wheather show all avaliable version can be install
#' @param destdir A string, point the install path
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like "GATK-3.7"
#' @param github.cfg Configuration file of installed by github url,
#' default is system.file('extdata', 'github.toml', package='BioInstaller')
#' @param db File of saving softwares infomation, default is Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
#' system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller"))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param verbose TRUE is debug mode
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
install.github <- function(name = "", version = NULL, show.list = FALSE, destdir = "./", 
  name.saved = NULL, github.cfg = system.file("extdata", "github.toml", package = "BioInstaller"), 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
    package = "BioInstaller")), download.only = FALSE, verbose = FALSE, ...) {
  old.work.dir <- getwd()
  config.cfg <- github.cfg
  name <- tolower(name)

  status <- config.and.name.initial(config.cfg, name)
  if(!status) {
    return(FALSE)
  }

  config <- eval.config()
  version <- version.initial(name, version, config)
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all <- args.all[names(args.all) != ""]
  config <- parse.config.with.var(config = config, args.all = args.all)
  config <- parse.config.with.db(config, db)

  if (show.list) {
    show.avaliable.versions(config)
    return(NULL)
  }

  destdir <- normalizePath(destdir, mustWork = FALSE)
  status <- destdir.initial(destdir, strict = FALSE, download.only)
  if(status == FALSE) {
    return(FALSE)
  }

  github_url <- config$github_url
  make.dir <- config$make_dir

  if(download.only && !verbose) {
    msg <- sprintf("Now start to download %s in %s.", name, destdir)
    flog.info(msg)
    repo <- git2r::clone(github_url, destdir)
    text <- sprintf("git2r::checkout(git2r::tags(repo)[['%s']])", version)
    eval(parse(text = text))
    return(status)
  } else if (download.only && verbose) {
    msg <- sprintf("Debug:Now need to download %s in %s.", name, destdir)
    flog.info(msg)
    return(TRUE)
  }

  process.dependence(config, db, destdir, verbose)
  config <- parse.config.with.db(config, db)

  if(!is.null(name.saved)) {
    msg <- sprintf("Now start to install %s in %s.", name, destdir)
  } else {
    msg <- sprintf("Now start to install %s in %s.", name.saved, destdir)
  }
  flog.info(msg)
  flog.info("Running before install steps.")
  if (!verbose) {
    repo <- git2r::clone(github_url, destdir)
    text <- sprintf("git2r::checkout(git2r::tags(repo)[['%s']])", version)
    eval(parse(text = text))
  } else {
    flog.info("Gebug:Git clone and checkout to point version.")
    flog.info(sprintf("Debug:github_url:%s", github_url))
    flog.info(sprintf("Debug:destdir:%s", destdir))
    flog.info(sprintf("Debug:version:%s", version))
  }
  if(!verbose) {
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
      if(verbose) {
        flog.info("Debug:Update Biosoftwares database step.")
      } else{
        last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        if(!is.null(name.saved)) {
          name <- tolower(name.saved)
        }
        change.info(name = name, installed = TRUE, source.dir = destdir, bin.dir = bin.dir, version = version,
          last.update.time = last.update.time, db = db, ...)
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
#' @param version Software version
#' @param show.list Logical wheather show all avaliable version can be install
#' @param destdir A string, point the install path
#' @param name.saved Software name when you want to install different version, you
#' can use this to point the installed softwares name like "GATK-3.7"
#' @param nongithub.cfg Configuration file of installed by non github url,
#' default is system.file('extdata', 'nongithub.toml', package='BioInstaller')
#' @param db File of saving softwares infomation, default is Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", 
#' system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller"))
#' @param download.only Logicol indicating wheather only download source or file (non-github)
#' @param decompress Logicol indicating wheather need to decompress the downloaded file, default is TRUE
#' @param ... Other key and value paired need be saved in BioInstaller passed to \code{\link{change.info}}
#' @param verbose TRUE is debug mode
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
install.nongithub <- function(name = "", version = NULL, show.list = FALSE, destdir = "./", 
  name.saved = NULL, nongithub.cfg = system.file("extdata", "nongithub.toml", package = "BioInstaller"), 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
    package = "BioInstaller")), download.only = FALSE, decompress = TRUE, verbose = FALSE, ...) {
  old.work.dir <- getwd()
  config.cfg <- nongithub.cfg
  name <- tolower(name)

  status <- config.and.name.initial(config.cfg, name)
  if(!status) {
    return(FALSE)
  }
  config <- eval.config()
  version <- version.initial(name, version, config)
  args.all <- as.list(match.call())
  args.all$version <- version
  args.all$destdir <- destdir
  args.all <- args.all[names(args.all) != ""]
  config <- parse.config.with.var(config = config, args.all = args.all)
  config <- parse.config.with.db(config, db)
  if (show.list) {
    show.avaliable.versions(config)
    return(NULL)
  }

  destdir <- normalizePath(destdir, mustWork = FALSE)
  status <- destdir.initial(destdir, strict = FALSE, download.only)
  if(status == FALSE) {
    return(FALSE)
  }

  source_url <- config$source_url
  filename <- url2filename(source_url)
  if(download.only && !verbose) {
    msg <- sprintf("Now start to download %s in %s.", name, destdir)
    flog.info(msg)
    destfile <- sprintf(sprintf("%s/%s", destdir, filename))
    status <- download.dir.files(config, source_url, destfile)
    return(status)
  } else if (download.only && verbose) {
    msg <- sprintf("Debug:Now need to download %s in %s.", name, destdir)
    flog.info(msg)
    return(TRUE)
  }

  process.dependence(config, db, destdir, verbose)
  config <- parse.config.with.db(config, db)
  extract_dir <- sprintf("%s/install_tmp/", tempdir())
  dir.create(extract_dir, showWarnings = FALSE)
  destfile <- sprintf("%s/%s", extract_dir, filename)

  if (show.list) {
    show.avaliable.versions(config)
    return(NULL)
  }
  if(!is.null(name.saved)) {
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
    status <- download.dir.files(config, source_url, destfile)
    if(!status) {
      return(FALSE)
    }
    status <- extract.file(destfile, destdir, decompress)
    if(!status) {
      return(FALSE)
    }
  }
  make.dir <- config$make_dir
  files <- list.files(destdir)
  if(!verbose) {
    set.makedir(make.dir, destdir)
  } else {
    flog.info("Debug:Now is step of set workdir of make")
  }
  if(!verbose){
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
      if(verbose) {
        flog.info("Update Biosoftwares database step.")
      } else {
        last.update.time <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        if(!is.null(name.saved)) {
          name <- tolower(name.saved)
        }
        change.info(name = name, installed = TRUE, source.dir = destdir, bin.dir = bin.dir, version = version,
          last.update.time = last.update.time, db = db, ...)
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
