#' Search softwares docker infomation in BioInstaller docker database 
#'
#' @param name Software name, e.g bwa
#' @param docker.db A list including docker repo infomation, 
#' default to use built-in config/docker/docker.toml
#' @export
#' @return A list 
#' @examples
#' docker.search('bwa')
docker.search <- function(name, docker.db = system.file("extdata", "config/docker/docker.toml", 
  package = "BioInstaller")) {
  docker.db.dat <- configr::read.config(file = docker.db)
  docker.db.dat.names <- names(docker.db.dat)
  candidates <- docker.db.dat.names[str_detect(docker.db.dat.names, name)]
  return(docker.db.dat[candidates])
}


#' Use docker to pull image
#'
#' @param repo, Repository name of docker hub, e.g life2cloud 
#' @param name Software name, e.g bwa
#' @param version Image version
#' @param all.tags Download all tagged images in the repository
#' @param disable.content.trust Skip image verification (default true)
#' @param docker.bin Docker executable file, default is 'docker' in $PATH
#' @param verbose Ligical indicating wheather show the log message
#' @export
#' @return Bool Value
#' @examples
#' docker.bin <- unname(Sys.which('docker'))
#' if (docker.bin != '') {
#'   docker.pull(repo = 'learn', name = 'tutorial')
#' }
docker.pull <- function(repo, name, version = NULL, docker.bin = NULL, all.tags = FALSE, 
  disable.content.trust = TRUE, verbose = TRUE) {
  if (is.null(docker.bin)) {
    docker.bin <- unname(Sys.which("docker"))
    if (docker.bin == "") {
      stop("Docker executable file were not be specified.")
    }
  }
  if (!is.null(version)) {
    image <- sprintf("%s/%s", repo, name)
    msg <- sprintf("Now start to pull docker image %s.", image)
    info.msg(msg, verbose = verbose)
    cmd <- sprintf("%s pull %s", docker.bin, image)
  } else {
    image <- sprintf("%s/%s:%s", repo, name, version)
    msg <- sprintf("Now start to pull docker image %s.", image)
    info.msg(msg, verbose = verbose)
    cmd <- sprintf("%s pull %s", docker.bin, image)
  }
  if (all.tags) {
    cmd <- str_replace(cmd, " pull ", " -a pull ")
  }
  if (!disable.content.trust) {
    cmd <- str_replace(cmd, " pull ", " --disable-content-trust pull ")
  }
  for_runcmd(cmd, verbose = verbose)
}
