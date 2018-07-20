#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=15:00:00
Dmem=10G
threads=1

if [ $# -ne 1 ]
then
    echo "Please, give:"
    echo "1) fastqfile to trim"
    exit
fi

input==$1

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/trim.sh $1" | qsub -cwd -N trim-$1 -o trim-$1.out -e trim-$1.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
