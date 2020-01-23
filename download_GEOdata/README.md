# Download data from GEO

## Steps 

1. Download *.txt file with list of all GSM numbers that belong to the repository (e.g. GSE_Sample.txt: single column file with al listed GSE numbers).

2. Convert them to SRR id's:
```{bash}
for gsm in $(awk '{if (NR>1) print $NF}' GSE_Sample.txt );  
do  
  srr=$(esearch -db sra -query $gsm | efetch -format runinfo | awk -F "," '{print $1}' | grep 'SRR'); echo $gsm $srr; 
done > SRR_Sample.txt
```
you can alternatively obtain all SRR id's from the SRP number:
```{bash}
SRA=$1
esearch -db sra -query $SRA | \
  efetch -format docsum | \
  xtract -pattern DocumentSummary -element Run@acc | \
  tr '\t' '\n'
```


3. Change download directory by writing:
```{bash}
run vdb-config -i
```
and setting the new directory

4. Download data. For each srr number: 

```{bash}
/hpc/hub_oudenaarden/aalemany/bin/sratoolkit.2.8.0-ubuntu64/bin/prefetch -v $srr
/hpc/hub_oudenaarden/aalemany/bin/sratoolkit.2.8.0-ubuntu64/bin/fastq-dump --outdir ./ --split-files --gzip ${opath}/${srr}.sra
rm ${opath}/${srr}.sra
```
This will download on spot the related fastq files. 
