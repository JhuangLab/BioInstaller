set.biosoftwares.db(sprintf("%s/.BioInstaller", tempdir()))
flog.info('Debug:install.github(name = "bwa", destdir = sprintf(destdir="%s/bwa", tempdir()), verbose = T)')
status <- install.github(name = "bwa", destdir = sprintf("%s/bwa", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "star", destdir = sprintf(destdir="%s/star", tempdir()), verbose = T)')
status <- install.github(name = "star", destdir = sprintf("%s/star", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "star", destdir = sprintf(destdir="%s/star2.3", tempdir()), verbose = T, version = "STAR_2.3.1z12")')
status <- install.github(name = "star", destdir = sprintf("%s/star2.3", tempdir()), verbose = T, version = "STAR_2.3.1z12")
print(status)

flog.info('Debug:install.github(name = "htslib", destdir = sprintf(destdir="%s/htslib", tempdir()), verbose = T)')
status <- install.github(name = "htslib", destdir = sprintf("%s/htslib", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "samtools", destdir = sprintf(destdir="%s/samtools", tempdir()), verbose = T)')
status <- install.github(name = "samtools", destdir = sprintf("%s/samtools", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bcftools", destdir = sprintf(destdir="%s/bcftools", tempdir()), verbose = T)')
status <- install.github(name = "bcftools", destdir = sprintf("%s/bcftools", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bowtie", destdir = sprintf(destdir="%s/bowtie", tempdir()), verbose = T)')
status <- install.github(name = "bowtie", destdir = sprintf("%s/bowtie", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "bowtie2", destdir = sprintf(destdir="%s/bowtie2", tempdir()), verbose = T)')
status <- install.github(name = "bowtie2", destdir = sprintf("%s/bowtie2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "tophat2", destdir = sprintf(destdir="%s/tophat2", tempdir()), verbose = T)')
status <- install.github(name = "tophat2", destdir = sprintf("%s/tophat2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "varscan2", destdir = sprintf(destdir="%s/varscan2", tempdir()), verbose = T)')
status <- install.github(name = "varscan2", destdir = sprintf("%s/varscan2", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "picard", destdir = sprintf(destdir="%s/picard", tempdir()), verbose = T)')
status <- install.github(name = "picard", destdir = sprintf("%s/picard", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "vcftools", destdir = sprintf(destdir="%s/vcftools", tempdir()), verbose = T)')
status <- install.github(name = "vcftools", destdir = sprintf("%s/vcftools", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "pindel", destdir = sprintf(destdir="%s/pindel", tempdir()), verbose = T)')
status <- install.github(name = "pindel", destdir = sprintf("%s/pindel", tempdir()), verbose = T)
print(status)

flog.info('Debug:install.github(name = "lofreq", destdir = sprintf(destdir="%s/lofreq", tempdir()), verbose = F)')
status <- install.github(name = "lofreq", destdir = sprintf("%s/lofreq", tempdir()), verbose = F)
print(status)

flog.info('Debug:install.github(name = "hisat2", destdir = sprintf(destdir="%s/hisat2", tempdir()), verbose = T)')
status <- install.github(name = "hisat2", destdir = sprintf("%s/hisat2", tempdir()), verbose = T)

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
