# BioInstaller 0.3.6

## New features

* add copy\_plugins and copy\_configs functions to restore 
  the plugins and config
* use fromJSON to access the github APIs, 
  which can avoid the SSL problem on windows platform

# BioInstaller 0.3.5.7000

## Minor bugs fixed

* Add conda and spack in the Docker image

# BioInstaller 0.3.5.6000

## New features

* Shiny application supported

* Numbers increased of included items, especialy the databases

* Use github [forum](https://github.com/JhuangLab/BioInstaller/issues)

* Add parameter `overwrite` in `install.bioinfo`

* Add Opencpu, Shiny and Rstudio service in Docker container

* Use 'Setting' module in Shiny application to manage the variables

## Minor bugs fixed

* Check and confirm delete the existing dir only when clone a github project

# BioInstaller 0.3.3

## New features

* Multiple resources file be supported

* Adjust and set db, github, nongithub, web and docker in inst/extdata/config

* Meta information of software and database be added in newly supported items

* Decompress can be auto-recognized

* Docker supported


## Minor bugs fixed

* change.info default is to write tempfile() now

* Fixed a bug when set save.to.db to FALSE. It can raise installed fail

# BioInstaller 0.2.1

## New features

* ANNOVAR databases can be download using inst/extdata/databases/ANNOVAR.toml

* Move databases toml file to inst/extdata/databases/

* `local.source` be supported (Don't need download the source code again when it were download already)

* Function `docker.pull` and `docker.search` be added to download and search docker repo

* Function `craw.all.versions` be added to crawl source code of all version (Sotwares or databases)

# BioInstaller 0.1.2

## New features

* #R# CMD #R# marked the R CMD need to be runed

* glue parse be supported

* Softwares versions of github.cfg be fetched from github API

* destdir and download.dir can be setted respectively

* `verbose` default is TRUE, show log infomation

## Minor bugs fixed

* Fix `unlink()` clean tests files fail on windows (force = TRUE)
