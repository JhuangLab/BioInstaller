FROM bioinstaller/bioinstaller-base:latest

## This handle reaches Jianfeng
MAINTAINER "Jianfeng Li" lee_jianfeng@life2cloud.com

ADD . /tmp/BioInstaller

Run apt update && apt install -y lmodern openssl \
    && echo "options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /home/opencpu/.Rprofile \
    && echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> /home/opencpu/.Rprofile \
    && echo "options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /root/.Rprofile \
    && echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> /root/.Rprofile \
    && Rscript -e "devtools::install('/tmp/BioInstaller')" \ 
    && runuser -s /bin/bash -l opencpu -c "export BIO_SOFTWARES_DB_ACTIVE=/home/opencpu/.BioInstaller/info.yaml" \
    && chown -R opencpu /home/opencpu/ \
    && echo 'export BIO_SOFTWARES_DB_ACTIVE="~/.BioInstaller/info.yaml"\n' >> /home/opencpu/.bashrc \
    && echo 'BIO_SOFTWARES_DB_ACTIVE="~/.BioInstaller/info.yaml"\n' >> /home/opencpu/.Renviron \
    && runuser -s /bin/bash -l opencpu -c "export AUTO_CREATE_BIOINSTALLER_DIR=TRUE" \
    && echo 'source /etc/profile' >> /home/opencpu/.bashrc \
    && echo 'source /etc/profile' >> /root/.bashrc \
    && echo 'export SPACK_ROOT=/home/opencpu/opt/spack;source $SPACK_ROOT/share/spack/setup-env.sh;' >> /etc/profile \
    && echo 'export PATH=/home/opencpu/opt/miniconda2/bin:$PATH\n' >> /etc/profile \
    && echo 'file=`ls /usr/local/lib/R/site-library/`; cd /usr/lib/R/library; for i in ${file}; do rm -rf ${i};done' >> /tmp/rm_script \
    && sh /tmp/rm_script \
    && ln -sf /usr/local/lib/R/site-library/* /usr/lib/R/library/ \
    && rm /tmp/rm_script \
    && rm -rf /tmo/BioInstaller \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

Run Rscript -e "source(system.file('extdata', 'shiny/deps.R', package = 'BioInstaller'))"

Run runuser -s /bin/bash -l opencpu -c "Rscript -e \"BioInstaller::install.bioinfo('miniconda2', destdir = '/home/opencpu/opt/')\"" \
    && rm /home/opencpu/opt/*.sh \
    && runuser -s /bin/bash -l opencpu -c "Rscript -e \"BioInstaller::install.bioinfo('spack', version = 'master', destdir = '/home/opencpu/opt/spack')\""

CMD service cron start && runuser -s /bin/bash -l opencpu -c '. ~/.bashrc; export AUTO_CREATE_BIOINSTALLER_DIR="TRUE";Rscript -e "BioInstaller::set_shiny_workers(3, auto_create = TRUE)" &' && runuser -s /bin/bash -l opencpu -c '. ~/.bashrc; sh /usr/bin/start_shiny_server' && . /etc/profile; /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND
