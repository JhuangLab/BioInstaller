# Check BioInstaller Database
db.check <- function(db) {
  if(file.exists(db)) {
    return(TRUE)
  } else {
    file.create(db)
  }

}
# Configuration file and install name initial
config.and.name.initial <- function(config.cfg, name) {
  status <- check.configfile.validate(config.cfg)
  if(!status) {
    return(FALSE)
  }
  Sys.setenv(R_CONFIGFILE_ACTIVE = config.cfg)
  status <- check.install.name(name, config.cfg)
  if(!status) {
    return(FALSE)
  }
  Sys.setenv(R_CONFIG_ACTIVE = name)
  return(TRUE)
}

# Check configfile wheather is a valid format configuration file
check.configfile.validate <- function(config.cfg) {
  if(is.list(read.config(config.cfg))) {
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
  print(paste(config$version_available, sep = "\n"))
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
    need.install.version <- config$dependence_version[!config$dependence %in% 
      show.installed()]
    return(list(need.install = need.install, need.install.version = need.install.version))
}

# Install dependence
install.dependence <- function(need.install, need.install.version, destdir) {
  flog.info(sprintf("Try install the dependence:%s", paste0(need.install, collapse = ", ")))
  install.status <- install.bioinfo(need.install, sprintf("%s/%s", dirname(destdir), need.install), 
    version = need.install.version)
  fail.list <- install.status$fail.list
  if(!is.null(fail.list) && fail.list != "") {
    stop(sprintf("Dependence Error:%s install fail.", paste0(fail.list, collapse = ", ")))
  }
}

# Dependence processor
process.dependence <- function(config, db, destdir, verbose) {
  if(verbose) {
    sprintf("Debug:Check and install dependence step.")
  } else if (is.setted.dependence(config)) {
    need.install <- get.need.install(config, db)$need.install
    need.install.version <- get.need.install(config, db)$need.install.version
    if(is.need.dependence(need.install)) {
      install.dependence(need.install, need.install.version, destdir)
    }
  }
}


# Check wheather will download a dir
is.download.dir <- function(config) {
  return(!is.null(config$source_is.dir) && config$source_is.dir)
}


# According the config$source_is.dir decide wheather need to download a dir or a file to destfile
download.dir.files <- function(config, source_url, destfile) {
  if(any(!file.exists(dirname(destfile)))) {
    dir.create(dirname(destfile), showWarnings = FALSE, recursive = TRUE)
  }
  is.dir <- is.download.dir(config)
  count <- 1
  for (i in source_url) {
    tryCatch({download.file.custom(url = i, destfile = destfile[count], is.dir = is.dir);break}, 
      error = function(e) {
      }, warning = function(w) {})
    count <- count + 1
  }
  if (all(!file.exists(destfile))) {
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

# Parse config replace {{- htslib:bin_dir -}} to database value
parse.config.with.db <- function(config, db) {
  list.names <- names(config)
  for(list.item in list.names) {
    list.tmp <- config[[list.item]]
    if(is.list(list.tmp)) {
      config[[list.item]] <- parse.config.with.db(config[[list.item]], db)
    } else {
      if(all(!str_detect(list.tmp, "\\{\\{-"))) {
        next
      }
      text <- str_extract_all(list.tmp, "\\{\\{-.*-\\}\\}")
      text <- str_replace_all(text, fixed("{{-"), "")
      text <- str_split(text, fixed("-}}"))
      text <- text[[1]]
      text <- text[text != ""]
      text <- str_replace_all(text, " ", "")
      text.list <- str_split(text, ":")
      db.config <- read.config(file = db)
      for(i in 1:length(text.list)) {
          pass <- FALSE
          text.list.value <- text.list[[i]]
          for(j in 1:length(text.list.value)) {
              if(j == 1) {
                  if(text.list.value[[j]] %in% names(db.config)){
                    db.config.tmp <- db.config[[text.list.value[[j]]]]
                  } else {
                    db.config.tmp <- list()
                    pass <- TRUE 
                  }
              } else {
                  if(text.list.value[[j]] %in% names(db.config.tmp)){
                    db.config.tmp <- db.config.tmp[[text.list.value[[j]]]]
                  } else {
                    pass <- TRUE 
                  }
              }
          }
          if(!pass) {
            config[[list.item]] <- str_replace_all(config[[list.item]], sprintf("\\{\\{-%s-\\}\\}", text[i]), db.config.tmp)
          }
      }
    }
  }
  return(config)
}

parse.config.with.var <- function(config, args.all) {
  list.names <- names(config)
  for(list.item in list.names) {
    list.tmp <- config[[list.item]]
    if(is.list(list.tmp)) {
      config[[list.item]] <- parse.config.with.var(config[[list.item]], args.all)
    } else {
      if(all(!str_detect(list.tmp, "\\{\\{"))) {
        next
      }
      text <- str_extract_all(list.tmp, "\\{\\{.*\\}\\}")
      text <- str_replace_all(text, fixed("{{"), "")
      text <- str_split(text, fixed("}}"))
      text <- text[[1]]
      text <- text[text != ""]
      text <- str_replace_all(text, " ", "")
      for(item in text) {
        if(str_detect(item, "^-")){
          next
        }
        if(!item %in% names(args.all)) {
          next 
        }
        item.value <- eval(parse(text = sprintf("args.all$%s", item)))
        config[[list.item]] <- str_replace_all(config[[list.item]], sprintf("\\{\\{%s\\}\\}", item), item.value)
      }
    }
  }
  return(config)
}
