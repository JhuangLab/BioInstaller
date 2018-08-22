#' Wrapper function of spack
#'
#' @param suffix_params Command line parameters of spack (prefix_params spack suffix_params)
#' @param prefix_params Command line parameters of spack (prefix_params spack suffix_params)
#' @param spack Default is Sys.which('spack')
#' @param ... Parameters pass to 'system'
#' @export
#'
#' @examples
#' \dontrun{
#'   spack()
#' }
spack <- function(suffix_params = "", prefix_params = "", spack = Sys.which("spack"), 
  ...) {
  spack <- unname(spack)
  if (spack == "") {
    warning("Executable 'spack' Not Found.")
    return(FALSE)
  }
  objs <- system(sprintf("%s%s %s", prefix_params, spack, suffix_params), intern = TRUE, 
    ...)
  paste0(objs, collapse = "\n")
}

#' Wrapper function of 'spack list', list and search available packages
#'
#' @param ... Parameters pass to \code{\link{spack}}
#' @export
#'
#' @examples
#' \dontrun{
#'   spack.list()
#' }
spack.list <- function(...) {
  objs <- spack("list", ...)
  if (is.logical(objs) && !objs) {
    return(FALSE)
  }
  text <- paste0(objs, collapse = "\n")
  x <- read.table(text = text)
  colnames(x) <- c("Name")
  return(x)
}
