# [![Build Status](https://travis-ci.org/JhuangLab/BioInstaller.svg)](https://travis-ci.org/JhuangLab/BioInstaller) [![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller) [![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller) [![codecov](https://codecov.io/github/JhuangLab/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/JhuangLab/BioInstaller) 

BioInstaller package
==============

## Introduction
[Conda](https://conda.io/docs/intro.html) and [Bioconda](http://bioconda.github.io/) have made us easy to install many packages and bio-softwares conveniently. Yet, learning how to install and compile bioinformatics softwares were still necessary. Because, the experience will help you to  improve the ability of debugging.

Especialy, when start a NGS analysis work in a new computer or system, you need costs so much time and energy to establish a complete set of softwares and dependce of a analysis pipeline and set the corresponding configuration file.

[BioInstaller](https://github.com/JhuangLab/BioInstaller) can be used to download/install bioinformatics tools, dependences and databases in R relatively easily, and the information of installed softwares will be saved which can be used to generate configuration file. More detail can be founded in [Document](http://bioinfo.rjh.com.cn/labs/jhuang/tools/BioInstaller/) website.

Moreover, BioInstaller provide a different way to provide softwares download/install for others.

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

- ANNOVAR, SnpEff

**Utils:** 

- htslib, samtools, bcftools, bedtools, bamtools, vcftools, sratools, picard, HTSeq, seqtk, UCSC Utils(blat, liftOver), bamUtil, jvarkit, bcl2fastq2

**Genome:**

- hisat2_reffa, ucsc_reffa, ensemble_reffa 

**CHIP-seq Analysis:**

- MACS, CEAS

**Others:** 

- sparsehash, sqlite, pigz, lzo, lzop, bzip2, zlib, armadillo, pxz, ROOT, curl, xz, pcre, R, gatk_bundle, ImageJ, igraph
