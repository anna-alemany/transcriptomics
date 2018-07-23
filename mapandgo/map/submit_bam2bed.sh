#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=02:00:00
Dmem=5G
threads=1

if [ $# -ne 2 ]
then
    echo "Please, give these following inputs:"
    echo "1) input bam file"
    echo "2) output bed file"
    exit
fi

input==$1
output=$2

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/bam2bed.sh $1 $2" | qsub -cwd -N ${output%.bed} -o b2b-${output%.bed}.out -e b2b-${output%.bed}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
