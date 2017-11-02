PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
DOWNLOAD_DIR := "/tmp/test_BioInstaller"
DEST_DIR := "/tmp/test_src"

all: doc build

doc:
	Rscript -e "devtools::document()"

build:
	cd ..;\
	R CMD build $(PKGSRC)

build2:
	cd ..;\
	R CMD build --no-build-vignettes $(PKGSRC)

install:
	cd ..;\
	R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

check: build
	cd ..;\
	R CMD check $(PKGNAME)_$(PKGVERS).tar.gz

check_cran: build
	cd ..;\
	R CMD check --as-cran $(PKGNAME)_$(PKGVERS).tar.gz

clean:
	cd ..;\
	$(RM) -r $(PKGNAME).Rcheck/

show_names:
	cd .;\
    Rscript -e "cat(BioInstaller::install.bioinfo(show.all.names=T), sep = '\n')"

show_db_names:
	cd .;\
    Rscript -e "cat(BioInstaller::install.bioinfo(nongithub='./inst/extdata/databases/db_main.toml', \
	            show.all.names=T), sep = '\n')"

show_meta:
	cd .;\
	Rscript -e "BioInstaller::get.meta()"

show_versions:
	@echo "name:$(name)"
	cd .;\
    Rscript -e "BioInstaller::install.bioinfo(name='$(name)',show.all.versions = TRUE)";

test:
	cd .;\
    Rscript -e "devtools::test()"

test2:
	@echo "name:$(name), version:$(version)"
	cd .;\
    Rscript -e "BioInstaller::install.bioinfo(name='$(name)', download.dir=sprintf('$(DOWNLOAD_DIR)/%s/%s', basename(tempdir()), '$(name)'), dest.dir='$(DEST_DIR)', version='$(version)')";
