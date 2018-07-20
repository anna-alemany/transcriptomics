#!/bin/bash

path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64

if [ $# -ne 2 ]
then
    echo "Please, give:"
    echo "1) fastq file to map"
    echo "2) root for output file (no .sam or .bam extension)"
    echo "3) reference genome"
fi

file2map=$1
outfq=$2
ref=$3

if [ $ref == 'mouse' ]
then
   ref=$mousestar
elif [ $ref == 'human' ]
then
    ref=$humanstar
elif [ $ref == 'zebrafish' ]
then
    ref=$zebrafishstar
fi

${path2star}/STAR --runThreadN 12 --genomeDir $ref --readFilesIn ${file2map} --readFilesCommand zcat --outFileNamePrefix ${outfq} --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1 --quantMode TranscriptomeSAM
rm -r ${outfq}_STARtmp
