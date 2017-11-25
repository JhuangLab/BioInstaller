FROM rocker/r-base

## This handle reaches Jianfeng
MAINTAINER "Jianfeng Li" lee_jianfeng@life2cloud.com

Run apt-get update \
    && apt-get install -t unstable -y libcurl4-openssl-dev \
    && apt-get install -t unstable -y libssl-dev \
    && apt-get install -t unstable -y libxml2-dev \
    && Rscript -e "install.packages('devtools')" \
    && Rscript -e "devtools::install_github('JhuangLab/BioInstaller', ref = 'develop')"

CMD ["R"]
