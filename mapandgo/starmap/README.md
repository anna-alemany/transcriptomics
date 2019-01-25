# Map transcriptome data with star. 
We start from fastq files and end up with a table of unspliced and spliced transcripts per gene. 

Let's assume we start with the following fastq files:

* library_L001_R1_001.fastq.gz
* library_L001_R2_001.fastq.gz
* library_L002_R1_001.fastq.gz
* library_L002_R2_001.fastq.gz
* library_L003_R1_001.fastq.gz
* library_L003_R2_001.fastq.gz
* library_L004_R1_001.fastq.gz
* library_L004_R2_001.fastq.gz

## Steps

1. Merge lanes

```{bash}
submit_mergeLanes.sh library_L00 library
```
This will produce two new fastq files, named _library_R1.fastq.gz_ and _library_R2.fastq.gz_, which contain all the merged reads from R1 and R2 fastq files, respectively. You can keep these and remove all the initial fastq files. 

2. Demultiplex reads

```{bash}
submit_extractBC.sh library celseq2
```
Here we filter out reads that do not have a celseq2 barcode. We produce a new fastq file named _library\_cbc.fastq.gz_.

3. Trim data

```{bash}
submit_trim.sh library_cbc.fastq.gz
```

This will remove illumina adaptors from the end of the reads, and additionally will also get rid of bad quality base calls at the 3'-end of reads. A new file is produced, named _library\_cbc_trimmed.fq.gz_. 

4. Map with star
```{bash}
email=a.alemany@hubrecht.eu
file=library\_cbc_trimmed.fq.gz

path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64
starMouseRef=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/star_index_75
intron=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_introns_exonsubtracted.bed
exon=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_exons.bed

outfq=${file%.fq.gz}_star

echo "${path2star}/STAR --runThreadN 12 --genomeDir ${starMouseRef} --readFilesIn ${file} --readFilesCommand zcat --outFileNamePrefix ${outfq} --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1" | qsub -cwd -N star -m eas -M ${email} -pe threaded 12 -l h_rt=5:00:00 -l h_vmem=30G
````
We map using the STAR software to the reference genome (not transcriptome!). STAR needs a lot of memory, but generally goes very fast. 
After mapping, a bam file named library\_cbc_trimmedAligned.sortedByCoord.out.bam will be produced. 

To quickly assess mappability, we can do it from the bamfile. This command will give you the number of uniquely mapped reads:

````{bash}
samtools view -q 255 library_cbc_trimmed_starAligned.sortedByCoord.out.bam | wc
````


4. Get count tables

````
bamfile=library_cbc_trimmed_starAligned.sortedByCoord.out.bam

echo "/hpc/hub_oudenaarden/aalemany/bin/RNAvelocity/getIntronsExons.sh ${outfq}Aligned.sortedByCoord.out.bam $intron $exon ${outfq}_ie" | qsub -V -cwd -N RNAv -hold_jid star -m eas -M ${email} -pe threaded 2 -l h_rt=24:00:00 -l h_vmem=30G
```
