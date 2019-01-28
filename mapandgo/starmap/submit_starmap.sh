#!/bin/bash

if [ $# -ne 1 ] 
then
  echo "Please, give input fq.gz file"
fi

file=$1

email=a.alemany@hubrecht.eu
file=library\_cbc_trimmed.fq.gz

path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64
starMouseRef=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/star_index_75
intron=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_introns_exonsubtracted.bed
exon=/hpc/hub_oudenaarden/group_references/ensembl/93/mus_musculus/annotations_ensembl_93_mm_exons.bed

outfq=${file%.fq.gz}_star

echo "${path2star}/STAR --runThreadN 12 --genomeDir ${starMouseRef} --readFilesIn ${file} --readFilesCommand zcat --outFileNamePrefix ${outfq} --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1" | qsub -cwd -N star -m eas -M ${email} -pe threaded 12 -l h_rt=5:00:00 -l h_vmem=30G

