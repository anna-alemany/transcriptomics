#!/bin/bash
email=a.alemany@hubrecht.eu
Dt=20:30:00
Dmem=50G
threads=1

if [ $# -ne 5 ]
then
    echo "Please, give in this order the following inputs"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol [celseq1, celseq2, n]"
    echo "4) trim cbc.fastq file [y, n]"
    echo "5) reference folder [mouse, path, n]"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}

echo "/hpc/hub_oudenaarden/aalemany/bin/map/starmap/map.sh $1 $2 $3 $4 $5" | qsub -cwd -N star-${outfq} -o star-${outfq}.out -e star-${outfq}.err -m eas -M ${email} -pe threaded ${threads} -l h_rt=${Dt} -l h_vmem=${Dmem} -V
