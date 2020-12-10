mkdir nohuman_reads
for file in $(ls data/*R1*);do
	name=${file%_R1_100kseqs.fasta}
	name=${name#data\/}
	startTime=$(date +%s)
	bowtie2 -f --local --threads 24 -x /home/public/genome/human/human -U "$file",data/"$name"_R2_100kseqs.fasta -S "$name".nohuman.sam --un nohuman_reads/"$name".nohuman.fq
	rm "$name".nohuman.sam
	endTime=$(date +%s)
	echo "Remove "$name" human host reads took $(( endTime - startTime )) seconds"
done
