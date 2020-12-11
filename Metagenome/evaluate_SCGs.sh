../CONCOCT/scripts/COG_table.py -b Annotate/contigs_gt1000_c10K.faa.out -m ../CONCOCT/scgs/scg_cogs_min0.97_max1.03_unique_genera.txt -c concoct_output/clustering_gt1000.csv --cdd_cog_file ../CONCOCT/scgs/cdd_to_cog.tsv > clustering_gt1000_scg.tsv
../CONCOCT/scripts/COGPlot.R -s clustering_gt1000_scg.tsv -o clustering_gt1000_scg.pdf

tr "\t" "," < Concoct/coverage_table.tsv > Concoct/coverage_table.csv
python ../metag-rev-sup/ClusterMeanCov.py Concoct/coverage_table.csv concoct_output/clustering_gt1000.csv Concoct/contigs_10K.fa > cluster_freq.csv
