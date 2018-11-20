# BioInstaller <img src="https://raw.githubusercontent.com/JhuangLab/BioInstaller/master/man/figures/logo.png" align="right" />

[![Build
Status](https://travis-ci.org/JhuangLab/BioInstaller.svg)](https://travis-ci.org/JhuangLab/BioInstaller)
[![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller)
[![Zenodo](https://zenodo.org/badge/DOI/10.5281/zenodo.1343914.svg)](https://zenodo.org/record/1343914)
[![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller)
[![codecov](https://codecov.io/github/JhuangLab/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/JhuangLab/BioInstaller)

## Introduction

The increase in bioinformatics resources such as tools/scripts and databases poses a great challenge for users seeking to construct interactive and reproducible biological data analysis applications. 

R language, as the most popular programming language for statistics, biological data analysis, and big data, has enabled diverse and free R packages (>14000) for different types of applications. However, due to the lack of high-performance and open-source cloud platforms based on R (e.g., Galaxy for Python users), it is still difficult for R users, especially those without web development skills, to construct interactive and reproducible biological data analysis applications supporting the upload and management of files, long-time computation, task submission, tracking of output files, exception handling, logging, export of plots and tables, and extendible plugin systems.

The collection, management, and share of various bioinformatics tools/scripts and databases are also essential for almost all bioinformatics analysis projects.

Here, we established a new platform to construct interactive and reproducible biological data analysis applications based on R language. This platform contains diverse user interfaces, including the R functions and R Shiny application, REST APIs, and support for collecting, managing, sharing, and utilizing massive bioinformatics tools/scripts and databases.

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

**Note**, the Shiny application of BioInstaller was migrated to [bioshiny](https://github.com/ngsjs/bioshiny) project. All shiny files in this package will deprecated soon.

In the new project, we will provides one-click method (command line and Shiny UI) to create bioshiny application and its plugins. We are also developing more free plugins of bioshiny for various bioinformatics data analysis. 

```
# Start the standalone Shiny application
BioInstaller::web(auto_create = TRUE)
```

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview2.jpg" align="middle" />

<img src="https://raw.githubusercontent.com/Miachol/ftp/master/files/images/bioinstaller/overview1.jpg" align="middle" />

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

## Citation

- Li J, Cui B, Dai Y, et al. BioInstaller: a comprehensive R package to construct interactive and reproducible biological data analysis applications based on the R platform[J]. PeerJ, 2018, 6:e5853.

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
