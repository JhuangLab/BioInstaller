#' Get all BioInstaller meta files path, such as database, 
#' GitHub source, non-GitHub source, web source
#'
#' @param db.meta Database source meta file path, default is 
#' system.file('extdata', 'config/db/db_meta.toml', package = 'BioInstaller')
#' @param github.meta Github source meta file path, default is 
#' system.file('extdata', 'config/github/github_meta.toml', package = 'BioInstaller')
#' @param nongithub.meta non-Github source meta file path, default is 
#' system.file('extdata', 'config/nongithub/nongithub_meta.toml', package = 'BioInstaller')
#' @param web.meta Web source meta file path, default is 
#' system.file('extdata', 'config/web/web_meta.toml', package = 'BioInstaller')
#' @return
#' List contain the meta files path of BioInstaller collected sources
#' @export
#'
#' @examples
#' get.meta.files()
get.meta.files <- function(db.meta = system.file("extdata", "config/db/db_meta.toml", 
  package = "BioInstaller"), github.meta = system.file("extdata", "config/github/github_meta.toml", 
  package = "BioInstaller"), nongithub.meta = system.file("extdata", "config/nongithub/nongithub_meta.toml", 
  package = "BioInstaller"), web.meta = system.file("extdata", "config/web/web_meta.toml", 
  package = "BioInstaller")) {
  meta_files <- list(db_meta_file = db.meta, github_meta_file = github.meta, nongithub_meta_file = nongithub.meta, 
    web_meta_file = web.meta)
  return(meta_files)
}

#' Get meta information of BioInstaller collected sources, such as database, 
#' GitHub source, non-GitHub source, web source
#'
#' @param value Avaliable option for `db`, `github`, `nongithub`: `cfg_meta`, `item`; 
#' for web: `item`
#' @param config Avaliable option: `db`, `db_meta_file`, `github`, `github_meta_file`,
#' `nongithub`, `nongithub_meta_file`, `web`, `web_meta_file`
#' @param get.meta.files.params Params pass to \code{\link{get.meta.files}}
#' @param read.config.params Params pass to \code{\link[configr]{read.config}}
#' @return
#' List contain the meta files path of BioInstaller collected sources
#' @export
#'
#' @examples
#' meta <- get.meta()
#' db_cfg_meta <- get.meta(config = 'db', value = 'cfg_meta')
#' db_meta_file <- get.meta(config = 'db_meta_file')
#' db_cfg_meta_parsed <- get.meta(value = 'cfg_meta', config = 'db', 
#' read.config.params = list(rcmd.parse = TRUE))
get.meta <- function(value = NULL, config = NULL, get.meta.files.params = NULL, read.config.params = NULL) {
  if (is.null(get.meta.files.params)) {
    meta_files <- get.meta.files()
  } else {
    meta_files <- do.call("get.meta.files", get.meta.files.params)
  }
  config.list <- list()
  for (i in meta_files) {
    if (!is.null(read.config.params)) {
      params <- config.list.merge(list(file = i), read.config.params)
      config.list.tmp <- do.call("read.config", params)
    } else {
      config.list.tmp <- read.config(file = i)
    }
    config.list.tmp$Title <- NULL
    config.list <- config.list.merge(config.list, config.list.tmp)
  }
  config.list <- config.list.merge(meta_files, config.list)
  if (!is.null(config) && !is.null(value)) {
    return(config.list[[config]][[value]])
  } else if (!is.null(config) && is.null(value)) {
    return(config.list[[config]])
  } else {
    return(config.list)
  }
}
