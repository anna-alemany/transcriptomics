#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Please, give root to fastq files"
fi

fq=$1
zcat ${fq}*R1* > ${outfq}_R1.fastq
zcat ${fq}*R2* > ${outfq}_R2.fastq
gzip ${outfq}_R1.fastq
gzip ${outfq}_R2.fastq
