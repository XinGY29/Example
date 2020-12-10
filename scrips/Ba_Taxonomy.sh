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
mkdir Taxonomy
for file in $(ls nohuman_reads/);do
	name=${file%.nohuman.fq}
	name=${name#nohuman_reads\/}
	startTime=$(date +%s)
	echo "$file"
	metaphlan2.py -t rel_ab_w_read_stats  --no_map --nproc 24 --input_type fasta nohuman_reads/"$file"  > Taxonomy/"$name".nohuman.fa.metaphlan
	EndTime=$(date +%s)
	echo "Use MetaPhlAn2 taxonomy "$name" took $(( EndTime - startTime )) seconds"
done

merge_metaphlan_tables.py Taxonomy/*.metaphlan | sed 's/.nohuman.fa.metaphlan//g' > Taxonomy/merged_metaphlan2.txt
