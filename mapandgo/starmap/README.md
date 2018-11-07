Map transcriptome data with star. 
Get a table of unspliced and spliced transcripts.

Let's assume we start with the following fastq files:

* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L001_R1_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L001_R2_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L002_R1_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L002_R2_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L003_R1_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L003_R2_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L004_R1_001.fastq.gz
* MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L004_R2_001.fastq.gz

# Steps

1. Merge lanes
```{bash}
submit_mergeLanes.sh MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_AH2FMNBGX9_S1_L00 MB-2-gastruloid-plateF-C5-transcriptome-FACS0108
```
This will produce two new fastq files, named _MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_R1.fastq.gz_ and _MB-2-gastruloid-plateF-C5-transcriptome-FACS0108_R2.fastq.gz_, which contain all the merged reads from R1 and R2 fastq files, respectively. You can keep these and remove all the initial fastq files. 

2. Demultiplex reads
```{bash}
submit_extractBC.sh MB-2-gastruloid-plateG-C5-transcriptome-FACS0108 celseq2
```
Here we filter out reads that do not have a celseq2 barcode. We produce a new fastq file 

3. Trim data
```{bash}
submit_trim.sh MB-2-gastruloid-plateG-C5-transcriptome-FACS0108.fq.gz
```

4. Map and get count tables
```{bash}
path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64
starMouseRef=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/star_index_75
intron=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_introns_exonsubtracted.bed
exon=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_exons.bed

file=

outfq=${file%.fq.gz}_star
echo $file $outfq
echo "${path2star}/STAR --runThreadN 12 --genomeDir ${starMouseRef} --readFilesIn ${file} --readFilesCommand zcat --outFileNamePrefix ${outfq} --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1" | qsub -cwd -N star -m eas -M ${email} -pe threaded 12 -l h_rt=5:00:00 -l h_vmem=30G
echo "/hpc/hub_oudenaarden/aalemany/bin/RNAvelocity/getIntronsExons.sh ${outfq}Aligned.sortedByCoord.out.bam $intron $exon ${outfq}_ie" | qsub -V -cwd -N RNAv -hold_jid star -m eas -M ${email} -pe threaded 2 -l h_rt=24:00:00 -l h_vmem=30G
```
