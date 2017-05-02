set.biosoftwares.db(sprintf("%s/.BioInstaller", tempdir()))
flog.info('Debug:install.github(name = "bwa", download.dir = sprintf(download.dir="%s/bwa", tempdir()), verbose = T)')
status <- install.github(name = "bwa", download.dir = sprintf("%s/bwa", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "star", download.dir = sprintf(download.dir="%s/star", tempdir()), verbose = T)')
status <- install.github(name = "star", download.dir = sprintf("%s/star", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "star", download.dir = sprintf(download.dir="%s/star2.3", tempdir()), verbose = T, version = "STAR_2.3.1z12")')
status <- install.github(name = "star", download.dir = sprintf("%s/star2.3", tempdir()), verbose = T, version = "STAR_2.3.1z12")
print(status)

flog.info('Debug:install.github(name = "pxz", download.dir = sprintf(download.dir="%s/pxz", tempdir()), verbose = T)')
status <- install.github(name = "pxz", download.dir = sprintf("%s/pxz", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "speedseq", download.dir = sprintf(download.dir="%s/speedseq", tempdir()), verbose = T)')
status <- install.github(name = "speedseq", download.dir = sprintf("%s/speedseq", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bcftools", download.dir = sprintf(download.dir="%s/bcftools", tempdir()), verbose = T)')
status <- install.github(name = "bcftools", download.dir = sprintf("%s/bcftools", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bowtie", download.dir = sprintf(download.dir="%s/bowtie", tempdir()), verbose = T)')
status <- install.github(name = "bowtie", download.dir = sprintf("%s/bowtie", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bowtie2", download.dir = sprintf(download.dir="%s/bowtie2", tempdir()), verbose = T)')
status <- install.github(name = "bowtie2", download.dir = sprintf("%s/bowtie2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "tophat2", download.dir = sprintf(download.dir="%s/tophat2", tempdir()), verbose = T)')
status <- install.github(name = "tophat2", download.dir = sprintf("%s/tophat2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "varscan2", download.dir = sprintf(download.dir="%s/varscan2", tempdir()), verbose = T)')
status <- install.github(name = "varscan2", download.dir = sprintf("%s/varscan2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "picard", download.dir = sprintf(download.dir="%s/picard", tempdir()), verbose = T)')
status <- install.github(name = "picard", download.dir = sprintf("%s/picard", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "vcftools", download.dir = sprintf(download.dir="%s/vcftools", tempdir()), verbose = T)')
status <- install.github(name = "vcftools", download.dir = sprintf("%s/vcftools", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "pindel", download.dir = sprintf(download.dir="%s/pindel", tempdir()), verbose = T)')
status <- install.github(name = "pindel", download.dir = sprintf("%s/pindel", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "lofreq", download.dir = sprintf(download.dir="%s/lofreq", tempdir()), verbose = F)')
status <- install.github(name = "lofreq", destdir = sprintf("%s/lofreq", tempdir()), download.dir = sprintf("%s/lofreq", tempdir()), verbose = F)
print(status)

flog.info('Debug:install.github(name = "hisat2", download.dir = sprintf(download.dir="%s/hisat2", tempdir()), verbose = T)')
status <- install.github(name = "hisat2", download.dir = sprintf("%s/hisat2", tempdir()), verbose = T)

flog.info('Debug:install.github(show.all.versions = T, verbose = T)')
status <- suppressWarnings(install.github(show.all.versions = T, verbose = T))
print(status)

flog.info('Debug:install.github(name = "bwa", show.all.versions = T, verbose = T)')
status <- install.github(name = "bwa", show.all.versions = T, verbose = T)
print(status)

flog.info('Debug:install.github(name = list(), show.all.versions = T, verbose = T)')
status <- tryCatch(install.github(name = list(), show.all.versions = T, verbose = T), error = function(e) {return(e)})
print(status)


flog.info('Debug:install.bioinfo("bwa", sprintf("%s/bwa_test",tempdir()), verbose = TRUE)')
install.bioinfo('bwa', sprintf("%s/bwa_test",tempdir()), verbose = T)
