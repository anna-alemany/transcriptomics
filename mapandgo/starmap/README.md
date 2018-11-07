Map transcriptome data with star. 
Get a table of unspliced and spliced transcripts.

# Steps

1. Merge lanes
```{bash}
submit_mergeLanes.sh MB-2-gastruloid-plateG-C5-transcriptome-FACS0108_AH2FMNBGX9_S2_L00 MB-2-gastruloid-plateG-C5-transcriptome-FACS0108
```

2. Demultiplex reads
```{bash}
submit_extractBC.sh MB-2-gastruloid-plateG-C5-transcriptome-FACS0108 celseq2
```

3. Trim data
```{bash}
submit_trim.sh MB-2-gastruloid-plateG-C5-transcriptome-FACS0108.fq.gz
```

4. Map
```{bash}
path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64
starMouseRef=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/star_index_75
intron=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_introns_exonsubtracted.bed
exon=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_exons.bed

for file in *fq.gz 
do
    outfq=${file%.fq.gz}_star
    echo $file $outfq
    echo "${path2star}/STAR --runThreadN 12 --genomeDir ${starMouseRef} --readFilesIn ${file} --readFilesCommand zcat --outFileNamePrefix ${outfq} --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1" | qsub -cwd -N star -m eas -M ${email} -pe threaded 12 -l h_rt=5:00:00 -l h_vmem=30G
    echo "/hpc/hub_oudenaarden/aalemany/bin/RNAvelocity/getIntronsExons.sh ${outfq}Aligned.sortedByCoord.out.bam $intron $exon ${outfq}_ie" | qsub -V -cwd -N RNAv -hold_jid star -m eas -M ${email} -pe threaded 2 -l h_rt=24:00:00 -l h_vmem=30G
done
```
