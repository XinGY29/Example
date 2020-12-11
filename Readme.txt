1、依赖的软件包
Qiime2
TrimGalore
QCresult
cutadapt
CONCOCT
blast+
MetaPhlAn2
Prodigal

2、需要安装的软件包以及安装方法见 install conda.sh
不能运行请按如下操作进行

#conda install CONCOCT
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda create -n concoct_env python=3 concoct
#检查安装结果
conda activate concoct_env
concoct -v
conda deactivate
##如果报错vbgmm
##which concoct/where concoct
##try conda install mkl in your concoct conda env.
##https://github.com/BinPro/CONCOCT/issues/181


#conda install QIIME2
conda env create -n qiime2-2020.8 --file qiime2-2020.8-py36-linux-conda.yml
conda activate qiime2-2020.8
qiime -v
conda deactivate

#install Prodigal
mkdir Prodigal
export prodigal_PATH=$PWD/Prodigal
cd prodigal-2.6.1
make install INSTALLDIR=$prodigal_PATH

#下载COG数据库
cd COG
wget ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/little_endian/Cog_LE.tar.gz
tar -zxvf Cog_LE.tar.gz
