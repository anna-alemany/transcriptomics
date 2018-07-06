#/bin/bash

# created: 06-06-2018, Anna Alemany (Avo lab)
# The script first takes as input the root name of a set of fastq files (R1, R2) and, when required, merges the different lanes.
# Next, if filters out reads that do not have a proper protocol structure (specific cell-seq barcode, UMI position and length, etc). 
# Only the biological read is kept, polyA read is filtered out.
# bwa mapping to the biological read, annotated with cell-seq barcode and UMI in the read's name.
# Finaly, the count tables are created.

path2bwa=/hpc/tmp/avo/bwa/
path2scripts=/hpc/tmp/aalemany/bin/mapandgo/

if [ $# -ne 4 ]
then
    echo "Please, give the following inputs in this order"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol: celseq1, celseq2, scscar"
    echo "4) reference genome [human]"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
reference=$4

#### pool lanes ####
if [ $pool == 'y' ]
then
    zcat ${fq}*R1* > ${outfq}_R1.fastq
    zcat ${fq}*R2* > ${outfq}_R2.fastq
    gzip ${outfq}_R1.fastq
    gzip ${outfq}_R2.fastq
elif [ $pool == 'n' ]
then
    continue
else
    echo 'Pool lanes [y/n] not specified'
fi

#### clean fastq file ####
if [ $protocol == 'celseq1' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile {path2scripts}/bc_celseq1.tsv --cbchd 0 --lenumi 4
elif [ $protocol == 'celseq2' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile {path2scripts}/bc_celseq2.tsv --cbchd 0 --lenumi 6 --umifirst
elif [ $protocol == 'scscar' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile {path2scripts}/bc_scarsc.tsv --cbchd 0 --lenumi 3 --umifirst
else
    echo 'Protocol [celseq1, celseq2, scscar] not specified'
fi

#### map ####
if [ $reference == 'human' ]
then
    ref=/hpc/tmp/Mauro/refGenomes/hg19/hg19_RefSeq_genes_clean_ERCC92_fl.fa
fi
${path2bwa}/bwa mem -t 8 ${ref} ${outfq}_cbc.fastq > ${outfq}.sam

#### tabulator ####


#### zip files ####
gzip ${outfq}_cbc.fastq
