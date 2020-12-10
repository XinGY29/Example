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


	
