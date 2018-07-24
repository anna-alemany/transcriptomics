#!/bin/bash

#### Paths to scripts ####
path2scripts=/hpc/hub_oudenaarden/aalemany/bin/mapandgo

#### read input parameters ####

if [ $# -ne 8 ]
then
    echo "Please, give the following inputs in this order"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) output root name (no extensions)"
    echo "3) pool lanes [y, n]"
    echo "4) protocol: celseq1, celseq2, scscar, n [to skip concatenator step]"
    echo "5) trim cbc.fastq.gz file [y, n]"
    echo "6) mapping software [bwa, star]" 
    echo "7) reference genome [mouse, human, elegans, briggsae, zebrafish, GFP, full path for others, n for non (skip mapping)]"
    echo "8) create count tables [y, n]"
    exit
fi

fq=$1
outfq=$2
pool=$3
protocol=$4
trim=$5
soft=$6
ref=$7
count=$8

#### pool lanes ####
if [ $pool == 'y' ]
then
    ${path2scripts}/mergeLanes.sh $fq $outfq
elif [ $pool == 'n' ]
then
    echo "skip pooling lanes"
else
    echo 'Pool lanes [y/n] not specified'
fi

#### extract cell specific barcode and umi ####
if [ $protocol =! 'n' ]
then
    ${path2scripts}/extractBC.sh ${outfq} ${protocol}
    gzip ${outfq}_cbc.fastq
elif [ $protocol == 'n' ]
then
    echo "skip concatenation to create cbc.fastq file"
else
    echo 'Protocol [celseq1, celseq2, scscar, n] not specified'
fi

#### trim low quality bases ####
if [ $trim == 'y' ]
then
    file2trim=${outfq}_cbc.fastq.gz
    if [ ! -f ${file2trim} ]
    then
        file2trim=${outfq}_cbc.fastq
        if [ ! -f ${file2trim} ]
            then
            echo "file to trim (fastq or fastq.gz) not found"
            exit
        fi        
    fi
    ${path2scripts}/trim.sh ${file2trim}
elif [ $trim == 'n' ]
then
    echo "skip trimming"
else
    echo "trim [y, n] not specified"
    exit
fi

#### map ####
file2map=${outfq}_cbc_trimmed.fq.gz
if [ ! -f ${file2map} ]
then
    file2map=${outfq}_cbc_trimmed.fq
    if [ ! -f ${file2map} ]
    then
        echo "file to map _cbc_trimmed.fq or _cbc_trimmed.fq.gz not found"
        exit
    fi
fi

if [ $ref != 'n' ]
then
    if [ $soft == "bwa" ]
    then
        ${path2scripts}/mapbwa.sh ${file2map} ${outfq}_bwa $ref
    elif [ $soft == 'star' ]
    then
        ${path2scripts}/mapstar.sh ${file2map} ${outfq}_star $ref
    fi
else
    echo "skip mapping"
fi

#### Produce count tables ####
if [ $count == 'y' ]
then
    if [ $soft == 'bwa' ] 
    then
        ${path2scripts}/createCountTables.sh ${outfq}_bwa.bam
    elif [ $soft == 'star' ] 
    then
        ${path2scripts}/createCountTables.sh ${outfq}_starAligned.toTranscriptome.out.bam
    fi
fi
