#' Test active configuration file
#'
#' Check whether a Bio Softwares DB is active
#'
#' @param biosoftwares.db Configuration filename of bio-softwares db
#' @return
#' Logical indicating whether the specified configuration file is active
#'
#' @examples
#' is.biosoftwares.db.active('config.cfg')
#' @export
is.biosoftwares.db.active <- function(biosoftwares.db) {
  biosoftwares.db <- normalizePath(biosoftwares.db)
  identical(biosoftwares.db, Sys.getenv("BIO_SOFTWARES_DB_ACTIVE", system.file("extdata", "softwares_db_demo.yaml", 
    package = "BioInstaller")))
}

#' Set BIO_SOFWARES_DB_ACTIVE as the BioInstaller db
#'
#' @param biosoftwares.db Configuration filename of bio-softwares db
#' @return
#' Logical indicate wheather set db successful 
#' @examples
#' set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))
#' @export
set.biosoftwares.db <- function(biosoftwares.db) {
  biosoftwares.db <- normalizePath(biosoftwares.db, mustWork = FALSE)
  if (!file.exists(biosoftwares.db)) {
    file.create(biosoftwares.db)
  }
  Sys.setenv(BIO_SOFTWARES_DB_ACTIVE = biosoftwares.db)
}
