#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Please, give input (1) root file; (2) protocol [celseq1, celseq2, nla, scarsc]; (3) reference [mouse]"
    exit
fi

p2s=/hpc/hub_oudenaarden/aalemany/bin/mapandgo2
submit=/hpc/hub_oudenaarden/group_scripts/submission.py
source /hpc/hub_oudenaarden/aalemany/virtualEnvironments/venv36/bin/activate

in=$1
out=${in%_*_S*_L*}
protocol=$2
reference=$3

# merge data
$submit "${p2s}/mergeLanes.sh $in $out" -y --mf -N merge-$out -jp merge-$out -m 10 -time 15 -t 2

# extract barcodes
$submit "${p2s}/extractBC.sh $out ${protocol}" -y --mf -N extract-$out -jp extract-$out -m 10 -time 15 -hold merge-$out

# trim
$submit "${p2s}/trim.sh ${out}_cbc.fastq.gz" -y --mf -N trim-$out -jp trim-$out -m 10 -time 15 -hold merge-$out -hold extract-$out

# map with star
$submit "${p2s}/mapstar.sh ${out}_cbc_trimmed.fq.gz ${out}_cbc_trimmed_star $reference" -y --mf -N map-$out -jp map-$out -m 30 -time 15 -t 12 -hold merge-$out -hold extract-$out -hold trim-$out

# create count tables from star map
$submit "${p2s}/RNAvel_tables.sh ${out}_cbc_trimmed_starAligned.sortedByCoord.out.bam ${out}_cbc_trimmed_star" -y --mf -N tab-$out -jp tab-$out -m 10 -time 15 -t 2 -hold merge-$out -hold extract-$out -hold trim-$out -hold map-$out
