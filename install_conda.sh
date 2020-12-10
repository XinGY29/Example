#conda install CONCOCT
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda create -n concoct_env python=3 concoct

#conda install QIIME2
conda env create -n qiime2-2020.8 --file qiime2-2020.8-py36-linux-conda.yml

#install Prodigal
mkdir Prodigal
export prodigal_PATH=$PWD/Prodigal
cd prodigal-2.6.1
make install INSTALLDIR=$prodigal_PATH

#下载COG数据库
cd COG
wget ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/little_endian/Cog_LE.tar.gz
tar -zxvf Cog_LE.tar.gz