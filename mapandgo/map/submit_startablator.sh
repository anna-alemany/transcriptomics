#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=5:00:00
Dmem=10G
threads=1

if [ $# -ne 2 ]
then
    echo "Please, give these following inputs:"
    echo "1) bam file"
    echo "2) genome"
    exit
fi

inf=${1%.bam}
if [ $2 == 'mouse' ]
then
    ref=/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/transcript2geneID_mm10_fromGTF.tsv
else
    echo "sorry, genome not characterized yet."
    exit
fi

echo "python /hpc/hub_oudenaarden/aalemany/bin/mapandgo2/tablator_star.py $1 $ref" | qsub -V -cwd -N startab-${inf} -o startab-${inf}.out -e startab-${inf}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
