# BioInstaller <img src="https://raw.githubusercontent.com/JhuangLab/BioInstaller/master/man/figures/logo.png" align="right" />

[![Build
Status](https://travis-ci.org/JhuangLab/BioInstaller.svg)](https://travis-ci.org/JhuangLab/BioInstaller)
[![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller)
[![Zenodo](https://zenodo.org/badge/DOI/10.5281/zenodo.1343914.svg)](https://zenodo.org/record/1343914)
[![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller)
[![codecov](https://codecov.io/github/JhuangLab/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/JhuangLab/BioInstaller)

## Introduction

Accessing and management of various bioinformatics tool/script and database are essential for almost all bioinformatics analysis projects. 

There is an urgent need for the development of new all-in-one tools that allows users to search, download, install and share these bioinformatics tool/script and database.

[Conda](https://conda.io/docs/) and [Spack](https://spack.io/) have done a lot of work and we can use them to conveniently install some bioinformatics software. But there are still many problems with these package managers, such as incompatible to some precompiled programs, little support for the database and other non-software files.

[BioInstaller](https://github.com/JhuangLab/BioInstaller) is a comprehensive R package 
to integrate bioinformatics resources, such as software/script and database. 
It provides the R, Shiny web application, and the GitHub forum. Hundreds of bioinformatics tool/script and database have been included in BioInstaller.


**Feature**:

  - Easy-to-use
  - User-friendly Shiny application
  - Integrative platform of Databases and bioinformatics resources
  - Open source and completely free
  - One-click to download and install bioinformatics resources (via R, Shiny or Opencpu REST APIs)
  - More attention for those software and database resource that have not been
    by other tools
  - Logging
  - System monitor
  - Task submitting system
  - Parallel tasks

**Field**

  - Quality Control
  - Alignment And Assembly
  - Alternative Splicing
  - ChIP-seq analysis
  - Gene Expression Data Analysis
  - Variant Detection
  - Variant Annotation
  - Virus Related
  - Statistical and Visualization
  - Noncoding RNA Related Database
  - Cancer Genomics Database
  - Regulator Related Database
  - eQTL Related Database
  - Clinical Annotation
  - Drugs Database
  - Proteomic Database
  - Software Dependence Database 
  - ......

<img src="https://raw.githubusercontent.com/JhuangLab/BioInstaller/develop/man/figures/design_of_bioInstaller.jpg" align="middle" />

## Installation

### CRAN

``` r
#You can install this package directly from CRAN by running (from within R):
install.packages('BioInstaller')
```

### Github

``` bash
# install.packages("devtools")
devtools::install_github("JhuangLab/BioInstaller")

```
## Shiny UI overview

```
# Start the standalone Shiny application
BioInstaller::web()
```

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview1.jpg" align="middle" />

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview2.jpg" align="middle" />

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview3.jpg" align="middle" />

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview4.jpg" align="middle" />

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview5.jpg" align="middle" />


## Contributed Resources

  - [GitHub
    resource](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/github/github.toml)
  - GitHub resource [meta
    information](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/github/github_meta.toml)
  - [Non GitHub
    resource](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/nongithub/nongithub.toml)
  - Non Github resource [meta
    infrmation](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/nongithub/nongithub_meta.toml)
  - [Database](https://github.com/JhuangLab/BioInstaller/tree/master/inst/extdata/config/db)
  - [Web
    Service](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/web/web_meta.toml)
  - [Docker](https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/config/docker/docker.toml)

## Support Summary

**Quality Control:**

  - FastQC, PRINSEQ, SolexaQA, FASTX-Toolkit ...

**Alignment and Assembly:**

  - BWA, STAR, TMAP, Bowtie, Bowtie2, tophat2, hisat2, GMAP-GSNAP,
    ABySS, SSAHA2, Velvet, Edean, Trinity, oases, RUM, MapSplice2,
    NovoAlign ...

**Variant Detection:**

  - GATK, Mutect, VarScan2, FreeBayes, LoFreq, TVC, SomaticSniper,
    Pindel, Delly, BreakDancer, FusionCatcher, Genome STRiP, CNVnator,
    CNVkit, SpeedSeq ...

**Variant Annotation:**

  - ANNOVAR, SnpEff, VEP, oncotator ...

**Utils:**

  - htslib, samtools, bcftools, bedtools, bamtools, vcftools, sratools,
    picard, HTSeq, seqtk, UCSC Utils(blat, liftOver), bamUtil, jvarkit,
    bcl2fastq2, fastq\_tools ...

**Genome:**

  - hisat2\_reffa, ucsc\_reffa, ensemble\_reffa ...

**Others:**

  - sparsehash, SQLite, pigz, lzo, lzop, bzip2, zlib, armadillo, pxz,
    ROOT, curl, xz, pcre, R, gatk\_bundle, ImageJ, igraph ...

**Databases:**

  - ANNOVAR, blast, CSCD, GATK\_Bundle, biosystems, civic, denovo\_db,
    dgidb, diseaseenhancer, drugbank, ecodrug, expression\_atlas,
    funcoup, gtex, hpo, inbiomap, interpro, medreaders, mndr, msdd,
    omim, pancanqtl, proteinatlas, remap2, rsnp3, seecancer,
    srnanalyzer, superdrug2, tumorfusions, varcards ...

## Docker

You can use the BioInstaller in Docker since v0.3.0. Shiny application was supported since v0.3.5.

``` bash
docker pull bioinstaller/bioinstaller
docker run -it -p 80:80 -p 8004:8004 -v /tmp/download:/tmp/download bioinstaller/bioinstaller
```

Service list:

- localhost/ocpu/ Opencpu service
- localhost/shiny/BioInstaller Shiny service
- localhost/rstudio/ Rstudio server (opencpu/opencpu)

## How to contribute?

Please fork the [GitHub BioInstaller
repository](https://github.com/JhuangLab/BioInstaller), modify it, and
submit a pull request to us. Especialy, the files list in `contributed
section` should be modified when you see a tool or database that not be
included in the other software warehouse.

## Maintainer

[Jianfeng Li](https://github.com/Miachol)

## License

R package:

[MIT](https://en.wikipedia.org/wiki/MIT_License)

Related Other Resources

[Creative Commons Attribution-NonCommercial-NoDerivatives 4.0
International
License](https://creativecommons.org/licenses/by-nc-nd/4.0/)
