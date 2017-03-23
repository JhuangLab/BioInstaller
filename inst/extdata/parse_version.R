library("RCurl")
library("stringr")
options(stringsAsFactors = F)
# Get All Hisat2 ftp reffa url
get.hisat2.reffa.url <- function() {
  url <- "ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/"
  filenames <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames <- str_replace_all(filenames, "\r\n", "\n")
  filenames <- str_split(filenames, "\n")[[1]]
  filenames <- filenames[filenames != ""]
  return(paste0(rep(url, length(filenames)), filenames))
}

# Get All Hisat2 ftp reffa name
get.hisat2.reffa.name <- function() {
  url <- "ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/"
  filenames <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames <- str_replace_all(filenames, "\r\n", "\n")
  filenames <- str_split(filenames, "\n")[[1]]
  filenames <- filenames[filenames != ""]
  name <- str_replace_all(filenames, ".tar.gz", "")
  name <- paste0("hisat2_", name)
  return(name)
}

# Get All Hisat2 ftp reffa markdown table
get.hisat2.reffa.md <- function(out.md) {
  url <- "ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/"
  filenames <- getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames <- str_replace_all(filenames, "\r\n", "\n")
  filenames <- str_split(filenames, "\n")[[1]]
  filenames <- filenames[filenames != ""]
  name <- str_replace_all(filenames, ".tar.gz", "")
  name <- paste0("hisat2_", name)
  filenames <- paste0(rep(url, length(filenames)), filenames)
  writeLines(paste(name, filenames, sep = " | ", collapse = "\n"), out.md)
}

# Function get GMAP-GSNAP all versions
get.gmap.versions <- function() {
  urls <- c("http://research-pub.gene.com/gmap/archive.html", "http://research-pub.gene.com/gmap/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "gmap")]
    
    downlad_url <- str_extract(web, "href=.*z>")
    downlad_url <- str_replace(downlad_url, "href=|>", "")
    downlad_url <- paste0("http://research-pub.gene.com/gmap/", downlad_url)
    
    versions <- str_extract(downlad_url, "gmap-.*.tar")
    versions <- str_replace(versions, ".tar$", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get GMAP-GSNAP latest version
get.gmap.newest.version <- function() {
  urls <- c("http://research-pub.gene.com/gmap/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "gmap")]
    web <- web[str_detect(web, "Latest")]
    
    downlad_url <- str_extract(web, "href=.*z>")
    downlad_url <- str_replace(downlad_url, "href=|>", "")
    downlad_url <- paste0("http://research-pub.gene.com/gmap/", downlad_url)
    
    versions <- str_extract(downlad_url, "gmap-.*.tar")
    versions <- str_replace(versions, ".tar$", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}


# Function get Edena all versions
get.edena.versions <- function() {
  urls <- c("http://www.genomic.ch/edena.php")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "Edena")]
    
    downlad_url <- str_extract(web, "href=\".*[zp]\"")
    downlad_url <- str_replace_all(downlad_url, "href=\"|\"", "")
    downlad_url <- str_replace(downlad_url, fixed("./"), "http://www.genomic.ch/")
    
    versions <- str_extract(downlad_url, "/[eE].*[(zip)(gz)]")
    versions <- str_replace(versions, "/.*/", "")
    versions <- str_replace(versions, ".tar.gz$", "")
    versions <- str_replace(versions, ".zip$", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}
# Function get Edena newest version
get.edena.newest.version <- function() {
  return(get.edena.versions()[1])
}


# Function get fastqc all versions
get.fastqc.versions <- function() {
  urls <- c("http://www.bioinformatics.bbsrc.ac.uk/projects/fastqc/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    
    web <- web[str_detect(web, "Version")]
    web <- str_extract(web, "[0-9][.0-9]*")
  }
  return(versions_final)
}
# Function get fastqc newest version
get.fastqc.newest.version <- function() {
  return(get.fastqc.versions()[1])
}

# Function get Novoalign all versions
get.novoalign.versions <- function() {
  urls <- system.file("extdata", "html/novocraft.html", package = "BioInstaller")
  versions_final <- NULL
  for (url in urls) {
    web <- readLines(url, warn = FALSE)
    web <- web[str_detect(web, "download.php")]
    web <- web[str_detect(web, "tar.gz")]
    web <- str_extract(web, "[0-9][.0-9]*")
  }
  versions_final <- paste0("V", web, c(".Linux3.0", ".Linux2.6", ".MacOSX"))
  return(versions_final)
}
# Function get Novoalign newest version
get.novoalign.newest.version <- function() {
  return(get.novoalign.versions()[1])
}

# Function get ssaha2 all versions
get.ssaha2.versions <- function() {
  urls <- c("ftp://ftp.sanger.ac.uk/pub/resources/software/ssaha2/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "tgz")]
    web <- web[str_detect(web, "201[01 ]* ssaha2_v2.")]
    web <- str_extract(web, "ssaha2.*gz")
    web <- str_replace(web, "ssaha2_", "")
    web <- str_replace(web, ".tgz", "")
  }
  versions_final <- web
  return(versions_final)
}
# Function get ssaha2 newest version
get.ssaha2.newest.version <- function() {
  versions <- get.ssaha2.versions()
  return(versions[length(versions)])
}


# Function get breakdancer all versions
get.breakdancer.versions <- function() {
  urls <- c("https://sourceforge.net/projects/breakdancer/files/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "/download")]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- str_extract(web, "[0-9].*[pz]")
    web <- str_replace(web, "(.zip)|(.tgz)|(.tar.gz)|(.gz)", "")
  }
  versions_final <- web
  return(versions_final)
}
# Function get breakdancer newest version
get.breakdancer.newest.version <- function() {
  versions <- get.breakdancer.versions()
  return(versions[1])
}


# Function get fusioncatcher all versions
get.fusioncatcher.versions <- function() {
  urls <- c("https://sourceforge.net/projects/fusioncatcher/files/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "/download")]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- str_extract(web, "v[0-9].*[pz]")
    web <- str_replace(web, "(.zip)|(.tgz)|(.tar.gz)|(.gz)", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get fusioncatcher newest version
get.fusioncatcher.newest.version <- function() {
  versions <- get.fusioncatcher.versions()
  return(versions[1])
}


# Function get pigz all versions
get.pigz.versions <- function() {
  urls <- c("http://cdn-fastly.deb.debian.org/debian/pool/main/p/pigz/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "orig.tar.gz")]
    web <- web[str_detect(web, "href")]
    web <- str_extract(web, ">pigz_[0-9].*orig.tar.gz")
    web <- str_replace_all(web, "pigz_|>|.orig.tar.gz", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get pigz newest version
get.pigz.newest.version <- function() {
  versions <- get.pigz.versions()
  return(versions[length(versions)])
}


# Function get velvet all versions
get.velvet.versions <- function() {
  urls <- c("http://www.ebi.ac.uk/~zerbino/velvet/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "velvet")]
    web <- web[str_detect(web, "tgz")]
    web <- str_extract(web, "velvet_[0-9].*.tgz")
    web <- str_replace_all(web, "velvet_|>|.tgz", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get velvet newest version
get.velvet.newest.version <- function() {
  versions <- get.velvet.versions()
  return(versions[1])
}


# Function get lzo all versions
get.lzo.versions <- function() {
  urls <- c("http://www.oberhumer.com/opensource/lzo/download/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "lzo")]
    web <- web[str_detect(web, "tar.gz")]
    web <- str_extract(web, ">lzo-[0-9].*.tar.gz")
    web <- str_replace_all(web, "lzo-|>|.tar.gz", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get lzo newest version
get.lzo.newest.version <- function() {
  versions <- get.lzo.versions()
  return(versions[1])
}

# Function get snpeff all versions
get.snpeff.versions <- function() {
  urls <- c("https://sourceforge.net/projects/snpeff/files/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "/download")]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- str_extract(web, "v[0-9].*_core.zip")
    web <- str_replace(web, "(_core.zip)|snpEff_", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get snpeff newest version
get.snpeff.newest.version <- function() {
  versions <- get.snpeff.versions()
  return(versions[1])
}

# Function get zlib all versions
get.zlib.versions <- function() {
  urls <- c("https://sourceforge.net/projects/libpng/files/zlib/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- web[str_detect(web, 'files\\/zlib\\/')]
    web <- web[!str_detect(web, 'timeline')]
    web <- str_extract(web, "[0-9.]*")
    web <- str_extract(web, "[0-9][0-9.]*")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get zlib newest version
get.zlib.newest.version <- function() {
  versions <- get.zlib.versions()
  return(versions[1])
}

# Function get armadillo all versions
get.armadillo.versions <- function() {
  urls <- c("https://sourceforge.net/projects/arma/files/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- web[str_detect(web, 'files\\/armadillo')]
    web <- web[!str_detect(web, 'timeline')]
    web <- str_extract(web, "[0-9][0-9.]*")
    web <- str_replace(web, ".$", "")
    web <- web[!is.na(web)]
  }
  versions_final <- web
  return(versions_final)
}
# Function get armadillo newest version
get.armadillo.newest.version <- function() {
  versions <- get.armadillo.versions()
  return(versions[1])
}

