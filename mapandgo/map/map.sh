#!/bin/bash

#### Paths to software ####
path2bwa=/hpc/hub_oudenaarden/bin/software/bwa-0.7.10
path2scripts=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2scripts=/hpc/hub_oudenaarden/aalemany/bin/map/starmap
path2bcfile=/hpc/hub_oudenaarden/aalemany/bin/mapandgo
path2trimgalore=/hpc/hub_oudenaarden/aalemany/bin/TrimGalore-0.4.3
path2cutadapt=/hpc/hub_oudenaarden/aalemany/bin/
path2star=/hpc/hub_oudenaarden/avo/nascent/STAR-2.5.3a/bin/Linux_x86_64

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

if [ $# -ne 6 ]
then
    echo "Please, give the following inputs in this order"
    echo "1) library name (name until 1_R*_001.fastq.gz)"
    echo "2) pool lanes [y, n]"
    echo "3) protocol: celseq1, celseq2, scscar, n [to skip concatenator step]"
    echo "4) trim cbc.fastq.gz file [y, n]"
    echo "5) reference genome [mouse, human, elegans, briggsae, zebrafish, zebrafishDNA, zebrafishGFP full path for others, n for non (skip mapping)]"
    echo "6) create count tables [y, n]"
    exit
fi

fq=$1
outfq=${fq%_*_S*_L*}
pool=$2
protocol=$3
trim=$4
ref=$5
count=$6

