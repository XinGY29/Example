#该文件需要在CONCOCT conda 文件下运行，启动命令 conda activate concoct_env
StartTime=$(date +%s)
ls data/*R1*fasta | tr "\n" "," | sed 's/,$//' > R1.csv
ls data/*R2*fasta | tr "\n" "," | sed 's/,$//' > R2.csv
megahit -1 $(<R1.csv) -2 $(<R2.csv) -t 24 -o Assembly
EndTime=$(date +%s)
echo "Use Megahit assembly reads took $(( EndTime - StartTime)) seconds"

mkdir Reads2Contigs
mkdir Reads2Contigs/DB
mkdir Reads2Contigs/sam
StartTime=$(date +%s)
bowtie2-build --threads 24 Assembly/final.contigs.fa Reads2Contigs/DB/contigs
EndTime=$(date +%s)
echo "##############################################      Build Contigs DB took $((EndTime - StartTime)) seconds      #############################################"
for file in $(ls data/*R1*);do
	name=${file%_R1_100kseqs.fasta}
	name=${name#data\/}
	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  "$name""
	StartTime=$(date +%s)
	bowtie2 -f --local --threads 24 -x Reads2Contigs/DB/contigs -U data/"$name"_R1_100kseqs.fasta,data/"$name"_R2_100kseqs.fasta -S Reads2Contigs/sam/"$name".sam
	samtools view -bS Reads2Contigs/sam/"$name".sam > Reads2Contigs/sam/"$name".bam
	samtools sort Reads2Contigs/sam/"$name".bam -o Reads2Contigs/"$name".sorted.bam
	samtools index Reads2Contigs/"$name".sorted.bam
	EndTime=$(date +%s)
	echo "Match "$name" to Contigs and form index took $(( EndTime - StartTime)) seconds"
done

mkdir Concoct
starttime=$(date +%s)
cut_up_fasta.py Assembly/final.contigs.fa -c 10000 -o 0 --merge_last -b Concoct/contigs_10K.bed > Concoct/contigs_10K.fa
concoct_coverage_table.py Concoct/contigs_10K.bed Reads2Contigs/*.sorted.bam > Concoct/coverage_table.tsv
concoct --composition_file Concoct/contigs_10K.fa --coverage_file Concoct/coverage_table.tsv -b concoct_output/
merge_cutup_clustering.py concoct_output/clustering_gt1000.csv > concoct_output/clustering_merged.csv
echo "#################################################"
cut -d"," -f2 concoct_output/clustering_gt1000.csv | sort | uniq -c | wc -l
echo "#################################################"
endtime=$(date +%s)
echo "#########  Concoct bining took $((endtime - starttime )) seconds  #########"

export METAG=$PWD/../metag-rev-sup
export CONCOCT=$PWD/../CONCOCT
export Prodigal=$PWD/../Prodigal
StartTime=$(date +%s)
$METAG/scripts/LengthFilter.pl Concoct/contigs_10K.fa 1000 > Annotate/contigs_gt1000_10K.fa
#Prodigal需要进行安装
$Prodigal/prodigal -i Annotate/contigs_gt1000_10K.fa -a Annotate/contigs_gt1000_10K.faa -d Annotate/contigs_gt1000_10K.fna  -f gff -p meta -o Annotate/contigs_gt1000_10K.gff
EndTime=$(date +%s)
echo "Call out genes using Prodigal took $((EndTime - StartTime)) seconds"
StartTime=$(date +%s)
rpsblast -outfmt "6 qseqid sseqid evalue pident score qstart qend sstart send length slen" -max_target_seqs 500 -evalue 0.00001 -query Annotate/contigs_gt1000_10K.faa -db ../COG/Cog -out Annotate/contigs_gt1000_c10K.faa.out -num_threads 24
EndTime=$(date +%s)
echo "#############   rpsblast took $((EndTime - StartTime)) seconds"
#需要退出conda环境，conda deactivate
$CONCOCT/scripts/COG_table.py -b Annotate/contigs_gt1000_c10K.faa.out -m ../CONCOCT/scgs/scg_cogs_min0.97_max1.03_unique_genera.txt -c concoct_output/clustering_gt1000.csv --cdd_cog_file ../CONCOCT/scgs/cdd_to_cog.tsv > clustering_gt1000_scg.tsv
$CONCOCT/scripts/COGPlot.R -s clustering_gt1000_scg.tsv -o clustering_gt1000_scg.pdf
