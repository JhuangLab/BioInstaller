FROM bioinstaller/bioinstaller-base:latest

## This handle reaches Jianfeng
MAINTAINER "Jianfeng Li" lee_jianfeng@life2cloud.com

ADD . /tmp/BioInstaller

Run apt update && apt install -y lmodern \
    && echo "options('repos' = c(CRAN='https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /home/opencpu/.Rprofile \
    && echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> /home/opencpu/.Rprofile \
    && Rscript -e "devtools::install('/tmp/BioInstaller')" \ 
    && Rscript -e "setRepositories(ind=1:2);BioInstaller::check_shiny_dep(TRUE)" \
    && Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('maftools')" \
    && echo 'file=`ls /usr/local/lib/R/site-library/`; cd /usr/lib/R/library; for i in ${file}; do rm -rf ${i};done' >> /tmp/rm_script \
    && sh /tmp/rm_script \
    && ln -sf /usr/local/lib/R/site-library/* /usr/lib/R/library/ \
    && rm /tmp/rm_script \
    && rm -rf /tmo/BioInstaller \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

CMD service cron start && runuser -l opencpu -c 'Rscript -e "BioInstaller::set_shiny_workers(3)" &>/log/BioInstaller_worker_main.log &' && runuser -l opencpu -c 'sh /usr/bin/start_shiny_server' && /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND
