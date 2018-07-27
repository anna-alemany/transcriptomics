#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Please, give input root file"
    exit
fi

p2s=/hpc/hub_oudenaarden/aalemany/bin/mapandgo2


in=$1
out=${in%_*_S*_L*}

# merge data
${p2s}/mergeLanes.sh $in $out

# extract barcodes
${p2s}/extractBC.sh $out celseq2

# trim
${p2s}/trim.sh ${out}_cbc.fastq.gz

# map with bwa
${p2s}/mapbwa.sh ${out}_cbc_trimmed.fq.gz ${out}_cbc_trimmed_bwa mouse

# map with star
${p2s}/mapstar.sh ${out}_cbc_trimmed.fq.gz ${out}_cbc_trimmed_star mouse

# create cout tables from bwa map
python ${p2s}/tablator_bwa.py ${out}_cbc_trimmed_bwa.bam
