#' This package is a new platform to construct interactive and reproducible biological 
#' data analysis applications based on R language, which includes the R functions and R 
#' Shiny application, REST APIs.
#'
#' @author
#' Li Jianfeng \url{lee_jianfeng@sjtu.edu.cn}
#' @seealso
#' Useful links:
#'
#' \url{https://github.com/JhuangLab/BioInstaller}
#'
#' Report bugs at \url{https://github.com/JhuangLab/BioInstaller/issues}
#'
#' @docType package
#' @name BioInstaller
#' @import configr stringr futile.logger rvest liteq
#' @importFrom jsonlite fromJSON
#' @importFrom git2r clone checkout
#' @importFrom stringi stri_rand_strings
#' @importFrom RCurl getURL basicTextGatherer
#' @importFrom R.utils gunzip gzip
#' @importFrom utils unzip untar download.file URLencode read.table
#' @importFrom utils compareVersion install.packages installed.packages
#' @importFrom devtools install_github install_url
#' @importFrom shiny runApp
NULL
