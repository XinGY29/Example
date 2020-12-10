###该sh文件需要在Qiime2 conda环境下运行，激活环境 conda activate qiime2-2020.8
#导入数据
startTime=$(date +%s)
qiime tools import \
  --type "SampleData[SequencesWithQuality]" \
  --input-format SingleEndFastqManifestPhred33V2 \
  --input-path ./manifest.tsv \
  --output-path ./demux_seqs.qza
endTime=$(date +%s)
echo "import data took $((endTime - startTime)) seconds" 
#使用dada2算法进行聚类处理
startTime=$(date +%s)
mkdir denoise
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux_seqs.qza \
  --p-trunc-len 150 \
  --p-n-threads 8 \
  --o-representative-sequences denoise/dada2_rep_set.qza \
  --o-table denoise/dada2_table.qza \
  --o-denoising-stats denoise/dada2_stats.qza
endTime=$(date +%s)
echo "dada2 denoise took $((endTime - startTime)) seconds" 
#查看结果/结果可视化，可选项
startTime=$(date +%s)
qiime metadata tabulate \
  --m-input-file denoise/dada2_stats.qza \
  --o-visualization denoise/dada2_stats.qzv
endTime=$(date +%s)
echo "make sOTUs table took $((endTime - startTime)) seconds" 
#提取聚类之后的信息
qiime feature-table summarize \
  --i-table denoise/dada2_table.qza \
  --m-sample-metadata-file metadata.tsv \
  --o-visualization denoise/data2_table.qzv
 
#训练分类器
startTime=$(date +%s)
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads taxonomy/ref_seqs_v4.qza \
  --i-reference-taxonomy taxonomy/ref_tax.qza \
  --i-class-weight taxonomy/animal_distal_gut.qza \
  --o-classifier taxonomy/bespoke.qza
endTime=$(date +%s)
echo "fit-classifier-naive-bayes took $((endTime - startTime)) seconds" 

#进行分类
startTime=$(date +%s)
qiime feature-classifier classify-sklearn \
  --i-reads denoise/dada2_rep_set.qza \
  --i-classifier taxonomy/bespoke.qza \
  --o-classification taxonomy/bespoke_taxonomy.qza
endTime=$(date +%s)
echo "classify-sklearn took $((endTime - startTime)) seconds" 

#分类结果可视化
qiime metadata tabulate \
  --m-input-file ./taxonomy/bespoke_taxonomy.qza \
  --o-visualization ./taxonomy/bespoke_taxonomy.qzv

#构建进化树分析
#使用参考序列的方法
#wget \
	#  -O "sepp-refs-gg-13-8.qza" \
	#  "https://data.qiime2.org/2020.8/common/sepp-refs-gg-13-8.qza"
#qiime fragment-insertion sepp \
	#  --i-representative-sequences ./dada2_rep_set.qza \
	#  --i-reference-database sepp-refs-gg-13-8.qza \
	#  --o-tree ./tree.qza \
	#  --o-placements ./tree_placements.qza \
	#  --p-threads 1  # update to a higher number if you can
#使用mafft fastttree构建进化树的方法
startTime=$(date +%s)
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences denoise/dada2_rep_set.qza \
  --output-dir mafft-fasttree-output
endTime=$(date +%s)
echo "mafft fastttree took $((endTime - startTime)) seconds" 

#Alpha rarefaction plotting
startTime=$(date +%s)
mkdir diversity
qiime diversity alpha-rarefaction \
  --i-table denoise/dada2_table.qza \
  --m-metadata-file metadata.tsv \
  --i-phylogeny mafft-fasttree-output/rooted_tree.qza \
  --p-min-depth 10 \
  --p-max-depth 4250 \
  --o-visualization diversity/alpha_rarefaction_curves.qzv
endTime=$(date +%s)
echo "alpha-rarefaction took $((endTime - startTime)) seconds" 

#进行多样性分析
startTime=$(date +%s)
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny mafft-fasttree-output/rooted_tree.qza \
  --i-table denoise/dada2_table.qza \
  --p-sampling-depth 2000 \
  --m-metadata-file metadata.tsv \
  --output-dir core-metrics-results
endTime=$(date +%s)
echo "core-metrics-phylogenetic took $((endTime - startTime)) seconds" 

#Alpha diversity
startTime=$(date +%s)
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file  metadata.tsv \
  --o-visualization core-metrics-results/evenness_statistics.qzv
endTime=$(date +%s)
echo "Alpha diversity took $((endTime - startTime)) seconds" 

#Beta diversity
startTime=$(date +%s)
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column cage_id \
  --o-visualization core-metrics-results/unweighted-unifrac-cage-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column cage_id \
  --o-visualization core-metrics-results/weighted-unifrac-cage-significance.qzv
endTime=$(date +%s)
echo "Beta diversity took $((endTime - startTime)) seconds" 





