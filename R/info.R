#' Update biologly softwares infomation of system
#'
#' @param name Software name
#' @param installed Wheather be installed successful in system
#' @param source.dir Directorie of softwares source code
#' @param bin.dir Directorie of softwares bin
#' @param executable.files Executable files in bin.dir
#' @param db File of saving softwares infomation
#' @param ... Other key and value paired need be saved in BioInstaller
#' @param verbose TRUE is debug mode
#' @export
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' change.info(name = 'demo', installed = 'yes', source.dir = '',
#' bin.dir = '', excutable.files = c('demo'), others.customer = 'demo')
change.info <- function(name = "", installed = TRUE, source.dir = "", bin.dir = "", executable.files = "", 
  db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", package = "BioInstaller")), 
  ..., verbose = FALSE) {
  msg <- sprintf("Running change.info for %s and be saved to %s", name, db)
  flog.info(msg)
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
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  config <- configr::read.config()
  config[[name]] = list(installed = installed, source.dir = source.dir, bin_dir = bin.dir, executable_files = executable.files, 
    ...)
  configr::write.config(config.dat = config, write.type = "yaml")
}

#' Show biologly softwares infomation of system
#'
#' @param name Software name
#' @param db File of saving softwares infomation
#' @param verbose TRUE is debug mode
#' @export
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' get.info('bwa')
get.info <- function(name = "", db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
  package = "BioInstaller")), verbose = FALSE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  if (!(name %in% configr::eval.config.groups())) {
    warning(sprintf("%s not existed in BioInstaller database.", name))
    return(FALSE)
  }
  Sys.setenv(R_CONFIG_ACTIVE = name)
  config <- configr::eval.config()
  return(config)
}

#' Delete biologly softwares infomation of system
#'
#' @param name Software name
#' @param db File of saving softwares infomation
#' @param verbose TRUE is debug mode
#' @export
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' del.info('bwa')
del.info <- function(name = "", db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
  package = "BioInstaller")), verbose = FALSE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  if (!(name %in% configr::eval.config.groups())) {
    warning(sprintf("%s not existed in BioInstaller database.", name))
    return(FALSE)
  }
  config <- configr::read.config(config = name)
  config[[name]] <- NULL
  configr::write.config(config.dat = config, write.type = "yaml")
}

#' Show all installed bio-softwares in system
#'
#' @param db File of saving softwares infomation
#' @param only.installed Logical wheather only show installed softwares in db
#' @param verbose TRUE is debug mode
#' @export
#' @return Bool Value
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' show.installed()
show.installed <- function(db = Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
  package = "BioInstaller")), only.installed = TRUE, verbose = FALSE) {
  db <- normalizePath(db, mustWork = FALSE)
  if (!db.check(db)) {
    return(FALSE)
  }
  config.cfg <- db
  if (!file.exists(config.cfg)) {
    file.create(config.cfg)
  }
  softwares <- c()
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  groups <- configr::eval.config.groups()
  for (i in groups) {
    Sys.setenv(R_CONFIG_ACTIVE = i)
    config <- eval.config()
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
