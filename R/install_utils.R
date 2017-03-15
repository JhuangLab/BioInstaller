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
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  status <- check.install.name(name, config.cfg)
  if (!status) {
    return(FALSE)
  }
  Sys.setenv(R_CONFIG_ACTIVE = name)
  return(TRUE)
}

# Check configfile wheather is a valid format configuration file
check.configfile.validate <- function(config.cfg) {
  if (is.list(read.config(config.cfg))) {
    return(TRUE)
  }
}

# Check install function parametrs
check.install.name <- function(name, config.cfg) {
  if (!is.character(name)) {
    warning("Parameter 'name' must be a character.")
    return(FALSE)
  }
  if (!(name %in% eval.config.groups(config.cfg))) {
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
version.initial <- function(name, version, config) {
  if (is.null(version)) {
    version <- config$version_newest
  }
  if (!version %in% config$version_available) {
    stop(sprintf("%s version of %s are not available!", version, name))
  }
  return(version)
}

# Check wheather show all avaliable version can be installed
show.avaliable.versions <- function(config) {
  return(config$version_available)
}

# Check wheather destdir is exist or not, if not will create it, and set workdir in make.dir
set.makedir <- function(make.dir, destdir) {
  if (dir.exists(destdir)) {
    setwd(destdir)
    for (i in make.dir) {
      if (i != "./" && dir.exists(i)) {
        setwd(i)
      }
    }
  } else {
    dir.create(destdir, showWarnings = FALSE, recursive = TRUE)
    setwd(destdir)
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

# Get need install name
get.need.install <- function(config, db) {
  need.install <- config$dependence[!config$dependence %in% show.installed(db)]
  need.install.version <- config$dependence_version[!config$dependence %in% show.installed()]
  return(list(need.install = need.install, need.install.version = need.install.version))
}

# Install dependence
install.dependence <- function(need.install, need.install.version, destdir) {
  flog.info(sprintf("Try install the dependence:%s", paste0(need.install, collapse = ", ")))
  install.status <- install.bioinfo(name = need.install, destdir = sprintf("%s/%s", dirname(destdir), need.install), version = need.install.version)
  fail.list <- install.status$fail.list
  if (!is.null(fail.list) && fail.list != "") {
    stop(sprintf("Dependence Error:%s install fail.", paste0(fail.list, collapse = ", ")))
  }
}

# Dependence processor
process.dependence <- function(config, db, destdir, verbose) {
  if (verbose) {
    sprintf("Debug:Check and install dependence step.")
  } else if (is.setted.dependence(config)) {
    need.install <- get.need.install(config, db)$need.install
    need.install.version <- get.need.install(config, db)$need.install.version
    count <- 1
    for(i in need.install) {
      if (is.need.dependence(i)) {
        install.dependence(i, need.install.version[count], destdir)
      }
      count <- count + 1
    }
  }
}


# Check wheather will download a dir
is.download.dir <- function(config) {
  return(!is.null(config$source_is.dir) && config$source_is.dir)
}


# According the config$source_is.dir decide wheather need to download a dir or a file to destfile
download.dir.files <- function(config, source_url, destfile, showWarnings = FALSE) {
  if (any(!file.exists(dirname(destfile)))) {
    dir.create(dirname(destfile), showWarnings = FALSE, recursive = TRUE)
  }
  is.dir <- is.download.dir(config)
  count <- 1
  for (i in source_url) {
    tryCatch({
      status <- download.file.custom(url = i, destfile = destfile[count], is.dir = is.dir)
      break
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
  
  if (!is.dir && all(!file.exists(destfile))) {
    return(FALSE)
  } else if (is.dir && length(list.files(destfile)) == 0) {
    return(FALSE)
  }
  status <- TRUE
  attr(status, "success") <- destfile[count]
  return(status)
}

# Convert URL to filename
url2filename <- function(url) {
  return(str_replace_all(url, ".*/", ""))
}
