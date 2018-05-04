
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BioInstaller <img src="man/figures/logo.png" align="right" />

[![Build
Status](https://travis-ci.org/JhuangLab/BioInstaller.svg)](https://travis-ci.org/JhuangLab/BioInstaller)
[![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller)
[![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller)
[![codecov](https://codecov.io/github/JhuangLab/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/JhuangLab/BioInstaller)

## Introduction

[BioInstaller](https://life2cloud.com/tools/bioinstaller) is a
downloader and installer of bio-software and bio-databases. The
inspiration for this project comes from the various types package
manager, such as [pip](https://pypi.python.org/pypi/pip) for Python
package, `install.packages` for R package, biocLite for
[Bioconductor](http://www.bioconductor.org) R package, etc.

**Feature**:

  - More attention for those software and database resource that not be
    included in the other software warehouse
  - Extendible
  - Craw the source code and version information from the original site
  - One step installation or download software and databases (Partial
    dependence supported)
  - A software and database resources
pool

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

  - FastQC, PRINSEQ, SolexaQA, FASTX-Toolkit …

**Alignment and Assembly:**

  - BWA, STAR, TMAP, Bowtie, Bowtie2, tophat2, hisat2, GMAP-GSNAP,
    ABySS, SSAHA2, Velvet, Edean, Trinity, oases, RUM, MapSplice2,
    NovoAlign …

**Variant Detection:**

  - GATK, Mutect, VarScan2, FreeBayes, LoFreq, TVC, SomaticSniper,
    Pindel, Delly, BreakDancer, FusionCatcher, Genome STRiP, CNVnator,
    CNVkit, SpeedSeq …

**Variant Annotation:**

  - ANNOVAR, SnpEff, VEP, oncotator …

**Utils:**

  - htslib, samtools, bcftools, bedtools, bamtools, vcftools, sratools,
    picard, HTSeq, seqtk, UCSC Utils(blat, liftOver), bamUtil, jvarkit,
    bcl2fastq2, fastq\_tools …

**Genome:**

  - hisat2\_reffa, ucsc\_reffa, ensemble\_reffa …

**Others:**

  - sparsehash, SQLite, pigz, lzo, lzop, bzip2, zlib, armadillo, pxz,
    ROOT, curl, xz, pcre, R, gatk\_bundle, ImageJ, igraph …

**Databases:**

  - ANNOVAR, blast, CSCD, GATK\_Bundle, biosystems, civic, denovo\_db,
    dgidb, diseaseenhancer, drugbank, ecodrug, expression\_atlas,
    funcoup, gtex, hpo, inbiomap, interpro, medreaders, mndr, msdd,
    omim, pancanqtl, proteinatlas, remap2, rsnp3, seecancer,
    srnanalyzer, superdrug2, tumorfusions, varcards …

## Docker

You can use the BioInstaller in Docker since v0.3.0.

``` bash
docker pull bioinstaller/bioinstaller:develop
docker run -it -v /tmp/download:/tmp/download bioinstaller/bioinstaller:develop R
```

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
