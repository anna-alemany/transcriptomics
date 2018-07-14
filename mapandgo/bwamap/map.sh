#/bin/bash

# created: 06-06-2018, Anna Alemany (Avo lab)
# The script first takes as input the root name of a set of fastq files (R1, R2) and, when required, merges the different lanes.
# Next, if filters out reads that do not have a proper protocol structure (specific cell-seq barcode, UMI position and length, etc). 
# Only the biological read is kept, polyA read is filtered out.
# bwa mapping to the biological read, annotated with cell-seq barcode and UMI in the read's name.
# Finaly, the count tables are created.

path2bwa=/hpc/hub_oudenaarden/bin/software/bwa-0.7.10
path2scripts=/hpc/hub_oudenaarden/aalemany/bin/mapandgo

if [ $# -ne 5 ]
then
    echo "Please, give the following inputs in this order"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol: celseq1, celseq2, scscar, n [to skip concatenator step]"
    echo "4) reference genome [mouse, human, elegans, briggsae, zebrafish, zebrafishDNA, zebrafishGFP full path for others, n for non (skip mapping)]"
    echo "5) maximum hamming distance to collapse barcodes"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
ref=$4
bccolapse=$5

if [[ ${ref} = "mouse" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/mouse_gene_models/mm10_eGFP_mito/mm10_RefSeq_genes_clean_ERCC92_polyA_10_masked_eGFP_Mito.fa
elif [[ ${ref} = "human" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/human_gene_models/hg19_mito/hg19_RefSeq_genes_clean_ERCC92_polyA_10_masked_Mito.fa
elif [[ ${ref} = "elegans" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/cel_gene_models/Aggregate_1003_genes_sorted_oriented_ERCC92.fa
elif [[ ${ref} = "briggsae" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/cbr_gene_models/cb3_transcriptome_ERCC92.fa
elif [[ ${ref} = "zebrafish" ]]
then
    ref=/hpc/hub_oudenaarden/abarve/genomes/Danio_rerio_Zv9_ens74_extended3_genes_ERCC92_GFPmod_geneids.fa
elif [[ ${ref} = "zebrafishDNA" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/zebrafish_gene_models/danRer10_clean.fa
elif [[ ${ref} = "zebrafishGFP" ]]
then
    ref=/hpc/hub_oudenaarden/gene_models/zebrafish_gene_models/lintrace_histone-GFP_ERCC92.fa
fi

#### pool lanes ####
if [ $pool == 'y' ]
then
    zcat ${fq}*R1* > ${outfq}_R1.fastq
    zcat ${fq}*R2* > ${outfq}_R2.fastq
    gzip ${outfq}_R1.fastq
    gzip ${outfq}_R2.fastq
elif [ $pool == 'n' ]
then
    echo "skip pooling lanes"
else
    echo 'Pool lanes [y/n] not specified'
fi

#### clean fastq file ####
if [ $protocol == 'celseq1' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_celseq1.tsv --cbchd ${bccolapse} --lenumi 4
elif [ $protocol == 'celseq2' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_celseq2.tsv --cbchd ${bccolapse} --lenumi 6 --umifirst
elif [ $protocol == 'scscar' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_scarsc.tsv --cbchd ${bccolapse} --lenumi 3 --umifirst
elif [ $protocol == 'n' ]
then
    echo "skip concatenation to create cbc.fastq file"
else
    echo 'Protocol [celseq1, celseq2, scscar, n] not specified'
fi

#### map ####
file2map=${outfq}_cbc.fastq.gz
if [ $ref != 'n' ]
then
    if [ ! -f ${file2map} ]
    then
        file2map=${outfq}_cbc.fastq
    fi
    if [ ! -f ${file2map} ]
    then
        echo "cbc.fastq or cbc.fastq.gz does not exist!"
        exit
    fi
    ${path2bwa}/bwa mem -t 8 ${ref} ${file2map} > ${outfq}.sam
elif [ $ref == 'n' ]
then
    echo "skip mapping step"
fi

#### tabulator ####
python ${path2scripts}/tablator.py ${outfq}.sam
