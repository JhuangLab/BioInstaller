# [![Build Status](https://travis-ci.org/Miachol/BioInstaller.svg)](https://travis-ci.org/Miachol/BioInstaller) [![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://en.wikipedia.org/wiki/MIT_License) [![CRAN](http://www.r-pkg.org/badges/version/BioInstaller)](https://cran.r-project.org/package=BioInstaller) [![Downloads](http://cranlogs.r-pkg.org/badges/BioInstaller?color=brightgreen)](http://www.r-pkg.org/pkg/BioInstaller) [![codecov](https://codecov.io/github/Miachol/BioInstaller/branch/master/graphs/badge.svg)](https://codecov.io/github/Miachol/BioInstaller) 

BioInstaller package
==============

## Introduction
Install and download massive bioinformatics analysis software and database, such as NGS analysis tools with its required database or/and reference, is still a task that need to spend a lot of time. 

Especialy, when start a NGS analysis work in a new computer or system, you need costs so much time and energy to 
 establish a complete set of softwares and dependce of a analysis pipeline and set the corresponding configuration file.

[BioInstaller](https://github.com/Miachol/BioInstaller) can be used to install these tools, dependences and databases in R conveniently. More detail can be founded in [Document](http://bioinfo.rjh.com.cn/labs/jhuang/tools/BioInstaller/) website.

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
devtools::install_github("Miachol/BioInstaller")
```

## Support Summary

**NGS Aligner:** 

- BWA, STAR, TMAP, Bowtie, Bowtie2, tophat2, hisat2, GMAP-GSNAP, ABySS, SSAHA2, Velvet, Edean, Trinity, oases, RUM, MapSplice2

**NGS Utils:** 

- htslib, samtools, bcftools, bedtools, bamtools, vcftools, sratools, picard, HTSeq, seqtk, UCSC Utils(blat, liftOver), bamUtil, jvarkit, bcl2fastq2

**NGS Variant Caller:** 
    
- GATK, Mutect, VarScan2, FreeBayes, LoFreq, TVC, SomaticSniper, Pindel, Delly, BreakDancer, FusionCatcher

**NGS Variant Annotation:** 

- ANNOVAR, SnpEff

**NGS Genome:**

- hisat2_reffa, ucsc_reffa, ensemble_reffa 

**NGS Quality Control:** 

- FastQC, PRINSEQ, SolexaQA, FASTX-Toolkit

**NGS Others:**

- gatk_bundle

**CHIP-seq Analysis:**

- MACS, CESA

**Image Processing:**

- ImageJ

**Others:** 

- sparsehash, sqlite, pigz, lzo, lzop, bzip2, zlib, armadillo

