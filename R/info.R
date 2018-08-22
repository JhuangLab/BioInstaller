#' Update biologly softwares infomation of system
#'
#' @param name Software name
#' @param installed Wheather be installed successful in system
#' @param source.dir Directorie of softwares source code
#' @param bin.dir Directorie of softwares bin
#' @param executable.files Executable files in bin.dir
#' @param db File saving softwares infomation
#' @param ... Other key and value paired need be saved in BioInstaller
#' @param verbose Ligical indicating wheather show the log message
#' @export
#' @return Bool Value
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' change.info(name = 'demo', installed = 'yes', source.dir = '',
#' bin.dir = '', excutable.files = c('demo'), others.customer = 'demo')
#' unlink(db)
change.info <- function(name = "", installed = TRUE, source.dir = "", bin.dir = "", 
  executable.files = "", db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", tempfile()), 
  ..., verbose = TRUE) {
  msg <- sprintf("Running change.info for %s and be saved to %s", name, db)
  info.msg(msg, verbose = verbose)
  source.dir <- normalizePath(source.dir, mustWork = F)
  bin.dir <- normalizePath(bin.dir, mustWork = F)
  db <- normalizePath(db, mustWork = F)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  config <- configr::read.config(file = config.cfg)
  config[[name]] = list(installed = installed, source.dir = source.dir, bin_dir = bin.dir, 
    executable_files = executable.files, ...)
  configr::write.config(config.dat = config, file = config.cfg, write.type = "yaml")
}

#' Show biologly softwares infomation of system
#'
#' @param name Software name
#' @param db File saving softwares infomation
#' @param verbose Ligical indicating wheather show the log message
#' @export
#' @return Bool Value
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' change.info(name = 'bwa', installed = 'yes', source.dir = '',
#' bin.dir = '', excutable.files = c('demo'), others.customer = 'demo')
#' get.info('bwa')
#' unlink(db)
get.info <- function(name = "", db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", tempfile()), 
  verbose = TRUE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  if (!(name %in% configr::eval.config.sections(file = db))) {
    warning(sprintf("%s not existed in BioInstaller database.", name))
    return(FALSE)
  }
  config <- configr::eval.config(config = name, file = db)
  return(config)
}

#' Delete biologly softwares infomation of system
#'
#' @param name Software name
#' @param db File saving softwares infomation
#' @param verbose Ligical indicating wheather show the log message
#' @export
#' @return Bool Value
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' change.info(name = 'bwa', installed = 'yes', source.dir = '',
#' bin.dir = '', excutable.files = c('demo'), others.customer = 'demo')
#' del.info('bwa')
#' unlink(db)
del.info <- function(name = "", db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", tempfile()), 
  verbose = TRUE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  if (!(name %in% configr::eval.config.sections(file = config.cfg))) {
    warning(sprintf("%s not existed in BioInstaller database.", name))
    return(FALSE)
  }
  config <- configr::read.config(config = name, file = config.cfg)
  config[[name]] <- NULL
  configr::write.config(config.dat = config, file = config.cfg, write.type = "yaml")
}

#' Show all installed bio-softwares in system
#'
#' @param db File saving softwares infomation
#' @param only.installed Logical wheather only show installed softwares in db
#' @param verbose Ligical indicating wheather show the log message
#' @export
#' @return Bool Value
#' @examples
#' db <- sprintf('%s/.BioInstaller', tempdir())
#' set.biosoftwares.db(db)
#' change.info(name = 'bwa', installed = 'yes', source.dir = '',
#' bin.dir = '', excutable.files = c('demo'), others.customer = 'demo')
#' show.installed()
#' unlink(db)
show.installed <- function(db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", tempfile()), 
  only.installed = TRUE, verbose = TRUE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  softwares <- c()
  sections <- configr::eval.config.sections(file = config.cfg)
  for (i in sections) {
    config <- eval.config(config = i, file = config.cfg)
    if ("installed" %in% names(config)) {
      is.installed <- config[["installed"]] %in% c(TRUE, "yes", 1)
    } else {
      is.installed <- FALSE
    }
    if (only.installed && is.installed) {
      softwares <- c(softwares, i)
    } else if (!only.installed) {
      softwares <- c(softwares, i)
    }
  }
  if (is.null(softwares)) {
    return(NULL)
  }
  attr(softwares, "file") <- db
  attr(softwares, "configtype") <- get.config.type(db)
  return(softwares)
}


db.check <- function(db) {
  if (!file.exists(db)) {
    if (!file.exists(dirname(db))) {
      status <- dir.create(dir.name(db), recursive = T)
    }
    status <- file.create(db)
    if (any(status == FALSE)) {
      return(FALSE)
    }
  }
  return(TRUE)
}
