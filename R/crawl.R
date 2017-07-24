#' A function can be used to craw all source code from nongithub.cfg stored information
#' @param name Software name
#' @param download.dir Source code stored dir
#' @param nongithub.cfg Configuration file of installed by non github url,
#' @param ... Other parameters pass to \code{\link[configr]{parse.extra}}
#' default is system.file('extdata', 'nongithub.toml', package='BioInstaller')
#' @export
#' @examples
#' craw.all.versions('demo')
craw.all.versions <- function(name, download.dir = "./", nongithub.cfg = system.file("extdata", 
  "nongithub.toml", package = "BioInstaller"), ...) {
  
  versions <- install.bioinfo(name, show.all.versions = TRUE)
  
  for (i in versions) {
    parse.extra.params <- list(...)
    parse.extra.params <- config.list.merge(parse.extra.params, list(config = name, 
      file = nongithub.cfg))
    parse.extra.params$extra.list$version = i
    config <- do.call(configr::eval.config, parse.extra.params)
    urls <- config$source_url
    if (is.download.all.urls(config$url_all_download)) {
      urls <- lapply(urls, function(x) return(x[1]))
    }
    urls <- unlist(urls)
    for (j in urls) {
      dest.name = basename(j)
      if (!file.exists(dest.name)) {
        tryCatch(download.file(j, dest.name), error = function(e) {
        }, warning = function(w) {
        })
      }
    }
  }
}

is.download.all.urls <- function(url_all_download) {
  !is.null(url_all_download) && url_all_download == FALSE
}
