#' Function to run BioInstaller shiny APP service
#'
#' @param appDir The application to run.
#' Default is system.file('extdata', 'tools/shiny/R', package = 'BioInstaller')
#' @param auto_create Auto create dir, default is FALSE
#' @param ... Other parameters pass to \code{\link[shiny]{runApp}}
#' @export
#'
#' @examples
#' \dontrun{
#'   web(auto_create = TRUE)
#' }
web <- function(appDir = system.file("extdata", "shiny", package = "BioInstaller"), 
  auto_create = FALSE, ...) {
  params <- list(...)
  params <- config.list.merge(list(appDir), params)
  Sys.setenv(AUTO_CREATE_BIOINSTALLER_DIR = FALSE)
  if (auto_create) 
    Sys.setenv(AUTO_CREATE_BIOINSTALLER_DIR = TRUE)
  do.call(runApp, params)
}

#' Function to set shiny workers for background service
#'
#'
#' @param n Number of needed workers
#' @param shiny_config_file BioInstaller shiny configuration file
#' @param auto_create Auto create log dir, default is FALSE
#' @export
#' @examples
#' \dontrun{
#' set_shiny_workers(4)
#' }
set_shiny_workers <- function(n, shiny_config_file = Sys.getenv("BIOINSTALLER_SHINY_CONFIG", 
  system.file("extdata", "config/shiny/shiny.config.yaml", package = "BioInstaller")), 
  auto_create = FALSE) {
  config <- configr::read.config(shiny_config_file)
  log_dir <- config$shiny_queue$log_dir
  if (auto_create) {
    if (!dir.exists(log_dir)) {
      dir.create(log_dir, recursive = TRUE)
    }
    Sys.setenv(AUTO_CREATE_BIOINSTALLER_DIR = TRUE)
  }
  worker_script <- system.file("extdata", "shiny/worker.R", package = "BioInstaller")
  
  for (i in 1:n) {
    system(sprintf("Rscript %s &> %s/worker_%s.log &", worker_script, log_dir, 
      stringi::stri_rand_strings(1, 20)))
  }
}

#' Function to copy the default plugins of BioInstaller
#' 
#' @param plugin_dir The destdir to store plugins [~/.BioInstaller/plugins]
#' @param template_dir The template dir system.file('extdata', 'config/shiny/', 
#' package = 'BioInstaller')
#' @param pattern Used in \code{\link{list.files}} ['shiny.*.parameters.toml']
#' @param auto_create Auto create dir, default is FALSE
#' @export
#' @examples
#' copy_plugins(tempdir())
copy_plugins <- function(plugin_dir = "~/.BioInstaller/plugins", template_dir = system.file("extdata", 
  "config/shiny/", package = "BioInstaller"), pattern = "shiny.*.parameters.toml", 
  auto_create = FALSE) {
  plugin_dir <- normalizePath(plugin_dir, mustWork = FALSE)
  if (!dir.exists(plugin_dir) && auto_create) {
    dir.create(plugin_dir, recursive = TRUE)
  } else if (!dir.exists(plugin_dir) && !auto_create) {
    warning(sprintf("Plugin dir %s not exists and auto_create was FALSE.", plugin_dir))
    return(FALSE)
  }
  if (!dir.exists(template_dir)) {
    warning(sprintf("Template dir %s not exists.", template_dir))
    return(FALSE)
  }
  all_plugins <- list.files(template_dir, pattern, full.names = TRUE)
  if (length(all_plugins) >= 1) 
    file.copy(all_plugins, plugin_dir)
}


#' Function to copy the default configuration file of BioInstaller
#' 
#' @param config_dir The destdir to store plugins [~/.BioInstaller]
#' @param template_dir The template dir system.file('extdata', 'config/shiny/', 
#' package = 'BioInstaller')
#' @param pattern Used in \code{\link{list.files}} ['shiny.config.yaml']
#' @param auto_create Auto create dir, default is FALSE
#' @export
#' @examples
#' copy_configs(tempdir())
copy_configs <- function(config_dir = "~/.BioInstaller/", template_dir = Sys.getenv("BIOINSTALLER_SHINY_CONFIG", 
  system.file("extdata", "config/shiny/", package = "BioInstaller")), pattern = "shiny.config.yaml", 
  auto_create = FALSE) {
  config_dir <- normalizePath(config_dir, mustWork = FALSE)
  if (!dir.exists(config_dir) && auto_create) {
    dir.create(config_dir, recursive = TRUE)
  } else if (!dir.exists(config_dir) && !auto_create) {
    warning(sprintf("Config dir %s not exists and auto_create was FALSE.", config_dir))
    return(FALSE)
  }
  if (!dir.exists(template_dir)) {
    warning(sprintf("Template dir %s not exists.", template_dir))
    return(FALSE)
  }
  all_configs <- list.files(template_dir, pattern, full.names = TRUE)
  if (length(all_configs) >= 1) 
    file.copy(all_configs, config_dir)
}
