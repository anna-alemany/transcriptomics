#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=30:00:00
Dmem=30G
threads=12

if [ $# -ne 1 ]
then
    echo "Please, give"
    echo "1) root input fastq lanes"
    echo "2) protocol (celseq1, celseq2, nla)"
    exit
fi

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/map.sh $1 $2" | qsub -cwd -N map-$1 -o map-${1}.out -e map-${1}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
