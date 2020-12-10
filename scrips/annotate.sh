export METAG=$PWD/../metag-rev-sup
StartTime=$(date +%s)
$METAG/scripts/LengthFilter.pl Concoct/contigs_10K.fa 1000 > Annotate/contigs_gt1000_10K.fa
/home/xingenyang/Biosoft/Prodigal/prodigal -i Annotate/contigs_gt1000_10K.fa -a Annotate/contigs_gt1000_10K.faa -d Annotate/contigs_gt1000_10K.fna  -f gff -p meta -o Annotate/contigs_gt1000_10K.gff
EndTime=$(date +%s)
echo "Call out genes using Prodigal took $((EndTime - StartTime)) seconds"
StartTime=$(date +%s)
rpsblast -outfmt "6 qseqid sseqid evalue pident score qstart qend sstart send length slen" -max_target_seqs 500 -evalue 0.00001 -query Annotate/contigs_gt1000_10K.faa -db ../COG/Cog -out Annotate/contigs_gt1000_c10K.faa.out -num_threads 24
EndTime=$(date +%s)
echo "#############   rpsblast took $((EndTime - StartTime)) seconds"

