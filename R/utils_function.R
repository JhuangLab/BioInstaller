# Check the file or dir wheather exists(file need size > 0) @param path A string.
# @return Bool Value @examples isexist('~/workdir')
is.file.empty <- function(path) {
  if (!is.na(file.size(path)) & file.size(path) > 0) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

# Get the operating system distribution
get.os <- function() {
  os <- Sys.info()["sysname"][[1]]
  if (os == "Linux") {
    centos.flag <- as.character(Sys.which("yum"))
    ubuntu.flag <- as.character(Sys.which("apt-get"))
    arch.flag <- as.character(Sys.which("pacman"))
    if (centos.flag != "") {
      return("centos")
    } else if (ubuntu.flag != "") {
      return("ubuntu")
    } else if (arch.flag != "") {
      return("arch")
    } else {
      return("other")
    }
  } else if (os == "Darwin") {
    return("mac")
  } else if (os == "Windows") {
    return("windows")
  } else {
    return("other")
  }
}

runcmd <- function(cmd, verbose = FALSE) {
  if (verbose) {
    flog.info(sprintf("Need to run CMD:%s", cmd))
    return(0)
  } else if (is.character(cmd) && cmd != "") {
    cmd <- str_replace_all(cmd, fixed("-e \\\""), "-e \"")
    cmd <- str_replace_all(cmd, fixed(")\\\""), ")\"")
    flog.info(sprintf("Running CMD:%s", cmd))
    system(cmd)
  } else {
    return(0)
  }
}

for_runcmd <- function(cmd_vector, verbose = FALSE) {
  status.vector <- NULL
  for (i in cmd_vector) {
    if (i != "") {
      status <- runcmd(i, verbose)
      status.vector <- c(status.vector, status)
    } else {
      status <- 0
      status.vector <- c(status.vector, status)
    }
  }
  return(status.vector)
}

get.subconfig <- function(config, subconfig) {
  os <- get.os()
  if (is.null(config[[subconfig]])) {
    return("")
  }
  if (!is.list(config[[subconfig]])) {
    return(config[[subconfig]])
  }
  if (os == "mac") {
    return(config[[subconfig]]$mac)
  } else if (os == "windows") {
    return(config[[subconfig]]$windows)
  } else {
    return(config[[subconfig]]$linux)
  }
}

get.file.type <- function(file) {
  filetype.lib <- c("tgz$", "tar.xz$", "tar.bz2$", "tar.gz$", "tar$", "gz$", "zip$", 
    "bz2$", "xz$")
  if (is.na(file)) {
    return(FALSE)
  }
  for (i in filetype.lib) {
    if (str_detect(file, i)) {
      return(str_replace_all(i, fixed("$"), ""))
    }
  }
  return("other")
}
extract.file <- function(file, destdir, decompress = TRUE) {
  filetype <- get.file.type(file)
  if (filetype == FALSE) {
    status <- FALSE
  }
  dir.create(destdir, showWarnings = F, recursive = TRUE)
  if (!decompress) {
    files <- list.files(dirname(file))
    files.path <- sprintf("%s/%s", dirname(file), files)
    destfiles.path <- sprintf("%s/%s", destdir, files)
    if (sum(length(list.files(files.path))) == 0) {
      status <- file.copy(files.path, destfiles.path)
    } else {
      status <- file.copy(files.path, destdir, recursive = T)
    }
    status <- all(status)
    return(status)
  }
  if (filetype == "zip") {
    unzip(file, exdir = destdir)
    status <- drop_redundance_dir(destdir)
  } else if (filetype %in% c("gz", "xz", "bz2")) {
    gunzip(file)
    status <- drop_redundance_dir(destdir)
  } else if (filetype %in% c("tar", "tar.gz", "tgz", "tar.bz2", "tar.xz")) {
    status <- untar(file, exdir = destdir)
    status <- drop_redundance_dir(destdir)
  } else {
    status <- TRUE
  }
  
  status <- all(status)
  return(status)
}


drop_redundance_dir <- function(destdir) {
  files.parent <- list.files(destdir)
  if (length(files.parent) == 1) {
    file.rename(sprintf("%s/%s", destdir, files.parent), sprintf("%s/tmp00", 
      destdir))
    unlink(sprintf("%s/%s", destdir, files.parent), recursive = TRUE)
    files.parent <- sprintf("%s/tmp00", destdir)
    files.child <- list.files(files.parent)
    files.path <- sprintf("%s/%s", files.parent, files.child)
    destfiles.path <- sprintf("%s/%s", destdir, files.child)
    if (sum(length(list.files(files.path))) == 0) {
      status <- file.copy(files.path, destfiles.path)
    } else {
      status <- file.copy(files.path, destdir, recursive = T)
    }
    unlink(files.parent, recursive = TRUE)
    files.parent <- list.files(destdir)
    if (length(files.parent) > 0) {
      TRUE
    } else {
      FALSE
    }
  }
}

download.file.custom <- function(url = "", destfile = "", is.dir = FALSE, showWarnings = F, 
  ...) {
  status <- NULL
  if (is.dir) {
    filenames <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    filenames <- str_replace_all(filenames, "\r\n", "\n")
    filenames <- str_split(filenames, "\n")[[1]]
    filenames <- filenames[filenames != ""]
    dir.create(destfile, showWarnings = F, recursive = TRUE)
    for (i in filenames) {
      fn <- sprintf("%s/%s", destfile, i)
      tryCatch({
        status.tmp <- download.file(url = sprintf("%s/%s", url, i), destfile = fn)
        status <- c(status.tmp, status)
      }, error = function(e) {
        if (showWarnings) {
          warning(e)
        }
      }, warning = function(w) {
        if (showWarnings) {
          warning(w)
        }
      })
    }
    if (any(status == 0)) {
      status <- 0
    }
  } else {
    status <- download.file(url = url, destfile = destfile, ...)
  }
  return(status)
}

# Check destdir and decide wheather overwrite
destdir.initial <- function(destdir, strict = TRUE, download.only = FALSE) {
  if (!download.only && file.exists(destdir) && length(list.files(destdir) != 0) && 
    strict) {
    flag <- "y"
    flag.input <- "N"
    while (flag.input == "N" || !flag.input %in% c("y", "n", "Y", "N")) {
      if (flag.input != "N" && !(flag.input %in% c("y", "n", "Y", "N"))) {
        cat("Please input y/n/Y/N!\n")
      }
      flag.input <- readline(prompt = sprintf("%s not empty, overwrite?[y]", 
        destdir))
      flag.input <- str_sub(flag.input, 1, 1)
      flag.input <- tolower(flag.input)
    }
    if (flag.input == "n") {
      return(FALSE)
    } else {
      unlink(destdir, recursive = TRUE)
      return(TRUE)
    }
  } else if (!download.only && file.exists(destdir) && !strict) {
    flag <- "y"
    flag.input <- "N"
    while (flag.input == "N" || !flag.input %in% c("y", "n", "Y", "N")) {
      if (flag.input != "N" && !(flag.input %in% c("y", "n", "Y", "N"))) {
        cat("Please input y/n/Y/N!\n")
      }
      flag.input <- readline(prompt = sprintf("%s existed, overwrite?[y]", 
        destdir))
      flag.input <- str_sub(flag.input, 1, 1)
      flag.input <- tolower(flag.input)
    }
    if (flag.input == "n") {
      return(FALSE)
    } else {
      unlink(destdir, recursive = TRUE)
      return(TRUE)
    }
  }
  return(TRUE)
}
