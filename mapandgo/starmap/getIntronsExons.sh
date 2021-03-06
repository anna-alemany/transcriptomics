#!/bin/bash

if [ $# -ne 4 ]
then
    echo "Please, give 4 input files:"
    echo "1) sorted bam file (map with star)"
    echo "2) intron bed file"
    echo "3) exon bed file"
    echo "4) output root files"
    exit
fi

p2b=/hpc/hub_oudenaarden/aalemany/bin/bedtools2/bin
p2s=/hpc/hub_oudenaarden/bdebarbanson/bin/samtools-1.3.1
intronbed=$2
exonbed=$3

${p2b}/bamToBed -i $1 -split > ${4}_bam2bed.bed
${p2b}/bedtools intersect -a ${4}_bam2bed.bed -b ${intronbed} -wb | awk '{if (($6==$10) && ($5==255)) print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$NF}' | uniq > ${4}_intron1.bed &
${p2b}/bedtools intersect -a ${4}_bam2bed.bed -b ${exonbed} -wb | awk '{if (($6==$10) && ($5==255)) print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$NF}' | uniq > ${4}_exon1.bed
wait

chroms=$(${p2s}/samtools view -H $1 | awk -F 'SN:|\t' '{print $3}')

if [ -f ${4}_intron.bed ]
then
    rm ${4}_intron.bed
fi
if [ -f ${4}_exon.bed ]
then
    rm ${4}_exon.bed
fi

for i in $(echo $chroms | awk '{for (i=1; i<=NF; i++) print $i}')
do
    awk -v i=$i '{if ($1==i) print $0}' ${4}_intron1.bed > ${4}_TMP_intron1_${i}.bed &
    awk -v i=$i '{if ($1==i) print $0}' ${4}_exon1.bed > ${4}_TMP_exon1_${i}.bed
    wait

    ${p2b}/bedtools intersect -a ${4}_TMP_intron1_${i}.bed -b ${4}_TMP_exon1_${i}.bed -v >> ${4}_intron.bed &
    ${p2b}/bedtools intersect -a ${4}_TMP_exon1_${i}.bed -b ${4}_TMP_intron1_${i}.bed -v >> ${4}_exon.bed
    wait

    rm  ${4}_TMP_exon1_${i}.bed ${4}_TMP_intron1_${i}.bed
done

rm ${4}_bam2bed.bed
rm ${4}_intron1.bed ${4}_exon1.bed

source /hpc/hub_oudenaarden/aalemany/virtualEnvironments/venv36/bin/activate
/hpc/hub_oudenaarden/aalemany/bin/RNAvelocity/countExonsIntrons.py ${4}_intron.bed ${4}_exon.bed $4

