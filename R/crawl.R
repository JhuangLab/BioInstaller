#' A function can be used to craw all source code from nongithub.cfg stored information
#' @param name Software name
#' @param download.dir Download destdir
#' @param nongithub.cfg Configuration file of installed by non github url,
#' default is system.file('extdata', 'config/nongithub/nongithub.toml', package='BioInstaller')
#' @param parse.extra.params Other parameters pass to \code{\link[configr]{parse.extra}}
#' @param license The BioInstaller download license code. 
#' @export
#' @examples
#' craw.all.versions('demo')
craw.all.versions <- function(name, download.dir = "./", nongithub.cfg = c(system.file("extdata", 
  "config/nongithub/nongithub.toml", package = "BioInstaller"), system.file("extdata", 
  "config/db/db_main.toml", package = "BioInstaller"), system.file("extdata", "config/db/db_annovar.toml", 
  package = "BioInstaller"), system.file("extdata", "config/db/db_blast.toml", 
  package = "BioInstaller")), parse.extra.params = list(extra.list = list(), rcmd.parse = TRUE, 
  bash.parse = TRUE, glue.parse = TRUE), license = "") {
  
  name <- tolower(name)
  versions <- install.bioinfo(name, show.all.versions = TRUE)
  if (!dir.exists(download.dir)) {
    dir.create(download.dir, recursive = TRUE)
  }
  parse.extra.params$extra.list <- config.list.merge(parse.extra.params$extra.list, 
    list(license = license))
  for (i in versions) {
    config <- fetch.config(nongithub.cfg)[[name]]
    parse.extra.params <- config.list.merge(parse.extra.params, list(config = config))
    parse.extra.params$extra.list$version = i
    config <- do.call(configr::parse.extra, parse.extra.params)
    urls <- config$source_url
    if (is.download.all.urls(config$url_all_download)) {
      urls <- lapply(urls, function(x) return(x[1]))
    }
    urls <- unlist(urls)
    for (j in urls) {
      dest.name = basename(j)
      if (!file.exists(dest.name) || file.size(dest.name) == 0) {
        tryCatch({
          fn <- sprintf("%s/%s", download.dir, dest.name)
          download.file(j, fn)
        }, error = function(e) {
        }, warning = function(w) {
          if (file.size(fn) == 0) {
          file.remove(fn)
          }
        })
      }
    }
  }
}

is.download.all.urls <- function(url_all_download) {
  !is.null(url_all_download) && url_all_download == FALSE
}
