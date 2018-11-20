op = options()
options(stringsAsFactors = FALSE)
suppressMessages(library(RCurl))
suppressMessages(library(stringr))
suppressMessages(library(rvest))

# Get All Hisat2 ftp reffa url
get.hisat2_reffa.versions <- function() {
  urls <- "ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/data/"
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url, encoding = "UTF-8")
    files.txt <- web %>% html_nodes("p") %>% html_text()
    files.row <- str_split(files.txt, "\n") %>% .[[1]] %>% as.character()
    files.row <- str_split(files.row, " ")
    files <- lapply(files.row, function(x) return(x[str_detect(x, "tar.gz")]))
    versions <- str_extract(files, ".*tar.gz")
    versions <- versions[!is.na(versions)]
    versions <- str_extract(versions, ".*.tar")
    versions <- str_replace(versions, ".tar$", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get GMAP-GSNAP all versions
get.gmap.versions <- function() {
  urls <- c("http://research-pub.gene.com/gmap/src/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url, encoding = "UTF-8")
    files.table <- web %>% html_nodes("table") %>% .[[1]] %>% html_table()
    files <- files.table$Name
    versions <- str_extract(files, "gmap-.*tar.gz")
    versions <- versions[!is.na(versions)]
    versions <- str_extract(versions, "gmap-.*.tar")
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
    web <- read_html(url)
    hrefs <- web %>% html_nodes(".txt a") %>% html_attr(name = "href")
    hrefs <- hrefs[!is.na(hrefs)]
    hrefs <- hrefs[str_detect(hrefs, ".tar.gz|.zip")]
    versions <- basename(hrefs)
    versions <- str_replace_all(versions, ".tar.gz|.zip", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get fastqc all versions
get.fastqc.versions <- function() {
  urls <- c("http://www.bioinformatics.babraham.ac.uk/projects/fastqc/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("div ul li") %>% html_text()
    versions <- versions[str_detect(versions, "Version")]
    versions <- versions[str_detect(versions, "released")]
    versions <- str_extract(versions, "Version [0-9][.0-9]*")
    versions <- str_replace_all(versions, "Version ", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get Novoalign all versions
get.novoalign.versions <- function() {
  urls <- "http://www.novocraft.com/support/download/"
  versions_final <- NULL
  for (url in urls) {
    myheader <- c(`User-Agent` = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0_1 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A306 Safari/6531.22.7", 
      Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
      `Accept-Language` = "en-us", Connection = "keep-alive", `Accept-Charset` = "GB2312,utf-8;q=0.7,*;q=0.7")
    
    web <- getURL(url = "http://www.novocraft.com/support/download/", httpheader = myheader, 
      verbose = F)
    web <- str_split(web, "\n") %>% .[[1]]
    web <- web[str_detect(web, "download.php")]
    web <- web[str_detect(web, "tar.gz")]
    versions <- str_extract(web, "[0-9][.0-9]*")
    versions_final <- c(versions_final, versions)
  }
  versions_final <- paste0("V", versions, c(".Linux3.0", ".Linux2.6", ".MacOSX"))
  return(versions_final)
}

# Function get ssaha2 all versions
get.ssaha2.versions <- function() {
  urls <- c("ftp://ftp.sanger.ac.uk/pub/resources/software/ssaha2/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url, encoding = "UTF-8")
    files.txt <- web %>% html_nodes("p") %>% html_text()
    files.row <- str_split(files.txt, "\n") %>% .[[1]] %>% as.character()
    files.row <- str_split(files.row, " ")
    files <- lapply(files.row, function(x) return(x[str_detect(x, "tgz")]))
    files <- unlist(files)
    versions <- str_extract(files, "_v.*tgz")
    versions <- versions[!is.na(versions)]
    versions <- str_replace_all(versions, "^_|.tgz$", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get fusioncatcher all versions
get.fusioncatcher.versions <- function() {
  urls <- c("https://sourceforge.net/projects/fusioncatcher/files/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("#files_list") %>% html_table() %>% .[[1]]
    versions <- versions$Name
    versions <- str_extract(versions, ".*[(tgz)(tar.gz)(zip)]+$")
    
    versions <- versions[!is.na(versions)]
    versions <- str_extract(versions, "v[0-9].*[pz]")
    versions <- versions[!is.na(versions)]
    versions <- str_replace(versions, "(.zip)|(.tgz)|(.tar.gz)|(.gz)", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get pigz all versions
get.pigz.versions <- function() {
  urls <- c("http://cdn-fastly.deb.debian.org/debian/pool/main/p/pigz/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("table") %>% html_table() %>% .[[1]]
    versions <- versions$Name
    versions <- str_extract(versions, ".*orig.*[(tgz)(tar.gz)(zip)]+$")
    
    versions <- versions[!is.na(versions)]
    versions <- str_extract(versions, "[0-9].*[pz]")
    versions <- str_replace_all(versions, ".orig|(.zip)|(.tgz)|(.tar.gz)|(.gz)", 
      "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
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
    versions <- str_extract(web, "velvet_[0-9].*.tgz")
    versions <- str_replace_all(versions, "velvet_|>|.tgz", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
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
    versions <- str_replace_all(web, "lzo-|>|.tar.gz", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
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
    versions <- str_replace(web, "(_core.zip)|snpEff_", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get zlib all versions
get.zlib.versions <- function() {
  urls <- c("https://sourceforge.net/projects/libpng/files/zlib/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("#files_list") %>% html_table() %>% .[[1]]
    versions <- versions$Name
    versions <- str_extract(versions, "[0-9.]*")
    
    versions <- versions[!is.na(versions)]
    versions <- versions[versions != ""]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
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
    web <- web[str_detect(web, "files\\/armadillo")]
    web <- web[!str_detect(web, "timeline")]
    web <- str_extract(web, "[0-9][0-9.]*")
    versions <- str_replace(web, ".$", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- c(versions_final, "4.600.1")
  return(versions_final)
}

# Function get prinseq all versions
get.prinseq.versions <- function() {
  urls <- c("https://sourceforge.net/projects/prinseq/files/standalone/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- web[str_detect(web, "files/standalone/prinseq-lite")]
    web <- web[!str_detect(web, "timeline")]
    web <- str_extract(web, "[0-9][0-9.]*")
    versions <- str_replace(web, ".$", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get solexaqa all versions
get.solexaqa.versions <- function() {
  urls <- c("https://sourceforge.net/projects/solexaqa/files/src/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[!str_detect(web, "source=files")]
    web <- web[str_detect(web, "files/src/SolexaQA")]
    web <- web[!str_detect(web, "timeline")]
    web <- str_extract(web, "[v.][0-9][0-9.]*")
    web <- str_replace(web, ".$", "")
    versions <- str_replace(web, "^[v.]", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get mapsplice2 all versions
get.mapsplice2.versions <- function() {
  urls <- c("http://www.netlab.uky.edu/p/bioinfo/MapSplice2")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "download")]
    versions <- str_extract(web, "[0-9]\\.[0-9.]*")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

# Function get root all versions
get.root.versions <- function() {
  urls <- c("https://root.cern.ch/releases")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "Release")]
    web <- str_extract(web, "[0-9]\\.[0-9./]*")
    versions <- str_replace_all(web, fixed("/"), fixed("."))
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

# Function get curl all versions
get.curl.versions <- function() {
  urls <- c("https://curl.haxx.se/download/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "curl-")]
    web <- str_extract(web, "[0-9]\\.[0-9./]*")
    web <- web[!is.na(web)]
    versions <- web[!duplicated(web)]
    versions <- str_replace(versions, ".$", "")
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

# Function get r all versions
get.r.versions <- function() {
  urls <- paste0("https://cran.r-project.org/src/base/R-", c(0, 1, 2, 3), "/")
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "R-")]
    web <- str_extract(web, "R.[0-9-a-z.]*.tgz|R.[0-9-a-z.]*.tar.gz")
    web <- str_replace(web, ".tar.gz|.tgz$", "")
    web <- str_replace(web, "R-", "")
    versions <- web[!is.na(web)]
    versions <- versions[!duplicated(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

get.pcre.versions <- function() {
  urls <- "https://ftp.pcre.org/pub/pcre/"
  versions_final <- NULL
  for (url in urls) {
    h <- basicTextGatherer()
    web <- getURL(url, headerfunction = h$update)
    web <- str_split(web, "\n")
    web <- web[[1]]
    web <- web[str_detect(web, "href")]
    web <- web[str_detect(web, "pcre")]
    web <- str_extract(web, "pcre[0-9-a-z.]*.tar.gz")
    web <- web[!str_detect(web, "pcre2")]
    web <- str_replace(web, ".tar.gz$", "")
    web <- str_replace(web, "pcre-", "")
    versions <- web[!is.na(web)]
    versions <- versions[!duplicated(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

get.ensemble_grch38_reffa.versions <- function() {
  urls <- "ftp://ftp.ensembl.org/pub/"
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url, encoding = "UTF-8")
    files.txt <- web %>% html_nodes("p") %>% html_text()
    files.row <- str_split(files.txt, "\n") %>% .[[1]] %>% as.character()
    files.row <- str_split(files.row, " ")
    files <- lapply(files.row, function(x) return(x[str_detect(x, "release")]))
    files <- unlist(files)
    versions <- str_extract(files, "[0-9][0-9]*")
    versions <- versions[!is.na(versions)]
    versions <- versions[versions > "75"]
    versions <- unique(versions)
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

get.ucsc_utils.versions <- function() {
  urls <- "http://hgdownload.cse.ucsc.edu/admin/exe/"
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("pre a") %>% html_attr(name = "href")
    versions <- versions[str_detect(versions, "userApps")]
    versions <- versions[str_detect(versions, ".v")]
    versions <- str_extract(versions, "v[0-9]*")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- sort(versions_final, decreasing = T)
  return(versions_final)
}

get.sqlite.versions <- function() {
  url <- "https://www.sqlite.org/chronology.html"
  web <- read_html(url)
  versions <- web %>% html_nodes("table") %>% html_table() %>% .[[1]]
  versions <- versions$Version
  
  pos <- str_split(versions, fixed("."))
  func <- function(version.number) {
    op <- options()
    options(scipen = 200)
    
    version.number <- as.numeric(version.number)
    a <- version.number[1] * 1e+06
    b <- version.number[2] * 10000
    if (is.na(version.number[3])) {
      result <- a + b
      if (result < 3071506) {
        return(NULL)
      } else {
        return(result)
      }
    } else {
      c <- version.number[3] * 100
    }
    if (is.na(version.number[4])) {
      result <- a + b + c
    } else {
      d <- version.number[4] * 1
      result <- a + b + c + d
    }
    if (result < 3071506) {
      return(NULL)
    }
    result <- as.character(result)
    options(op)
    
    return(result)
  }
  versions <- unlist(lapply(pos, func))
}

get.sratools.versions <- function() {
  url <- "https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/"
  
  web <- read_html(url)
  versions <- web %>% html_nodes("pre a") %>% html_attr(name = "href")
  versions <- versions[!str_detect(versions, "-prere")]
  versions <- str_extract(versions, "[0-9-.]*")
  versions <- versions[versions != ""]
  
  versions <- sort(versions, decreasing = T)
}

get.solexaqa.versions <- function() {
  url <- "https://sourceforge.net/projects/solexaqa/files/src/"
  web <- read_html(url)
  versions <- web %>% html_nodes("#files_list") %>% html_table() %>% .[[1]]
  versions <- versions$Name
  versions <- str_extract(versions, "[0-9][.0-9]+[0-9]")
  versions <- versions[!is.na(versions)]
}

get.reditools.versions <- function() {
  urls <- c("https://sourceforge.net/projects/reditools/files/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_nodes("#files_list") %>% html_table() %>% .[[1]]
    versions <- versions$Name
    versions <- str_extract(versions, ".*[(tgz)(tar.gz)(zip)]+$")
    
    versions <- versions[!is.na(versions)]
    versions <- str_extract(versions, "[0-9].*[pz]")
    versions <- versions[!is.na(versions)]
    versions <- str_replace(versions, "(.zip)|(.tgz)|(.tar.gz)|(.gz)", "")
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

get.miniconda2.versions <- function() {
  urls <- c("https://repo.continuum.io/miniconda/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_table() %>% .[[1]]
    versions <- versions$Filename
    versions <- versions[str_detect(versions, "Miniconda2")]
    versions <- str_replace(versions, "-Linux.*|-Windows.*|-MacOSX.*", "")
    versions <- str_extract(versions, "-[0-9.(latest)]*")
    versions <- unique(str_replace(versions, "^-", ""))
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

get.miniconda3.versions <- function() {
  urls <- c("https://repo.continuum.io/miniconda/")
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url)
    versions <- web %>% html_table() %>% .[[1]]
    versions <- versions$Filename
    versions <- versions[str_detect(versions, "Miniconda3")]
    versions <- str_replace(versions, "-Linux.*|-Windows.*|-MacOSX.*", "")
    versions <- str_extract(versions, "-[0-9.(latest)]*")
    versions <- unique(str_replace(versions, "^-", ""))
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  return(versions_final)
}

get.blast.versions <- function() {
  urls <- "https://anaconda.org/bioconda/blast/files"
  versions_final <- NULL
  for (url in urls) {
    web <- read_html(url, encoding = "UTF-8")
    files.table <- web %>% html_nodes("table") %>% .[[1]] %>% html_table()
    files <- files.table$Name
    versions <- str_extract(files, "blast-[0-9]+[.0-9]*")
    versions <- str_replace(versions, "blast-", "")
    versions <- versions[!is.na(versions)]
    versions_final <- c(versions_final, versions)
  }
  versions_final <- unique(versions_final)
  versions_final <- sort(versions_final, decreasing = T)
}

get.db_sedb.versions <- function() {
  files <- system.file("extdata", "files/sedb_files", package = "BioInstaller")
  versions_final <- readLines(files)
  return(versions_final)
}
