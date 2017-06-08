# Check BioInstaller Database
db.check <- function(db) {
  if (file.exists(db)) {
    return(TRUE)
  } else {
    file.create(db)
  }
}
# Configuration file and install name initial
config.and.name.initial <- function(config.cfg, name) {
  status <- check.configfile.validate(config.cfg)
  if (!status) {
    return(FALSE)
  }
  status <- check.install.name(name, config.cfg)
  if (!status) {
    return(FALSE)
  }
  return(TRUE)
}

# Check configfile wheather is a valid format configuration file
check.configfile.validate <- function(config.cfg) {
  if (is.list(read.config(file = config.cfg))) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Check install function parametrs
check.install.name <- function(name, config.cfg) {
  if (!is.character(name)) {
    warning("Parameter 'name' must be a character.")
    return(FALSE)
  }
  if (!(name %in% eval.config.sections(file = config.cfg))) {
    if (name == "") {
      warning("Parameter 'name' can not be empty!")
    } else {
      warning(sprintf("%s are not available in BioInstaller.", name))
    }
    return(FALSE)
  }
  return(TRUE)
}

# Initial parameter version
version.initial <- function(name = "", version = NULL, versions = NULL, config = NULL) {
  if (is.null(version)) {
    params <- list(config = config, versions = versions)
    version <- do.call(version.newest, params)
  }
  if (is.numeric(version)) {
    version <- as.character(version)
  }
  if (!version %in% versions) {
    stop(sprintf("%s version of %s are not available!", version, name))
  }
  return(version)
}

# Check wheather show all avaliable version can be installed
show.avaliable.versions <- function(config, name) {
  flag <- use.github.response(config)
  if (flag) {
    versions <- as.character(get.github.version(config))
  } else {
    versions <- nongithub2versions(name)
    if (is.null(versions)) {
      versions <- config$version_available
    }
  }
  return(versions)
}

# Check wheather destdir is exist or not, if not will create it, and set workdir
# in make.dir
set.makedir <- function(make.dir, destdir) {
  destdir <- normalizePath(destdir, "/", mustWork = FALSE)
  if (dir.exists(destdir)) {
    setwd(destdir)
  } else {
    dir.create(destdir, showWarnings = FALSE, recursive = TRUE)
    setwd(destdir)
  }
  if (!is.null(make.dir)) {
    make.dir <- normalizePath(make.dir, "/", mustWork = FALSE)
    for (i in make.dir) {
      if (i != "./" && dir.exists(i)) {
        setwd(i)
      }
    }
  }
}

# Check dependence
is.need.dependence <- function(need.install) {
  return(length(need.install) > 0)
}

# Setted dependence
is.setted.dependence <- function(config) {
  return(!is.null(config$dependence_version) && !is.null(config$dependence))
}

check.need.install <- function(names, versions, db) {
  result <- c()
  names.installed <- show.installed(db)
  count <- 1
  for (i in names) {
    if (i %in% names.installed) {
      if (versions[count] == get.info(i)$version) {
        result <- c(result, TRUE)
      } else {
        result <- c(result, FALSE)
      }
    } else {
      result <- c(result, FALSE)
    }
    count <- count + 1
  }
  return(result)
}

# Get need install name
get.need.install <- function(config, db) {
  fil1 <- check.need.install(config$dependence, config$dependence_version, db)
  fil2 <- check.need.install(str_replace_all(config$dependence, "@", "_"), config$dependence_version, 
    db)
  need.install <- config$dependence[!(fil1 | fil2)]
  need.install.version <- config$dependence_version[!(fil1 | fil2)]
  return(list(need.install = need.install, need.install.version = need.install.version))
}

# Install dependence
install.dependence <- function(need.install, need.install.version, download.dir, 
  destdir, verbose) {
  info.msg(sprintf("Try install the dependence:%s", paste0(need.install, collapse = ", ")), 
    verbose = verbose)
  dest.path <- Sys.getenv("BIO_DEPENDENCE_DIR")
  if (dest.path != "") {
    dest.path <- normalizePath(dest.path, mustWork = F)
    download.dir <- dest.path
    destdir <- dest.path
  }
  download.dir = sprintf("%s/%s", download.dir, str_replace_all(need.install, "@", 
    "_"))
  install.status <- install.bioinfo(name = need.install, download.dir = download.dir, 
    destdir = rep(destdir, length(download.dir)), version = need.install.version, 
    verbose = verbose)
  fail.list <- install.status$fail.list
  if (!is.null(fail.list) && fail.list != "") {
    stop(sprintf("Dependence Error:%s install fail.", paste0(fail.list, collapse = ", ")))
  }
  return(TRUE)
}

# Dependence processor
process.dependence <- function(config, db, download.dir, destdir, verbose) {
  status <- TRUE
  if (is.setted.dependence(config)) {
    need.install <- get.need.install(config, db)$need.install
    need.install.version <- get.need.install(config, db)$need.install.version
    count <- 1
    if (is.need.dependence(need.install)) {
      status <- install.dependence(need.install, need.install.version, destdir = destdir, 
        download.dir = download.dir, verbose = verbose)
    }
  }
  return(status)
}

# Check wheather will download a dir
is.download.dir <- function(config) {
  return(!is.null(config$source_is.dir) && config$source_is.dir)
}


# According the config$source_is.dir decide wheather need to download a dir or a
# file to destfile
download.dir.files <- function(config, source_url, destfile, showWarnings = FALSE, 
  url.all.download = TRUE) {
  index <- !file.exists(dirname(destfile))
  if (any(index)) {
    need.create.dir <- dirname(destfile)[index]
    sapply(need.create.dir, function(x) {
      dir.create(x, showWarnings = showWarnings, recursive = TRUE)
    })
  }
  is.dir <- is.download.dir(config)
  count <- 1
  status <- c()
  for (i in source_url) {
    tryCatch({
      status.tmp <- download.file.custom(url = i, destfile = destfile[count], 
        is.dir = is.dir, showWarnings = showWarnings)
      if (!is.logical(status.tmp) && status.tmp == 0) {
        status.tmp <- TRUE
      } else {
        status.tmp <- FALSE
      }
      status.attr <- attributes(status)$success
      status <- c(status, status.tmp)
      if (status.tmp) {
        attr(status, "success") <- c(status.attr, destfile[count])
      }
      if (!url.all.download && status.tmp) {
        break
      }
    }, error = function(e) {
      if (showWarnings) {
        warning(e)
      }
    }, warning = function(w) {
      if (showWarnings) {
        warning(w)
      }
    })
    count <- count + 1
  }
  destfile <- unique(destfile)
  destfile <- destfile[file.exists(destfile)]
  
  if (!is.dir && all(!(file.size(destfile) > 0))) {
    return(FALSE)
  }
  if (is.dir && length(list.files(destfile)) == 0) {
    return(FALSE)
  }
  return(status)
}

# Convert URL to filename
url2filename <- function(url) {
  filename <- basename(url)
  filename <- str_replace_all(filename, ".*=", "")
  return(filename)
}

# Initital source_url
source.url.initial <- function(config) {
  source_url <- config$source_url
  if (is.null(source_url)) {
    return(NULL)
  }
  if (is.list(config$source_url)) {
    os.version <- get.os()
    if (os.version == "windows") {
      return(source_url$windows)
    } else if (os.version == "mac") {
      return(source_url$mac)
    } else {
      return(source_url$linux)
    }
  } else {
    return(config$source_url)
  }
}

convert.bool <- function(flag) {
  if (is.null(flag) || !(flag %in% c(FALSE, 0, "no", "false")) || flag %in% c("true", 
    TRUE, 1, "yes")) {
    TRUE
  } else {
    FALSE
  }
}

git.download <- function(name, destdir, version, github_url, use_git2r, recursive_clone, 
  verbose) {
  msg <- sprintf("Now start to download %s in %s.", name, destdir, verbose)
  info.msg(msg, verbose = verbose)
  use_git2r <- convert.bool(use_git2r)
  recursive_clone <- convert.bool(recursive_clone)
  if (use_git2r) {
    if (!dir.exists(dirname(destdir))) {
      dir.create(dirname(destdir), recursive = TRUE)
    }
    repo <- git2r::clone(github_url, destdir)
    if (version != "master") {
      text <- sprintf("git2r::checkout(git2r::tags(repo)[['%s']])", version)
      status <- eval(parse(text = text))
      status <- is.null(status)
    }
    if (length(list.files(destdir)) != 0) {
      status <- TRUE
    } else {
      status <- FALSE
    }
  } else {
    if (recursive_clone) {
      cmd <- sprintf("git clone --recursive %s %s", github_url, destdir)
    } else {
      cmd <- sprintf("git clone %s %s", github_url, destdir)
    }
    status <- for_runcmd(cmd)
    status <- status == 0
    status[is.null(status)] <- FALSE
    if (!status) {
      return(FALSE)
    }
    olddir <- getwd()
    setwd(destdir)
    if (version != "master") {
      status <- for_runcmd(sprintf("git checkout %s", version))
    }
    setwd(olddir)
  }
  return(status)
}


pre.process.dir <- function(name, destdir, download.dir, count) {
  if (is.null.na(destdir[count]) && !is.null.na(download.dir[count])) {
    download.dir[count] <- normalizePath(download.dir[count], mustWork = FALSE)
    destdir[count] <- download.dir[count]
  } else if (is.null.na(download.dir[count]) && !is.null.na(destdir[count])) {
    destdir[count] <- normalizePath(destdir[count], mustWork = FALSE)
    download.dir[count] <- destdir[count]
  } else if (is.null.na(download.dir[count]) && is.null.na(destdir[count])) {
    download.dir[count] <- sprintf("%s/%s", tempdir(), name)
    destdir[count] <- download.dir[count]
  } else {
    download.dir[count] <- normalizePath(download.dir[count], mustWork = FALSE)
    destdir[count] <- normalizePath(destdir[count], mustWork = FALSE)
  }
  processed.dirs <- list(des.dir = destdir[count], down.dir = download.dir[count])
  return(processed.dirs)
}
