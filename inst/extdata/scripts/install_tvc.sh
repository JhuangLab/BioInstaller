
TVC_VERSION=tvc-$2

BUILD_ROOT_DIR=`mktemp -d`
cp $TVC_VERSION.tar.gz $BUILD_ROOT_DIR
DISTRIBUTION_CODENAME=`lsb_release -is`_`lsb_release -rs`_`uname -m`
TVC_INSTALL_DIR=$BUILD_ROOT_DIR/$TVC_VERSION-$DISTRIBUTION_CODENAME-binary
mkdir -p $TVC_INSTALL_DIR/bin/


cd $BUILD_ROOT_DIR
wget http://updates.iontorrent.com/updates/software/external/armadillo-4.600.1.tar.gz
tar xvzf armadillo-4.600.1.tar.gz
cd armadillo-4.600.1/
sed -i 's:^// #define ARMA_USE_LAPACK$:#define ARMA_USE_LAPACK:g' include/armadillo_bits/config.hpp
sed -i 's:^// #define ARMA_USE_BLAS$:#define ARMA_USE_BLAS:g'     include/armadillo_bits/config.hpp
cmake .
make -j4


cd $BUILD_ROOT_DIR
wget updates.iontorrent.com/updates/software/external/bamtools-2.4.0.20150702+git15eadb925f.tar.gz
tar xvzf bamtools-2.4.0.20150702+git15eadb925f.tar.gz
mkdir bamtools-2.4.0.20150702+git15eadb925f-build
cd bamtools-2.4.0.20150702+git15eadb925f-build
cmake ../bamtools-2.4.0.20150702+git15eadb925f -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
make -j4


cd $BUILD_ROOT_DIR
wget --no-check-certificate https://github.com/samtools/htslib/archive/1.2.1.tar.gz -O htslib-1.2.1.tar.gz
tar xvzf htslib-1.2.1.tar.gz
ln -s htslib-1.2.1 htslib # for samtools
cd htslib-1.2.1
make -j4

cd $BUILD_ROOT_DIR
wget --no-check-certificate https://github.com/samtools/samtools/archive/1.2.tar.gz -O samtools-1.2.tar.gz
tar xvzf samtools-1.2.tar.gz
cd samtools-1.2
make -j4
cp samtools $TVC_INSTALL_DIR/bin/

cd $BUILD_ROOT_DIR
tar xvzf $TVC_VERSION.tar.gz
TVC_SOURCE_DIR=$BUILD_ROOT_DIR/$TVC_VERSION
mkdir $TVC_VERSION-build
cd $TVC_VERSION-build
cmake $TVC_SOURCE_DIR -DCMAKE_INSTALL_PREFIX:PATH=$TVC_INSTALL_DIR -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
make -j4 install

tar cvzf $TVC_VERSION-$DISTRIBUTION_CODENAME-binary.tar.gz -C $BUILD_ROOT_DIR $TVC_VERSION-$DISTRIBUTION_CODENAME-binary

TVC_ROOT_DIR=$1
tar xvzf $TVC_VERSION-$DISTRIBUTION_CODENAME-binary.tar.gz -C $TVC_ROOT_DIR
mv $TVC_ROOT_DIR/*binary/* $TVC_ROOT_DIR
rm -rf $TVC_ROOT_DIR/*binary $TVC_ROOT_DIR/tvc-*gz
