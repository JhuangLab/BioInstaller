#' Wrapper function of conda
#'
#' @param suffix_params Command line parameters of conda
#' @param prefix_params Command line parameters of conda
#' @param conda Default is Sys.which('conda')
#' @param ... Parameters pass to 'system'
#' @export
#'
#' @examples
#' \dontrun{
#'   conda()
#' }
conda <- function(suffix_params = "", prefix_params = "", conda = Sys.which("conda"), 
  ...) {
  conda <- unname(conda)
  if (conda == "") {
    warning("Executable 'conda' Not Found.")
    return(FALSE)
  }
  objs <- system(sprintf("%s%s %s", prefix_params, conda, suffix_params), intern = TRUE, 
    ...)
  x <- paste0(objs, collapse = "\n")
  return(x)
}

#' Wrapper function of 'conda list', list linked packages in a conda environment.
#'
#' @param env_name Name of environment, default is current
#' @param ... Parameters pass to \code{\link{conda}}
#' @export
#'
#' @examples
#' \dontrun{
#'   conda.list()
#'   conda.list(env_name = 'your_env')
#' }
conda.list <- function(env_name = "base", ...) {
  if (!is.null(env_name) && env_name != "") 
    objs <- conda("list", prefix_params = sprintf("source activate %s;", env_name), 
      ...)
  if (is.null(env_name) || env_name == "") 
    objs <- conda("list", ...)
  if (is.logical(objs) && !objs) {
    return(FALSE)
  }
  text <- paste0(objs, collapse = "\n")
  x <- tryCatch(read.table(text = text, fill = TRUE), error = function(e) {
    data.frame()
  })
  if (nrow(x) == 0) 
    return(x)
  colnames(x)[1:3] <- c("Name", "Version", "Build")
  if (ncol(x) == 4) 
    colnames(x)[4] <- "Channel"
  return(x)
}

#' Wrapper function of 'conda env list', list the Conda environments
#'
#' @param ... Parameters pass to \code{\link{conda}}
#' @export
#'
#' @examples
#' \dontrun{
#'   conda.env.list()
#' }
conda.env.list <- function(...) {
  objs <- conda("env list", ...)
  if (is.logical(objs) && !objs) {
    return(FALSE)
  }
  text <- paste0(objs, collapse = "\n")
  x <- read.table(text = str_replace(text, " [*] ", ""), skip = 2)
  colnames(x) <- c("env_name", "env_path")
  return(x)
}

#' Wrapper function of 'conda env create', create an environment based on an environment file
#'
#' @param env_name Name of environment
#' @param env_file Environment definition file (default: environment.yml)
#' @param env_path Full path to environment prefix
#' @param params Extra command line parameters of conda
#' @param ... Parameters pass to \code{\link{conda}}
#' @export
#'
#' @examples
#' \dontrun{
#'   conda.env.create(params = 'vader/deathstar')
#'   conda.env.create(env_name = 'name')
#'   conda.env.create(env_file = '/path/to/environment.yml')
#'   conda.env.create(env_name = 'deathstar',
#'                    env_file = '/path/to/requirements.txt')
#'   conda.env.create(env_file = '/path/to/requirements.txt',
#'   env_path = '/home/user/software/deathstar')
#' }
conda.env.create <- function(env_name = "", env_file = "", env_path = "", params = "", 
  ...) {
  if (env_name != "") 
    env_name <- paste0("-n ", env_name, " ")
  if (env_file != "") 
    env_file <- paste0("-f=", env_file, " ")
  if (env_path != "") 
    env_path <- paste0("-p ", env_path, " ")
  conda(sprintf("env create %s%s%s%s", env_name, env_file, env_path, params), ...)
}
