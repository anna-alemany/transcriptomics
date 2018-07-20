#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=15:00:00
Dmem=10G
threads=1

if [ $# -ne 2 ]
then
    echo "Please, give these following inputs:"
    echo "1) root of _*_S*_L*_R1/R2.fastq.gz files"
    echo "2) root for output files"
    exit
fi

input==$1
output=$2

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/mergeLanes.sh $1 $2" | qsub -cwd -N ${output} -o merge-${output}.out -e merge-${output}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
