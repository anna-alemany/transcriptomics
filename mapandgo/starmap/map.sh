#!/bin/bash

path2scripts=/hpc/hub_oudenaarden/aalemany/bin/map/starmap
path2bcfile=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2trimgalore=/hpc/hub_oudenaarden/aalemany/bin/TrimGalore-0.4.3
path2cutadapt=/hpc/hub_oudenaarden/aalemany/bin/

if [ $# -ne 5 ]
then
    echo "Please, give following inputs:"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol [celseq1, celseq2, n]"
    echo "4) trim cbc.fastq file [y, n]"
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
trim=$4

#### pool lanes ####
if [ $pool == 'y' ]
then
    zcat ${fq}*R1* > ${outfq}_R1.fastq
    zcat ${fq}*R2* > ${outfq}_R2.fastq
    gzip ${outfq}_R1.fastq
    gzip ${outfq}_R2.fastq
elif [ $pool == 'n' ]
then
    echo "skip pool lanes"
else
    echo "pool lanes [y/n] not specified"
    exit
fi

#### extract cell specific barcode and umi ####
if [ $protocol == 'celseq1' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2bcfile}/bc_celseq1.tsv --cbchd 0 --lenumi 4
elif [ $protocol == 'celseq2' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2bcfile}/bc_celseq2.tsv --cbchd 0 --lenumi 6 --umifirst
elif [ $protocol == 'n' ]
then
    echo "skip concatenation to create cbc.fastq file"
else
    echo "protocol [celseq2, celseq2, n] not specified"
    exit
fi
