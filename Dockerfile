FROM bioinstaller/opencpu:latest

## This handle reaches Jianfeng
MAINTAINER "Jianfeng Li" lee_jianfeng@life2cloud.com

ADD . /tmp/BioInstaller

ADD https://raw.githubusercontent.com/JhuangLab/annovarR/master/inst/docker/shiny-server.conf /etc/shiny-server/shiny-server.conf
ADD https://raw.githubusercontent.com/JhuangLab/annovarR/master/inst/docker/shiny-apache.conf /etc/apache2/sites-enabled/000-default.conf

Run apt update && apt install -y lmodern openssl tcl environment-modules qpdf \
    && Rscript -e "install.packages('prettydoc')" \ 
    && Rscript -e "devtools::install('/tmp/BioInstaller')" \ 
    && Rscript -e "devtools::install_github('openbiox/bioshiny/src/bioshiny')" \ 
    && ln -s /usr/local/lib/R/site-library/bioshiny/extdata/shiny /srv/shiny-server/bioshiny \
    && mkdir /home/opencpu/.bioshiny \
    && chown -R opencpu /home/opencpu/.bioshiny \
    && runuser -s /bin/bash -l opencpu -c "Rscript -e 'bioshiny::copy_configs()'" \
    && chown -R opencpu /etc/shiny-server/shiny-server.conf \
    && chmod a+r /etc/apache2/sites-enabled/000-default.conf \
    && echo 'LC_ALL="en_US.UTF-8"\nLANG="en_US.UTF-8"' >> /etc/R/Renviron \
    && Rscript -e "source(system.file('extdata', 'shiny/deps.R', package = 'bioshiny'))" \
    && runuser -s /bin/bash -l opencpu -c "export BIO_SOFTWARES_DB_ACTIVE=/home/opencpu/.bioshiny/info.yaml" \
    && export BIO_SOFTWARES_DB_ACTIVE="/home/opencpu/.bioshiny/info.yaml" \
    && export BIOSHINY_CONFIG="/home/opencpu/.bioshiny/shiny.config.yaml" \
    && echo 'source /usr/share/modules/init/bash\n' >> /etc/profile \
    && echo 'export BIO_SOFTWARES_DB_ACTIVE="/home/opencpu/.bioshiny/info.yaml"\n' >> /home/opencpu/.bashrc \
    && echo 'BIOSHINY_CONFIG="/home/opencpu/.bioshiny/shiny.config.yaml"\n' >> /home/opencpu/.Renviron \
    && echo 'export BIO_SOFTWARES_DB_ACTIVE="/home/opencpu/.bioshiny/info.yaml"\n' >> /home/opencpu/.bashrc \
    && echo 'BIOSHINY_CONFIG="/home/opencpu/.bioshiny/shiny.config.yaml"\n' >> /home/opencpu/.Renviron \
    && runuser -s /bin/bash -l opencpu -c "export AUTO_CREATE_BIOSHINY_DIR=TRUE" \
    && chown -R opencpu /home/opencpu/ \
    && chown -R opencpu /usr/local/lib/R/site-library \
    && chown -R opencpu /usr/lib/R/library \
    && echo 'file=`ls /usr/local/lib/R/site-library/`; cd /usr/lib/R/library; for i in ${file}; do rm -rf ${i};done' >> /tmp/rm_script \
    && sh /tmp/rm_script \
    && ln -sf /usr/local/lib/R/site-library/* /usr/lib/R/library/ \
    && rm /tmp/rm_script \
    && rm -rf /tmo/BioInstaller \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

Run runuser -s /bin/bash -l opencpu -c "Rscript -e \"BioInstaller::install.bioinfo('miniconda2', destdir = '/home/opencpu/opt/')\"" \
    && rm /home/opencpu/opt/*.sh \
    && runuser -s /bin/bash -l opencpu -c "Rscript -e \"BioInstaller::install.bioinfo('spack', version = 'master', destdir = '/home/opencpu/opt/spack')\""

Run echo 'source /etc/profile' >> /home/opencpu/.bashrc \
    && echo 'source /etc/profile' >> /root/.bashrc \
    && echo 'export SPACK_ROOT=/home/opencpu/opt/spack;source $SPACK_ROOT/share/spack/setup-env.sh;' >> /etc/profile \
    && echo 'export PATH=/home/opencpu/opt/miniconda2/bin:$PATH\n' >> /etc/profile \
    && echo "options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /home/opencpu/.Rprofile \
    && echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> /home/opencpu/.Rprofile \
    && echo "options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /root/.Rprofile \
    && echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> /root/.Rprofile

CMD service cron start && runuser -s /bin/bash -l opencpu -c '. ~/.bashrc; export AUTO_CREATE_BIOSHINY_DIR="TRUE";Rscript -e "bioshiny::set_shiny_workers(3, auto_create = TRUE)" &' && runuser -s /bin/bash -l opencpu -c '. ~/.bashrc; sh /usr/bin/start_shiny_server' && . /etc/profile; /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND
