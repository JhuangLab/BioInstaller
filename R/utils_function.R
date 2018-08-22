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

# Run shell or R cmd
runcmd <- function(cmd, verbose = TRUE) {
  if (is.character(cmd) && cmd != "") {
    if (str_detect(cmd, "^\\#R\\#") && str_detect(cmd, "\\#R\\#$")) {
      cmd <- str_replace_all(cmd, "^\\#R\\#", "")
      cmd <- str_replace_all(cmd, "\\#R\\#$", "")
      cmd <- str_replace_all(cmd, fixed("%'%"), "\"")
      cmd <- str_split(cmd, "\\\\n")[[1]]
      cmd <- paste0(cmd, collapse = ";")
      cmd <- str_replace_all(cmd, ";;", ";")
      cmd <- str_replace_all(cmd, fixed("{;"), fixed("{"))
      info.msg(sprintf("Running R CMD:%s", cmd), verbose = verbose)
      status <- -1
      tryCatch(status <- eval(parse(text = cmd)), error = function(e) {
        return(-1)
      })
      if (is.null(status) || is.na(status) || status != -1) {
        return(0)
      } else {
        return(-1)
      }
    } else {
      cmd <- str_replace_all(cmd, fixed("-e \\\""), "-e \"")
      cmd <- str_replace_all(cmd, fixed(")\\\""), ")\"")
      cmd <- str_replace_all(cmd, fixed("%'%"), "\"")
      info.msg(sprintf("Running CMD:%s", cmd), verbose = verbose)
      system(cmd)
    }
  } else {
    return(0)
  }
}

# Run a group of cmd
for_runcmd <- function(cmd_vector, verbose = TRUE) {
  if (is.null(cmd_vector)) {
    return(0)
  }
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
  if (!decompress || filetype == "other") {
    files <- list.files(dirname(file))
    files.path <- sprintf("%s/%s", dirname(file), files)
    
    rm.index <- file.size(files.path) == 0
    file.remove(files.path[rm.index])
    files.path <- files.path[!rm.index]
    destfiles.path <- sprintf("%s/%s", destdir, basename(files.path))
    status <- file.rename(files.path, destfiles.path)
    status <- all(status)
    return(status)
  }
  if (filetype == "zip") {
    unzip(file, exdir = destdir)
    status <- drop_redundance_dir(destdir)
  } else if (filetype %in% c("gz", "xz", "bz2")) {
    status <- gunzip(filename = file, sprintf("%s/%s", destdir, str_replace_all(basename(file), 
      ".gz$|.xz|.bz2", "")))
    status <- is.character(status)
  } else if (filetype %in% c("tar", "tar.gz", "tgz", "tar.bz2", "tar.xz")) {
    status <- untar(file, exdir = destdir)
    status <- drop_redundance_dir(destdir)
  } else {
    status <- TRUE
  }
  
  status <- all(status)
  return(status)
}


# Extract file and dirs if only one dir present after decomparessed
drop_redundance_dir <- function(destdir) {
  files.parent <- list.files(destdir)
  if (length(files.parent) == 1) {
    dirs.parent <- list.dirs(destdir)
    if (length(dirs.parent) == 1) {
      return(TRUE)
    }
    file.rename(sprintf("%s/%s", destdir, files.parent), sprintf("%s/tmp00", 
      destdir))
    unlink(sprintf("%s/%s", destdir, files.parent), recursive = TRUE)
    files.parent <- sprintf("%s/tmp00", destdir)
    files.child <- list.files(files.parent)
    files.path <- sprintf("%s/%s", files.parent, files.child)
    destfiles.path <- sprintf("%s/%s", destdir, files.child)
    status <- file.rename(files.path, destfiles.path)
    unlink(files.parent, recursive = TRUE)
    files.parent <- list.files(destdir)
    if (length(files.parent) > 0) {
      TRUE
    } else {
      FALSE
    }
  }
}

# Download from url, if is.dir is TRUE, it will get filenames first and download
# them (FTP supported only)
download.file.custom <- function(url = "", destfile = "", is.dir = FALSE, showWarnings = FALSE, 
  ...) {
  status <- NULL
  if (is.dir) {
    filenames <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
    filenames <- str_replace_all(filenames, "\r\n", "\n")
    filenames <- str_split(filenames, "\n")[[1]]
    filenames <- filenames[filenames != ""]
    if (!str_detect(url, "ftp://")) {
      filenames <- str_extract(filenames, "href=.*\">.*</a>")
      filenames <- str_split(filenames, "\"")
      filenames <- sapply(filenames, function(x) {
        return(x[2])
      })
      filenames <- filenames[!is.na(filenames)]
      dirs <- filenames[str_detect(filenames, "/$")]
      filenames <- filenames[!str_detect(filenames, ";|/")]
    }
    dir.create(destfile, showWarnings = showWarnings, recursive = TRUE)
    for (i in filenames) {
      fn <- sprintf("%s/%s", destfile, i)
      tryCatch({
        url.encode <- URLencode(sprintf("%s/%s", url, i))
        status.tmp <- download.file(url = url.encode, destfile = fn, ...)
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
    url.encode <- URLencode(url)
    status <- download.file(url = url.encode, destfile = destfile, ...)
  }
  return(status)
}

# Check destdir and decide wheather overwrite
destdir.initial <- function(destdir, strict = TRUE, download.only = FALSE, local.source = NULL, 
  is.git = TRUE, overwrite = FALSE) {
  if (!is.null(local.source)) {
    return(TRUE)
  }
  if (overwrite && dir.exists(destdir)) {
    unlink(destdir, recursive = TRUE)
  } else if (!is.git) {
    return(TRUE)
  }
  if (!download.only && file.exists(destdir) && length(list.files(destdir) != 0) && 
    strict) {
    flag <- "y"
    flag.input <- "N"
    count <- 1
    while (flag.input == "N" || !flag.input %in% c("y", "n", "Y", "N")) {
      if (count > 3) {
        cat("More than 3 counts input, default is not to overwrite.\n")
        return(FALSE)
      }
      if (flag.input != "N" && !(flag.input %in% c("y", "n", "Y", "N"))) {
        cat("Please input y/n/Y/N!\n")
      }
      flag.input <- readline(prompt = sprintf("%s not empty, overwrite?[y]", 
        destdir))
      flag.input <- str_sub(flag.input, 1, 1)
      flag.input <- tolower(flag.input)
      count <- count + 1
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
    count <- 1
    while (flag.input == "N" || !flag.input %in% c("y", "n", "Y", "N")) {
      if (count > 3) {
        cat("More than 3 counts input, default is not to overwrite.\n")
        return(FALSE)
      }
      if (flag.input != "N" && !(flag.input %in% c("y", "n", "Y", "N"))) {
        cat("Please input y/n/Y/N!\n")
      }
      flag.input <- readline(prompt = sprintf("%s existed, overwrite?[y]", 
        destdir))
      flag.input <- str_sub(flag.input, 1, 1)
      flag.input <- tolower(flag.input)
      count <- count + 1
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

is.null.na <- function(value) {
  return(is.null(value) || is.na(value))
}

info.msg <- function(msg, verbose = TRUE, ...) {
  if (verbose) {
    flog.info(msg, ...)
  }
}

print.vb <- function(x, verbose = TRUE, ...) {
  if (verbose) {
    print(x, ...)
  }
}
