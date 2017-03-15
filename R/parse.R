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


# Function get Edena all versions
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
# Function get Edena newest version
get.fastqc.newest.version <- function() {
  return(get.edena.versions()[1])
}
