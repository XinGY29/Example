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
