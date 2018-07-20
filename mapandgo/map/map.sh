#!/bin/bash

#### Paths to software ####
path2bwa=/hpc/hub_oudenaarden/bin/software/bwa-0.7.10
path2scripts=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2bcfile=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2trimgalore=/hpc/hub_oudenaarden/aalemany/bin/TrimGalore-0.4.3
path2cutadapt=/hpc/hub_oudenaarden/aalemany/bin/
path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64
path2samtools=

#### Paths to reference files ####
## bwa ##
mousebwa=/hpc/hub_oudenaarden/gene_models/mouse_gene_models/mm10_eGFP_mito/mm10_RefSeq_genes_clean_ERCC92_polyA_10_masked_eGFP_Mito.fa
humanbwa=/hpc/hub_oudenaarden/gene_models/human_gene_models/hg19_mito/hg19_RefSeq_genes_clean_ERCC92_polyA_10_masked_Mito.fa
elegansbwa=/hpc/hub_oudenaarden/gene_models/cel_gene_models/Aggregate_1003_genes_sorted_oriented_ERCC92.fa
zebrafishbwa=/hpc/hub_oudenaarden/abarve/genomes/Danio_rerio_Zv9_ens74_extended3_genes_ERCC92_GFPmod_geneids.fa
GFPbwa=/hpc/hub_oudenaarden/gene_models/zebrafish_gene_models/danRer10_clean.fa
## star ##
mousestar=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Mouse-mm10-release81/STAR
humanstar=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Human-hg38-release81/STAR
zebrafishstar=/hpc/hub_oudenaarden/avo/nascent/IRFinder-1.2.3/REF/Zebrafish-dr10-release91/STAR

#### read input parameters ####

if [ $# -ne 7 ]
then
    echo "Please, give the following inputs in this order"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol: celseq1, celseq2, scscar, n [to skip concatenator step]"
    echo "4) trim cbc.fastq.gz file [y, n]"
    echo "5) mapping software [bwa, star]" 
    echo "6) reference genome [mouse, human, elegans, briggsae, zebrafish, GFP, full path for others, n for non (skip mapping)]"
    echo "7) create count tables [y, n]"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
trim=$4
soft=$5
ref=$6
count=$7

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

#### extract cell specific barcode and umi ####
if [ $protocol == 'celseq1' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_celseq1.tsv --cbchd 0 --lenumi 4
    gzip ${outfq}_cbc.fastq.gz
elif [ $protocol == 'celseq2' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_celseq2.tsv --cbchd 0 --lenumi 6 --umifirst
    gzip ${outfq}_cbc.fastq.gz
elif [ $protocol == 'scscar' ]
then
    python ${path2scripts}/concatenator.py --fqf ${outfq} --cbcfile ${path2scripts}/bc_scarsc.tsv --cbchd 0 --lenumi 3 --umifirst
    gzip ${outfq}_cbc.fastq.gz
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
    ${path2trimgalore}/trim_galore --path_to_cutadapt ${path2cutadapt}/cutadapt ${file2trim}
    if [ ${file2trim} == ${outfq}_cbc.fastq.gz ]
    then
        mv ${outfq}_cbc_trimmed.fq.gz ${outfq}_cbc_trimmed.fastq.gz
    elif [ ${file2trim} == ${outfq}_cbc.fastq ]
    then
        mv ${outfq}_cbc_trimmed.fq ${outfq}_cbc_trimmed.fastq
    fi
elif [ $trim == 'n' ]
then
    echo "skip trimming"
else
    echo "trim [y, n] not specified"
    exit
fi

#### map ####
file2map=${outfq}_cbc_trimmed.fastq.gz
if [ ! -f ${file2map} ]
then
    file2map=${outfq}_cbc_trimmed.fastq
    if [ ! -f ${file2map} ]
    then
        echo "file to map _cbc_trimmed.fastq or _cbc_trimmed.fastq.gz not found"
        exit
    fi
fi

if [ $soft == "bwa" ]
then
    if [[ ${ref} = "mouse" ]]
    then
        ref=$mousebwa
    elif [[ ${ref} = "human" ]]
    then
        ref=$humanbwa
    elif [[ ${ref} = "elegans" ]]
    then
        ref=$elegansbwa
    elif [[ ${ref} = "zebrafish" ]]
    then
        ref=$zebrafishbwa
    elif [[ ${ref} = "GFP" ]]
    then
        ref=$GFPbwa
    fi
    if [ ${ref} != 'n' ]
    then
        ${path2bwa}/bwa mem -t 8 ${ref} ${file2map} > ${outfq}.sam
        ${path2samtools}/samtools view -Sb ${outfq}.sam > ${outfq}.bam
        rm ${outfq}.sam
    fi
elif [ $soft == 'star' ]
then
    if [ $ref == 'mouse' ]
    then
       ref=$mousestar
    elif [ $ref == 'human' ]
    then
        ref=$humanstar
    elif [ $ref == 'zebrafish' ]
    then
        ref=$zebrafishstar
    fi
    if [ $ref != 'n' ]
    then
        ${path2star}/STAR --runThreadN 12 --genomeDir $ref --readFilesIn ${file2map} --readFilesCommand zcat --outFileNamePrefix ${outfq}_star --outSAMtype BAM SortedByCoordinate --outSAMattributes All --outSAMstrandField intronMotif --outFilterMultimapNmax 1 --quantMode TranscriptomeSAM
        rm -r ${outfq}_star_STARtmp
    fi

#### Produce count tables ####
if [ $count == 'y' ]
then
    if [ $soft == 'bwa' ] 
    then
        python ${path2scripts}/tablator.py ${outfq}.bam
    elif [ $soft == 'star' ] 
    then
        python ${path2scripts}/tablator.py ${outfq}_starAligned.toTranscriptome.out.bam
    fi
fi
