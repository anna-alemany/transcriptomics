#!/bin/bash

path2scripts=/hpc/hub_oudenaarden/aalemany/bin/map/starmap
path2bcfile=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2trimgalore=/hpc/hub_oudenaarden/aalemany/bin/TrimGalore-0.4.3
path2cutadapt=/hpc/hub_oudenaarden/aalemany/bin/
path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64

if [ $# -ne 5 ]
then
    echo "Please, give following inputs:"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol [celseq1, celseq2, n]"
    echo "4) trim cbc.fastq file [y, n]"
    echo "5) reference genome folder [mouse, path, n]"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
trim=$4
ref=$5

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
    gzip ${outfq}_cbc.fastq
elif [ $protocol == 'celseq2' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2bcfile}/bc_celseq2.tsv --cbchd 0 --lenumi 6 --umifirst
    gzip ${outfq}_cbc.fastq
elif [ $protocol == 'n' ]
then
    echo "skip concatenation to create cbc.fastq file"
else
    echo "protocol [celseq2, celseq2, n] not specified"
    exit
fi

#### trim low quality bases ####
if [ $trim == 'y' ]
then
    file2trim=${outfq}_cbc.fastq.gz
    if [ ! -f ${file2trim} ]
    then
        file2trim=${outfq}_cbc.fastq
    fi
    if [ ! -f ${file2trim} ]
    then
        echo "file to trim (fastq or fastq.gz) not found"
        exit
    fi
    ${path2trimgalore}/trim_galore --path_to_cutadapt ${path2cutadapt}/cutadapt ${file2trim}
    mv ${outfq}_cbc_trimmed.fq.gz ${outfq}_cbc_trimmed.fastq.gz
elif [ $trim == 'n' ]
then
    echo "skip trimming"
else
    echo "trim [y, n] not specified"
    exit
fi

#### Map using STAR ####
file2map=${outfq}_cbc_trimmed.fastq.gz
if [ ! -f ${file2map} ]
then
    file2map=${outfq}_cbc_trimmed.fastq
    if [ ! -f ${file2map} ]
    then
        echo "file to map _cbc_trimmed.fq or _cbc_trimmed.fq.gz not found"
        exit
    fi
    gzip ${file2map}
    file2map=${outfq}_cbc_trimmed.fastq.gz
fi

if [ $ref == 'mouse' ]
then
   ref=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Mouse-mm10-release81/STAR
elif [ $ref == 'human' ]
then
    ref=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Human-hg38-release81/STAR
elif [ $ref == 'zebrafish' ]
then
    ref=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Zebrafish-dr10-release91/STAR
fi

if [ $ref != 'n' ]
then
    ${path2star}/STAR --runThreadN 12 --genomeDir $ref --readFilesIn ${file2map} --readFilesCommand zcat --outFileNamePrefix ${outfq}_star --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1 --quantMode TranscriptomeSAM
fi
