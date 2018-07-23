#!/bin/bash

path2bedtools=/hpc/hub_oudenaarden/avo/bin/bedtools2/bin/

if [ $# -ne 1 ]
then
    echo "Please, give:"
    echo "1) input bam file"
    echo "2) output file"
    exit
fi

${path2bedtools}/bamToBed -i $1 -split | awk -F '\t|:' '{col=NF; cell=col-2; umi=col-4; print $0"\t"$cell"\t"$umi}' > $2



