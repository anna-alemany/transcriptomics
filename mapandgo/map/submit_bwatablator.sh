#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=5:00:00
Dmem=10G
threads=1

if [ $# -ne 1 ]
then
    echo "Please, give these following inputs:"
    echo "1) bam file"
    exit
fi

inf=${1%.bam}

echo "python /hpc/hub_oudenaarden/aalemany/bin/mapandgo2/tablator_bwa.py $1" | qsub -V -cwd -N bwatab-${inf} -o bwatab-${inf}.out -e bwatab-${inf}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
