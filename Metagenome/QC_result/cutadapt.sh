export WorkPATH=$PWD/../../TrimGalore-0.6.6
mkdir result
mkdir QC_result

fastqc -o QC_result HMP_GUT_R1_100k.fastq HMP_GUT_R2_100k.fastq

$WorkPATH/trim_galore -q 25 --phred33 --stringency 3 --length 20 -e 0.1 \
	--paired HMP_GUT_R1_100k.fastq HMP_GUT_R2_100k.fastq  \
	--gzip -o result

#--quality：设定Phred quality score阈值，默认为20。
#--phred33：：选择-phred33或者-phred64，表示测序平台使用的Phred quality score。
#--adapter：输入adapter序列。也可以不输入，Trim Galore!会自动寻找可能性最高的平台对应的adapter。自动搜选的平台三个，也直接显式输入这三种平台，即--illumina、--nextera和--small_rna。
#--stringency：设定可以忍受的前后adapter重叠的碱基数，默认为1（非常苛刻）。可以适度放宽，因为后一个adapter几乎不可能被测序仪读到。
#--length：设定输出reads长度阈值，小于设定值会被抛弃。
#--paired：对于双端测序结果，一对reads中，如果有一个被剔除，那么另一个会被同样抛弃，而不管是否达到标准。
#--retain_unpaired：对于双端测序结果，一对reads中，如果一个read达到标准，但是对应的另一个要被抛弃，达到标准的read会被单独保存为一个文件。
#--gzip和--dont_gzip：清洗后的数据zip打包或者不打包。
#--output_dir：输入目录。需要提前建立目录，否则运行会报错。
#-- trim-n : 移除read一端的reads

