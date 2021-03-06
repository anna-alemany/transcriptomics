## Explanation found in https://www.biostars.org/p/13290/ 

Following is a set of detailed instructions on how to get a BED file of all introns from the UCSC table browser. Note that most of the following options will be set by default. So the number of steps required is not as bad as it seems

* Go to the UCSC table browser.
* Select desired species and assembly
* Select group: Genes and Gene Prediction Tracks
* Select track: UCSC Genes (or Refseq, Ensembl, etc.)
* Select table: knownGene
* Select region: genome (or you can test on a single chromosome or smaller region)
* Select output format: BED - browser extensible data
* Enter output file: UCSC_Introns.tsv
* Select file type returned: gzip compressed
* Hit the 'get output' button
* A second page of options relating to the BED file will appear.
* Under 'create one BED record per:'. Select 'Introns plus'
* Add desired flank for introns being returned, or leave as 0 to get just the introns
* Hit the 'get BED' option

You will get output that looks like this for every UCSC gene:

| chromosome | start | end | gene_name | strand | strand |
| ---------- | ----- | --- | --------- | ------ | ------ |
| chr3  |  124449474  |  124453939  |  uc003ehl.3_intron_0_0_chr3_124449475_f |   0  |  + |
| chr3  |  124454093  |  124456414  |  uc003ehl.3_intron_1_0_chr3_124454094_f |   0  |  + |
| chr3  |  124457086  |  124458870  |  uc003ehl.3_intron_2_0_chr3_124457087_f |   0  |  + |
| chr3  |  124459046  |  124460998  |  uc003ehl.3_intron_3_0_chr3_124459047_f |   0  |  + |
| chr3  |  124461113  |  124462761  |  uc003ehl.3_intron_4_0_chr3_124461114_f |   0  |  + |
