#' Install and download massive bioinformatics analysis software and database,
#' such as NGS analysis tools with its required database or/and reference genome,
#' is still a complicated task. BioInstaller can be used to install
#' that tools and database in R conveniently.
#'
#' @author
#' Li Jianfeng \url{lee_jianfeng@sjtu.edu.cn}
#' @seealso
#' Useful links:
#'
#' \url{https://github.com/Miachol/BioInstaller}
#'
#' Report bugs at \url{https://github.com/Miachol/BioInstaller/issues}
#'
#' @docType package
#' @name BioInstaller
#' @import configr stringr futile.logger
#' @importFrom git2r clone checkout
#' @importFrom RCurl getURL basicTextGatherer
#' @importFrom R.utils gunzip gzip
#' @importFrom utils unzip untar download.file
NULL
