# [![Build Status](https://travis-ci.org/JhuangLab/BioInstaller.svg)](https://travis-ci.org/JhuangLab/BioInstaller) [![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller) [![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller) [![codecov](https://codecov.io/github/JhuangLab/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/JhuangLab/BioInstaller) 

BioInstaller package
==============

## Introduction

BioInstaller is a downloader and installer of bio-software and bio-databases. The inspiration for this project comes from the various types package manager, such as [pip](https://pypi.python.org/pypi/pip) for Python package, `install.packages` for R package, biocLite for [Bioconductor](http://www.bioconductor.org) R package, etc.

**Why we do not have an integrated bioinformatics database and software package manager?**

In fact, there are already some tools can complete part of the work:

[Conda](https://conda.io/docs/intro.html) and [BioConda](http://bioconda.github.io) have done a lot of work and we can use them to conveniently install some of the bioinformatics software. But there are still many problems with these package managers, such as version updating not timely, incompatible to some pre-compiled programs, little support for the database and other non-software files.

[docker](https://www.docker.com/) is another kind very promising tool to complete the migration of the analytical environment. But the root authority is required that it's difficult for you to always get root privileges.

Furthermore, learning how to install and compile bioinformatics software is still necessary, because these 'unpleasant' experience will help you to improve the ability to debug and modify programs.

As for me, when starting some NGS analysis work on a new computer or operating system, I have to spend much time and energy to
establish a complete set of software and dependent files and set the corresponding configuration file.

BioInstaller can help us to download, install and manage a variety of bioinformatics tools and databases more easily and systematically.

What's more, BioInstaller provides a different way to download and install your files, software, and databases for others, more detail can be found in another vignette [Examples of Templet Configuration File](https://CRAN.R-project.org/package=BioInstaller/vignettes/write_configuration_file.html).

**Feature**:

- Extendible
- Craw the source code and version information from the original site
- One step installation or download software and databases (Partial dependence supported)

## Installation

### CRAN
``` r
#You can install this package directly from CRAN by running (from within R):
install.packages('BioInstaller')
```

### Github
``` bash
# Install the cutting edge development version from Lab-GitHub:
# Now only Jhuanglab members can get the source
# install.packages("devtools")
devtools::install_github("JhuangLab/BioInstaller")
```

## Support Summary

**Quality Control:** 

- FastQC, PRINSEQ, SolexaQA, FASTX-Toolkit

**Alignment and Assembly:** 

- BWA, STAR, TMAP, Bowtie, Bowtie2, tophat2, hisat2, GMAP-GSNAP, ABySS, SSAHA2, Velvet, Edean, Trinity, oases, RUM, MapSplice2, NovoAlign

**Variant Detection:** 
    
- GATK, Mutect, VarScan2, FreeBayes, LoFreq, TVC, SomaticSniper, Pindel, Delly, BreakDancer, FusionCatcher, Genome STRiP, CNVnator, CNVkit, SpeedSeq

**Variant Annotation:** 

- ANNOVAR, SnpEff, VEP

**Utils:** 

- htslib, samtools, bcftools, bedtools, bamtools, vcftools, sratools, picard, HTSeq, seqtk, UCSC Utils(blat, liftOver), bamUtil, jvarkit, bcl2fastq2

**Genome:**

- hisat2_reffa, ucsc_reffa, ensemble_reffa 

**CHIP-seq Analysis:**

- MACS, CEAS

**Others:** 

- sparsehash, SQLite, pigz, lzo, lzop, bzip2, zlib, armadillo, pxz, ROOT, curl, xz, pcre, R, gatk_bundle, ImageJ, igraph
