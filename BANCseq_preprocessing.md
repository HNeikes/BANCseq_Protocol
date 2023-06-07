# 1. Pre-processing
QCs, alignment, peak-calling was performed with seq2science tool; https://vanheeringen-lab.github.io/seq2science/index.html) in order to use spike-in normalisation, it is necessary to align not only to the target genome (human/mouse), but also to the spike-in genome (drosophila / S. cerevisae) an example workflow can look like this:
```console
mkdir BANCseq_NatureProtocols
cd BANCseq_NatureProtocols
conda activate seq2science
seq2science init chip-seq
```
IMPORTANT: adjust the samples.tsv and config.yaml to your needs. And example is provided in the GitHub. Run seq2science for the target and spike-in genome separately.
```console
seq2science run chip-seq --cores 18
```

# 2. Spike in quantification
For spike-in normalisation, calculate read counts of aligned spike-in and human/mouse reads in every sample. Be sure you have samtools installed, for example in a separate conda environment named 'samtools'. If so, activate this environment first.
```console
conda activate samtools
samples='HN0059_1_1000nM_YY1_mESC
HN0059_2_0564nM_YY1_mESC
HN0059_3_0500nM_YY1_mESC
HN0059_4_0250nM_YY1_mESC
HN0059_5_0125nM_YY1_mESC
HN0059_6_0050nM_YY1_mESC
HN0059_7_0010nM_YY1_mESC
HN0059_8_0001nM_YY1_mESC
HN0059_9_0000nM_YY1_mESC'
```
List the sample names here by removing the genome name ('mm10-'/'hg38-') and the '.samtools-coordinates.bam' from the list of bam files generated by seq2science
```console
echo -e "sample\ttargetReads\tspikeInReads" > readCounts.txt
for i in $samples; do echo ${i};
targetReads=`nice samtools view -F 0x4 results_mouse/final_bam/mm10-${i}.samtools-coordinate.bam | cut -f 1 | sort | uniq | wc -l`;
spikeInReads=`nice samtools view -F 0x4 results_spikeIn/final_bam/S.cerevisiae-74-D694-2.0-${i}.samtools-coordinate.bam | cut -f 1 | sort | uniq | wc -l`;
echo -e "${i}\t${targetReads}\t${spikeInReads}" >> readCounts.txt;
done;
conda deactivate
```

# 3.  
Next, for KdApp determination in R, we need the raw read count af every peak for every sample.
## 3a. Scale peaks
For that, we first scale the peaks of the sample with the highest tested TF concentration to the median peak length in that sample (you can do that in R, and store the results in a SAF format, which you will need for the next step)
```console
Rscript BANCseq_MedianPeakLength.R results_mouse/macs2/mm10-HN0059_1_1000nM_YY1_mESC_peaks.narrowPeak mm10-HN0059_1_1000nM_YY1_mESC_peaks.saf
```

## 3b. Read quantification
This can be done with for example featureCounts from the Subread package (https://subread.sourceforge.net/); be sure to have it installed as well. Any other tool to calculate coverage over a set of peaks is of course suitable as well, e.g. bedtools multicov
```console
conda activate featureCounts
featureCounts -p -C -O -g GeneID -s 0 -F SAF -B \
-a mm10-HN0059_1_1000nM_YY1_mESC_peaks.saf \
-o mm10-HN0059_1_1000nM_YY1_mESC_peaks.counts \
results_mouse/final_bam/mm10-*.samtools-coordinate.bam \
2> mm10-HN0059_1_1000nM_YY1_mESC_peaks.log
conda deactivate
```
From here, continue in R for the calculation of KdApps