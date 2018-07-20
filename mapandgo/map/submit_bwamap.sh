#!/bin/bash

email=a.alemany@hubrecht.eu
Dt=15:00:00
Dmem=20G
threads=5

if [ $# -ne 3 ]
then
    echo "Please, give these following inputs:"
    echo "1) input fastq file to map"
    echo "2) root for output file (no .sam or .bam exntesion)"
    echo "3) reference file [mouse, elegans, human, zebrafish, GFP, full path to reference file]"
    exit
fi

infq=$1
outbam=$2
ref=$3

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo2/mapbwa.sh $infq $outbam $ref" | qsub -cwd -N bwa-$outbam -o bwa-${outbam}.out -e bwa-${outbam}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem}
