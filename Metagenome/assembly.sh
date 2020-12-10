
StartTime=$(date +%s)
ls data/*R1*fasta | tr "\n" "," | sed 's/,$//' > R1.csv
ls data/*R2*fasta | tr "\n" "," | sed 's/,$//' > R2.csv
megahit -1 $(<R1.csv) -2 $(<R2.csv) -t 24 -o Assembly
EndTime=$(date +%s)
echo "Use Megahit assembly reads took $(( EndTime - StartTime)) seconds"

