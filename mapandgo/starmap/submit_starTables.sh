#!/bin/bash

if [ $# -ne 4 ]
then
  echo "Please, give: "
  echo "1) sorted bam file (output from STAR mapping)"
  echo "2) bed file with annotated introns (from reference genome)"
  echo "3) bed file with annotated exons (from reference genome)"
  echo "4) root for name of output files"
fi

email=a.alemany@hubrecht.eu

bamfile=$1
intron=$2
exon=$3
output=$4

echo "/hpc/hub_oudenaarden/aalemany/bin/RNAvelocity/getIntronsExons.sh $bamfile $intron $exon $output" | qsub -V -cwd -N RNAv -hold_jid star -m eas -M ${email} -pe threaded 2 -l h_rt=24:00:00 -l h_vmem=30G
