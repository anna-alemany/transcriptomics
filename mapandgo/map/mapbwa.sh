#!/bin/bash

path2bwa=/hpc/hub_oudenaarden/bin/software/bwa-0.7.10
path2samtools=/hpc/hub_oudenaarden/bdebarbanson/bin/samtools-1.3.1

if [ $# -ne 3 ]
then
    echo "Please, give:"
    echo "1) input fastq file to map"
    echo "2) root for output file (no .sam or .bam extension)"
    echo "2) reference file [mouse, human, elegans, zebrafish, GFP, full path to reference file]"
fi

file2map=$1
outfq=$2
ref=$3

if [ $ref == 'mouse' ]
then
    ref=/hpc/hub_oudenaarden/gene_models/mouse_gene_models/mm10_eGFP_mito/mm10_RefSeq_genes_clean_ERCC92_polyA_10_masked_eGFP_Mito.fa
elif [ $ref == 'human' ]
then
    ref=/hpc/hub_oudenaarden/gene_models/human_gene_models/hg19_mito/hg19_RefSeq_genes_clean_ERCC92_polyA_10_masked_Mito.fa
elif [ $ref == 'elegans' ] 
then
    ref=/hpc/hub_oudenaarden/gene_models/cel_gene_models/Aggregate_1003_genes_sorted_oriented_ERCC92.fa
elif [ $ref == 'zebrafish' ]
then
    ref=/hpc/hub_oudenaarden/abarve/genomes/Danio_rerio_Zv9_ens74_extended3_genes_ERCC92_GFPmod_geneids.fa
elif [ $ref == 'GFP' ]
then
    ref=/hpc/hub_oudenaarden/gene_models/zebrafish_gene_models/danRer10_clean.fa
fi

${path2bwa}/bwa mem -t 8 ${ref} ${file2map} > ${outfq}.sam
${path2samtools}/samtools view -Sb ${outfq}.sam > ${outfq}.bam
rm ${outfq}.sam
