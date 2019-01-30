# Map transcriptome data with star

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

### 1. Merge lanes

```{bash}
submit_mergeLanes.sh library_L00 library
```
This will produce two new fastq files, named _library_R1.fastq.gz_ and _library_R2.fastq.gz_, which contain all the merged reads from R1 and R2 fastq files, respectively. You can keep these and remove all the initial fastq files. 

### 2. Demultiplex reads

```{bash}
submit_extractBC.sh library celseq2
```
Here we filter out reads that do not have a celseq2 barcode. The protocol celseq2 can be replaced by celseq1 or nla. 

This produces a new fastq file named _library\_cbc.fastq.gz_.

### 3. Trim data

```{bash}
submit_trim.sh library_cbc.fastq.gz
```

This will remove illumina adaptors from the end of the reads, and additionally will also get rid of bad quality base calls at the 3'-end of reads. A new file is produced, named _library\_cbc_trimmed.fq.gz_. 

### 4. Map with star

```{bash}
submit_starmap.sh library\_cbc_trimmed.fq.gz
````
We map using the STAR software to the reference genome (not transcriptome!). STAR needs a lot of memory, but generally goes very fast. 
After mapping, a bam file named library\_cbc_trimmedAligned.sortedByCoord.out.bam will be produced. 

To quickly assess mappability, we can do it from eiter the bam file of the coutc.tsv file. This last file is produced in the next step, so for now I will focus here on the bam file. The two following commands will give you the number of reads and the number of uniquely mapped reads, respectively:

````{bash}
zcat library_cbc_trimmed.fq.gz | grep '+' | wc
samtools view -q 255 library_cbc_trimmed_starAligned.sortedByCoord.out.bam | wc
````
The mappability is equal to the division of the first number by the second. 

### 5. Get count tables

````{bash}
submit_starTables.sh library_cbc_trimmed_starAligned.sortedByCoord.out.bam intron_file.bed exon_file.bed output_name
````
This will produce a total of 9 files:

