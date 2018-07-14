#!/bin/bash
email=a.alemany@hubrecht.eu
Dt=20:30:00
Dmem=10G
threads=1

if [ $# -ne 5 ]
then
    echo "Please, give in this order the following inputs"
    echo "1) root of fastq.gz files to map together (common part in all of them)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol. Options are: [celseq1, celseq2, scarsc, n (to skip concatenation)]"
    echo "4) reference genome/transcriptome (full path OR any of [mouse, human, elegans, briggsae, zebrafish, zebrafishDNA, zebrafishGFP], n (to skip mapping))"
    echo "5) maximum hamming distance to collapse cel barcodes."
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}

echo "/hpc/hub_oudenaarden/aalemany/bin/mapandgo/map.sh $1 $2 $3 $4 $5" | qsub -cwd -N map-${outfq} -o map-${outfq}.out -e map-${outfq}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem} -V 

